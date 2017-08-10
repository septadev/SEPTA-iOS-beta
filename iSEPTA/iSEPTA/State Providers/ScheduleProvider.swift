// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class ScheduleProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest?
    static let sharedInstance = ScheduleProvider()
    var currentScheduleRequest = ScheduleRequest()
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

    func newState(state: StoreSubscriberStateType) {
        guard let scheduleRequest = state,
            let _ = scheduleRequest.transitMode,
            let selectedRoute = scheduleRequest.selectedRoute else { return }
        updateSelectedRoute(selectedRoute)
        currentScheduleRequest = scheduleRequest
    }

    func updateSelectedRoute(_ route: Route) {
        guard let transitMode = currentScheduleRequest.transitMode else { return }
        if shouldUpdateSelectedRoute(route) {
            if let query = buildQueryForRoutes(transitMode: transitMode, route: route) {
                runQueryForRoutes(transitMode: transitMode, query: query)
            }
        }
    }

    func buildQueryForRoutes(transitMode: TransitMode, route _: Route) -> SQLQuery? {
        var query: SQLQuery?
        switch transitMode {
        case .bus:
            query = SQLQuery.busRoute(routeType: .bus)
        default:
            query = nil
        }
        return query
    }

    func shouldUpdateSelectedRoute(_ route: Route) -> Bool {
        guard let currentRoute = currentScheduleRequest.selectedRoute else { return true }
        return currentRoute != route
    }

    func runQueryForRoutes(transitMode: TransitMode, query: SQLQuery) {

        switch transitMode {
        case .bus:
            busCommands.busRoutes(withQuery: query) { routes, error in
                let action = RoutesLoaded(routes: routes, error: error)
                store.dispatch(action)
            }
        default:
            break
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
