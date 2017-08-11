// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class ScheduleProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest?
    static let sharedInstance = ScheduleProvider()
    var lastScheduleRequest = ScheduleRequest()
    let busCommands = BusCommands()
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
        }

        lastScheduleRequest = scheduleRequest
    }

    func hasTransitModeChanged(transitMode: TransitMode) -> Bool {
        if let lastTransitMode = lastScheduleRequest.transitMode {
            return transitMode != lastTransitMode
        } else {
            return true
        }
    }

    func hasSelectedRouteChanged(selectedRoute: Route?) -> Bool {
        let lastSelectedRoute = lastScheduleRequest.selectedRoute
        switch (lastSelectedRoute, selectedRoute) {
        case (.some, .some):
            return lastSelectedRoute != selectedRoute
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
        guard let sqlQuery = buildQueryForRoutes(transitMode: transitMode) else { return }
        busCommands.busRoutes(withQuery: sqlQuery) { routes, error in
            let routesLoadedAction = RoutesLoaded(routes: routes, error: error?.localizedDescription, description: "Routes have now been loaded")
            store.dispatch(routesLoadedAction)
        }
    }

    func buildQueryForRoutes(transitMode: TransitMode) -> SQLQuery? {
        var query: SQLQuery?
        switch transitMode {
        case .bus:
            query = SQLQuery.busRoute(routeType: .bus)
        case .trolley:
            query = SQLQuery.busRoute(routeType: .trolley)
        default:
            query = nil
        }
        return query
    }

    // MARK: - Retrieve Starting Stops
    /*
     func  retrieveAvailableStartingStops(selectedRoute: selectedRoute){

     }

     func buildQueryForStartingStops(transitMode: transitMode, route: Route) -> SQLQuery? {
     var query: SQLQuery?
     switch transitMode {
     case .bus:
     query = SQLQuery.busRoute(routeType: .bus)
     default:
     query = nil
     }
     return query
     }
     */

    deinit {
        store.unsubscribe(self)
    }
}
