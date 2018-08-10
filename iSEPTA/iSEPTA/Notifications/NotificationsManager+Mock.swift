//
//  NotificationsManager+Mock.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
class RealTimeMockRequest {
    func sendRequest() {
        let session = URLSession.shared
//        90324    Langhorne
        // 90326    Yardley
        // 90317    Meadowbrook
        // 90409    Elkins Park

        let begin = "90409" //
        let end = "90326"
        let url = URL(string: "https://vnjb5kvq2b.execute-api.us-east-1.amazonaws.com/prod/realtimearrivals?destination=\(end)&origin=\(begin)&type=RAIL")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue("7Nx754dd9G5YkpYoRLbi4aoNW9LtWllt1Jcbw9v8", forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { [weak self] (data: Data?, _: URLResponse?, error: Error?) -> Void in
            guard let strongSelf = self, error == nil, let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                guard let jsonDict = json as? [String: Any],
                    let arrivals = jsonDict["arrivals"] as? [[String: Any]],
                    let firstArrival = arrivals.first else { return }
                strongSelf.mapResponse(firstArrival: firstArrival)
            } catch {
                print(error.localizedDescription)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

    func mapResponse(firstArrival: [String: Any]) {
        guard let vehicleId = firstArrival["orig_line_trip_id"] as? String,
            let routeId = firstArrival["orig_line_route_id"] as? String,
            let destinationStopIdInt = firstArrival["orig_last_stop_id"] as? Int else { return }

        let dict: [String: String] = [
            "notificationType": "DELAY",
            "routeId": routeId,
            "message": "There is a super long delay on \(routeId) that will keep you busy for a long time",
            "routeType": "RAIL",
            "vehicleId": vehicleId,
            "destinationStopId": String(destinationStopIdInt),
            "delayType": "ACTUAL",
            "expires": DateFormatters.networkFormatter.string(from: Date().addingTimeInterval(60 * 60 * 3)),
        ]

        DispatchQueue.main.async {
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
            delegate.application(UIApplication.shared, didReceiveRemoteNotification: dict, fetchCompletionHandler: { _ in })
        }
    }
}
