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
    fileprivate let target: TargetForScheduleAction
    fileprivate let transitMode: TransitMode
    fileprivate weak var delegate: NextToArriveReverseTripDelegate?
    fileprivate var reversedScheduleRequest: ScheduleRequest = ScheduleRequest()

    init(target: TargetForScheduleAction, scheduleRequest: ScheduleRequest, delegate: NextToArriveReverseTripDelegate) {
        self.target = target
        self.scheduleRequest = scheduleRequest
        transitMode = scheduleRequest.transitMode
        self.delegate = delegate
        reversedScheduleRequest = ScheduleRequest(transitMode: scheduleRequest.transitMode)
    }



    func reverseNextToArrive() {
        updateStatus(status: .willReverse)
        triggerNextToArriveReversalState(nextToArriveReverseTripStatus: .willReverse)
        if transitMode == .rail {
            reverseRouteForRail()
        } else {
            reverseRouteForNonRail()
        }
    }

    fileprivate func reverseRouteForRail() {
        self.reversedScheduleRequest = ScheduleRequest(transitMode: transitMode, selectedRoute: Route.allRailRoutesRoute())
        reverseStops(target: target)
    }

    /// We're going into the database to find the one route going in the opposite direction
    fileprivate func reverseRouteForNonRail() {
        let transitMode = scheduleRequest.transitMode
        guard let selectedRoute = scheduleRequest.selectedRoute else { return }
        ReverseRouteCommand.sharedInstance.reverseRoute(forTransitMode: transitMode, route: selectedRoute) { [weak self] routes, _ in
            guard let target = self?.target, let scheduleRequest = self?.scheduleRequest,
                let routes = routes, let route = routes.first else { return }
                self?.reversedScheduleRequest = ScheduleRequest(transitMode: transitMode, selectedRoute: route)


            self?.reverseStops(target: target)
        }
    }

    /// Again we go into the database to find the stops on the other side of the street.  So the starting stop becomes the ending stop,
    /// and vice versa.
    fileprivate func reverseStops(target: TargetForScheduleAction) {

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
            guard let rsr = self?.reversedScheduleRequest, let stops = stops, let firstStop = stops.first else { return }

            self?.reversedScheduleRequest = ScheduleRequest(transitMode: rsr.transitMode, selectedRoute: rsr.selectedRoute, selectedStart: firstStop)

            self?.loadAvailableTripEnds(target: target, tripStopId: tripStopId)
        }
    }

    fileprivate func loadAvailableTripEnds(target: TargetForScheduleAction, tripStopId: TripStopId) {
        FindStopCommand.sharedInstance.stops(forTransitMode: transitMode, forStopId: tripStopId.end) { [weak self] stops, _ in
            guard let rsr = self?.reversedScheduleRequest, let stops = stops, let firstStop = stops.first else { return }

            self?.reversedScheduleRequest = ScheduleRequest(transitMode: rsr.transitMode, selectedRoute: rsr.selectedRoute, selectedStart: rsr.selectedStart, selectedEnd: firstStop)
            self?.submitReversedScheduleRequest()
            self?.updateStatus(status: .didReverse)
            self?.reverseCompleted()
        }
    }

    fileprivate func triggerRefreshForNextToArrive() {
        let refreshDataAction = NextToArriveRefreshDataRequested(refreshUpdateRequested: true)
        store.dispatch(refreshDataAction)
    }

    fileprivate func triggerNextToArriveReversalState(nextToArriveReverseTripStatus: NextToArriveReverseTripStatus) {
        let action = UpdateNextToArriveReverseTripStatus(nextToArriveReverseTripStatus: nextToArriveReverseTripStatus)
        store.dispatch(action)
    }

    fileprivate func reverseCompleted() {
        delegate?.tripReverseCompleted()
    }

    fileprivate func updateStatus(status: NextToArriveReverseTripStatus){
        let action = UpdateFavoriteNextToArriveReverseTripStatus(nextToArriveReverseTripStatus: status)
        store.dispatch(action)
    }

     fileprivate func submitReversedScheduleRequest(){
        let action = UpdateFavoriteReverseTripScheduleRequest(reverseTripScheduleRequest: reversedScheduleRequest)
        store.dispatch(action)
    }
}
