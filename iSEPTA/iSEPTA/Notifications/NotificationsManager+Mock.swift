//
//  NotificationsManager+Mock.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import UIKit

class RealTimeMockRequest {
    let tripId = "828"

    func sendRequest() {
        let session = URLSession.shared

        let url = URL(string: "https://vnjb5kvq2b.execute-api.us-east-1.amazonaws.com/prod/realtimearrivals/details?id=\(tripId)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue("7Nx754dd9G5YkpYoRLbi4aoNW9LtWllt1Jcbw9v8", forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            /* Start a new Task */
            let task = session.dataTask(with: request, completionHandler: { [weak self] (data: Data?, _: URLResponse?, error: Error?) -> Void in
                guard let strongSelf = self, error == nil, let data = data else { return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    guard let jsonDict = json as? [String: Any],
                        let details = jsonDict["details"] as? [String: Any] else { return }
                    strongSelf.mapResponse(details: details)
                } catch {
                    print(error.localizedDescription)
                }
            })
            task.resume()
            session.finishTasksAndInvalidate()
        }
    }

    func sendSimpleNotification() {
        let tripId = "527"
        let routeId = "LAN"

        let dict: [String: String] = [
            "notificationType": "DELAY",
            "routeId": routeId,
            "message": "ios Debugging Delay ",
            "routeType": "RAIL",
            "vehicleId": tripId,
            "destinationStopId": "unknown",
            "delayType": "ACTUAL",
            "expires": DateFormatters.networkFormatter.string(from: Date().addingTimeInterval(60 * 60 * 3)),
        ]

        DispatchQueue.main.async {
//            guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
//            delegate.application(UIApplication.shared, didReceiveRemoteNotification: dict, fetchCompletionHandler: { _ in })
        }
    }

    func mapResponse(details: [String: Any]) {
        guard let tripId = details["tripid"] as? String,
            let nextStop = details["nextstop"] as? [String: Any],
            let nextStopName = nextStop["station"] as? String,
            let nextStopDelay = nextStop["delay"] as? Int,
            let destination = details["destination"] as? [String: Any],
            let destinationStopName = destination["station"] as? String,
            let destinationStopDelay = destination["delay"] as? Int,
            let routeName = details["line"] as? String else {
            print(details)
            return
        }

        FindStopByStopNameCommand.sharedInstance.stop(stopName: destinationStopName) { [weak self] stops, _ in
            guard let strongSelf = self, let stops = stops, let firstStop = stops.first else { return }

            let dict: [String: String] = [
                "notificationType": "DELAY",
                "routeId": "PAO",
                "message": "Route \(routeName), Trip \(tripId): Next Stop is \(nextStopName) with delay \(nextStopDelay); Destination \(destinationStopName) with delay \(destinationStopDelay)",
                "routeType": "RAIL",
                "vehicleId": String(strongSelf.tripId),
                "destinationStopId": String(firstStop.stopId),
                "delayType": "ACTUAL",
                "expires": DateFormatters.networkFormatter.string(from: Date().addingTimeInterval(60 * 60 * 3)),
            ]

            DispatchQueue.main.async {
//                guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
//                delegate.application(UIApplication.shared, didReceiveRemoteNotification: dict, fetchCompletionHandler: { _ in })
            }
        }
    }
}
