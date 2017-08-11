// Septa. 2017

import Foundation
import SeptaSchedule
import ReSwift

class RoutesViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = [Route]?

    fileprivate var routes: [Route]?
    weak var delegate: UpdateableFromViewModel?

    init(delegate: UpdateableFromViewModel) {
        self.delegate = delegate
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    func filterSubscription(state: AppState) -> [Route]? {
        return state.scheduleState.scheduleData?.availableRoutes
    }

    func newState(state: StoreSubscriberStateType) {
        routes = state
    }

    func configureDisplayable(_ displayable: RouteCellDisplayable, atRow row: Int) {
        guard let routes = routes, row < routes.count else { return }
        let route = routes[row]
        displayable.setShortName(text: route.routeShortName)
        displayable.setLongName(text: route.routeLongName)
    }

    func canCellBeSelected(atRow _: Int) -> Bool {
        return true
    }

    func rowSelected(row: Int) {
        guard let routes = routes, row < routes.count else { return }
        let action = RouteSelected(route: routes[row], description: "Row Selected in Routes View Model")
        store.dispatch(action)
        let dismissAction = DismissModal(navigationController: .schedules, description: "Route has been selected")
        store.dispatch(dismissAction)
    }

    func numberOfRows() -> Int {
        guard let routes = routes else { return 0 }
        return routes.count
    }

    deinit {
        store.unsubscribe(self)
    }
}
