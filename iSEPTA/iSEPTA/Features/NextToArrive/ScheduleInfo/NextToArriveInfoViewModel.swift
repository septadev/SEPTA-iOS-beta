//
//  NextToArriveInfoViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit
import SeptaSchedule

class NextToArriveInfoViewModel: StoreSubscriber {
    enum CellIds: String {
        case noConnectionCell
        case connectionCell
        case noConnectionSectionHeader
    }

    let alerts = store.state.alertState.alertDict
    var groupedTripData = [[NextToArriveTrip]]()

    typealias StoreSubscriberStateType = [NextToArriveTrip]

    func scheduleRequest() -> ScheduleRequest {
        return store.state.nextToArriveState.scheduleState.scheduleRequest
    }

    func transitMode() -> TransitMode {
        return scheduleRequest().transitMode
    }

    var delegate: UpdateableFromViewModel! {
        didSet {
            subscribe()
        }
    }

    func newState(state: StoreSubscriberStateType) {
        groupedTripData = NextToArriveGrouper.buildNextToArriveTripSections(trips: state)

        delegate.viewModelUpdated()
    }

    deinit {
        unsubscribe()
    }

    func viewTitle() -> String {
        return scheduleRequest().transitMode.nextToArriveInfoDetailTitle()
    }

    func registerViews(tableView: UITableView) {
        tableView.register(UINib(nibName: "NoConnectionCell", bundle: nil), forCellReuseIdentifier: CellIds.noConnectionCell.rawValue)
        tableView.register(UINib(nibName: "ConnectionCell", bundle: nil), forCellReuseIdentifier: CellIds.connectionCell.rawValue)
        tableView.register(NoConnectionUIHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: CellIds.noConnectionSectionHeader.rawValue)
    }
}

extension NextToArriveInfoViewModel { // Section Headers

    func numberOfSections() -> Int {
        return groupedTripData.count
    }

    func viewIdForSection(_ section: Int) -> String? {
        guard section < groupedTripData.count,
            let firstTripInSection = groupedTripData[section].first else { return nil }

        if tripHasConnection(trip: firstTripInSection) {
            return nil
        } else {
            return CellIds.noConnectionSectionHeader.rawValue
        }
    }

    func heightForHeaderInSection(_ section: Int) -> CGFloat {
        guard section < groupedTripData.count,
            let firstTripInSection = groupedTripData[section].first else { return 0 }

        if tripHasConnection(trip: firstTripInSection) {
            return 0
        } else {
            return 35
        }
    }

    func configureSectionHeader(view: UITableViewHeaderFooterView, forSection section: Int) {
        guard section < groupedTripData.count,
            let firstTripInSection = groupedTripData[section].first,
            let headerView = view as? NoConnectionUIHeaderFooterView,
            let noConnectionHeaderView = headerView.noConnectionSectionHeader,
            let tripHeaderView = noConnectionHeaderView.tripHeaderView else { return }

        tripHeaderView.pillView.backgroundColor = transitMode().colorForPill()
        tripHeaderView.lineNameLabel.text = firstTripInSection.startStop.routeName
        let alert = alerts[transitMode()]?[firstTripInSection.startStop.routeId]
        tripHeaderView.alertStackView.addAlert(alert)
    }
}

extension NextToArriveInfoViewModel { // Table View

    func numberOfRows(forSection section: Int) -> Int {
        guard section < groupedTripData.count else { return 0 }
        return groupedTripData[section].count
    }

    func cellIdAtIndexPath(_ indexPath: IndexPath) -> String {
        let trip = groupedTripData[indexPath.section][indexPath.row]

        if tripHasConnection(trip: trip) {
            return CellIds.connectionCell.rawValue
        } else {
            return CellIds.noConnectionCell.rawValue
        }
    }

    func tripHasConnection(trip: NextToArriveTrip) -> Bool {
        if let _ = trip.connectionLocation {
            return true
        } else {
            return false
        }
    }

    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        guard indexPath.section < groupedTripData.count, indexPath.row < groupedTripData[indexPath.section].count else { return }
        let trip = groupedTripData[indexPath.section][indexPath.row]
        switch cell {
        case let cell as NoConnectionCell:
            configureNoConnectionCell(cell: cell, forTrip: trip)
        case let cell as ConnectionCell:
            configureConnectionCell(cell: cell)
        default:break
        }
    }

    func configureNoConnectionCell(cell: NoConnectionCell, forTrip trip: NextToArriveTrip) {
        let tripView = cell.tripView!
        tripView.startStopLabel.text = generateTimeString(trip: trip)
        tripView.departingWhenLabel.text = generateTimeToDeparture(trip: trip)
        tripView.onTimeLabel.text = generateOnTimeString(trip: trip)
        tripView.onTimeLabel.textColor = generateOnTimeColor(trip: trip)
        tripView.endStopLabel.text = generateLastStopName(trip: trip)
        tripView.departingBox.layer.borderColor = generateDepartingBoxColor(trip: trip)
    }

    func configureConnectionCell(cell _: ConnectionCell) {
    }

    func generateTimeString(trip: NextToArriveTrip) -> String? {
        if tripHasConnection(trip: trip) {
            return DateFormatters.formatDurationString(startDate: trip.startStop.departureTime, endDate: trip.startStop.arrivalTime)
        } else {
            return DateFormatters.formatDurationString(startDate: trip.startStop.departureTime, endDate: trip.endStop.arrivalTime)
        }
    }

    func generateTimeToDeparture(trip: NextToArriveTrip) -> String? {
        return DateFormatters.formatTimeFromNow(date: trip.startStop.arrivalTime)
    }

    func generateOnTimeString(trip: NextToArriveTrip) -> String? {
        guard let tripDelayMinutes = trip.startStop.delayMinutes else { return "Scheduled" }
        let delayString = String(tripDelayMinutes)
        if tripDelayMinutes > 0 {
            return "\(delayString) min late"
        } else if let _ = trip.vehicleLocation.firstLegLocation {
            return "On Time"
        } else {
            return "Scheduled"
        }
    }

    func generateOnTimeColor(trip: NextToArriveTrip) -> UIColor {
        guard let tripDelayMinutes = trip.startStop.delayMinutes else { return SeptaColor.transitIsScheduled }

        if tripDelayMinutes > 0 {
            return SeptaColor.transitIsLate
        } else if let _ = trip.vehicleLocation.firstLegLocation {
            return SeptaColor.transitOnTime
        } else {
            return SeptaColor.transitIsScheduled
        }
    }

    func generateLastStopName(trip: NextToArriveTrip) -> String? {
        guard let lastStopName = trip.startStop.lastStopName else { return nil }
        if transitMode() == .rail {
            return "#\(trip) to \(lastStopName)"
        } else if let tripIdInt = trip.startStop.tripId {
            return "#\(String(tripIdInt)) to \(lastStopName)"
        } else {
            return "to \(lastStopName)"
        }
    }

    func generateDepartingBoxColor(trip: NextToArriveTrip) -> CGColor {
        guard let tripDelayMinutes = trip.startStop.delayMinutes else { return SeptaColor.transitOnTime.cgColor }

        if tripDelayMinutes > 0 {
            return SeptaColor.transitIsLate.cgColor
        } else {
            return SeptaColor.transitOnTime.cgColor
        }
    }
}

extension NextToArriveInfoViewModel: SubscriberUnsubscriber {
    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.nextToArriveState.nextToArriveTrips
            }.skipRepeats { $0 == $1 }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
