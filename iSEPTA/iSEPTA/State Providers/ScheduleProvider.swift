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

    func retrieveAvailableRoutes(transitMode: TransitMode) {
        guard let sqlQuery = buildQueryForRoutes(transitMode: transitMode) else { return }
        busCommands.busRoutes(withQuery: sqlQuery) { routes, error in
            let routesLoadedAction = RoutesLoaded(routes: routes, error: error)
            store.dispatch(routesLoadedAction)
        }
    }

    func buildQueryForRoutes(transitMode: TransitMode) -> SQLQuery? {
        var query: SQLQuery?
        switch transitMode {
        case .bus:
            query = SQLQuery.busRoute(routeType: .bus)
        default:
            query = nil
        }
        return query
    }

    deinit {
        store.unsubscribe(self)
    }
}
