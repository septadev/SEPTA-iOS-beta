// Septa. 2017

import Foundation
import SeptaSchedule
import ReSwift

class BaseRoutesViewModel: NSObject, StoreSubscriber, UITextFieldDelegate {
    typealias StoreSubscriberStateType = ScheduleRouteState
    var targetForScheduleAction = TargetForScheduleAction.schedules
    let transitMode = store.state.scheduleState.scheduleRequest.transitMode!
    let alerts = store.state.alertState.alertDict

    @IBOutlet weak var selectRoutesViewController: UpdateableFromViewModel?

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

    override func awakeFromNib() {
        super.awakeFromNib()
        subscribe()
    }

    func subscribe() {
    }

    func newState(state: StoreSubscriberStateType) {
        allRoutes = state.routes
        if state.updateMode == .loadValues && state.routes.count == 0 {
            selectRoutesViewController?.displayErrorMessage(message: SeptaString.NoRoutesAvailable, shouldDismissAfterDisplay: true)
        }
    }

    func configureDisplayable(_ displayable: RouteCellDisplayable, atRow row: Int) {
        guard let filteredRoutes = filteredRoutes, row < filteredRoutes.count else { return }
        let route = filteredRoutes[row].route
        if let shortNameOverride = route.shortNameOverrideForRoute(transitMode: transitMode) {
            displayable.setShortName(text: shortNameOverride)
        } else {
            displayable.setShortName(text: route.routeShortName)
        }

        displayable.setLongName(text: route.routeLongName)
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

        let action = RouteSelected(targetForScheduleAction: targetForScheduleAction, selectedRoute: route)
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

class RoutesViewModel: BaseRoutesViewModel {
    override func awakeFromNib() {

        if let targetForRouteUpdates = determineTargetForRouteUpdates() {
            super.targetForScheduleAction = targetForRouteUpdates
        }
        super.awakeFromNib()
    }

    func determineTargetForRouteUpdates() -> TargetForScheduleAction? {
        let scheduleTargets: [NavigationController] = [.nextToArrive, .schedules]
        let activeNavigationController = store.state.navigationState.activeNavigationController
        guard scheduleTargets.contains(activeNavigationController) else { return nil }

        if activeNavigationController == .schedules { return TargetForScheduleAction.schedules }
        if activeNavigationController == .nextToArrive { return TargetForScheduleAction.nextToArrive }
        return nil
    }

    override func subscribe() {
        if super.targetForScheduleAction == .schedules {
            store.subscribe(self) {
                $0.select { $0.scheduleState.scheduleData.availableRoutes }.skipRepeats { $0 == $1 }
            }
        } else if super.targetForScheduleAction == .nextToArrive {
            store.subscribe(self) {
                $0.select { $0.nextToArriveState.scheduleState.scheduleData.availableRoutes }.skipRepeats { $0 == $1 }
            }
        }
    }
}
