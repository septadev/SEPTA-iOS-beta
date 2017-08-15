// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleDataReducer {

    static func initScheduleData() -> ScheduleData {
        return ScheduleData()
    }

    static func reduceData(action: ScheduleAction, scheduleData: ScheduleData) -> ScheduleData {
        var newScheduleData = scheduleData
        switch action {
        case _ as TransitModeSelected:
            newScheduleData = ScheduleData()
        case let action as RouteSelected:
            newScheduleData = reduceRouteSelected(action: action, scheduleData: scheduleData)
        case let action as RoutesLoaded:
            newScheduleData = reduceRoutesLoaded(action: action, scheduleData: newScheduleData)
        case let action as TripStartsLoaded:
            newScheduleData = reduceTripStartsLoaded(action: action, scheduleData: newScheduleData)
        case _ as TripStartSelected:
            break
        default: fatalError("An unhandled action came ")
        }
        return newScheduleData
    }

    static func reduceRoutesLoaded(action: RoutesLoaded, scheduleData: ScheduleData) -> ScheduleData {
        let scheduleData = ScheduleData(availableRoutes: action.routes,
                                        availableStarts: nil,
                                        availableStops: nil,
                                        availableTrips: nil,
                                        errorString: action.error)
        return scheduleData
    }

    static func reduceRouteSelected(action _: RouteSelected, scheduleData: ScheduleData) -> ScheduleData {
        let scheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
                                        availableStarts: nil,
                                        availableStops: nil,
                                        availableTrips: nil,
                                        errorString: nil)
        return scheduleData
    }

    static func reduceTripStartsLoaded(action: TripStartsLoaded, scheduleData: ScheduleData) -> ScheduleData {
        let scheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
                                        availableStarts: action.availableStarts,
                                        availableStops: nil,
                                        availableTrips: nil,
                                        errorString: action.error)
        return scheduleData
    }
}
