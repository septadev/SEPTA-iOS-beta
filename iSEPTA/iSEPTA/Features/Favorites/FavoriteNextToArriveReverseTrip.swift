//
//  FavoriteNextToArriveReverseTrip.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/11/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule

/// Responsible for reversing a trip for Next To Arrive.
class FavoriteNextToArriveReverseTrip {
    fileprivate let scheduleRequest: ScheduleRequest
    fileprivate let transitMode: TransitMode
    fileprivate weak var delegate: NextToArriveReverseTripDelegate?
    fileprivate var reversedScheduleRequest: ScheduleRequest = ScheduleRequest()

    init(scheduleRequest: ScheduleRequest, delegate: NextToArriveReverseTripDelegate) {
        self.scheduleRequest = scheduleRequest
        transitMode = scheduleRequest.transitMode
        self.delegate = delegate
        reversedScheduleRequest = ScheduleRequest(transitMode: scheduleRequest.transitMode)
    }

    func reverseFavorite() {
        if store.state.favoritesState.nextToArriveReverseTripStatus == .noReverse {
            if transitMode == .rail {
                reverseRouteForRail()
            } else {
                reverseRouteForNonRail()
            }
        } else {
            store.dispatch(UndoReversedFavorite())
        }
    }

    fileprivate func reverseRouteForRail() {
        reversedScheduleRequest = ScheduleRequest(transitMode: transitMode, selectedRoute: Route.allRailRoutesRoute())
        reverseStops()
    }

    /// We're going into the database to find the one route going in the opposite direction
    fileprivate func reverseRouteForNonRail() {
        let transitMode = scheduleRequest.transitMode
        guard let selectedRoute = scheduleRequest.selectedRoute else { return }
        ReverseRouteCommand.sharedInstance.reverseRoute(forTransitMode: transitMode, route: selectedRoute) { [weak self] routes, _ in
            guard let routes = routes, let route = routes.first else { return }
            self?.reversedScheduleRequest = ScheduleRequest(transitMode: transitMode, selectedRoute: route)
            self?.reverseStops()
        }
    }

    /// Again we go into the database to find the stops on the other side of the street.  So the starting stop becomes the ending stop,
    /// and vice versa.
    fileprivate func reverseStops() {
        guard let selectedStartId = scheduleRequest.selectedStart?.stopId,
            let selectedEndId = scheduleRequest.selectedEnd?.stopId else { return }
        let tripStopId = TripStopId(start: selectedStartId, end: selectedEndId)
        StopReverseCommand.sharedInstance.reverseStops(forTransitMode: transitMode, tripStopId: tripStopId) { [weak self] tripStopIds, _ in
            guard let tripStopIds = tripStopIds, let tripStopId = tripStopIds.first else { return }

            self?.loadAvailableTripStarts(tripStopId: tripStopId)
        }
    }

    /// Now we load available trip starts for the given starting position.
    fileprivate func loadAvailableTripStarts(tripStopId: TripStopId) {
        FindStopCommand.sharedInstance.stops(forTransitMode: transitMode, forStopId: tripStopId.start) { [weak self] stops, _ in
            guard let rsr = self?.reversedScheduleRequest, let stops = stops, let firstStop = stops.first else { return }

            self?.reversedScheduleRequest = ScheduleRequest(transitMode: rsr.transitMode, selectedRoute: rsr.selectedRoute, selectedStart: firstStop)

            self?.loadAvailableTripEnds(tripStopId: tripStopId)
        }
    }

    fileprivate func loadAvailableTripEnds(tripStopId: TripStopId) {
        FindStopCommand.sharedInstance.stops(forTransitMode: transitMode, forStopId: tripStopId.end) { [weak self] stops, _ in
            guard let rsr = self?.reversedScheduleRequest, let stops = stops, let firstStop = stops.first else { return }

            self?.reversedScheduleRequest = ScheduleRequest(transitMode: rsr.transitMode, selectedRoute: rsr.selectedRoute, selectedStart: rsr.selectedStart, selectedEnd: firstStop)

            self?.uploadReversedFavorite()
            self?.reverseCompleted()
        }
    }

    fileprivate func uploadReversedFavorite() {
        guard let favorite = reversedScheduleRequest.convertedToFavorite(favoriteId: Favorite.reversedFavoriteId) else { return }
        let action = UploadReversedFavorite(favorite: favorite)
        store.dispatch(action)
    }

    fileprivate func reverseCompleted() {
        delegate?.tripReverseCompleted()
    }

    fileprivate func updateStatus(status _: NextToArriveReverseTripStatus) {
    }

    fileprivate func submitReversedScheduleRequest() {
    }
}
