//
//  PushNotificationTripDetailState.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

struct PushNotificationTripDetailState: Equatable {
    let consist: [String]?
    let destination: String?
    let destinationDelay: Int?
    let destinationStation: String?
    let direction: String?
    let latitude: Double?
    let line: String?
    let longitude: Double?
    let nextstopDelay: Int?
    let nextstopStation: String?
    let results: Int?
    let service: String?
    let source: String?
    let speed: String?
    let track: String?
    let trackChange: String?
    let tripid: Int?
    let lastUpdated: Date
    init(
        consist: [String]? = nil,
        destination: String? = nil,
        destinationDelay: Int? = nil,
        destinationStation: String? = nil,
        direction: String? = nil,
        latitude: Double? = nil,
        line: String? = nil,
        longitude: Double? = nil,
        nextstopDelay: Int? = nil,
        nextstopStation: String? = nil,
        results: Int? = nil,
        service: String? = nil,
        source: String? = nil,
        speed: String? = nil,
        track: String? = nil,
        trackChange: String? = nil,
        tripid: Int? = nil
    ) {
        self.consist = consist
        self.destination = destination
        self.destinationDelay = destinationDelay
        self.destinationStation = destinationStation
        self.direction = direction
        self.latitude = latitude
        self.line = line
        self.longitude = longitude
        self.nextstopDelay = nextstopDelay
        self.nextstopStation = nextstopStation
        self.results = results
        self.service = service
        self.source = source
        self.speed = speed
        self.track = track
        self.trackChange = trackChange
        self.tripid = tripid

        lastUpdated = Date()
    }

    init(nextToArriveRailDetails details: NextToArriveRailDetails) {
        consist = details.consist
        destination = details.destination
        destinationDelay = details.destinationDelay
        destinationStation = details.destinationStation
        direction = details.direction
        latitude = details.latitude
        line = details.line
        longitude = details.longitude
        nextstopDelay = details.nextstopDelay
        nextstopStation = details.nextstopStation
        results = details.results
        service = details.service
        source = details.source
        speed = details.speed
        track = details.track
        trackChange = details.trackChange
        tripid = details.tripid

        lastUpdated = Date()
    }
}
