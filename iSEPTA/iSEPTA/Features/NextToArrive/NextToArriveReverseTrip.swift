//
//  NextToArriveReverseTrip.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/10/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule

protocol NextToArriveReverseTripDelegate: class {
    func tripReverseCompleted()
}

/// Responsible for reversing a trip for Next To Arrive.
class NextToArriveReverseTrip {
    fileprivate let scheduleRequest: ScheduleRequest
    fileprivate let target: TargetForScheduleAction
    fileprivate let transitMode: TransitMode
    fileprivate weak var delegate: NextToArriveReverseTripDelegate?

    init(target: TargetForScheduleAction, scheduleRequest: ScheduleRequest, delegate: NextToArriveReverseTripDelegate) {
        self.target = target
        self.scheduleRequest = scheduleRequest
        transitMode = scheduleRequest.transitMode
        self.delegate = delegate
    }

    func reverseNextToArrive() {
        if transitMode == .rail {
            reverseRouteForRail()
        } else {
            reverseRouteForNonRail()
        }
    }

    fileprivate func reverseRouteForRail() {
        reverseStops(target: target, scheduleRequest: scheduleRequest)
    }

    /// We're going into the database to find the one route going in the opposite direction
    fileprivate func reverseRouteForNonRail() {
        let transitMode = scheduleRequest.transitMode
        guard let selectedRoute = scheduleRequest.selectedRoute else { return }
        ReverseRouteCommand.sharedInstance.reverseRoute(forTransitMode: transitMode, route: selectedRoute) { [weak self] routes, _ in
            guard let target = self?.target, let scheduleRequest = self?.scheduleRequest,
                let routes = routes, let route = routes.first else { return }

            let routeSelectedAction = RouteSelected(targetForScheduleAction: target, selectedRoute: route)
            store.dispatch(routeSelectedAction)

            self?.reverseStops(target: target, scheduleRequest: scheduleRequest)
        }
    }

    /// Again we go into the database to find the stops on the other side of the street.  So the starting stop becomes the ending stop,
    /// and vice versa.
    fileprivate func reverseStops(target: TargetForScheduleAction, scheduleRequest: ScheduleRequest) {
        guard let selectedStartId = scheduleRequest.selectedStart?.stopId,
            let selectedEndId = scheduleRequest.selectedEnd?.stopId else { return }
        let tripStopId = TripStopId(start: selectedStartId, end: selectedEndId)
        StopReverseCommand.sharedInstance.reverseStops(forTransitMode: transitMode, tripStopId: tripStopId) { [weak self] tripStopIds, _ in
            guard let tripStopIds = tripStopIds, let tripStopId = tripStopIds.first else { return }

            self?.loadAvailableTripStarts(target: target, tripStopId: tripStopId)
        }
    }

    /// Now we load available trip ends for the given starting position.
    fileprivate func loadAvailableTripStarts(target: TargetForScheduleAction, tripStopId: TripStopId) {
        FindStopCommand.sharedInstance.stops(forTransitMode: transitMode, forStopId: tripStopId.start) { [weak self] stops, _ in
            guard let stops = stops, let firstStop = stops.first else { return }
            let tripStartSelectedAction = TripStartSelected(targetForScheduleAction: target, selectedStart: firstStop)
            store.dispatch(tripStartSelectedAction)

            self?.loadAvailableTripEnds(target: target, tripStopId: tripStopId)
        }
    }

    fileprivate func loadAvailableTripEnds(target: TargetForScheduleAction, tripStopId: TripStopId) {
        FindStopCommand.sharedInstance.stops(forTransitMode: transitMode, forStopId: tripStopId.end) { [weak self] stops, _ in
            guard let stops = stops, let firstStop = stops.first else { return }
            let tripEndSelectedAction = TripEndSelected(targetForScheduleAction: target, selectedEnd: firstStop)
            store.dispatch(tripEndSelectedAction)

            self?.triggerNextToArriveReversalState()
            self?.triggerRefreshForNextToArrive()
            self?.reverseCompleted()
        }
    }

    fileprivate func triggerRefreshForNextToArrive() {
        let refreshDataAction = NextToArriveRefreshDataRequested(refreshUpdateRequested: true)
        store.dispatch(refreshDataAction)
    }

    fileprivate func triggerNextToArriveReversalState() {
        let action = ToggleNextToArriveReverseTripStatus()
        store.dispatch(action)
    }

    fileprivate func reverseCompleted() {
        delegate?.tripReverseCompleted()
    }
}
