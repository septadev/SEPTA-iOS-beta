// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleDataReducer {
    static func reduceData(action: ScheduleAction, scheduleData: ScheduleData) -> ScheduleData {
        var newScheduleData = scheduleData

        switch action {
        case let action as TransitModeSelected:
            newScheduleData = reduceTransitModeSelected(action: action, scheduleData: scheduleData)
        case let action as ClearRoutes:
            newScheduleData = reduceClearRoutes(action: action, scheduleData: newScheduleData)
        case let action as RoutesLoaded:
            newScheduleData = reduceRoutesLoaded(action: action, scheduleData: newScheduleData)
        case let action as ClearTripStarts:
            newScheduleData = reduceClearTripStarts(action: action, scheduleData: newScheduleData)
        case let action as TripStartsLoaded:
            newScheduleData = reduceTripStartsLoaded(action: action, scheduleData: newScheduleData)
        case let action as ClearTripEnds:
            newScheduleData = reduceClearTripEnds(action: action, scheduleData: newScheduleData)
        case let action as TripEndsLoaded:
            newScheduleData = reduceTripEndsLoaded(action: action, scheduleData: newScheduleData)
        case let action as ClearTrips:
            newScheduleData = reduceClearTrips(action: action, scheduleData: newScheduleData)
        case let action as TripsLoaded:
            newScheduleData = reduceTripLoaded(action: action, scheduleData: newScheduleData)

        default: break
        }

        return newScheduleData
    }

    static func reduceTransitModeSelected(action _: TransitModeSelected, scheduleData _: ScheduleData) -> ScheduleData {
        let newScheduleData = ScheduleData()
        return newScheduleData
    }

    // MARK: - Clearing Data

    static func reduceClearRoutes(action _: ClearRoutes, scheduleData _: ScheduleData) -> ScheduleData {
        return ScheduleData()
    }

    static func reduceClearTripStarts(action _: ClearTripStarts, scheduleData: ScheduleData) -> ScheduleData {
        var newScheduleData = scheduleData
        newScheduleData.availableStarts = ScheduleStopState()
        return newScheduleData
    }

    static func reduceClearTripEnds(action _: ClearTripEnds, scheduleData: ScheduleData) -> ScheduleData {
        var newScheduleData = scheduleData
        newScheduleData.availableStops = ScheduleStopState()
        return newScheduleData
    }

    static func reduceClearTrips(action _: ClearTrips, scheduleData: ScheduleData) -> ScheduleData {
        var newScheduleData = scheduleData
        newScheduleData.availableTrips = ScheduleTripState()
        return newScheduleData
    }

    // MARK: - Loading Data

    static func reduceRoutesLoaded(action: RoutesLoaded, scheduleData: ScheduleData) -> ScheduleData {
        var newScheduleData = scheduleData
        newScheduleData.availableRoutes = ScheduleRouteState(routes: action.routes, updateMode: .loadValues)
        return newScheduleData
    }

    static func reduceTripStartsLoaded(action: TripStartsLoaded, scheduleData: ScheduleData) -> ScheduleData {
        var newScheduleData = scheduleData
        newScheduleData.availableStarts = ScheduleStopState(stops: action.availableStarts, updateMode: .loadValues)
        return newScheduleData
    }

    static func reduceTripEndsLoaded(action: TripEndsLoaded, scheduleData: ScheduleData) -> ScheduleData {
        var newScheduleData = scheduleData
        newScheduleData.availableStops = ScheduleStopState(stops: action.availableStops, updateMode: .loadValues)
        return newScheduleData
    }

    static func reduceTripLoaded(action: TripsLoaded, scheduleData: ScheduleData) -> ScheduleData {
        var newScheduleData = scheduleData
        newScheduleData.availableTrips = ScheduleTripState(trips: action.availableTrips, updateMode: .loadValues)
        return newScheduleData
    }
}
