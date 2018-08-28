//
//  TransitViewSelectionViewModel.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift
import SeptaSchedule

class TransitViewSelectionViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = TransitViewModel

    weak var delegate: UpdateableFromViewModel?

    var firstRoute: TransitRoute?
    var secondRoute: TransitRoute?
    var thirdRoute: TransitRoute?
    var selectedSlot: TransitViewRouteSlot?

    init(delegate: UpdateableFromViewModel) {
        self.delegate = delegate
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.transitViewState.transitViewModel
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        firstRoute = state.firstRoute
        secondRoute = state.secondRoute
        thirdRoute = state.thirdRoute
        delegate?.viewModelUpdated()
    }

    func cellFor(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.section

        switch row {
        case 0:
            if let route = firstRoute {
                return constructRouteSelectedCell(tableView: tableView, indexPath: indexPath, route: route)
            } else {
                return constructEmptyRouteCell(tableView: tableView, indexPath: indexPath, enabled: true)
            }
        case 1:
            if let route = secondRoute {
                return constructRouteSelectedCell(tableView: tableView, indexPath: indexPath, route: route)
            } else {
                return constructEmptyRouteCell(tableView: tableView, indexPath: indexPath, enabled: firstRoute != nil)
            }
        case 2:
            if let route = thirdRoute {
                return constructRouteSelectedCell(tableView: tableView, indexPath: indexPath, route: route)
            } else {
                return constructEmptyRouteCell(tableView: tableView, indexPath: indexPath, enabled: secondRoute != nil)
            }
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonViewCell", for: indexPath) as! ButtonViewCell
            cell.buttonText = "View Map"
            cell.enabled = firstRoute != nil
            return cell
        default:
            return UITableViewCell()
        }
    }

    private func constructEmptyRouteCell(tableView: UITableView, indexPath: IndexPath, enabled: Bool) -> SingleStringCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "singleStringCell", for: indexPath) as! SingleStringCell
        cell.setEnabled(enabled)
        return cell
    }

    private func constructRouteSelectedCell(tableView: UITableView, indexPath: IndexPath, route: TransitRoute) -> RouteSelectedTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeSelectedCell", for: indexPath) as! RouteSelectedTableViewCell
        cell.routeIdLabel.text = "\(route.routeId):"
        cell.routeShortNameLabel.text = route.routeName
        cell.pillView.backgroundColor = Route.colorForRouteId(route.routeId, transitMode: route.mode())
        return cell
    }

    func canSelectRow(row: Int) -> Bool {
        switch row {
        case 0:
            return true
        case 1:
            return firstRoute != nil
        case 2:
            return secondRoute != nil
        case 3:
            return firstRoute != nil
        default:
            return false
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
