//
//  MapVehicleCalloutView.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class MapVehicleCalloutView: UIView {
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!

    func buildCalloutView(vehicleLocation: VehicleLocation) {
        let nextToArriveStop = vehicleLocation.nextToArriveStop

        let transitMode = nextToArriveStop.transitMode

        if transitMode.useBusForDetails() {
            configureBusToLastStopLabel(nextToArriveStop: nextToArriveStop, label: label1)

            configureBusVehicleIDLabel(nextToArriveStop: nextToArriveStop, label: label2)

            configureDelayLabel(nextToArriveStop: nextToArriveStop, label: label3)
            return
        }

        if transitMode.useRailForDetails() {
            configureTrainToLastStopLabel(nextToArriveStop: nextToArriveStop, label: label1)

            configureDelayLabel(nextToArriveStop: nextToArriveStop, label: label2)

            configureRailVehicleIDLabel(nextToArriveStop: nextToArriveStop, label: label3)

            return
        }

        label1.text = ""
        label2.text = ""
        label3.text = ""
    }

    func configureDelayLabel(nextToArriveStop: NextToArriveStop, label: UILabel) {
        let delayString = nextToArriveStop.generateDelayString(prefixString: "Status: ")
        if let delayString = delayString {
            label.text = delayString
        } else {
            label.text = "Status: No Realtime data"
        }
    }

    func configureTrainToLastStopLabel(nextToArriveStop: NextToArriveStop, label: UILabel) {
        if let tripId = nextToArriveStop.tripId, let lastStopName = nextToArriveStop.lastStopName {
            label.text = "Train: #\(tripId) to \(lastStopName)"
        } else {
            label.text = ""
        }
    }

    func configureBusToLastStopLabel(nextToArriveStop: NextToArriveStop, label: UILabel) {
        if let lastStopName = nextToArriveStop.lastStopName {
            label.text = "#\(nextToArriveStop.routeId):  to \(lastStopName)"
        } else {
            label.text = ""
        }
    }

    func configureBusVehicleIDLabel(nextToArriveStop: NextToArriveStop, label: UILabel) {
        if let vehicleIds = nextToArriveStop.vehicleIds, let firstVehicle = vehicleIds.first {
            label.text = "Vehicle Number: \(firstVehicle)"
        } else {
            label.text = "Vehicle Number not available"
        }
    }

    func configureRailVehicleIDLabel(nextToArriveStop: NextToArriveStop, label: UILabel) {
        if let vehicleIds = nextToArriveStop.vehicleIds {
            label.text = "# of Train Cars: \(vehicleIds.count)"
        } else {
            label.text = "# of Train Cars: unknown"
        }
    }
}
