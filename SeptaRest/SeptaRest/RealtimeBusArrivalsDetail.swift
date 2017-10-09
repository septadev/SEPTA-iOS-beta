//
//  RealtimeBusArrivalsDetail.swift
//  SeptaRest
//
//  Created by Mark Broski on 10/9/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

import Foundation
import ObjectMapper

class NextToArriveBusDetails {
    var blockid: Int?
    var destinationDelay: Int?
    var direction: String?
    var latitude: Double?
    var line: Int?
    var longitude: Double?
    var results: Int?
    var route: Int?
    var destinationStation: String?
    var tripid: Int?
    var vehicleid: Int?

    public required init?(map _: Map) {
    }

    public func mapping(map: Map) {
        direction <- map["details.direction"]
        latitude <- map["details.latitude"]
        longitude <- map["details.longitude"]
        line <- map["details.line"]
        vehicleid <- map["details.vehicleid"]
        tripid <- map["details.tripid"]
        blockid <- map["details.blockid"]
        destinationStation <- map["details.destination.station"]
        destinationDelay <- map["details.destination.delay"]
        route <- map["route"]
        vehicleid <- map["vehicleid"]
        results <- map["results"]
    }
}
