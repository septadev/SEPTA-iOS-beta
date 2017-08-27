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

struct DisplayAddress {
    let street: String
    let csz: String
}

class SelectAddressViewModel: NSObject, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    let geoCoder = CLGeocoder()

    var region: CLRegion?

    func identifyPhillyRegion() {
        // Get a region in Philly to optimize searches
        let location = CLLocation(latitude: 39.936770, longitude: -75.228173)
        geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            guard let firstPlacemark = placemarks?.first else { return }
            self.region = firstPlacemark.region
        }
    }

    override func awakeFromNib() {
        identifyPhillyRegion()
    }

    func numberOfRows() -> Int {
        return 0
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

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
    }

    var filterString = ""
    func textField(_: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {

        guard let swiftRange = Range(range, in: filterString) else { return false }
        filterString = filterString.replacingCharacters(in: swiftRange, with: replacementString.lowercased())

        if filterString.count > 3 {
            geoCodeFilterString()
        }
        return true
    }

    func geoCodeFilterString() {
        addresses.removeAll()
        geoCoder.geocodeAddressString(filterString, in: region) { placemarks, _ in
            guard let placemarks = placemarks else { return }

            for placemark in placemarks {
                guard let name = placemark.name, let locality = placemark.locality, let state = placemark.administrativeArea, let zip = placemark.postalCode else { continue }
                let address = DisplayAddress(street: "\(name)", csz: "\(locality) \(state) \(zip)")
                self.addresses.append(address)
            }
            self.selectStopViewController?.viewModelUpdated()
        }
    }
}
