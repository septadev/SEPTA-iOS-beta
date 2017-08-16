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
        case let action as TransitModeSelected:
            return reduceTransitModeSelected(action: action, scheduleData: scheduleData)
        case let action as RoutesLoaded:
            newScheduleData = reduceRoutesLoaded(action: action, scheduleData: newScheduleData)
        case let action as CurrentStopToEdit:
            newScheduleData = reduceCurrentStopToEdit(action: action, scheduleData: newScheduleData)
        case let action as TripStartsLoaded:
            newScheduleData = reduceTripStartsLoaded(action: action, scheduleData: newScheduleData)
        case let action as TripEndsLoaded:
            newScheduleData = reduceTripEndsLoaded(action: action, scheduleData: newScheduleData)
        case let action as TripsLoaded:
            newScheduleData = reduceTripLoaded(action: action, scheduleData: newScheduleData)

        default: break
        }
        return newScheduleData
    }

    static func reduceTransitModeSelected(action _: TransitModeSelected, scheduleData: ScheduleData) -> ScheduleData {
        let scheduleData = ScheduleData()
        return scheduleData
    }

    static func reduceRoutesLoaded(action: RoutesLoaded, scheduleData: ScheduleData) -> ScheduleData {
        let scheduleData = ScheduleData(availableRoutes: action.routes,
                                        availableStarts: nil,
                                        availableStops: nil,
                                        availableTrips: nil,
                                        errorString: action.error)
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

    static func reduceTripEndsLoaded(action: TripEndsLoaded, scheduleData: ScheduleData) -> ScheduleData {
        let scheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
                                        availableStarts: scheduleData.availableStarts,
                                        availableStops: action.availableStops,
                                        availableTrips: nil,
                                        errorString: action.error)
        return scheduleData
    }

    static func reduceTripLoaded(action: TripsLoaded, scheduleData: ScheduleData) -> ScheduleData {
        let scheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
                                        availableStarts: scheduleData.availableStarts,
                                        availableStops: scheduleData.availableStops,
                                        availableTrips: action.availableTrips,
                                        errorString: action.error)
        return scheduleData
    }

    static func reduceCurrentStopToEdit(action _: CurrentStopToEdit, scheduleData: ScheduleData) -> ScheduleData {
        //        var scheduleData: ScheduleData = ScheduleData()
        //        if action.stopToEdit == .starts {
        //            scheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
        //                                        availableStarts: nil,
        //                                        availableStops: nil,
        //                                        availableTrips: nil,
        //                                        errorString: nil)
        //        } else {
        //            scheduleData = ScheduleData(availableRoutes: scheduleData.availableRoutes,
        //                                        availableStarts: scheduleData.availableStarts,
        //                                        availableStops: nil,
        //                                        availableTrips: nil,
        //                                        errorString: nil)
        //        }
        return scheduleData
    }
}
