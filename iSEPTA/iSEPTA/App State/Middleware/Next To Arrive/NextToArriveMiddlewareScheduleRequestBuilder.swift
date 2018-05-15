//
//  NextToArriveRailScheduleRequestBuilder.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/24/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

class NextToArriveMiddlewareScheduleRequestBuilder {
    static let sharedInstance = NextToArriveMiddlewareScheduleRequestBuilder()
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
        guard let selectedStart = scheduleRequest.selectedStart, let selectedEnd = scheduleRequest.selectedEnd else { return }
        let routeId = nextToArriveTrip.startStop.routeId
        let startStopId = selectedStart.stopId
        let endStopId = determineEndingStopId(nextToArriveTrip: nextToArriveTrip, selectedEnd: selectedEnd)
        RailRouteFromStopsCommand.sharedInstance.routes(routeId: routeId, startStopId: startStopId, endStopId: endStopId) { [weak self] routes, _ in
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

                strongSelf.setSelectedEnd(nextToArriveTrip: nextToArriveTrip, scheduleRequest: routeUpdatedScheduleRequest)
            }
        }
    }

    private func setSelectedEnd(nextToArriveTrip: NextToArriveTrip, scheduleRequest: ScheduleRequest) {
        guard let selectedEnd = scheduleRequest.selectedEnd else { return }
        let endStopId = determineEndingStopId(nextToArriveTrip: nextToArriveTrip, selectedEnd: selectedEnd)

        if endStopId == selectedEnd.stopId {
            copyScheduleRequestToSchedules(scheduleRequest: scheduleRequest)
        } else {
            findSelectedEndStop(stopId: endStopId, scheduleRequest: scheduleRequest)
        }
    }

    private func findSelectedEndStop(stopId: Int, scheduleRequest: ScheduleRequest) {
        FindStopCommand.sharedInstance.stops(forTransitMode: scheduleRequest.transitMode, forStopId: stopId) { [weak self] stops, _ in
            guard let strongSelf = self else { return }
            let stops = stops ?? [Stop]()
            if let connectionStop = stops.first {
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

    private func determineEndingStopId(nextToArriveTrip: NextToArriveTrip, selectedEnd: Stop) -> Int {
        if let connectionStopId = nextToArriveTrip.connectionLocation?.stopId {
            return connectionStopId
        } else {
            return selectedEnd.stopId
        }
    }

    func copyScheduleRequestToSchedules(scheduleRequest: ScheduleRequest) {
        let copyAction = CopyScheduleRequestToTargetForScheduleAction(targetForScheduleAction: targetForScheduleAction, scheduleRequest: scheduleRequest, description: "Copying a rail schedule Request from Next To Arrive To Schedules")
        store.dispatch(copyAction)
    }
}
