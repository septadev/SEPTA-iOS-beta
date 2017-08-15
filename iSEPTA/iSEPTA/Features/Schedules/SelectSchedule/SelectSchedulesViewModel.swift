// Septa. 2017

import Foundation
import ReSwift
import UIKit

fileprivate struct RowDisplayModel {
    let text: String
    let color: UIColor
    let accessoryType: CellDecoration
    let isSelectable: Bool
    let targetController: ViewController
}

class SelectSchedulesViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest?
    var scheduleRequest: ScheduleRequest?
    weak var delegate: UpdateableFromViewModel?

    fileprivate var selectRouteRowDisplayModel: RowDisplayModel?
    fileprivate var selectStartRowDisplayModel: RowDisplayModel?
    fileprivate var selectEndRowDisplayModel: RowDisplayModel?
    fileprivate var displayModel = [RowDisplayModel]()

    var onlyOneRouteAvailable: Bool = false

    init(delegate: UpdateableFromViewModel) {
        self.delegate = delegate
    }

    func subscribe() {
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    func filterSubscription(state: AppState) -> ScheduleRequest? {
        return state.scheduleState.scheduleRequest
    }

    func newState(state: StoreSubscriberStateType) {
        scheduleRequest = state
        buildDisplayModel()
        delegate?.viewModelUpdated()
    }

    func buildDisplayModel() {

        onlyOneRouteAvailable = scheduleRequest?.onlyOneRouteAvailable ?? false

        displayModel = [
            configureSelectRouteDisplayModel(),
            configureSelectStartDisplayModel(),
            configureSelectEndisplayModel(),
        ]
    }

    fileprivate func configureSelectRouteDisplayModel() -> RowDisplayModel {
        let text: String
        if let routeName = scheduleRequest?.selectedRoute?.routeLongName {
            text = routeName
        } else {
            if let routeTitle = scheduleRequest?.transitMode?.selectRouteTitle() {
                text = routeTitle
            } else {
                text = SeptaString.SelectRoute
            }
        }

        let accessoryType = onlyOneRouteAvailable ? CellDecoration.none : CellDecoration.disclosureIndicator
        let color = SeptaColor.enabledText
        let isSelectable = !onlyOneRouteAvailable
        return RowDisplayModel(text: text, color: color, accessoryType: accessoryType, isSelectable: isSelectable, targetController: .routesViewController)
    }

    fileprivate func configureSelectStartDisplayModel() -> RowDisplayModel {
        let text: String
        let color: UIColor
        let accessoryType: CellDecoration
        let isSelectable: Bool
        if let _ = scheduleRequest?.selectedRoute {
            accessoryType = .disclosureIndicator
            isSelectable = true
            if let startName = scheduleRequest?.selectedStart?.stopName {
                text = startName
                color = SeptaColor.enabledText
            } else {
                text = SeptaString.SelectStart
                color = SeptaColor.disabledText
            }
        } else {
            text = SeptaString.SelectStart
            color = SeptaColor.disabledText
            accessoryType = .none
            isSelectable = false
        }
        return RowDisplayModel(text: text, color: color, accessoryType: accessoryType, isSelectable: isSelectable, targetController: .selectStopNavigationController)
    }

    fileprivate func configureSelectEndisplayModel() -> RowDisplayModel {
        let text: String
        let color: UIColor
        let accessoryType: CellDecoration
        let isSelectable: Bool
        if let _ = scheduleRequest?.selectedStart {
            accessoryType = .disclosureIndicator
            isSelectable = true
            if let stopName = scheduleRequest?.selectedEnd?.stopName {
                text = stopName
                color = SeptaColor.enabledText
            } else {
                text = SeptaString.SelectEnd
                color = SeptaColor.disabledText
            }
        } else {
            text = SeptaString.SelectEnd
            accessoryType = .none
            color = SeptaColor.disabledText
            isSelectable = false
        }
        return RowDisplayModel(text: text, color: color, accessoryType: accessoryType, isSelectable: isSelectable, targetController: .selectStopController)
    }

    func configureDisplayable(_ displayable: SingleStringDisplayable, atRow row: Int) {
        guard row < displayModel.count else { return }
        let rowModel = displayModel[row]
        displayable.setLabelText(rowModel.text)
        displayable.setTextColor(rowModel.color)
        displayable.setAccessoryType(rowModel.accessoryType)
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
