//
//  AlertsViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

class AlertsViewModel {
    let cellId = "singleStringcell"
    var delegate: UpdateableFromViewModel! {
        didSet {
            scheduleRequestWatcher?.delegate = self
        }
    }

    weak var schedulesDelegate: SchedulesViewModelDelegate?
    var transitMode: TransitMode!
    var cellModel: CellModel!
    let scheduleRequestWatcher: BaseScheduleRequestWatcher?

    var scheduleRequest: ScheduleRequest? {
        didSet {
            cellModel = configureSelectRouteDisplayModel()
            formIsCompleteUpdateNeeded()
        }
    }

    func formIsCompleteUpdateNeeded() {
        if let _ = scheduleRequest?.selectedRoute {
            schedulesDelegate?.formIsComplete(true)
        } else {
            schedulesDelegate?.formIsComplete(false)
        }
    }

    init() {
        scheduleRequestWatcher = store.state.watcherForScheduleActions()
    }
}

extension AlertsViewModel {
    func scheduleTitle() -> String {
        return transitMode.systemStatusTitle()
    }

    func transitModeTitle() -> String {
        return "Select Line to View Status"
    }
}

extension AlertsViewModel { // Table View
    func cellIdForRow(_: Int) -> String {
        return cellModel.cellId
    }

    func rowSelected(_ row: Int) {
        if row == 0 {
            let action = PresentModal(viewController: .routesViewController, description: "Selecting a Route from alerts")
            store.dispatch(action)
        }
    }

    func configureCell(_ cell: UITableViewCell, atRow _: Int) {
        switch cell {
        case let cell as SingleStringCell:
            cell.setLabelText(cellModel.text)
            cell.searchIcon.image = UIImage(named: "selectRouteAccessory")
            cell.shouldFill = true
        case let cell as RouteSelectedTableViewCell:
            guard let selectedRoute = scheduleRequest?.selectedRoute else { return }
            cell.routeIdLabel.text = "\(selectedRoute.routeId):"
            cell.routeShortNameLabel.text = cellModel.text
            cell.pillView.backgroundColor = cellModel.pillColor

        default: break
        }
    }

    func canCellBeSelected(atRow _: Int) -> Bool {
        return true
    }

    func heightForSectionHeader(atRow row: Int) -> CGFloat {
        switch row {
        case 0: return 37
        case 1: return 21

        default: return 0
        }
    }

    func shouldDisplayBlankSectionHeaderForSection(_: Int) -> Bool {
        return true
    }
}

extension AlertsViewModel: ScheduleRequestWatcherDelegate {
    func scheduleRequestUpdated(scheduleRequest: ScheduleRequest) {
        self.transitMode = scheduleRequest.transitMode
        self.scheduleRequest = scheduleRequest
        delegate.viewModelUpdated()
    }
}

extension AlertsViewModel {
    // MARK: -  configure routes

    func configureSelectRouteDisplayModel() -> NextToArriveRowDisplayModel {

        let cellModel: CellModel
        if let route = scheduleRequest?.selectedRoute {
            cellModel = configureRoute_RouteDefined(route: route)
        } else {
            cellModel = configureRoute_NoRoute()
        }
        return cellModel
    }

    func configureRoute_NoRoute() -> NextToArriveRowDisplayModel {
        return CellModel(
            text: transitMode.selectRoutePlaceholderText(),
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .routesViewController,
            showSearchIcon: false,
            fontWeight: UIFont.Weight.regular)
    }

    func configureRoute_RouteDefined(route: Route) -> NextToArriveRowDisplayModel {
        return CellModel(
            text: route.routeLongName,
            cellId: "routeSelectedCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .routesViewController,
            pillColor: Route.colorForRoute(route, transitMode: transitMode),
            showSearchIcon: true,
            fontWeight: UIFont.Weight.medium)
    }
}
