// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

struct ScheduleRequestReducer {

    static func reduceRequest(action: ScheduleAction, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        var newScheduleRequest: ScheduleRequest
        switch action {

        case let action as TransitModeSelected:
            newScheduleRequest = reduceTransitModeSelected(action: action, scheduleRequest: scheduleRequest)
        case let action as RouteSelected:
            newScheduleRequest = reduceRouteSelected(action: action, scheduleRequest: scheduleRequest)
        case let action as TripStartSelected:
            newScheduleRequest = reduceTripStartSelected(action: action, scheduleRequest: scheduleRequest)
        case let action as CurrentStopToEdit:
            newScheduleRequest = reduceCurrentStopToEdit(action: action, scheduleRequest: scheduleRequest)
        case let action as TripEndSelected:
            newScheduleRequest = reduceTripEndSelected(action: action, scheduleRequest: scheduleRequest)
        case let action as ScheduleTypeSelected:
            newScheduleRequest = reduceScheduleTypeSelected(action: action, scheduleRequest: scheduleRequest)
        case let action as ReverseStops:
            newScheduleRequest = reduceReverseStops(action: action, scheduleRequest: scheduleRequest)
        case let action as ResetSchedule:
            newScheduleRequest = reduceResetSchedule(action: action, scheduleRequest: scheduleRequest)
        case let action as LoadAllRailRoutes:
            newScheduleRequest = reduceLoadAllRailRoutes(action: action, scheduleRequest: scheduleRequest)
        case let action as CopyScheduleRequestToTargetForScheduleAction:
            newScheduleRequest = reduceCopyScheduleRequestToTargetForScheduleAction(action: action, scheduleRequest: scheduleRequest)
        default:
            newScheduleRequest = scheduleRequest
        }
        return newScheduleRequest
    }

    static func reduceTransitModeSelected(action: TransitModeSelected, scheduleRequest _: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: action.transitMode, selectedRoute: nil, selectedStart: nil, selectedEnd: nil)
    }

    static func reduceRouteSelected(action: RouteSelected, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: action.selectedRoute)
    }

    static func reduceTripStartSelected(action: TripStartSelected, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: scheduleRequest.selectedRoute, selectedStart: action.selectedStart)
    }

    static func reduceCurrentStopToEdit(action _: CurrentStopToEdit, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: scheduleRequest.selectedRoute, selectedStart: scheduleRequest.selectedStart, selectedEnd: scheduleRequest.selectedEnd)
    }

    static func reduceTripEndSelected(action: TripEndSelected, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: scheduleRequest.selectedRoute, selectedStart: scheduleRequest.selectedStart, selectedEnd: action.selectedEnd, scheduleType: scheduleRequest.transitMode.defaultScheduleType())
    }

    static func reduceScheduleTypeSelected(action: ScheduleTypeSelected, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: scheduleRequest.selectedRoute, selectedStart: scheduleRequest.selectedStart, selectedEnd: scheduleRequest.selectedEnd, scheduleType: action.scheduleType)
    }

    static func reduceReverseStops(action _: ReverseStops, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: scheduleRequest.selectedRoute, selectedStart: scheduleRequest.selectedStart, selectedEnd: scheduleRequest.selectedEnd, scheduleType: scheduleRequest.scheduleType, reverseStops: true)
    }

    static func reduceResetSchedule(action _: ResetSchedule, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: nil, selectedStart: nil, selectedEnd: nil, scheduleType: scheduleRequest.transitMode.defaultScheduleType(), reverseStops: false)
    }

    static func reduceLoadAllRailRoutes(action _: LoadAllRailRoutes, scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        return ScheduleRequest(transitMode: scheduleRequest.transitMode, selectedRoute: Route.allRailRoutesRoute(), selectedStart: nil, selectedEnd: nil, scheduleType: scheduleRequest.transitMode.defaultScheduleType(), reverseStops: false)
    }

    static func reduceCopyScheduleRequestToTargetForScheduleAction(action: CopyScheduleRequestToTargetForScheduleAction, scheduleRequest _: ScheduleRequest) -> ScheduleRequest {
        return action.scheduleRequest
    }
}
