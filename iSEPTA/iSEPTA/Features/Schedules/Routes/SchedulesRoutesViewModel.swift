// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class RoutesViewModel: NSObject, StoreSubscriber, UITextFieldDelegate {
    typealias StoreSubscriberStateType = ScheduleRouteState
    var targetForScheduleAction: TargetForScheduleAction! = store.state.targetForScheduleActions()
    let transitMode = TransitMode.currentTransitMode()!
    let alerts = store.state.alertState.alertDict
    @IBOutlet var selectRoutesViewController: UpdateableFromViewModel?

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

    func newState(state: StoreSubscriberStateType) {
        allRoutes = state.routes
        if targetForScheduleAction == .alerts {
            // For schedules, only show one option per route rather than one for each direction.
            if let routes = allRoutes {
                var routeDict: [String:Route] = [:]
                for r in routes {
                    routeDict[r.routeId] = r
                }
                allRoutes = Array(routeDict.values)
            }
        }
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

        if let routeImage = RouteIcon.get(for: route.routeId, transitMode: transitMode) {
            displayable.setIcon(image: routeImage)
        }
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
        let dismissAction = DismissModal(description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }

    func numberOfRows() -> Int {
        guard let filteredRoutes = filteredRoutes else { return 0 }
        return filteredRoutes.count
    }

    var filterString = ""
    func textField(_: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {

        guard let allFilterableRoutes = allFilterableRoutes, let swiftRange = Range(range, in: filterString) else { return false }
        filterString = filterString.replacingCharacters(in: swiftRange, with: replacementString.lowercased())
        filteredRoutes = allFilterableRoutes.filter {
            guard filterString.count > 0 else { return true }

            return $0.filterstringComponents.filter({ $0.starts(with: filterString) }).count > 0
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.selectRoutesViewController?.viewModelUpdated()
        }
        return true
    }

    func subscribe() {
        if targetForScheduleAction == .schedules {
            store.subscribe(self) {
                $0.select { $0.scheduleState.scheduleData.availableRoutes }.skipRepeats { $0 == $1 }
            }
        } else if targetForScheduleAction == .alerts {
            store.subscribe(self) {
                $0.select { $0.alertState.scheduleState.scheduleData.availableRoutes }.skipRepeats { $0 == $1 }
            }

        } else if targetForScheduleAction == .nextToArrive {
            store.subscribe(self) {
                $0.select { $0.nextToArriveState.scheduleState.scheduleData.availableRoutes }.skipRepeats { $0 == $1 }
            }
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
