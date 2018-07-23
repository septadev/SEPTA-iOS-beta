// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class SelectSchedulesViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest?
    var scheduleRequest: ScheduleRequest?
    var targetForScheduleAction: TargetForScheduleAction! { return store.state.targetForScheduleActions() }
    weak var delegate: UpdateableFromViewModel?
    weak var schedulesDelegate: SchedulesViewModelDelegate?

    fileprivate var selectRouteRowDisplayModel: SelectSchedulesRowDisplayModel?
    fileprivate var selectStartRowDisplayModel: SelectSchedulesRowDisplayModel?
    fileprivate var selectEndRowDisplayModel: SelectSchedulesRowDisplayModel?
    fileprivate var displayModel = [SelectSchedulesRowDisplayModel]()

    init(delegate: UpdateableFromViewModel) {
        self.delegate = delegate
    }

    func subscribe() {
        if targetForScheduleAction == .schedules {
            store.subscribe(self) {
                $0.select {
                    $0.scheduleState.scheduleRequest
                }
            }
        } else {
            store.subscribe(self) {
                $0.select {
                    $0.nextToArriveState.scheduleState.scheduleRequest
                }
            }
        }
    }

    func scheduleTitle() -> String? {
        return scheduleRequest?.transitMode.scheduleName()
    }

    func filterSubscription(state: AppState) -> ScheduleRequest? {
        return state.scheduleState.scheduleRequest
    }

    func newState(state: StoreSubscriberStateType) {
        scheduleRequest = state

        buildDisplayModel()
        delegate?.viewModelUpdated()
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

    func cellIdForRow(_ row: Int) -> String {
        if row == 0 && scheduleRequest?.selectedRoute != nil {
            return "routeSelectedCell"
        } else {
            return "singleStringCell"
        }
    }

    func configureSelectRouteDisplayModel() -> SelectSchedulesRowDisplayModel {
        var text = scheduleRequest?.transitMode.selectRoutePlaceholderText() ?? ""
        let isSelectable = true
        var pillColor = UIColor.clear
        if let route = scheduleRequest?.selectedRoute {
            text = route.routeLongName

            if let routeColor = route.colorForRoute() {
                pillColor = routeColor
            } else if let transitModeColor = scheduleRequest?.transitMode.colorForPill() {
                pillColor = transitModeColor
            }
        }
        return SelectSchedulesRowDisplayModel(text: text, shouldFillCell: true, isSelectable: isSelectable, targetController: .routesViewController, pillColor: pillColor, searchIconName: "selectRouteAccessory")
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
                text = scheduleRequest?.transitMode.startingStopName() ?? ""
            }
        } else {
            text = scheduleRequest?.transitMode.startingStopName() ?? ""
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
                text = scheduleRequest?.transitMode.endingStopName() ?? ""
            }
        } else {
            text = scheduleRequest?.transitMode.endingStopName() ?? ""
            isSelectable = false
        }
        return SelectSchedulesRowDisplayModel(text: text, shouldFillCell: true, isSelectable: isSelectable, targetController: .selectStopController, pillColor: UIColor.clear, showSearchIcon: true, fontWeight: fontWeight)
    }

    func configureCell(_ cell: UITableViewCell, atRow row: Int) {
        guard row < displayModel.count else { return }
        let rowModel = displayModel[row]
        if let cell = cell as? SingleStringCell {
            cell.label?.font = UIFont.systemFont(ofSize: 14, weight: rowModel.fontWeight)
            cell.setLabelText(rowModel.text)
            cell.setEnabled(rowModel.isSelectable)
            cell.setShouldFill(rowModel.shouldFillCell)
            cell.searchIcon.isHidden = !rowModel.showSearchIcon
            cell.searchIcon.image = UIImage(named: rowModel.searchIconName)
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

    func numberOfRows() -> Int {
        return 3
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
