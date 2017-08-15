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
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    func filterSubscription(state: AppState) -> ScheduleRequest? {
        return state.scheduleState.scheduleRequest
    }

    // MARK: - Primary State Handler

    func newState(state: StoreSubscriberStateType) {
        guard let scheduleRequest = state else { return }

        processTransitMode(scheduleRequest: scheduleRequest)
    }

    func processTransitMode(scheduleRequest: ScheduleRequest) {
        let comparisonResult = optionalCompare(currentValue: currentScheduleRequest.transitMode, newValue: scheduleRequest.transitMode)
        switch comparisonResult {
        case .newIsNil:
            clearOutNonMatchingRoutes()
        case .bothNonNilAndDifferent, .currentIsNil:
            retrieveAvailableRoutes(scheduleRequest: scheduleRequest)
        case .bothNonNilAndEqual:
            processRoutes(scheduleRequest: scheduleRequest)
            return
        default: break
        }

        currentScheduleRequest = scheduleRequest
    }

    func processRoutes(scheduleRequest: ScheduleRequest) {
        let comparisonResult = optionalCompare(currentValue: currentScheduleRequest.selectedRoute, newValue: scheduleRequest.selectedRoute)
        switch comparisonResult {
        case .newIsNil:
            clearOutNonMatchingTripStarts()
        case .bothNonNilAndDifferent, .currentIsNil:
            retrieveStartingStopsForRoute(scheduleRequest: scheduleRequest)
        case .bothNonNilAndEqual:
            processTripStarts(scheduleRequest: scheduleRequest)
            return
        default: break
        }
        currentScheduleRequest = scheduleRequest
    }

    func processTripStarts(scheduleRequest: ScheduleRequest) {
        let comparisonResult = optionalCompare(currentValue: currentScheduleRequest.selectedStart, newValue: scheduleRequest.selectedStart)
        switch comparisonResult {
        case .newIsNil:
            clearOutNonMatchingTripEnds()
        case .bothNonNilAndDifferent, .currentIsNil:
            retrieveStartingStopsForRoute(scheduleRequest: scheduleRequest)
        case .bothNonNilAndEqual:
            processTripEnds(scheduleRequest: scheduleRequest)
            return
        default: break
        }
        currentScheduleRequest = scheduleRequest
    }

    func processTripEnds(scheduleRequest: ScheduleRequest) {
        let comparisonResult = optionalCompare(currentValue: currentScheduleRequest.selectedEnd, newValue: scheduleRequest.selectedEnd)
        switch comparisonResult {
        case .newIsNil:
            clearOutNonMatchingTripEnds()
        case .bothNonNilAndDifferent, .currentIsNil:
            retrieveTripsForRoute(scheduleRequest: scheduleRequest)
        case .bothNonNilAndEqual:
            return
        default: break
        }
        currentScheduleRequest = scheduleRequest
    }

    func clearOutNonMatchingRoutes() {
        let routesLoadedAction = RoutesLoaded(routes: [Route](), error: nil)
        store.dispatch(routesLoadedAction)
    }

    func clearOutNonMatchingTripStarts() {
        let tripStartsLoadedAction = TripStartsLoaded(availableStarts: [Stop](), error: nil)
        store.dispatch(tripStartsLoadedAction)
    }

    func clearOutNonMatchingTripEnds() {
        let tripEndsLoadedAction = TripEndsLoaded(availableStops: [Stop](), error: nil)
        store.dispatch(tripEndsLoadedAction)
    }

    func clearOutNonMatchingTrips() {
        let tripsLoadedAction = TripsLoaded(availableTrips: [Trip](), error: nil)
        store.dispatch(tripsLoadedAction)
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

    func retrieveTripsForRoute(scheduleRequest _: ScheduleRequest) {

        //        TripEndCommand.sharedInstance.stops(forTransitMode: transitMode, forRoute: route, tripStart: tripStart) { stops, error in
        //            let action = TripEndsLoaded(availableStops: stops, error: error?.localizedDescription)
        //            store.dispatch(action)
        //        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
