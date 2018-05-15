//
//  NextToArriveReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct NextToArriveReducer {
    static func main(action: Action, state: NextToArriveState?) -> NextToArriveState {
        if let state = state {
            switch action {
            case let action as ScheduleAction where action.targetForScheduleAction.includesMe(.nextToArrive):
                return reduceScheduleAction(action: action, state: state)
            case let action as NextToArriveAction:
                return reduceNextToArriveAction(action: action, state: state)
            default:
                return state
            }

        } else {
            return NextToArriveState()
        }
    }

    static func reduceScheduleAction(action: ScheduleAction, state: NextToArriveState) -> NextToArriveState {
        let scheduleState = ScheduleReducer.main(action: action, state: state.scheduleState)
        return NextToArriveState(scheduleState: scheduleState, nextToArriveTrips: state.nextToArriveTrips)
    }

    static func reduceNextToArriveAction(action: NextToArriveAction, state: NextToArriveState) -> NextToArriveState {
        var state = state
        switch action {
        case let action as NextToArrivePrerequisteStatusChanged:
            state = reduceNextToArrivePrerequisteStatusChanged(action: action, state: state)

        case let action as ClearNextToArriveData:
            state = reduceClearNextToArriveData(action: action, state: state)
        case let action as NextToArriveRefreshDataRequested:
            state = reduceNextToArriveRefreshDataRequested(action: action, state: state)

        case let action as UpdateNextToArriveStatusAndData:
            state = reduceUpdateNextToArriveStatusAndData(action: action, state: state)

        case let action as ViewScheduleDataInNextToArrive:
            state = reduceViewScheduleData(action: action, state: state)
        case let action as InsertNextToArriveScheduleRequest:
            state = reduceInsertNextToArriveScheduleRequest(action: action, state: state)
        case let action as UpdateNextToArriveDetail:
            state = reduceUpdateNextToArriveDetail(action: action, state: state)
        default:
            break
        }

        return state
    }

    static func reduceNextToArrivePrerequisteStatusChanged(action: NextToArrivePrerequisteStatusChanged, state: NextToArriveState) -> NextToArriveState {
        return NextToArriveState(scheduleState: state.scheduleState, nextToArriveTrips: state.nextToArriveTrips, nextToArrivePrerequisiteStatus: action.newStatus, nextToArriveUpdateStatus: state.nextToArriveUpdateStatus, refreshDataRequested: state.refreshDataRequested)
    }

    static func reduceClearNextToArriveData(action _: ClearNextToArriveData, state: NextToArriveState) -> NextToArriveState {
        return NextToArriveState(scheduleState: state.scheduleState, nextToArriveTrips: [NextToArriveTrip](), nextToArrivePrerequisiteStatus: state.nextToArrivePrerequisiteStatus, nextToArriveUpdateStatus: state.nextToArriveUpdateStatus, refreshDataRequested: state.refreshDataRequested)
    }

    static func reduceNextToArriveRefreshDataRequested(action: NextToArriveRefreshDataRequested, state: NextToArriveState) -> NextToArriveState {
        return NextToArriveState(scheduleState: state.scheduleState, nextToArriveTrips: state.nextToArriveTrips, nextToArrivePrerequisiteStatus: state.nextToArrivePrerequisiteStatus, nextToArriveUpdateStatus: state.nextToArriveUpdateStatus, refreshDataRequested: action.refreshUpdateRequested)
    }

    static func reduceUpdateNextToArriveStatusAndData(action: UpdateNextToArriveStatusAndData, state: NextToArriveState) -> NextToArriveState {
        return NextToArriveState(scheduleState: state.scheduleState, nextToArriveTrips: action.nextToArriveTrips, nextToArrivePrerequisiteStatus: state.nextToArrivePrerequisiteStatus, nextToArriveUpdateStatus: action.nextToArriveUpdateStatus, refreshDataRequested: action.refreshDataRequested)
    }

    static func reduceViewScheduleData(action _: ViewScheduleDataInNextToArrive, state: NextToArriveState) -> NextToArriveState {
        return NextToArriveState(scheduleState: store.state.scheduleState, nextToArriveTrips: [NextToArriveTrip]())
    }

    static func reduceInsertNextToArriveScheduleRequest(action: InsertNextToArriveScheduleRequest, state: NextToArriveState) -> NextToArriveState {
        let scheduleState = ScheduleState(scheduleRequest: action.scheduleRequest, scheduleData: ScheduleData(), scheduleStopEdit: ScheduleStopEdit())
        return NextToArriveState(scheduleState: scheduleState, nextToArriveTrips: state.nextToArriveTrips)
    }

    static func reduceUpdateNextToArriveDetail(action: UpdateNextToArriveDetail, state: NextToArriveState) -> NextToArriveState {
        guard let tripId = action.realTimeArrivalDetail.tripid else { return state }

        var newTrips = [NextToArriveTrip]()
        for trip in state.nextToArriveTrips {
            let start = trip.startStop
            let transitMode = state.scheduleState.scheduleRequest.transitMode
            if let startTripId = trip.startStop.tripId, startTripId == tripId {
                var newStart = NextToArriveStop(transitMode: transitMode, routeId: start.routeId, routeName: start.routeName, tripId: start.tripId, arrivalTime: start.arrivalTime, departureTime: start.departureTime, lastStopId: start.lastStopId, lastStopName: start.lastStopName, delayMinutes: start.delayMinutes, direction: start.direction, vehicleLocationCoordinate: start.vehicleLocationCoordinate, vehicleIds: start.vehicleIds, hasRealTimeData: start.hasRealTimeData, service: start.service)
                newStart.addRealTimeData(nextToArriveDetail: action.realTimeArrivalDetail)
                let newTrip = NextToArriveTrip(startStop: newStart, endStop: trip.endStop, vehicleLocation: trip.vehicleLocation, connectionLocation: trip.connectionLocation)
                newTrips.append(newTrip)
            } else if let endTripId = trip.endStop.tripId, endTripId == tripId {
                var newEnd = NextToArriveStop(transitMode: transitMode, routeId: start.routeId, routeName: start.routeName, tripId: start.tripId, arrivalTime: start.arrivalTime, departureTime: start.departureTime, lastStopId: start.lastStopId, lastStopName: start.lastStopName, delayMinutes: start.delayMinutes, direction: start.direction, vehicleLocationCoordinate: start.vehicleLocationCoordinate, vehicleIds: start.vehicleIds, hasRealTimeData: start.hasRealTimeData, service: start.service)
                newEnd.addRealTimeData(nextToArriveDetail: action.realTimeArrivalDetail)

                let newTrip = NextToArriveTrip(startStop: trip.startStop, endStop: newEnd, vehicleLocation: trip.vehicleLocation, connectionLocation: trip.connectionLocation)
                newTrips.append(newTrip)
            } else {
                newTrips.append(trip)
            }
        }

        return NextToArriveState(scheduleState: state.scheduleState, nextToArriveTrips: newTrips)
    }
}
