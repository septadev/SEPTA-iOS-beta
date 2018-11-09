//
//  PushNotificationTripDetailRequestMapper.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/7/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

enum PushNotificationTripDetailMapperError: Error {
    case badJsonFormat
    case missingDetailsProbablyExpired
}

class PushNotificationTripDetailMapper {
    struct Keys {
        static let consist = "consist"
        static let delay = "delay"
        static let destination = "destination"
        static let details = "details"
        static let direction = "direction"
        static let latitude = "latitude"
        static let line = "line"
        static let longitude = "longitude"
        static let nextstop = "nextstop"
        static let results = "results"
        static let service = "service"
        static let source = "source"
        static let speed = "speed"
        static let station = "station"
        static let track = "track"
        static let trackChange = "trackChange"
        static let tripid = "tripid"
    }

    static func mapData(data: Data) throws -> PushNotificationTripDetailData {
        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { throw PushNotificationTripDetailMapperError.badJsonFormat }
        guard let detailsDict = jsonObject[Keys.details] as? [String: Any] else { throw PushNotificationTripDetailMapperError.missingDetailsProbablyExpired }

        let tripId = jsonObject[Keys.tripid] as? String
        let destination = jsonObject[Keys.destination] as? String
        let results = jsonObject[Keys.results] as? Int

        let latitude = detailsDict[Keys.latitude] as? Double
        let longitude = detailsDict[Keys.longitude] as? Double
        let line = detailsDict[Keys.line] as? String
        let track = detailsDict[Keys.track] as? String
        let trackChange = detailsDict[Keys.trackChange] as? String
        let speed = detailsDict[Keys.speed] as? String
        let direction = detailsDict[Keys.direction] as? String
        let service = detailsDict[Keys.service] as? String
        let source = detailsDict[Keys.source] as? String

        let nextstopDict = detailsDict[Keys.nextstop] as? [String: Any]
        let nextstopStation = nextstopDict?[Keys.station] as? String
        let nextstopDelay = nextstopDict?[Keys.delay] as? Int

        let destinationDict = detailsDict[Keys.destination] as? [String: Any]
        let destinationStation = destinationDict?[Keys.station] as? String
        let destinationDelay = destinationDict?[Keys.delay] as? Int
        let consist = detailsDict[Keys.consist] as? [String]

        
        
        
        return PushNotificationTripDetailData(consist: consist, destination: destination, destinationDelay: destinationDelay, destinationStation: destinationStation, direction: direction, latitude: latitude, line: line, longitude: longitude, nextstopDelay: nextstopDelay, nextstopStation: nextstopStation, results: results, service: service, source: source, speed: speed, track: track, trackChange: trackChange, tripId: tripId)
    }
}
