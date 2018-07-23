//
//  RealTimeRailArrivalsDetail.swift
//  SeptaRest
//
//  Created by Mark Broski on 10/9/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

import Foundation
import ObjectMapper

public class NextToArriveRailDetails: RestResponse, RealTimeArrivalDetail {
    public var consist: [String]?
    public var nextstopDelay: Int?
    public var destinationDelay: Int?
    public var destination: String?
    public var direction: String?
    public var latitude: Double?
    public var line: String?
    public var longitude: Double?
    public var results: Int?
    public var service: String?
    public var source: String?
    public var speed: String?
    public var nextstopStation: String?
    public var destinationStation: String?
    public var track: String?
    public var trackChange: String?
    public var tripid: Int?

    public override func mapping(map: Map) {
        super.mapping(map: map)

        if map["tripid"].isKeyPresent {
            success = true
        }

        trackChange <- map["details.trackChange"]
        source <- map["details.source"]
        track <- map["details.track"]
        nextstopDelay <- map["details.nextstop.delay"]
        nextstopStation <- map["details.nextstop.station"]

        longitude <- map["details.longitude"]
        line <- map["details.line"]
        consist <- map["details.consist"]
        speed <- map["details.speed"]
        service <- map["details.service"]
        direction <- map["details.direction"]
        destinationStation <- map["details.destination.station"]
        destinationDelay <- map["details.destination.delay"]

        var tripIdString = ""
        tripIdString <- map["details.tripid"]
        tripid = Int(tripIdString)
        latitude <- map["details.latitude"]

        destination <- map["destination"]
    }
}
