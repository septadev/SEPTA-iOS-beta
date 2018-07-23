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

    static func reduceClearRoutes(action _: ClearRoutes, scheduleData: ScheduleData) -> ScheduleData {
        let newScheduleData = ScheduleData(availableRoutes: ScheduleRouteState(),
                                           availableStarts: ScheduleStopState(),
                                           availableStops: ScheduleStopState(),
                                           availableTrips: ScheduleTripState())
        return newScheduleData
    }

    static func reduceClearTripStarts(action _: ClearTripStarts, scheduleData: ScheduleData) -> ScheduleData {
        let newScheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
                                           availableStarts: ScheduleStopState(),
                                           availableStops: ScheduleStopState(),
                                           availableTrips: ScheduleTripState())
        return newScheduleData
    }

    static func reduceClearTripEnds(action _: ClearTripEnds, scheduleData: ScheduleData) -> ScheduleData {
        let newScheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
                                           availableStarts: scheduleData.availableStarts,
                                           availableStops: ScheduleStopState(),
                                           availableTrips: ScheduleTripState())
        return newScheduleData
    }

    static func reduceClearTrips(action _: ClearTrips, scheduleData: ScheduleData) -> ScheduleData {
        let newScheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
                                           availableStarts: scheduleData.availableStarts,
                                           availableStops: scheduleData.availableStops,
                                           availableTrips: ScheduleTripState())
        return newScheduleData
    }

    // MARK: - Loading Data

    static func reduceRoutesLoaded(action: RoutesLoaded, scheduleData: ScheduleData) -> ScheduleData {
        let newScheduleData = ScheduleData(availableRoutes: ScheduleRouteState(routes: action.routes, updateMode: .loadValues),
                                           availableStarts: scheduleData.availableStarts,
                                           availableStops: scheduleData.availableStops,
                                           availableTrips: scheduleData.availableTrips)
        return newScheduleData
    }

    static func reduceTripStartsLoaded(action: TripStartsLoaded, scheduleData: ScheduleData) -> ScheduleData {
        let newScheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
                                           availableStarts: ScheduleStopState(stops: action.availableStarts, updateMode: .loadValues),
                                           availableStops: scheduleData.availableStops,
                                           availableTrips: scheduleData.availableTrips)
        return newScheduleData
    }

    static func reduceTripEndsLoaded(action: TripEndsLoaded, scheduleData: ScheduleData) -> ScheduleData {
        let newScheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
                                           availableStarts: scheduleData.availableStarts,
                                           availableStops: ScheduleStopState(stops: action.availableStops, updateMode: .loadValues),
                                           availableTrips: scheduleData.availableTrips)
        return newScheduleData
    }

    static func reduceTripLoaded(action: TripsLoaded, scheduleData: ScheduleData) -> ScheduleData {
        let newScheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
                                           availableStarts: scheduleData.availableStarts,
                                           availableStops: scheduleData.availableStops,
                                           availableTrips: ScheduleTripState(trips: action.availableTrips, updateMode: .loadValues))
        return newScheduleData
    }
}
