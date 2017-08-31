// Septa. 2017

import Foundation
import SeptaSchedule
import ReSwift

struct FilterableRoute {
    let filterString: String
    let sortString: String
    let route: Route

    static var routeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "0000"
        return formatter
    }()

    init(route: Route) {
        if let routeInt = Int(route.routeId), let routeString = FilterableRoute.routeNumberFormatter.string(from: NSNumber(value: routeInt)) {
            sortString = routeString + String(route.routeDirectionCode.rawValue)
        } else {
            sortString = "z\(route.routeId)"
        }
        filterString = (route.routeId + route.routeLongName).lowercased()
        self.route = route
    }
}

class RoutesViewModel: NSObject, StoreSubscriber, UITextFieldDelegate {
    typealias StoreSubscriberStateType = ScheduleRouteState

    let transitMode = store.state.scheduleState.scheduleRequest.transitMode!
    let alerts = store.state.alertState.alertDict

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
                $0.sortString < $1.sortString
            }
            selectRoutesViewController?.viewModelUpdated()
        }
    }

    @IBOutlet weak var selectRoutesViewController: UpdateableFromViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.scheduleState.scheduleData.availableRoutes }.skipRepeats { $0 == $1 }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        allRoutes = state.routes
        if state.updateMode == .loadValues && state.routes.count == 0 {
            selectRoutesViewController?.displayErrorMessage(message: SeptaString.NoRoutesAvailable)
        }
    }

    func configureDisplayable(_ displayable: RouteCellDisplayable, atRow row: Int) {
        guard let filteredRoutes = filteredRoutes, row < filteredRoutes.count else { return }
        let route = filteredRoutes[row].route
        displayable.setShortName(text: route.routeId)
        displayable.setLongName(text: route.routeShortName)
        var icon: UIImage?
        if let routeImage = route.iconForRoute() {
            icon = routeImage
        } else if let transitModeImage = transitMode.cellImage() {
            icon = transitModeImage
        }

        displayable.setIcon(image: icon!)
        let alert = alerts[transitMode]?[route.routeId]
        displayable.addAlert(alert)
    }

    func canCellBeSelected(atRow _: Int) -> Bool {
        return true
    }

    func rowSelected(row: Int) {
        guard let filteredRoutes = filteredRoutes, row < filteredRoutes.count else { return }
        let route = filteredRoutes[row].route

        let action = RouteSelected(selectedRoute: route)
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

            strongSelf.selectRoutesViewController?.viewModelUpdated()
        }
        return true
    }
}
