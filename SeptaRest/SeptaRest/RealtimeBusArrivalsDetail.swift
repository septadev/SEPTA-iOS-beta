//
//  RealtimeBusArrivalsDetail.swift
//  SeptaRest
//
//  Created by Mark Broski on 10/9/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

/*

 {
 "route": "22",
 "vehicleid": "8513",
 "details": {
 "tripid": "995286",
 "latitude": 40.038754,
 "longitude": -75.143875,
 "line": "22",
 "vehicleid": "8513",
 "blockid": "3244",
 "direction": "SouthBound",
 "destination": {
 "station": "Olney Transportation Center",
 "delay": 0
 }
 },
 "results": 1
 }

 */

import Foundation
import ObjectMapper

public class NextToArriveBusDetails: RestResponse, RealTimeArrivalDetail {

    public var blockid: String?
    public var destinationDelay: Int?
    public var destinationStation: String?
    public var direction: String?
    public var latitude: Double?
    public var line: String?
    public var longitude: Double?
    public var results: Int?
    public var route: String?
    public var tripid: Int?
    public var vehicleid: String?

    public override func mapping(map: Map) {

        super.mapping(map: map)

        if map["vehicleid"].isKeyPresent {
            success = true
        }

        blockid <- map["details.blockid"]
        destinationDelay <- map["details.destination.delay"]
        destinationStation <- map["details.destination.station"]
        direction <- map["details.direction"]
        latitude <- map["details.latitude"]
        line <- map["details.line"]
        longitude <- map["details.longitude"]
        results <- map["results"]
        route <- map["route"]
        var tripIdString = ""
        tripIdString <- map["details.tripid"]
        tripid = Int(tripIdString)
        vehicleid <- map["details.vehicleid"]
    }
}
