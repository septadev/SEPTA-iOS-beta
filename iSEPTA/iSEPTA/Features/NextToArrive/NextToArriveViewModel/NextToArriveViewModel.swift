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

typealias CellModel = NextToArriveRowDisplayModel

class NextToArriveViewModel: NSObject, StoreSubscriber {

    @IBOutlet weak var nextToArriveViewController: UpdateableFromViewModel?
    @IBOutlet weak var schedulesDelegate: SchedulesViewModelDelegate?
    typealias StoreSubscriberStateType = ScheduleRequest
    var scheduleRequest: ScheduleRequest?
    var transitMode: TransitMode!

    var targetForScheduleAction: TargetForScheduleAction { return store.state.targetForScheduleActions() }

    fileprivate var selectRouteRowDisplayModel: NextToArriveRowDisplayModel?
    fileprivate var selectStartRowDisplayModel: NextToArriveRowDisplayModel?
    fileprivate var selectEndRowDisplayModel: NextToArriveRowDisplayModel?
    fileprivate var displayModel = [NextToArriveRowDisplayModel]()

    func newState(state: StoreSubscriberStateType) {
        scheduleRequest = state

        transitMode = state.transitMode
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
        return transitMode.routeTitle()
    }

    func scheduleTitle() -> String {
        return transitMode.nextToArriveTitle()
    }

    deinit {
        unsubscribe()
    }
}

// MARK: -  Loading table view cells
extension NextToArriveViewModel {

    func shouldDisplayBlankSectionHeaderForSection(_ section: Int) -> Bool {

        if section == 0 && transitMode != .rail {
            return false
        } else {
            return true
        }
    }

    func heightForSectionHeader(atRow row: Int) -> CGFloat {
        switch row {
        case 0:
            return transitMode == .rail ? 10 : 37
        case 1, 3: return 21
        case 2: return 11
        default: return 0
        }
    }

    func numberOfRows() -> Int {
        return 4
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
            cell.label!.font = changeFontWeight(font: cell.label!.font, weight: rowModel.fontWeight)
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

    func changeFontWeight(font currentFont: UIFont, weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: currentFont.pointSize, weight: weight)
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
        //    insertDummyScheduleRequest()
        subscribe()
    }

    //    func insertDummyScheduleRequest() {
    //        let deadlineTime = DispatchTime.now() + .seconds(3)
    //        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
    //            let action = InsertNextToArriveScheduleRequest(scheduleRequest: self.scheduleRequest_rail)
    //            store.dispatch(action)
    //        }
    //    }

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
