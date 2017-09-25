//
//  NextToArriveRailScheduleRequestBuilder.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/24/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

class NextToArriveRailScheduleRequestBuilder {
    static let sharedInstance = NextToArriveRailScheduleRequestBuilder()
    private init() {}

    let targetForScheduleAction: TargetForScheduleAction = .schedules

    func updateScheduleRequestInSchedules(nextToArriveTrip: NextToArriveTrip, scheduleRequest: ScheduleRequest) {
        if scheduleRequest.transitMode == .rail {
            setRoute(nextToArriveTrip: nextToArriveTrip, scheduleRequest: scheduleRequest)
        } else {
            copyScheduleRequestToSchedules(scheduleRequest: scheduleRequest)
        }
    }

    private func setRoute(nextToArriveTrip: NextToArriveTrip, scheduleRequest: ScheduleRequest) {
        let routeId = nextToArriveTrip.startStop.routeId
        RoutesCommand.sharedInstance.routes(forTransitMode: .rail) { [weak self] routes, _ in
            guard let strongSelf = self else { return }
            let routes = routes ?? [Route]()
            if let route = routes.filter({ $0.routeId == routeId }).first {

                let routeUpdatedScheduleRequest = ScheduleRequest(
                    transitMode: .rail,
                    selectedRoute: route,
                    selectedStart: scheduleRequest.selectedStart,
                    selectedEnd: scheduleRequest.selectedEnd,
                    scheduleType: .mondayThroughThursday,
                    reverseStops: false)

                strongSelf.setSelectedTripEnd(nextToArriveTrip: nextToArriveTrip, scheduleRequest: routeUpdatedScheduleRequest)
            }
        }
    }

    private func setSelectedTripEnd(nextToArriveTrip: NextToArriveTrip, scheduleRequest: ScheduleRequest) {
        if let connectionStopId = nextToArriveTrip.connectionLocation?.stopId {
            setSelectedTripEndForConnectionLocation(connectionStopId: connectionStopId, scheduleRequest: scheduleRequest)
        } else {
            copyScheduleRequestToSchedules(scheduleRequest: scheduleRequest)
        }
    }

    private func setSelectedTripEndForConnectionLocation(connectionStopId: Int, scheduleRequest: ScheduleRequest) {
        guard let selectedRoute = scheduleRequest.selectedRoute, let selectedStart = scheduleRequest.selectedStart else { return }
        TripEndCommand.sharedInstance.stops(forTransitMode: .rail, forRoute: selectedRoute, tripStart: selectedStart) { [weak self] stops, _ in
            guard let strongSelf = self else { return }
            let stops = stops ?? [Stop]()
            if let connectionStop = stops.filter({ $0.stopId == connectionStopId }).first {
                let tripEndUpdatedScheduleRequest = ScheduleRequest(
                    transitMode: scheduleRequest.transitMode,
                    selectedRoute: scheduleRequest.selectedRoute,
                    selectedStart: scheduleRequest.selectedStart,
                    selectedEnd: connectionStop,
                    scheduleType: scheduleRequest.scheduleType,
                    reverseStops: scheduleRequest.reverseStops)

                strongSelf.copyScheduleRequestToSchedules(scheduleRequest: tripEndUpdatedScheduleRequest)
            }
        }
    }

    func copyScheduleRequestToSchedules(scheduleRequest: ScheduleRequest) {
        let copyAction = CopyScheduleRequestToTargetForScheduleAction(targetForScheduleAction: targetForScheduleAction, scheduleRequest: scheduleRequest, description: "Copying a rail schedule Request from Next To Arrive To Schedules")
        store.dispatch(copyAction)
    }
}
