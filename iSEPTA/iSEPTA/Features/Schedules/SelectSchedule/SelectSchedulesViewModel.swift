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
}

protocol SchedulesViewModelDelegate: AnyObject {
    func formIsComplete(_ complete: Bool)
}

class SelectSchedulesViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest?
    var scheduleRequest: ScheduleRequest? {
        didSet {
            transitModeVar = scheduleRequest?.transitMode
        }
    }

    var transitModeVar: TransitMode?

    func transitMode() -> TransitMode {
        if let transitMode = transitModeVar {
            return transitMode
        } else {
            return .bus
        }
    }

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
        return transitMode().routeTitle()
    }

    fileprivate func configureSelectRouteDisplayModel() -> RowDisplayModel {
        var text = transitMode().selector()
        let isSelectable = true
        if let routeName = scheduleRequest?.selectedRoute?.routeShortName {
            text = routeName
        }
        return RowDisplayModel(text: text, shouldFillCell: false, isSelectable: isSelectable, targetController: .routesViewController)
    }

    fileprivate func configureSelectStartDisplayModel() -> RowDisplayModel {
        var text: String = ""

        let isSelectable: Bool
        if let _ = scheduleRequest?.selectedRoute {
            isSelectable = true
            if let startName = scheduleRequest?.selectedStart?.stopName {
                text = startName
            } else {
                text = transitMode().startingStopName()
            }
        } else {
            text = transitMode().startingStopName()
            isSelectable = false
        }
        return RowDisplayModel(text: text, shouldFillCell: true, isSelectable: isSelectable, targetController: .selectStopNavigationController)
    }

    fileprivate func configureSelectEndisplayModel() -> RowDisplayModel {
        var text: String = ""

        let isSelectable: Bool
        if let _ = scheduleRequest?.selectedStart {
            isSelectable = true
            if let stopName = scheduleRequest?.selectedEnd?.stopName {
                text = stopName
            } else {
                text = transitMode().endingStopName()
            }
        } else {
            text = transitMode().endingStopName()
            isSelectable = false
        }
        return RowDisplayModel(text: text, shouldFillCell: true, isSelectable: isSelectable, targetController: .selectStopController)
    }

    func configureDisplayable(_ displayable: SingleStringDisplayable, atRow row: Int) {
        guard row < displayModel.count else { return }
        let rowModel = displayModel[row]
        displayable.setLabelText(rowModel.text)
        displayable.setEnabled(rowModel.isSelectable)
        displayable.setShouldFill(rowModel.shouldFillCell)
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
