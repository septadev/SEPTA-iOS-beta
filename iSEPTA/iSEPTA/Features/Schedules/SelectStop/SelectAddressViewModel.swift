//
//  SelectAddressViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SeptaSchedule
import ReSwift

class SelectAddressViewModel: NSObject, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, StoreSubscriber {
    typealias StoreSubscriberStateType = AddressLookupState

    override func awakeFromNib() {
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.addressLookupState
            }.skipRepeats { $0 == $1 }
        }
    }

    private func unsubscribe() {
        store.unsubscribe(self)
    }

    deinit {
        unsubscribe()
    }

    var addresses = [DisplayAddress]()

    @IBOutlet weak var selectStopViewController: UpdateableFromViewModel?
    let cellId = "addressCell"

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return addresses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AddressCell else { return UITableViewCell() }

        configureCell(cell, atRow: indexPath.row)
        return cell
    }

    func configureCell(_ addressCell: AddressCell, atRow row: Int) {

        guard row < addresses.count else { return }
        addressCell.streetAddressLabel.text = addresses[row].street
        addressCell.CSZLabel.text = addresses[row].csz
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < addresses.count else { return }
        let displayAddress = addresses[indexPath.row]
        let addressSelectedAction = AddressSelected(selectedAddress: displayAddress)
        store.dispatch(addressSelectedAction)
    }

    var filterString = ""
    func textField(_: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {

        guard let swiftRange = Range(range, in: filterString) else { return false }
        filterString = filterString.replacingCharacters(in: swiftRange, with: replacementString.lowercased())

        geoCodeFilterString()
        return true
    }

    func geoCodeFilterString() {
        let action = LookupAddressRequest(searchString: filterString)
        store.dispatch(action)
    }

    func newState(state: StoreSubscriberStateType) {
        addresses = [DisplayAddress]()
        if let error = state.error {
            //            selectStopViewController?.displayErrorMessage(message: "There was an error retrieving address from your search.  Please try again later")
            print(error.localizedDescription)
        } else {
            for placemark in state.searchResults {
                guard let name = placemark.name, let locality = placemark.locality, let state = placemark.administrativeArea, let zip = placemark.postalCode else { continue }
                let address = DisplayAddress(street: "\(name)", csz: "\(locality) \(state) \(zip)", placemark: placemark)
                addresses.append(address)
            }
        }
        DispatchQueue.main.async {
            self.selectStopViewController?.viewModelUpdated()
        }
    }
}
