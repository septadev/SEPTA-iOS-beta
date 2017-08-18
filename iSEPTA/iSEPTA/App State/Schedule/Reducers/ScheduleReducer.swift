// Septa. 2017

import Foundation
import ReSwift

fileprivate typealias Req = ScheduleRequestReducer
fileprivate typealias Data = ScheduleDataReducer

struct ScheduleReducer {

    static func main(action: Action, state: ScheduleState?) -> ScheduleState {
        /// Handle the edge case of trip reverses
        if let action = action as? ReverseLoaded, state = state {
            reduceTripReverse(action: action, state, state)
        }
        /// only work with non optionals
        if let newState = state {
            guard let action = action as? ScheduleAction,
                let scheduleRequest = newState.scheduleRequest,
                let scheduleData = newState.scheduleData

            else { return newState }
            return ScheduleState(
                scheduleRequest: Req.reduceRequest(action: action, scheduleRequest: scheduleRequest),
                scheduleData: Data.reduceData(action: action, scheduleData: scheduleData)
            )
        /// if there are optionals, run through the init
        } else {
            return ScheduleState(
                scheduleRequest: Req.initRequest(),
                scheduleData: Data.initScheduleData()
            )
        }
    }
    
    static func reduceTripReverse(action: TripReverse, state: ScheduleState) -> ScheduleState{
        return ScheduleState(
            scheduleRequest: action.scheduleRequest,
            scheduleData: ScheduleData(availableRoutes: state?.scheduleData?.availableRoutes, availableStarts: nil, availableStops: nil, availableTrips: nil, errorString: action.error)
        )

        
    }
}



