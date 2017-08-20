// Septa. 2017

import Foundation
import ReSwift
import UIKit

fileprivate struct RowDisplayModel {
    let text: String
    let opacity: CGFloat
    let accessoryType: CellDecoration
    let isSelectable: Bool
    let targetController: ViewController
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

    var onlyOneRouteAvailable: Bool = false

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

        onlyOneRouteAvailable = false

        displayModel = [
            configureSelectRouteDisplayModel(),
            configureSelectStartDisplayModel(),
            configureSelectEndisplayModel(),
        ]
    }

    func transitModeTitle() -> String? {
        return scheduleRequest?.transitMode?.routeTitle()
    }

    fileprivate func configureSelectRouteDisplayModel() -> RowDisplayModel {
        var text = ""
        if let transitMode = scheduleRequest?.transitMode {
            text = transitMode.selector()
        }

        let accessoryType = CellDecoration.none

        let isSelectable = !onlyOneRouteAvailable
        let opacity = isSelectable ? CGFloat(1.0) : CGFloat(0.3)
        return RowDisplayModel(text: text, opacity: opacity, accessoryType: accessoryType, isSelectable: isSelectable, targetController: .routesViewController)
    }

    fileprivate func configureSelectStartDisplayModel() -> RowDisplayModel {
        var text: String = ""

        let accessoryType: CellDecoration
        let isSelectable: Bool
        if let _ = scheduleRequest?.selectedRoute {
            accessoryType = .none
            isSelectable = true
            if let startName = scheduleRequest?.selectedStart?.stopName {
                text = startName

            } else {
                text = SeptaString.SelectStart
            }
        } else {
            if let transitMode = scheduleRequest?.transitMode {
                text = transitMode.startingStopName()
            }
            text = SeptaString.SelectStart

            accessoryType = .none
            isSelectable = false
        }
        let opacity = isSelectable ? CGFloat(1.0) : CGFloat(0.3)
        return RowDisplayModel(text: text, opacity: opacity, accessoryType: accessoryType, isSelectable: isSelectable, targetController: .selectStopNavigationController)
    }

    fileprivate func configureSelectEndisplayModel() -> RowDisplayModel {
        var text: String = ""

        let accessoryType: CellDecoration
        let isSelectable: Bool
        if let _ = scheduleRequest?.selectedStart {
            accessoryType = .none
            isSelectable = true
            if let stopName = scheduleRequest?.selectedEnd?.stopName {
                text = stopName

            } else {
                text = SeptaString.SelectEnd
            }
        } else {
            if let transitMode = scheduleRequest?.transitMode {
                text = transitMode.endingStopName()
            }
            accessoryType = .none

            isSelectable = false
        }
        let opacity = isSelectable ? CGFloat(1.0) : CGFloat(0.3)
        return RowDisplayModel(text: text, opacity: opacity, accessoryType: accessoryType, isSelectable: isSelectable, targetController: .selectStopController)
    }

    func configureDisplayable(_ displayable: SingleStringDisplayable, atRow row: Int) {
        guard row < displayModel.count else { return }
        let rowModel = displayModel[row]
        displayable.setLabelText(rowModel.text)
        displayable.setTextOpacity(Float(rowModel.opacity))
        displayable.setAccessoryType(rowModel.accessoryType)
    }

    func configureBorder(_ cell: UITableViewCell, atRow row: Int) {
        guard row < displayModel.count else { return }
        let rowModel = displayModel[row]
        let layer = cell.contentView.layer
        layer.opacity = Float(rowModel.opacity)
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = SeptaColor.enabledCellBorder.cgColor
        layer.masksToBounds = false
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

    deinit {
        unsubscribe()
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
