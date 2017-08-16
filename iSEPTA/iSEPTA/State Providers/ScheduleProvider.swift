// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class ScheduleProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest?
    static let sharedInstance = ScheduleProvider()
    var currentScheduleRequest = ScheduleRequest()

    private init() {
    }

    func subscribe() {

        store.subscribe(self) {
            $0.select { $0.scheduleState.scheduleRequest }
                .skipRepeats { $0 != $1 }
        }
    }

    // MARK: - Primary State Handler

    func newState(state: StoreSubscriberStateType) {
        guard let scheduleRequest = state, let _ = scheduleRequest.transitMode else { return }
        print("New State fired")
        currentScheduleRequest =  processTransitMode(scheduleRequest: scheduleRequest)
    }

    func processTransitMode(scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.transitMode, newValue: scheduleRequest.transitMode)

        switch comparisonResult {
        case .bothNil:
            return scheduleRequest
        case .bothNonNilAndDifferent, .currentIsNil, .newIsNil:
            retrieveAvailableRoutes(scheduleRequest: scheduleRequest)
            return scheduleRequest
        case .bothNonNilAndEqual:
          return    processRoutes(scheduleRequest: scheduleRequest)
         }
      
    }

    func processRoutes(scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedRoute, newValue: scheduleRequest.selectedRoute)
        switch comparisonResult {
        case .newIsNil:
            return scheduleRequest
        case .bothNonNilAndDifferent, .currentIsNil:
            clearOutNonMatchingTripStarts()
            retrieveStartingStopsForRoute(scheduleRequest: scheduleRequest)
            return scheduleRequest
        case .bothNonNilAndEqual:
         return     processTripStarts(scheduleRequest: scheduleRequest)
       
        default: break
        }
        
    }

    func processTripStarts(scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedStart, newValue: scheduleRequest.selectedStart)
        switch comparisonResult {
        case .newIsNil:
            clearOutNonMatchingTripEnds()
        case .bothNonNilAndDifferent, .currentIsNil:
            clearOutNonMatchingTripEnds()
            retrieveEndingStopsForRoute(scheduleRequest: scheduleRequest)
        case .bothNonNilAndEqual:
      return        processTripEnds(scheduleRequest: scheduleRequest)
            return
        default: break
        }
      
    }

    func processTripEnds(scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedEnd, newValue: scheduleRequest.selectedEnd)
        switch comparisonResult {
        case .newIsNil:
            clearOutNonMatchingTripEnds()
            return scheduleRequest
        case .bothNonNilAndDifferent, .currentIsNil:
            clearOutNonMatchingTripEnds()
            retrieveTripsForRoute(scheduleRequest: scheduleRequest, scheduleType: scheduleRequest.scheduleType!)
            return scheduleRequest
            
        case .bothNonNilAndEqual:
            return processScheduleType(scheduleRequest: scheduleRequest)
        default: break
        }
        
    }

    func processScheduleType(scheduleRequest: ScheduleRequest) -> ScheduleRequest {

        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.scheduleType, newValue: scheduleRequest.scheduleType)
        switch comparisonResult {
        case .newIsNil:
            clearOutNonMatchingTrips()
            return scheduleRequest
        case .bothNonNilAndDifferent, .currentIsNil:
            clearOutNonMatchingTrips()
            retrieveTripsForRoute(scheduleRequest: scheduleRequest, scheduleType: scheduleRequest.scheduleType!)
            return scheduleRequest
        case .bothNonNilAndEqual:
            return scheduleRequest
        default: break
        }
        
    }

    func clearOutNonMatchingRoutes() {
        DispatchQueue.main.async {
            let routesLoadedAction = RoutesLoaded(routes: [Route](), error: nil)
            store.dispatch(routesLoadedAction)
        }
    }

    func clearOutNonMatchingTripStarts() {
        DispatchQueue.main.async {
            let tripStartsLoadedAction = TripStartsLoaded(availableStarts: [Stop](), error: nil)
            store.dispatch(tripStartsLoadedAction)
        }
    }

    func clearOutNonMatchingTripEnds() {
        DispatchQueue.main.async {
            let tripEndsLoadedAction = TripEndsLoaded(availableStops: [Stop](), error: nil)
            store.dispatch(tripEndsLoadedAction)
        }
    }

    func clearOutNonMatchingTrips() {
        DispatchQueue.main.async {
            let tripsLoadedAction = TripsLoaded(availableTrips: [Trip](), error: nil)
            store.dispatch(tripsLoadedAction)
        }
    }

    // MARK: - Retrieve Routes

    func retrieveAvailableRoutes(scheduleRequest: ScheduleRequest) {
        RoutesCommand.sharedInstance.routes(forTransitMode: scheduleRequest.transitMode!) { routes, error in
            let routesLoadedAction = RoutesLoaded(routes: routes, error: error?.localizedDescription)
            store.dispatch(routesLoadedAction)
        }
    }

    func retrieveStartingStopsForRoute(scheduleRequest: ScheduleRequest) {

        TripStartCommand.sharedInstance.stops(forTransitMode: scheduleRequest.transitMode!, forRoute: scheduleRequest.selectedRoute!) { stops, error in
            let action = TripStartsLoaded(availableStarts: stops, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    func retrieveEndingStopsForRoute(scheduleRequest: ScheduleRequest) {

        TripEndCommand.sharedInstance.stops(forTransitMode: scheduleRequest.transitMode!, forRoute: scheduleRequest.selectedRoute!, tripStart: scheduleRequest.selectedStart!) { stops, error in
            let action = TripEndsLoaded(availableStops: stops, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    func retrieveTripsForRoute(scheduleRequest: ScheduleRequest, scheduleType: ScheduleType = .weekday) {

        TripScheduleCommand.sharedInstance.tripSchedules(forTransitMode: scheduleRequest.transitMode!, route: scheduleRequest.selectedRoute!, selectedStart: scheduleRequest.selectedStart!, selectedEnd: scheduleRequest.selectedEnd!, scheduleType: scheduleType) { trips, error in
            let action = TripsLoaded(availableTrips: trips, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
