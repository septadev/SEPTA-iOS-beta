// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class ScheduleDataProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest?
    static let sharedInstance = ScheduleDataProvider()
    var currentScheduleRequest = ScheduleRequest()

    private init() {
    }

    func subscribe() {

        store.subscribe(self) {
            $0.select { $0.scheduleState.scheduleRequest }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let scheduleRequest = state else { return }
        print("New State in Schedule Data Provider")

        currentScheduleRequest = processSelectedRoute(scheduleRequest: scheduleRequest)
    }

    func processSelectedRoute(scheduleRequest: ScheduleRequest) -> ScheduleRequest {

        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.transitMode, newValue: scheduleRequest.transitMode)

        switch comparisonResult {
        case .bothNonNilAndEqual, .bothNil:
            break
        case .newIsNil:
            clearRoutes()
        default:
            retrieveAvailableRoutes(scheduleRequest: scheduleRequest)
        }

        return processSelectedTripStart(scheduleRequest: scheduleRequest)
    }

    func processSelectedTripStart(scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedRoute, newValue: scheduleRequest.selectedRoute)

        switch comparisonResult {
        case .bothNonNilAndEqual, .bothNil:
            break
        case .newIsNil:
            clearStartingStops()
        default:
            retrieveStartingStopsForRoute(scheduleRequest: scheduleRequest)
        }

        return processSelectedTripEnd(scheduleRequest: scheduleRequest)
    }

    func processSelectedTripEnd(scheduleRequest: ScheduleRequest) -> ScheduleRequest {
        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedStart, newValue: scheduleRequest.selectedStart)

        switch comparisonResult {
        case .bothNonNilAndEqual, .bothNil:
            break
        case .newIsNil:
            clearEndingStops()
        default:
            retrieveEndingStopsForRoute(scheduleRequest: scheduleRequest)
        }

        return processSelectedTrip(scheduleRequest: scheduleRequest)
    }

    func processSelectedTrip(scheduleRequest: ScheduleRequest) -> ScheduleRequest {

        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedEnd, newValue: scheduleRequest.selectedEnd)

        switch comparisonResult {
        case .bothNonNilAndEqual, .bothNil:
            break
        case .newIsNil:
            clearTrips()
        default:
            retrieveTripsForRoute(scheduleRequest: scheduleRequest)
        }

        return processSelectedScheduleType(scheduleRequest: scheduleRequest)
    }

    func processSelectedScheduleType(scheduleRequest: ScheduleRequest) -> ScheduleRequest {

        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.scheduleType, newValue: scheduleRequest.scheduleType)

        switch comparisonResult {
        case .bothNonNilAndEqual, .bothNil:
            break
        case .newIsNil:
            clearTrips()
        default:
            retrieveTripsForRoute(scheduleRequest: scheduleRequest, scheduleType: scheduleRequest.scheduleType!)
        }

        return scheduleRequest
    }

    func clearRoutes() {
        DispatchQueue.main.async {
            let routesLoadedAction = RoutesLoaded(routes: nil, error: nil)
            store.dispatch(routesLoadedAction)
        }
    }

    func clearStartingStops() {
        DispatchQueue.main.async {
            let tripStartsLoadedAction = TripStartsLoaded(availableStarts: nil, error: nil)
            store.dispatch(tripStartsLoadedAction)
        }
    }

    func clearEndingStops() {
        DispatchQueue.main.async {
            let tripEndsLoadedAction = TripEndsLoaded(availableStops: nil, error: nil)
            store.dispatch(tripEndsLoadedAction)
        }
    }

    func clearTrips() {
        DispatchQueue.main.async {
            let tripsLoadedAction = TripsLoaded(availableTrips: nil, error: nil)
            store.dispatch(tripsLoadedAction)
        }
    }

    // MARK: - Retrieve Routes

    func retrieveAvailableRoutes(scheduleRequest: ScheduleRequest) {
        clearRoutes()
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
        clearEndingStops()
        TripEndCommand.sharedInstance.stops(forTransitMode: scheduleRequest.transitMode!, forRoute: scheduleRequest.selectedRoute!, tripStart: scheduleRequest.selectedStart!) { stops, error in
            let action = TripEndsLoaded(availableStops: stops, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    func retrieveTripsForRoute(scheduleRequest: ScheduleRequest, scheduleType: ScheduleType = .weekday) {
        clearTrips()
        TripScheduleCommand.sharedInstance.tripSchedules(forTransitMode: scheduleRequest.transitMode!, route: scheduleRequest.selectedRoute!, selectedStart: scheduleRequest.selectedStart!, selectedEnd: scheduleRequest.selectedEnd!, scheduleType: scheduleType) { trips, error in
            let action = TripsLoaded(availableTrips: trips, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
