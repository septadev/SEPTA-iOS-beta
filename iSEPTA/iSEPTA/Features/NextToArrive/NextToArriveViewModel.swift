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

class NextToArriveViewModel: NSObject, StoreSubscriber {

    @IBOutlet weak var nextToArriveViewController: UpdateableFromViewModel?
    @IBOutlet weak var schedulesDelegate: SchedulesViewModelDelegate?
    typealias StoreSubscriberStateType = ScheduleRequest?
    var scheduleRequest: ScheduleRequest?
    var targetForScheduleAction: TargetForScheduleAction { return store.state.targetForScheduleActions() }

    fileprivate var selectRouteRowDisplayModel: SelectSchedulesRowDisplayModel?
    fileprivate var selectStartRowDisplayModel: SelectSchedulesRowDisplayModel?
    fileprivate var selectEndRowDisplayModel: SelectSchedulesRowDisplayModel?
    fileprivate var displayModel = [SelectSchedulesRowDisplayModel]()

    func scheduleTitle() -> String? {
        return scheduleRequest?.transitMode?.nextToArriveTitle()
    }

    func newState(state: StoreSubscriberStateType) {
        scheduleRequest = state

        buildDisplayModel()
        nextToArriveViewController?.viewModelUpdated()
        schedulesDelegate?.formIsComplete(scheduleRequest?.selectedEnd != nil)
    }

    func buildDisplayModel() {

        displayModel = [
            configureSelectRouteDisplayModel(),
            configureSelectStartDisplayModel(),
            configureSelectEndisplayModel(),
        ]
    }

    func transitModeTitle() -> String? {
        guard let transitMode = scheduleRequest?.transitMode else { return nil }
        return transitMode.routeTitle()
    }

    func configureSelectRouteDisplayModel() -> SelectSchedulesRowDisplayModel {
        var text = scheduleRequest?.transitMode?.selectRoutePlaceholderText() ?? ""
        let isSelectable = true
        var pillColor = UIColor.clear
        if let route = scheduleRequest?.selectedRoute {
            text = route.routeLongName

            if let routeColor = route.colorForRoute() {
                pillColor = routeColor
            } else if let transitModeColor = scheduleRequest?.transitMode?.colorForPill() {
                pillColor = transitModeColor
            }
        }
        return SelectSchedulesRowDisplayModel(text: text, shouldFillCell: false, isSelectable: isSelectable, targetController: .routesViewController, pillColor: pillColor)
    }

    func configureSelectStartDisplayModel() -> SelectSchedulesRowDisplayModel {
        var text: String = ""
        var fontWeight = UIFont.Weight.regular
        let isSelectable: Bool
        if let _ = scheduleRequest?.selectedRoute {
            isSelectable = true
            if let startName = scheduleRequest?.selectedStart?.stopName {
                text = startName
                fontWeight = UIFont.Weight.medium
            } else {
                text = scheduleRequest?.transitMode?.startingStopName() ?? ""
            }
        } else {
            text = scheduleRequest?.transitMode?.startingStopName() ?? ""
            isSelectable = false
        }
        return SelectSchedulesRowDisplayModel(text: text, shouldFillCell: true, isSelectable: isSelectable, targetController: .selectStopNavigationController, pillColor: UIColor.clear, showSearchIcon: true, fontWeight: fontWeight)
    }

    func configureSelectEndisplayModel() -> SelectSchedulesRowDisplayModel {
        var text: String = ""
        var fontWeight = UIFont.Weight.regular
        let isSelectable: Bool
        if let _ = scheduleRequest?.selectedStart {
            isSelectable = true
            if let stopName = scheduleRequest?.selectedEnd?.stopName {
                text = stopName
                fontWeight = UIFont.Weight.medium
            } else {
                text = scheduleRequest?.transitMode?.endingStopName() ?? ""
            }
        } else {
            text = scheduleRequest?.transitMode?.endingStopName() ?? ""
            isSelectable = false
        }
        return SelectSchedulesRowDisplayModel(text: text, shouldFillCell: true, isSelectable: isSelectable, targetController: .selectStopController, pillColor: UIColor.clear, showSearchIcon: true, fontWeight: fontWeight)
    }

    deinit {
        unsubscribe()
    }
}

extension NextToArriveViewModel { // Loading table view cells

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

    func configureCell(_ cell: UITableViewCell, atRow row: Int) {
        guard row < displayModel.count else { return }
        let rowModel = displayModel[row]
        if let cell = cell as? SingleStringCell {
            cell.label?.font = UIFont.systemFont(ofSize: 14, weight: rowModel.fontWeight)
            cell.setLabelText(rowModel.text)
            cell.setEnabled(rowModel.isSelectable)
            cell.setShouldFill(rowModel.shouldFillCell)
            if let searchIcon = cell.searchIcon {
                cell.searchIcon.isHidden = !rowModel.showSearchIcon
            }
        } else if let cell = cell as? RouteSelectedTableViewCell, let selectedRoute = scheduleRequest?.selectedRoute {
            cell.routeIdLabel.text = "\(selectedRoute.routeId):"
            cell.routeShortNameLabel.text = rowModel.text
            cell.pillView.backgroundColor = rowModel.pillColor
        }
    }

    func canCellBeSelected(atRow row: Int) -> Bool {
        guard row < displayModel.count else { return false }
        return displayModel[row].isSelectable
    }

    func rowSelected(_ row: Int) {
        guard row < displayModel.count else { return }
        let viewController = displayModel[row].targetController
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
