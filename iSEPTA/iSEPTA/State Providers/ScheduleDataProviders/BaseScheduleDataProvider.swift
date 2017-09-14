// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class BaseScheduleDataProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest
    var currentScheduleRequest = ScheduleRequest()

    let targetForScheduleAction: TargetForScheduleAction

    let databaseStateWatcher: ScheduleProviderDatabaseStateWatcher

    init(targetForScheduleAction: TargetForScheduleAction) {
        self.targetForScheduleAction = targetForScheduleAction
        databaseStateWatcher = ScheduleProviderDatabaseStateWatcher()
        databaseStateWatcher.delegate = self
    }

    func subscribe() {
    }

    func newState(state: StoreSubscriberStateType) {
        let scheduleRequest = state
        processNewState(scheduleRequest: scheduleRequest)
        currentScheduleRequest = scheduleRequest
    }

    func processNewState(scheduleRequest: ScheduleRequest) {
        processReverseTrip(scheduleRequest: scheduleRequest)
        processSelectedRoute(scheduleRequest: scheduleRequest)
        processSelectedTripStart(scheduleRequest: scheduleRequest)
        processSelectedTripEnd(scheduleRequest: scheduleRequest)
        processSelectedTrip(scheduleRequest: scheduleRequest)
    }

    func processSelectedRoute(scheduleRequest: ScheduleRequest) {
        let prereqsExist = prerequisitesExistForRoutes(scheduleRequest: scheduleRequest)
        let prereqsChanged = prerequisitesForRoutesHaveChanged(scheduleRequest: scheduleRequest)

        if prereqsExist && prereqsChanged {

            retrieveAvailableRoutes(scheduleRequest: scheduleRequest)
        }
    }

    func processSelectedTripStart(scheduleRequest: ScheduleRequest) {
        let prereqsExist = prerequisitesExistForTripStarts(scheduleRequest: scheduleRequest)
        let prereqsChanged = prerequisitesForTripStartsHaveChanged(scheduleRequest: scheduleRequest)

        if prereqsExist && prereqsChanged {

            retrieveStartingStopsForRoute(scheduleRequest: scheduleRequest)
        }
    }

    func processSelectedTripEnd(scheduleRequest: ScheduleRequest) {
        let prereqsExist = prerequisitesExistForTripEnds(scheduleRequest: scheduleRequest)
        let prereqsChanged = prerequisitesForTripEndsHaveChanged(scheduleRequest: scheduleRequest)

        if prereqsExist && prereqsChanged {

            retrieveEndingStopsForRoute(scheduleRequest: scheduleRequest)
        }
    }

    func processSelectedTrip(scheduleRequest: ScheduleRequest) {
        let prereqsExist = prerequisitesExistForTrips(scheduleRequest: scheduleRequest)
        let prereqsChanged = prerequisitesForTripsHaveChanged(scheduleRequest: scheduleRequest)

        if prereqsExist && prereqsChanged {

            retrieveTripsForRoute(scheduleRequest: scheduleRequest)
        }
    }

    func processReverseTrip(scheduleRequest: ScheduleRequest) {
        if scheduleRequest.reverseStops == true {
            reverseTrip(scheduleRequest: scheduleRequest)
        }
    }

    // MARK: - Prerequisites Exist

    func prerequisitesExistForRoutes(scheduleRequest _: ScheduleRequest) -> Bool {
        return true
    }

    func prerequisitesExistForTripStarts(scheduleRequest: ScheduleRequest) -> Bool {
        return
            scheduleRequest.selectedRoute != nil
    }

    func prerequisitesExistForTripEnds(scheduleRequest: ScheduleRequest) -> Bool {
        return
            scheduleRequest.selectedRoute != nil &&
            scheduleRequest.selectedStart != nil
    }

    func prerequisitesExistForTrips(scheduleRequest: ScheduleRequest) -> Bool {
        return
            scheduleRequest.selectedRoute != nil &&
            scheduleRequest.selectedStart != nil &&
            scheduleRequest.selectedEnd != nil &&
            scheduleRequest.scheduleType != nil
    }

    // MARK: -  Prerequisites Have Changed

    func prerequisitesForRoutesHaveChanged(scheduleRequest: ScheduleRequest) -> Bool {

        return scheduleRequest.transitMode != currentScheduleRequest.transitMode
    }

    func prerequisitesForTripStartsHaveChanged(scheduleRequest: ScheduleRequest) -> Bool {
        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedRoute, newValue: scheduleRequest.selectedRoute)
        return !comparisonResult.equalityResult()
    }

    func prerequisitesForTripEndsHaveChanged(scheduleRequest: ScheduleRequest) -> Bool {
        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedStart, newValue: scheduleRequest.selectedStart)
        return !comparisonResult.equalityResult()
    }

    func prerequisitesForTripsHaveChanged(scheduleRequest: ScheduleRequest) -> Bool {
        let selectedEndComparison = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedEnd, newValue: scheduleRequest.selectedEnd)
        let scheduleTypeComparison = Optionals.optionalCompare(currentValue: currentScheduleRequest.scheduleType, newValue: scheduleRequest.scheduleType)
        return !selectedEndComparison.equalityResult() || !scheduleTypeComparison.equalityResult()
    }

    // MARK: - Clear out existing data
    func clearRoutes() {
        DispatchQueue.main.async {
            store.dispatch(ClearRoutes(targetForScheduleAction: self.targetForScheduleAction))
        }
    }

    func clearStartingStops() {
        DispatchQueue.main.async {
            store.dispatch(ClearTripStarts(targetForScheduleAction: self.targetForScheduleAction))
        }
    }

    func clearEndingStops() {
        DispatchQueue.main.async {
            store.dispatch(ClearTripEnds(targetForScheduleAction: self.targetForScheduleAction))
        }
    }

    func clearTrips() {
        DispatchQueue.main.async {
            store.dispatch(ClearTrips(targetForScheduleAction: self.targetForScheduleAction))
        }
    }

    // MARK: - Retrieve Data

    func retrieveAvailableRoutes(scheduleRequest: ScheduleRequest) {
        clearRoutes()
        RoutesCommand.sharedInstance.routes(forTransitMode: scheduleRequest.transitMode) { routes, error in
            let routes = routes ?? [Route]()
            let routesLoadedAction = RoutesLoaded(targetForScheduleAction: self.targetForScheduleAction, routes: routes, error: error?.localizedDescription)
            store.dispatch(routesLoadedAction)
        }
    }

    func retrieveStartingStopsForRoute(scheduleRequest: ScheduleRequest) {
        clearStartingStops()
        TripStartCommand.sharedInstance.stops(forTransitMode: scheduleRequest.transitMode, forRoute: scheduleRequest.selectedRoute!) { stops, error in
            let stops = stops ?? [Stop]()
            let action = TripStartsLoaded(targetForScheduleAction: self.targetForScheduleAction, availableStarts: stops, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    func retrieveEndingStopsForRoute(scheduleRequest: ScheduleRequest) {
        clearEndingStops()
        TripEndCommand.sharedInstance.stops(forTransitMode: scheduleRequest.transitMode, forRoute: scheduleRequest.selectedRoute!, tripStart: scheduleRequest.selectedStart!) { stops, error in
            let stops = stops ?? [Stop]()
            let action = TripEndsLoaded(targetForScheduleAction: self.targetForScheduleAction, availableStops: stops, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    func retrieveTripsForRoute(scheduleRequest: ScheduleRequest) {
        clearTrips()
        TripScheduleCommand.sharedInstance.tripSchedules(forTransitMode: scheduleRequest.transitMode, route: scheduleRequest.selectedRoute!, selectedStart: scheduleRequest.selectedStart!, selectedEnd: scheduleRequest.selectedEnd!, scheduleType: scheduleRequest.scheduleType!) { trips, error in
            let trips = trips ?? [Trip]()
            let action = TripsLoaded(targetForScheduleAction: self.targetForScheduleAction, availableTrips: trips, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    // MARK: - Reverse Trip

    func reverseTrip(scheduleRequest: ScheduleRequest) {
        let transitMode = scheduleRequest.transitMode
        guard
            let selectedRoute = scheduleRequest.selectedRoute,
            let selectedStart = scheduleRequest.selectedStart,
            let selectedEnd = scheduleRequest.selectedEnd,
            let scheduleType = scheduleRequest.scheduleType else { return }

        let tripStopId = TripStopId(start: selectedStart.stopId, end: selectedEnd.stopId)

        StopReverseCommand.sharedInstance.reverseStops(forTransitMode: transitMode, tripStopId: tripStopId) { tripStopIds, _ in
            guard let tripStopIds = tripStopIds, let tripStopId = tripStopIds.first else { return }
            TripReverseCommand.sharedInstance.reverseTrip(forTransitMode: transitMode, tripStopId: tripStopId, scheduleType: scheduleType) { trips, _ in
                guard let reversedTrips = trips else { return }
                StopsByStopIdCommand.sharedInstance.retrieveStops(forTransitMode: transitMode, tripStopId: tripStopId) { stops, _ in
                    guard let stops = stops,
                        let newStart = stops.filter({ $0.stopId == tripStopId.start }).first,
                        let newEnd = stops.filter({ $0.stopId == tripStopId.end }).first else { return }
                    ReverseRouteCommand.sharedInstance.reverseRoute(forTransitMode: transitMode, route: selectedRoute) { routes, error in
                        guard let routes = routes, let newRoute = routes.first else { return }
                        let newScheduleRequest = ScheduleRequest(transitMode: transitMode, selectedRoute: newRoute, selectedStart: newStart, selectedEnd: newEnd, scheduleType: scheduleType, reverseStops: false)
                        let action = ReverseLoaded(targetForScheduleAction: self.targetForScheduleAction, scheduleRequest: newScheduleRequest, trips: reversedTrips, error: error?.localizedDescription)
                        store.dispatch(action)
                    }
                }
            }
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
