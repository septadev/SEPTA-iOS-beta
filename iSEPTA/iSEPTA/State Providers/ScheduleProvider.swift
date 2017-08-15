// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class ScheduleProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest?
    static let sharedInstance = ScheduleProvider()
    var currentScheduleRequest = ScheduleRequest()
    let routesCommand = RoutesCommand()
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
        guard let scheduleRequest = state,
            let transitMode = scheduleRequest.transitMode else { return }

        if hasTransitModeChanged(transitMode: transitMode) {
            retrieveAvailableRoutes(transitMode: transitMode)
            currentScheduleRequest = scheduleRequest
            return
        }

        if hasSelectedRouteChanged(selectedRoute: scheduleRequest.selectedRoute) {
            if let selectedRoute = scheduleRequest.selectedRoute {
                retrieveStartingStopsForRoute(transitMode: transitMode, route: selectedRoute)
                currentScheduleRequest = scheduleRequest
            }
            return
        }
    }

    func hasTransitModeChanged(transitMode: TransitMode) -> Bool {
        if let lastTransitMode = currentScheduleRequest.transitMode {
            return transitMode != lastTransitMode
        } else {
            return true
        }
    }

    func hasSelectedRouteChanged(selectedRoute: Route?) -> Bool {
        let currentSelectedRoute = currentScheduleRequest.selectedRoute
        switch (currentSelectedRoute, selectedRoute) {
        case (.some, .some):
            return currentSelectedRoute != selectedRoute
        case (.none, .some):
            return true
        case (.some, .none):
            clearOutNonMatchingRoutes()
            return false
        case (.none, .none):
            return false
        }
    }

    func clearOutNonMatchingRoutes() {
        let routesLoadedAction = RoutesLoaded(routes: [Route](), error: nil, description: "Clearing out matching routes")
        store.dispatch(routesLoadedAction)
    }

    // MARK: - Retrieve Routes

    func retrieveAvailableRoutes(transitMode: TransitMode) {

        routesCommand.routes(forTransitMode: transitMode) { routes, error in
            let routesLoadedAction = RoutesLoaded(routes: routes, error: error?.localizedDescription, description: "Routes have now been loaded")
            store.dispatch(routesLoadedAction)
        }
    }

    func retrieveStartingStopsForRoute(transitMode: TransitMode, route: Route) {

        TripStartCommand.sharedInstance.stops(forTransitMode: transitMode, forRoute: route) { stops, error in
            let action = TripStartsLoaded(availableStarts: stops, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
