//
//  NextToArriveTripGrouper.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import SeptaSchedule

class NextToArriveGrouper {

    static func filterRoutesToMap(trips: [NextToArriveTrip], requestRouteId: String) -> [String] {
        var allRouteIds: [String] = (trips.map { $0.startStop.routeId }) + (trips.map { $0.endStop.routeId })
        if requestRouteId != Route.allRailRoutesRoute().routeId {
            allRouteIds.append(requestRouteId)
        }
        return Array(Set(allRouteIds.flatMap { $0 }))
    }

    static func buildNextToArriveTripSections(trips: [NextToArriveTrip]) -> [[NextToArriveTrip]] {
        let sortedTrips = sortTripsByDepartureTime(trips: trips)
        var tripSections = [[NextToArriveTrip]]()
        var lastTrip: NextToArriveTrip?
        for trip in sortedTrips {

            if tripHasConnectionStation(trip: trip) ||
                tripHasConnectionStation(trip: lastTrip) ||
                routeIdsHaveChanged(a: lastTrip, b: trip) {
                tripSections.append([trip])
            } else {
                var tripSection = tripSections.removeLast()
                tripSection.append(trip)
                tripSections.append(tripSection)
            }
            lastTrip = trip
        }
        return tripSections
    }

    static func routeIdsHaveChanged(a: NextToArriveTrip?, b: NextToArriveTrip?) -> Bool {

        if let a = a, let b = b {
            return a.startStop.routeId == b.startStop.routeId
        } else {
            return true
        }
    }

    static func tripHasConnectionStation(trip: NextToArriveTrip?) -> Bool {
        if let trip = trip {
            return trip.connectionLocation != nil
        } else {
            return false
        }
    }

    static func sortTripsByDepartureTime(trips: [NextToArriveTrip]) -> [NextToArriveTrip] {
        return trips.sorted { $0.startStop.departureTime < $1.startStop.departureTime }
    }
}
