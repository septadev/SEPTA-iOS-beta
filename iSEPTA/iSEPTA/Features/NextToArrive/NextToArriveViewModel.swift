//
//  NextToArriveViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/5/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit
import SeptaSchedule

fileprivate typealias CellModel = NextToArriveSchedulesRowDisplayModel

struct NextToArriveSchedulesRowDisplayModel {
    let text: String?
    let cellId: String
    let shouldFillCell: Bool
    let isSelectable: Bool
    let targetController: ViewController?
    let pillColor: UIColor?
    let showSearchIcon: Bool?
    let fontWeight: UIFont.Weight?

    init(text: String? = nil,
         cellId: String,
         shouldFillCell: Bool = false,
         isSelectable: Bool = false,
         targetController: ViewController? = nil,
         pillColor: UIColor? = nil,
         showSearchIcon: Bool = false,
         fontWeight: UIFont.Weight = UIFont.Weight.regular) {
        self.text = text
        self.cellId = cellId
        self.shouldFillCell = shouldFillCell
        self.isSelectable = isSelectable
        self.targetController = targetController
        self.pillColor = pillColor
        self.showSearchIcon = showSearchIcon
        self.fontWeight = fontWeight
    }
}

class NextToArriveViewModel: NSObject, StoreSubscriber {

    @IBOutlet weak var nextToArriveViewController: UpdateableFromViewModel?
    @IBOutlet weak var schedulesDelegate: SchedulesViewModelDelegate?
    typealias StoreSubscriberStateType = ScheduleRequest?
    var scheduleRequest: ScheduleRequest?
    var transitMode: TransitMode! {
        didSet {
            if transitMode == .rail && scheduleRequest?.selectedRoute == nil {
                let action = LoadAllRailRoutes()
                store.dispatch(action)
            }
        }
    }

    var targetForScheduleAction: TargetForScheduleAction { return store.state.targetForScheduleActions() }

    fileprivate var selectRouteRowDisplayModel: NextToArriveSchedulesRowDisplayModel?
    fileprivate var selectStartRowDisplayModel: NextToArriveSchedulesRowDisplayModel?
    fileprivate var selectEndRowDisplayModel: NextToArriveSchedulesRowDisplayModel?
    fileprivate var displayModel = [NextToArriveSchedulesRowDisplayModel]()

    func scheduleTitle() -> String? {
        return scheduleRequest?.transitMode?.nextToArriveTitle()
    }

    func newState(state: StoreSubscriberStateType) {
        scheduleRequest = state
        guard let transitMode = state?.transitMode else { return }
        self.transitMode = transitMode
        buildDisplayModel()
        nextToArriveViewController?.viewModelUpdated()
        schedulesDelegate?.formIsComplete(scheduleRequest?.selectedEnd != nil)
    }

    func buildDisplayModel() {

        displayModel = [
            configureSelectRouteDisplayModel(),
            configureSelectStartDisplayModel(),
            configureSelectEndDisplayModel(),
        ]
    }

    func transitModeTitle() -> String? {
        guard let transitMode = scheduleRequest?.transitMode else { return nil }
        return transitMode.routeTitle()
    }

    func shouldDisplaySectionHeaderForSection(_ section: Int) -> Bool {
        guard let transitMode = scheduleRequest?.transitMode else { return false }
        if section == 0 && transitMode == .rail {
            return false
        } else {
            return true
        }
    }

    // MARK: -  configure routes

    func configureSelectRouteDisplayModel() -> NextToArriveSchedulesRowDisplayModel {

        let cellModel: CellModel
        if transitMode == .rail {
            cellModel = configureRouteForRail()
        } else if let route = scheduleRequest?.selectedRoute {
            cellModel = configureRouteForNonRail_RouteDefined(route: route)
        } else {
            cellModel = configureRouteForNonRail_NoRoute()
        }
        return cellModel
    }

    func configureRouteForRail() -> NextToArriveSchedulesRowDisplayModel {
        return CellModel(text: SeptaString.NoRouteNeeded, cellId: "NoRouteNeeded")
    }

    func configureRouteForNonRail_NoRoute() -> NextToArriveSchedulesRowDisplayModel {
        return CellModel(
            text: transitMode.selectRoutePlaceholderText(),
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .routesViewController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureRouteForNonRail_RouteDefined(route: Route) -> NextToArriveSchedulesRowDisplayModel {
        return CellModel(
            text: transitMode.selectRoutePlaceholderText(),
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .routesViewController,
            pillColor: Route.colorForRoute(route, transitMode: transitMode),
            showSearchIcon: true,
            fontWeight: UIFont.Weight.medium)
    }

    // MARK: -  configure Starting Stop

    func configureSelectStartDisplayModel() -> NextToArriveSchedulesRowDisplayModel {
        let cellModel: CellModel
        if let route = scheduleRequest?.selectedRoute, let start = scheduleRequest?.selectedStart {
            cellModel = configureSelectedStart_RouteDefined_StartDefined(route: route, start: start)
        } else if let route = scheduleRequest?.selectedRoute {
            cellModel = configureSelectedStart_RouteDefined_NoStart(route: route)
        } else {
            cellModel = configureSelectedStart_NoRoute()
        }
        return cellModel
    }

    func configureSelectedStart_NoRoute() -> NextToArriveSchedulesRowDisplayModel {
        return CellModel(
            text: transitMode.startingStopName(),
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: false,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureSelectedStart_RouteDefined_NoStart(route _: Route) -> NextToArriveSchedulesRowDisplayModel {
        return CellModel(
            text: transitMode.startingStopName(),
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureSelectedStart_RouteDefined_StartDefined(route _: Route, start: Stop) -> NextToArriveSchedulesRowDisplayModel {
        return CellModel(
            text: start.stopName,
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    // MARK: - Trip ends

    func configureSelectEndDisplayModel() -> NextToArriveSchedulesRowDisplayModel {
        let cellModel: CellModel
        if let route = scheduleRequest?.selectedRoute, let start = scheduleRequest?.selectedStart, let end = scheduleRequest?.selectedEnd {
            cellModel = configureSelectedEnd_RouteDefined_StartDefined_StopDefined(route: route, start: start, end: end)
        } else if let route = scheduleRequest?.selectedRoute, let start = scheduleRequest?.selectedStart {
            cellModel = configureSelectedEnd_RouteDefined_StartDefined_NoStop(route: route, start: start)
        } else if let route = scheduleRequest?.selectedRoute {
            cellModel = configureSelectedEnd_RouteDefined_NoStart(route: route)
        } else {
            cellModel = configureSelectedEnd_NoRoute()
        }
        return cellModel
    }

    func configureSelectedEnd_NoRoute() -> NextToArriveSchedulesRowDisplayModel {
        return CellModel(
            text: transitMode.endingStopName(),
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureSelectedEnd_RouteDefined_NoStart(route _: Route) -> NextToArriveSchedulesRowDisplayModel {
        return CellModel(
            text: transitMode.endingStopName(),
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureSelectedEnd_RouteDefined_StartDefined_NoStop(route _: Route, start _: Stop) -> NextToArriveSchedulesRowDisplayModel {
        return CellModel(
            text: transitMode.endingStopName(),
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureSelectedEnd_RouteDefined_StartDefined_StopDefined(route _: Route, start _: Stop, end: Stop) -> NextToArriveSchedulesRowDisplayModel {
        return CellModel(
            text: end.stopName,
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    deinit {
        unsubscribe()
    }
}

// MARK: -  Loading table view cells
extension NextToArriveViewModel {

    func numberOfRows() -> Int {
        guard let transitMode = scheduleRequest?.transitMode else { return 0 }
        return transitMode == .rail ? 2 : 3
    }

    func cellIdForRow(_ row: Int) -> String {
        guard let transitMode = scheduleRequest?.transitMode else { return "" }
        if transitMode == .rail && row == 0 {
            return "noRouteNeeded"
        } else {
            if row == 0 && scheduleRequest?.selectedRoute != nil {
                return "routeSelectedCell"
            } else {
                return "singleStringCell"
            }
        }
    }

    func configureCell(_: UITableViewCell, atRow row: Int) {
        guard row < displayModel.count else { return }
        _ = displayModel[row]
        //        if let cell = cell as? SingleStringCell {
        //            cell.label?.font = UIFont.systemFont(ofSize: 14, weight: rowModel.fontWeight)
        //            cell.setLabelText(rowModel.text)
        //            cell.setEnabled(rowModel.isSelectable)
        //            cell.setShouldFill(rowModel.shouldFillCell)
        //            if let _ = cell.searchIcon {
        //                cell.searchIcon.isHidden = !rowModel.showSearchIcon
        //            }
        //        } else if let cell = cell as? RouteSelectedTableViewCell, let selectedRoute = scheduleRequest?.selectedRoute {
        //            cell.routeIdLabel.text = "\(selectedRoute.routeId):"
        //            cell.routeShortNameLabel.text = rowModel.text
        //            cell.pillView.backgroundColor = rowModel.pillColor
        //        }
    }

    func canCellBeSelected(atRow row: Int) -> Bool {
        guard row < displayModel.count else { return false }
        return displayModel[row].isSelectable
    }

    func rowSelected(_ row: Int) {
        guard row < displayModel.count,
            let viewController = displayModel[row].targetController else { return }
        let action = PresentModal(
            viewController: viewController,
            description: "User Wishes to pick a route")

        store.dispatch(action)

        if let stopToEdit = StopToSelect(rawValue: row) {
            let editStopAction = CurrentStopToEdit(targetForScheduleAction: targetForScheduleAction, stopToEdit: stopToEdit)
            store.dispatch(editStopAction)
        }
    }
}

extension NextToArriveViewModel: SubscriberUnsubscriber {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.nextToArriveState.scheduleState.scheduleRequest
            }.skipRepeats { $0 == $1 }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
