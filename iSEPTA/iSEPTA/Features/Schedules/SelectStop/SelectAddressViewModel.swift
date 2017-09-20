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

class SelectAddressViewModel: NSObject, StoreSubscriber {
    typealias StoreSubscriberStateType = AddressLookupState
    @IBOutlet weak var selectStopViewController: UpdateableFromViewModel?
    let cellId = "addressCell"
    var targetForScheduleAction: TargetForScheduleAction! { return store.state.targetForScheduleActions() }
    var addresses = [DisplayAddress]()
    var filterString = ""

    override func awakeFromNib() {
        subscribe()
    }

    func subscribe() {
        if store.state.navigationState.activeNavigationController == .schedules {
            store.subscribe(self) {
                $0.select {
                    $0.addressLookupState
                }.skipRepeats { $0 == $1 }
            }
        } else if store.state.navigationState.activeNavigationController == .nextToArrive {
            store.subscribe(self) {
                $0.select {
                    $0.addressLookupState
                }.skipRepeats { $0 == $1 }
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        addresses = [DisplayAddress]()
        if let error = state.error {
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

    deinit {
        unsubscribe()
    }

    private func unsubscribe() {
        store.unsubscribe(self)
    }
}

extension SelectAddressViewModel: UITableViewDataSource, UITableViewDelegate {
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
        let addressSelectedAction = AddressSelected(targetForScheduleAction: targetForScheduleAction, selectedAddress: displayAddress)
        store.dispatch(addressSelectedAction)
        let clearAddressesAction = ClearLookupAddresses()
        store.dispatch(clearAddressesAction)
    }
}

extension SelectAddressViewModel: UITextFieldDelegate {
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
}
