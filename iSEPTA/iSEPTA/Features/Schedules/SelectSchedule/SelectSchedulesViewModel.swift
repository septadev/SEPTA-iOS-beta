// Septa. 2017

import Foundation
import ReSwift
import UIKit
import SeptaSchedule

fileprivate struct RowDisplayModel {
    let text: String
    let shouldFillCell: Bool
    let isSelectable: Bool
    let targetController: ViewController
    let pillColor: UIColor
    let showSearchIcon: Bool

    init(text: String, shouldFillCell: Bool, isSelectable: Bool, targetController: ViewController, pillColor: UIColor, showSearchIcon: Bool = false) {
        self.text = text
        self.shouldFillCell = shouldFillCell
        self.isSelectable = isSelectable
        self.targetController = targetController
        self.pillColor = pillColor
        self.showSearchIcon = showSearchIcon
    }
}

protocol SchedulesViewModelDelegate: AnyObject {
    func formIsComplete(_ complete: Bool)
}

class SelectSchedulesViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest?
    var scheduleRequest: ScheduleRequest?

    weak var delegate: UpdateableFromViewModel?
    weak var schedulesDelegate: SchedulesViewModelDelegate?

    fileprivate var selectRouteRowDisplayModel: RowDisplayModel?
    fileprivate var selectStartRowDisplayModel: RowDisplayModel?
    fileprivate var selectEndRowDisplayModel: RowDisplayModel?
    fileprivate var displayModel = [RowDisplayModel]()

    init(delegate: UpdateableFromViewModel) {
        self.delegate = delegate
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.scheduleState.scheduleRequest
            }
        }
    }

    func scheduleTitle() -> String? {
        return scheduleRequest?.transitMode?.scheduleName()
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

    fileprivate func configureSelectRouteDisplayModel() -> RowDisplayModel {
        var text = scheduleRequest?.transitMode?.selectRoutePlaceholderText() ?? ""
        let isSelectable = true
        var pillColor = UIColor.clear
        if let route = scheduleRequest?.selectedRoute, let transitMode = scheduleRequest?.transitMode {
            text = (transitMode == .rail) ? route.routeLongName : route.routeShortName

            if let routeColor = route.colorForRoute() {
                pillColor = routeColor
            } else if let transitModeColor = scheduleRequest?.transitMode?.colorForPill() {
                pillColor = transitModeColor
            }
        }
        return RowDisplayModel(text: text, shouldFillCell: false, isSelectable: isSelectable, targetController: .routesViewController, pillColor: pillColor)
    }

    fileprivate func configureSelectStartDisplayModel() -> RowDisplayModel {
        var text: String = ""

        let isSelectable: Bool
        if let _ = scheduleRequest?.selectedRoute {
            isSelectable = true
            if let startName = scheduleRequest?.selectedStart?.stopName {
                text = startName
            } else {
                text = scheduleRequest?.transitMode?.startingStopName() ?? ""
            }
        } else {
            text = scheduleRequest?.transitMode?.startingStopName() ?? ""
            isSelectable = false
        }
        return RowDisplayModel(text: text, shouldFillCell: true, isSelectable: isSelectable, targetController: .selectStopNavigationController, pillColor: UIColor.clear, showSearchIcon: true)
    }

    fileprivate func configureSelectEndisplayModel() -> RowDisplayModel {
        var text: String = ""

        let isSelectable: Bool
        if let _ = scheduleRequest?.selectedStart {
            isSelectable = true
            if let stopName = scheduleRequest?.selectedEnd?.stopName {
                text = stopName
            } else {
                text = scheduleRequest?.transitMode?.endingStopName() ?? ""
            }
        } else {
            text = scheduleRequest?.transitMode?.endingStopName() ?? ""
            isSelectable = false
        }
        return RowDisplayModel(text: text, shouldFillCell: true, isSelectable: isSelectable, targetController: .selectStopController, pillColor: UIColor.clear, showSearchIcon: true)
    }

    func configureCell(_ cell: UITableViewCell, atRow row: Int) {
        guard row < displayModel.count else { return }
        let rowModel = displayModel[row]
        if let cell = cell as? SingleStringCell {

            cell.setLabelText(rowModel.text)
            cell.setEnabled(rowModel.isSelectable)
            cell.setShouldFill(rowModel.shouldFillCell)
            cell.searchIcon.isHidden = !rowModel.showSearchIcon
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
        let action = PresentModal(navigationController: .schedules,
                                  viewController: viewController,
                                  description: "User Wishes to pick a route")

        store.dispatch(action)

        if let stopToEdit = StopToSelect(rawValue: row) {
            let editStopAction = CurrentStopToEdit(stopToEdit: stopToEdit)
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
