//
//  Favorite.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct Favorite: Codable {

    let transitMode: TransitMode
    let selectedRoute: Route
    let selectedStart: Stop
    let selectedEnd: Stop

    init(transitMode: TransitMode, selectedRoute: Route, selectedStart: Stop, selectedEnd: Stop) {
        self.transitMode = transitMode
        self.selectedRoute = selectedRoute
        self.selectedStart = selectedStart
        self.selectedEnd = selectedEnd
    }

    enum CodingKeys: String, CodingKey {
        case transitMode
        case selectedRoute
        case selectedStart
        case selectedEnd
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self) // defining our (keyed) container
        transitMode = try container.decode(TransitMode.self, forKey: .transitMode)
        selectedRoute = try container.decode(Route.self, forKey: .selectedRoute)
        selectedStart = try container.decode(Stop.self, forKey: .selectedStart)
        selectedEnd = try container.decode(Stop.self, forKey: .selectedEnd)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transitMode, forKey: .transitMode)
        try container.encode(selectedRoute, forKey: .selectedRoute)
        try container.encode(selectedStart, forKey: .selectedStart)
        try container.encode(selectedEnd, forKey: .selectedEnd)
    }
}

extension Favorite: Equatable {}
func ==(lhs: Favorite, rhs: Favorite) -> Bool {
    var areEqual = true

    areEqual = lhs.transitMode == rhs.transitMode
    guard areEqual else { return false }

    areEqual = lhs.selectedRoute == rhs.selectedRoute
    guard areEqual else { return false }

    areEqual = lhs.selectedStart == rhs.selectedStart
    guard areEqual else { return false }

    areEqual = lhs.selectedEnd == rhs.selectedEnd
    guard areEqual else { return false }

    return areEqual
}

func ==(lhs: Favorite, rhs: ScheduleRequest) -> Bool {
    guard let scheduleRequestTransitMode = rhs.transitMode,
        let scheduleRequestSelectedRoute = rhs.selectedRoute,
        let scheduleRequestSelectedStart = rhs.selectedStart,
        let scheduleRequestSelectedEnd = rhs.selectedEnd else { return false }
    var areEqual = true

    areEqual = lhs.transitMode == scheduleRequestTransitMode
    guard areEqual else { return false }

    areEqual = lhs.selectedRoute == scheduleRequestSelectedRoute
    guard areEqual else { return false }

    areEqual = lhs.selectedStart == scheduleRequestSelectedStart
    guard areEqual else { return false }

    areEqual = lhs.selectedEnd == scheduleRequestSelectedEnd
    guard areEqual else { return false }

    return areEqual
}

func ==(lhs: ScheduleRequest, rhs: Favorite) -> Bool {
    return rhs == lhs
}
