//
//  RealTimeRailArrivalsDetail.swift
//  SeptaRest
//
//  Created by Mark Broski on 10/9/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

import Foundation
import ObjectMapper

public class NextToArriveDetails: Mappable {
    public var destinationArrival_time: Date?
    public var nextstopArrival_time: Date?
    public var consist: [Int]?
    public var destinationDelay: Int?
    public var nextstopDelay: Int?
    public var destination: Int?
    public var direction: String?
    public var latitude: Double?
    public var line: String?
    public var longitude: Double?
    public var results: Int?
    public var service: String?
    public var source: String?
    public var speed: String?
    public var destinationStation: String?
    public var nextstopStation: String?
    public var track: String?
    public var trackChange: String?
    public var tripid: Int?

    public required init?(map _: Map) {
    }

    public func mapping(map: Map) {

        consist <- map["details.consist"]
        tripid <- map["details.tripid"]
        direction <- map["details.direction"]
        service <- map["details.service"]
        trackChange <- map["details.trackChange"]
        destinationArrival_time <- map["details.destination.arrival_time"]
        destinationStation <- map["details.destination.station"]
        destinationDelay <- map["details.destination.delay"]

        speed <- map["details.speed"]
        nextstopArrival_time <- map["details.nextstop.arrival_time"]
        nextstopStation <- map["details.nextstop.station"]
        nextstopDelay <- map["details.nextstop.delay"]

        line <- map["details.line"]
        latitude <- map["details.latitude"]
        source <- map["details.source"]
        track <- map["details.track"]
        longitude <- map["details.longitude"]

        tripid <- map["tripid"]
        results <- map["results"]
    }
}
