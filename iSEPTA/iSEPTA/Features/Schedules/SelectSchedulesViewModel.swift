// Septa. 2017

import Foundation
import ReSwift
import UIKit

fileprivate enum Row: Int {
    case selectRoute
    case selectStart
    case selectEnd

    static func rows() -> [Row] {
        return [.selectRoute, .selectStart, .selectEnd]
    }
}

fileprivate struct RowDisplayModel {
    let text: String
    let color: UIColor
    let enabled: Bool
}

class SelectSchedulesViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest?
    var scheduleRequest: ScheduleRequest?
    weak var delegate: UpdateableFromViewModel?
    fileprivate var displayModel = [RowDisplayModel]()

    init(delegate: UpdateableFromViewModel) {
        self.delegate = delegate
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    func filterSubscription(state: AppState) -> ScheduleRequest? {
        return state.scheduleState.scheduleRequest
    }

    func newState(state: StoreSubscriberStateType) {
        scheduleRequest = state
        delegate?.viewModelUpdated()
    }

    func buildDisplayModel() {
        var title: String = ""
        var enabled: Bool = false
        var color: UIColor = UIColor.clear
        displayModel = Row.rows().map { row in

            switch row {
            case .selectRoute:
                if let routeName = scheduleRequest?.selectedRoute?.routeShortName {
                    title = routeName
                    color = UIColor.black
                    enabled = true
                } else {
                    title = String.SelectRoute
                    enabled = true
                    color = UIColor.gray
                }
            case .selectStart:
                if let startName = scheduleRequest?.selectedStart?.stopName {
                    title = startName
                    color = UIColor.black
                    enabled = true
                } else {
                    title = String.SelectStart
                    enabled = true
                    color = UIColor.gray
                }

            case .selectEnd:
                if let endName = scheduleRequest?.selectedEnd?.stopName {
                    title = endName
                    color = UIColor.black
                    enabled = false
                } else {
                    title = String.SelectEnd
                    enabled = true
                    color = UIColor.gray
                }
            }
            return RowDisplayModel(text: title, color: color, enabled: enabled)
        }
    }

    func configureDisplayable(_ displayable: SingleStringDisplayable, atRow row: Int) {
        guard row < displayModel.count else { return }
        let rowModel = displayModel[row]
        displayable.setLabelText(text: rowModel.text)
        displayable.setTextColor(color: rowModel.color)
    }

    func canCellBeSelected(atRow row: Int) -> Bool {
        guard row < displayModel.count else { return false }
        return displayModel[row].enabled
    }

    func rowSelected(_: Int) {
        // Fire off the action
    }

    deinit {
        store.unsubscribe(self)
    }
}
