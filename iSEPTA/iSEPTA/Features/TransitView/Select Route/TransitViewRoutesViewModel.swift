//
//  TransitViewRoutesViewModel.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift
import SeptaSchedule

class TransitViewRoutesViewModel: NSObject, StoreSubscriber, UITextFieldDelegate {
    typealias StoreSubscriberStateType = TransitViewState

    var updateableFromViewModelController: UpdateableFromViewModel?
    var slotBeingChanged: TransitViewRouteSlot?
    var selectedRoutes: [TransitRoute] = []

    let alerts = store.state.alertState.alertDict

    var allRoutes: [TransitRoute]? {
        didSet {
            guard let allRoutes = allRoutes else { return }
            allFilterableRoutes = allRoutes.map {
                FilterableTransitRoute(route: $0)
            }
        }
    }

    fileprivate var allFilterableRoutes: [FilterableTransitRoute]? {
        didSet {
            filteredRoutes = allFilterableRoutes
        }
    }

    var filteredRoutes: [FilterableTransitRoute]? {
        didSet {
            guard let filteredRoutes = filteredRoutes else { return }
            self.filteredRoutes = filteredRoutes.sorted {
                $0.sortString < $1.sortString
            }
            updateableFromViewModelController?.viewModelUpdated()
        }
    }

    override init() {
        super.init()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.transitViewState }.skipRepeats { $0 == $1 }
        }
    }

    func newState(state: TransitViewState) {
        allRoutes = state.availableRoutes
        if let route = state.transitViewModel.firstRoute {
            selectedRoutes.append(route)
        }
        if let route = state.transitViewModel.secondRoute {
            selectedRoutes.append(route)
        }
        if let route = state.transitViewModel.thirdRoute {
            selectedRoutes.append(route)
        }
    }

    func numberOfRows() -> Int {
        guard let filteredRoutes = filteredRoutes else { return 0 }
        return filteredRoutes.count
    }

    func configure(cell: RouteTableViewCell, atRow row: Int) {
        guard let filteredRoutes = filteredRoutes, row < filteredRoutes.count else { return }
        let route = filteredRoutes[row].route
        cell.setShortName(text: "\(route.routeId): \(route.routeName)")

        cell.enabled = !selectedRoutes.contains(route)

        if let routeImage = RouteIcon.get(for: route.routeId, transitMode: route.mode()) {
            cell.setIcon(image: routeImage)
        }

        // Configure alerts
        cell.alertsAreInteractive = false // Alert icons are informative only
        let alert = alerts[route.mode()]?[route.routeId]
        cell.addAlert(alert)
    }

    func shouldHighlight(row: Int) -> Bool {
        guard let routes = filteredRoutes, row < routes.count else { return true }
        let route = routes[row].route
        print("selected routes count: \(selectedRoutes.count)")
        return !selectedRoutes.contains(route)
    }

    func rowSelected(row: Int) {
        guard let filteredRoutes = filteredRoutes, row < filteredRoutes.count, let slot = slotBeingChanged else { return }
        let route = filteredRoutes[row].route

        let action = TransitViewRouteSelected(slot: slot, route: route, description: "TransitView route selected")
        store.dispatch(action)
        let dismissAction = DismissModal(description: "TransitView route selection should be dismissed")
        store.dispatch(dismissAction)
    }

    var filterString = ""
    func textField(_ : UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
        guard let allFilterableRoutes = allFilterableRoutes, let filterRange = Range(range, in: filterString) else { return false }
        filterString = filterString.replacingCharacters(in: filterRange, with: replacementString.lowercased())
        filteredRoutes = allFilterableRoutes.filter {
            guard filterString.count > 0 else { return true }

            return $0.filterstringComponents.filter({ $0.starts(with: filterString) }).count > 0
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.updateableFromViewModelController?.viewModelUpdated()
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    deinit {
        store.unsubscribe(self)
    }
}
