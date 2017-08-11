// Septa. 2017

import Foundation
import SeptaSchedule
import ReSwift

struct FilterableRoute {
    let filterString: String
    let route: Route

    init(route: Route) {
        filterString = (route.routeId + route.routeLongName).lowercased()
        self.route = route
    }
}

class RoutesViewModel: NSObject, StoreSubscriber, UITextFieldDelegate {
    typealias StoreSubscriberStateType = [Route]?

    var allRoutes: [Route]? {
        didSet {
            guard let allRoutes = allRoutes else { return }
            allFilterableRoutes = allRoutes.map {
                FilterableRoute(route: $0)
            }
        }
    }

    fileprivate var allFilterableRoutes: [FilterableRoute]? {
        didSet {
            filteredRoutes = allFilterableRoutes
        }
    }

    var filteredRoutes: [FilterableRoute]? {
        didSet {
            guard let filteredRoutes = filteredRoutes else { return }
            self.filteredRoutes = filteredRoutes.sorted {
                $0.filterString < $1.filterString
            }
        }
    }

    @IBOutlet weak var delegate: UpdateableFromViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
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
        allRoutes = state
    }

    func configureDisplayable(_ displayable: RouteCellDisplayable, atRow row: Int) {
        guard let filteredRoutes = filteredRoutes, row < filteredRoutes.count else { return }
        let route = filteredRoutes[row].route
        displayable.setShortName(text: route.routeShortName)
        displayable.setLongName(text: route.routeLongName)
    }

    func canCellBeSelected(atRow _: Int) -> Bool {
        return true
    }

    func rowSelected(row: Int) {
        guard let filteredRoutes = filteredRoutes, row < filteredRoutes.count else { return }
        let route = filteredRoutes[row].route
        let action = RouteSelected(route: route, description: "A Route has been selected")
        store.dispatch(action)
        let dismissAction = DismissModal(navigationController: .schedules, description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }

    func numberOfRows() -> Int {
        guard let filteredRoutes = filteredRoutes else { return 0 }
        return filteredRoutes.count
    }

    deinit {
        store.unsubscribe(self)
    }

    var filterString = ""
    func textField(_: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {

        guard let allFilterableRoutes = allFilterableRoutes, let swiftRange = Range(range, in: filterString) else { return false }
        filterString = filterString.replacingCharacters(in: swiftRange, with: replacementString.lowercased())
        filteredRoutes = allFilterableRoutes.filter {
            guard filterString.characters.count > 0 else { return true }
            return $0.filterString.contains(filterString)
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.delegate?.viewModelUpdated()
        }
        return true
    }
}
