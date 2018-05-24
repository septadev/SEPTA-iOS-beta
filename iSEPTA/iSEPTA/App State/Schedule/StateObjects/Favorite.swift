//
//  Favorite.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
// TODO: create a parallel favorite data array so that we aren't writing favorites to disk so much
struct Favorite: Codable {
    let favoriteId: String
    var favoriteName: String
    let transitMode: TransitMode
    let selectedRoute: Route
    let selectedStart: Stop
    let selectedEnd: Stop
    var nextToArriveTrips: [NextToArriveTrip]
    var nextToArriveUpdateStatus: NextToArriveUpdateStatus
    var refreshDataRequested: Bool
    var collapsed: Bool
    var sortOrder: Int

    var scheduleRequest: ScheduleRequest {
        return convertedToScheduleRequest()
    }

    init(favoriteId: String, favoriteName: String, transitMode: TransitMode, selectedRoute: Route, selectedStart: Stop, selectedEnd: Stop, nextToArriveTrips: [NextToArriveTrip] = [NextToArriveTrip](), nextToArriveUpdateStatus: NextToArriveUpdateStatus = .idle, refreshDataRequested: Bool = false, collapsed: Bool = false, sortOrder: Int = 0) {
        self.favoriteId = favoriteId
        self.favoriteName = favoriteName
        self.transitMode = transitMode
        self.selectedRoute = selectedRoute
        self.selectedStart = selectedStart
        self.selectedEnd = selectedEnd
        self.nextToArriveTrips = nextToArriveTrips
        self.nextToArriveUpdateStatus = nextToArriveUpdateStatus
        self.refreshDataRequested = refreshDataRequested
        self.collapsed = collapsed
        self.sortOrder = sortOrder
    }

    enum CodingKeys: String, CodingKey {
        case favoriteId
        case favoriteName
        case transitMode
        case selectedRoute
        case selectedStart
        case selectedEnd
        case collapsed
        case sortOrder
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self) // defining our (keyed) container

        transitMode = try container.decode(TransitMode.self, forKey: .transitMode)
        selectedRoute = try container.decode(Route.self, forKey: .selectedRoute)
        selectedStart = try container.decode(Stop.self, forKey: .selectedStart)
        selectedEnd = try container.decode(Stop.self, forKey: .selectedEnd)

        
        let defaultId = UUID().uuidString
        do {
            favoriteId = try container.decode(String?.self, forKey: .favoriteId) ?? defaultId
        } catch {
            favoriteId = defaultId
        }

        let defaultName = "\(selectedRoute.routeId): \(selectedStart.stopName) to \(selectedEnd.stopName)"
        do {
            favoriteName = try container.decode(String?.self, forKey: .favoriteName) ?? defaultName
        } catch {
            favoriteName = defaultName
        }
        
        let defaultCollapsed = false
        do {
            collapsed = try container.decode(Bool?.self, forKey: .collapsed) ?? defaultCollapsed
        } catch {
            self.collapsed = defaultCollapsed
        }
        
        let defaultOrder = 0
        do {
            sortOrder = try container.decode(Int?.self, forKey: .sortOrder) ?? defaultOrder
        } catch {
            self.sortOrder = defaultOrder
        }
        
        nextToArriveTrips = [NextToArriveTrip]()
        nextToArriveUpdateStatus = .idle
        refreshDataRequested = true
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(favoriteId, forKey: .favoriteId)
        try container.encode(favoriteName, forKey: .favoriteName)
        try container.encode(transitMode, forKey: .transitMode)
        try container.encode(selectedRoute, forKey: .selectedRoute)
        try container.encode(selectedStart, forKey: .selectedStart)
        try container.encode(selectedEnd, forKey: .selectedEnd)
        try container.encode(collapsed, forKey: .collapsed)
        try container.encode(sortOrder, forKey: .sortOrder)
    }
}

extension Favorite: Hashable {
    var hashValue: Int {
        return favoriteId.hashValue
    }
}

extension Favorite: Equatable {}
func == (lhs: Favorite, rhs: Favorite) -> Bool {
    var areEqual = true

    areEqual = lhs.favoriteId == rhs.favoriteId
    guard areEqual else { return false }

    areEqual = lhs.favoriteName == rhs.favoriteName
    guard areEqual else { return false }

    areEqual = lhs.transitMode == rhs.transitMode
    guard areEqual else { return false }

    areEqual = lhs.selectedRoute == rhs.selectedRoute
    guard areEqual else { return false }

    areEqual = lhs.selectedStart == rhs.selectedStart
    guard areEqual else { return false }

    areEqual = lhs.selectedEnd == rhs.selectedEnd
    guard areEqual else { return false }

    areEqual = lhs.nextToArriveTrips == rhs.nextToArriveTrips
    guard areEqual else { return false }

    areEqual = lhs.nextToArriveUpdateStatus == rhs.nextToArriveUpdateStatus
    guard areEqual else { return false }

    areEqual = lhs.refreshDataRequested == rhs.refreshDataRequested
    guard areEqual else { return false }

    areEqual = lhs.collapsed == rhs.collapsed
    guard areEqual else { return false }
    
    areEqual = lhs.sortOrder == rhs.sortOrder
    guard areEqual else { return false }
    
    return areEqual
}

func == (lhs: Favorite, rhs: ScheduleRequest) -> Bool {
    let scheduleRequestTransitMode = rhs.transitMode
    guard
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

func == (lhs: ScheduleRequest, rhs: Favorite) -> Bool {
    return rhs == lhs
}
