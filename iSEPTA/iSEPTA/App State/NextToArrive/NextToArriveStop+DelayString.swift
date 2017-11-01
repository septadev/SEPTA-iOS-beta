//
//  NextToArriveStop+DelayString.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

extension NextToArriveStop {
    func generateDelayString() -> String? {
        let absoluteDelay = abs(delay)
        let delayString: String
                switch delay {
                    case let delay where delay < 0:
                    delayString = "Status: \(absoluteDelay) min early"
                    case 0:
                    delayString = "Status: On Time"
                    case  let delay where delay > 0:
                    delayString = "Status: \(delay) min late"
                    default:
                    delayString = ""
                }
        return delayString
    }

    private func determineDelay() -> Int? {



    if let detail = nextToArriveDetail as? NextToArriveRailDetails, let delay = detail.destinationDelay {

                return delay
            }
        if let detail = nextToArriveDetail as? NextToArriveBusDetails,
            let delay = detail.destinationDelay {

                let delayString = buildDelayString(delay:delay)
                calloutView.label1.text = "Block ID: \(blockId) to \(destination)"
                calloutView.label2.text = "Vehicle Number: \(vehicleId)"
                calloutView.label3.text = delayString
                return
            }
        let stop = vehicleLocation.nextToArriveStop

        if transitMode.useBusForDetails(){
           if let lastStopName = stop.lastStopName {
                calloutView.label1.text = "#\(stop.routeId):  to \(lastStopName)"
           } else {
                calloutView.label1.text = ""
           }

           if let vehicleIds = stop.vehicleIds, let firstVehicle = vehicleIds.first {
                calloutView.label2.text = "Vehicle Number: \(firstVehicle)"
           } else {
                calloutView.label3.text = "Vehicle Number not available"
           }

           if let delay = stop.delayMinutes {
                let delayString = buildDelayString(delay:delay)
                calloutView.label3.text = delayString
           } else {
                calloutView.label3.text = "Status: No Realtime data"
           }
            return
        }

           if transitMode.useRailForDetails(){
           if let  tripId = stop.tripId , let lastStopName = stop.lastStopName{
                calloutView.label1.text = "Train: #\(tripId) to \(lastStopName)"
           } else {
                calloutView.label1.text = ""
           }

        if let delay = stop.delayMinutes {
                let delayString = buildDelayString(delay:delay)
                calloutView.label2.text = delayString
           } else {
                calloutView.label2.text = "Status: No Realtime data"
           }

           if let vehicleIds = stop.vehicleIds {
                calloutView.label3.text = "# of Train Cars: \(vehicleIds.count)"
           } else {
                calloutView.label3.text = "# of Train Cars: unknown"
           }

         return

        }

          calloutView.label1.text = ""
                calloutView.label2.text = ""
                calloutView.label3.text = ""

    }


}
