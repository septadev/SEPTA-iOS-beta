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

class BaseNextToArriveInfoViewModel {
    enum CellIds: String {
        case noConnectionCell
        case connectionCell
        case noConnectionSectionHeader
    }

    let alerts = store.state.alertState.alertDict
    var groupedTripData = [[NextToArriveTrip]]() {
        didSet {
            delegate.viewModelUpdated()
        }
    }

    func scheduleRequest() -> ScheduleRequest {
        return store.state.targetForScheduleActionsScheduleRequest()
    }

    func transitMode() -> TransitMode {
        return scheduleRequest().transitMode
    }

    var delegate: UpdateableFromViewModel! {
        didSet {
            subscribe()
        }
    }

    func subscribe() {}

    func registerViews(tableView: UITableView) {
        tableView.register(UINib(nibName: "NoConnectionCell", bundle: nil), forCellReuseIdentifier: CellIds.noConnectionCell.rawValue)
        tableView.register(UINib(nibName: "ConnectionCell", bundle: nil), forCellReuseIdentifier: CellIds.connectionCell.rawValue)
        tableView.register(NoConnectionUIHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: CellIds.noConnectionSectionHeader.rawValue)
    }
}

extension BaseNextToArriveInfoViewModel { // Section Headers

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

    func configureSectionHeader(view: UIView, forSection section: Int) {
        guard section < groupedTripData.count,
            let firstTripInSection = groupedTripData[section].first,
            let headerView = view as? NoConnectionUIHeaderFooterViewDisplayable,
            let noConnectionHeaderView = headerView.noConnectionSectionHeader,
            let tripHeaderView = noConnectionHeaderView.tripHeaderView else { return }
        let routeId = firstTripInSection.startStop.routeId
        tripHeaderView.pillView.backgroundColor = Route.colorForRouteId(routeId, transitMode: transitMode())
        tripHeaderView.lineNameLabel.text = firstTripInSection.startStop.routeName
        let alert = alerts[transitMode()]?[routeId]
        tripHeaderView.alertStackView.addAlert(alert)
    }

    func configureSectionHeader(firstTripInSection: NextToArriveTrip, headerView: NoConnectionSectionHeader) {
        let routeId = firstTripInSection.startStop.routeId
        guard let tripHeaderView = headerView.tripHeaderView else { return }
        tripHeaderView.pillView.backgroundColor = Route.colorForRouteId(routeId, transitMode: transitMode())
        tripHeaderView.lineNameLabel.text = firstTripInSection.startStop.routeName
        let alert = alerts[transitMode()]?[routeId]
        tripHeaderView.alertStackView.addAlert(alert)
    }
}

extension BaseNextToArriveInfoViewModel { // Table View

    func numberOfRows(forSection section: Int) -> Int {
        guard section < groupedTripData.count else { return 0 }
        return groupedTripData[section].count
    }

    func cellIdAtIndexPath(_ indexPath: IndexPath) -> String {
        guard indexPath.section < groupedTripData.count, indexPath.row < groupedTripData[indexPath.section].count else { return CellIds.noConnectionCell.rawValue }
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

    func configureCell(_ cell: UIView, atIndexPath indexPath: IndexPath) {
        guard indexPath.section < groupedTripData.count, indexPath.row < groupedTripData[indexPath.section].count else { return }
        let trip = groupedTripData[indexPath.section][indexPath.row]
        switch cell {
        case let cell as NoConnectionCellDisplayable:
            configureNoConnectionCell(cell: cell, forTrip: trip)
        case let cell as ConnectionCellDisplayable:
            configureConnectionCell(cell: cell, forTrip: trip)
        default:break
        }
    }

    func configureNoConnectionCell(cell: NoConnectionCellDisplayable, forTrip trip: NextToArriveTrip) {
        let tripView = cell.tripView!
        configureTripView(tripView: tripView, forTrip: trip)
    }

    func configureTripView(tripView: TripView, forTrip trip: NextToArriveTrip) {
        let hasVehicleLocation = trip.vehicleLocation.firstLegLocation != nil
        tripView.startStopLabel.text = generateTimeString(stop: trip.startStop)
        tripView.departingWhenLabel.text = generateTimeToDeparture(stop: trip.startStop)
        tripView.onTimeLabel.text = generateOnTimeString(stop: trip.startStop, hasVehicleLocation: hasVehicleLocation)
        tripView.onTimeLabel.textColor = generateOnTimeColor(stop: trip.startStop, hasVehicleLocation: hasVehicleLocation)
        tripView.endStopLabel.text = generateLastStopName(stop: trip.startStop)
        tripView.departingBox.layer.borderColor = generateDepartingBoxColor(stop: trip.startStop)
    }

    func configureConnectionCell(cell: ConnectionCellDisplayable, forTrip trip: NextToArriveTrip) {

        let firstLegTripView = cell.startConnectionView.tripView!
        let startHasVehicleLocation = trip.vehicleLocation.firstLegLocation != nil
        firstLegTripView.startStopLabel.text = generateTimeString(stop: trip.startStop)
        firstLegTripView.departingWhenLabel.text = generateTimeToDeparture(stop: trip.startStop)
        firstLegTripView.onTimeLabel.text = generateOnTimeString(stop: trip.startStop, hasVehicleLocation: startHasVehicleLocation)
        firstLegTripView.onTimeLabel.textColor = generateOnTimeColor(stop: trip.startStop, hasVehicleLocation: startHasVehicleLocation)
        firstLegTripView.endStopLabel.text = generateLastStopName(stop: trip.startStop)
        firstLegTripView.departingBox.layer.borderColor = generateDepartingBoxColor(stop: trip.startStop)

        let secondLegTripView = cell.endConnectionView.tripView!
        let endHasVehicleLocation = trip.vehicleLocation.secondLegLocation != nil
        secondLegTripView.startStopLabel.text = generateTimeString(stop: trip.endStop)
        secondLegTripView.departingWhenLabel.text = generateTimeToDeparture(stop: trip.endStop)
        secondLegTripView.onTimeLabel.text = generateOnTimeString(stop: trip.endStop, hasVehicleLocation: endHasVehicleLocation)
        secondLegTripView.onTimeLabel.textColor = generateOnTimeColor(stop: trip.endStop, hasVehicleLocation: endHasVehicleLocation)
        secondLegTripView.endStopLabel.text = generateLastStopName(stop: trip.endStop)
        secondLegTripView.departingBox.layer.borderColor = generateDepartingBoxColor(stop: trip.endStop)

        let connectionStation = trip.connectionLocation?.stopName ?? ""
        cell.connectionLabel.text = "Connect @\(connectionStation)"

        styleTripHeaderView(tripHeaderView: cell.startConnectionView.tripHeaderView, forStop: trip.startStop)
        styleTripHeaderView(tripHeaderView: cell.endConnectionView.tripHeaderView, forStop: trip.endStop)
    }

    func styleTripHeaderView(tripHeaderView: TripHeaderView, forStop stop: NextToArriveStop) {
        tripHeaderView.pillView.backgroundColor = Route.colorForRouteId(stop.routeId, transitMode: transitMode())
        tripHeaderView.lineNameLabel.text = stop.routeName
        let alert = alerts[transitMode()]?[stop.routeId]
        tripHeaderView.alertStackView.addAlert(alert)
    }

    func generateTimeString(stop: NextToArriveStop) -> String? {
        let sortedDates = [stop.arrivalTime, stop.departureTime].sorted()
        return DateFormatters.formatDurationString(startDate: sortedDates[0], endDate: sortedDates[1])
    }

    func generateTimeString(trip: NextToArriveTrip) -> String? {
        let sortedDates = [trip.startStop.arrivalTime, trip.endStop.arrivalTime].sorted()
        return DateFormatters.formatDurationString(startDate: sortedDates[0], endDate: sortedDates[1])
    }

    func generateTimeToDeparture(stop: NextToArriveStop) -> String? {
        let sortedDates = [stop.arrivalTime, stop.departureTime].sorted()
        return DateFormatters.formatTimeFromNow(date: sortedDates[0])
    }

    func generateOnTimeString(stop: NextToArriveStop, hasVehicleLocation: Bool) -> String? {
        guard let tripDelayMinutes = stop.delayMinutes else { return "Scheduled" }
        let delayString = String(tripDelayMinutes)
        if tripDelayMinutes > 0 {
            return "\(delayString) min late"
        } else if hasVehicleLocation {
            return "On Time"
        } else {
            return "Scheduled"
        }
    }

    func generateOnTimeColor(stop: NextToArriveStop, hasVehicleLocation: Bool) -> UIColor {
        guard let tripDelayMinutes = stop.delayMinutes else { return SeptaColor.transitIsScheduled }

        if tripDelayMinutes > 0 {
            return SeptaColor.transitIsLate
        } else if hasVehicleLocation {
            return SeptaColor.transitOnTime
        } else {
            return SeptaColor.transitIsScheduled
        }
    }

    func generateLastStopName(stop: NextToArriveStop) -> String? {
        guard let lastStopName = stop.lastStopName, let tripId = stop.tripId else { return nil }
        if transitMode() == .rail {
            return "#\(tripId) to \(lastStopName)"
        } else if let tripIdInt = stop.tripId {
            return "#\(String(tripIdInt)) to \(lastStopName)"
        } else {
            return "to \(lastStopName)"
        }
    }

    func generateDepartingBoxColor(stop: NextToArriveStop) -> CGColor {
        guard let tripDelayMinutes = stop.delayMinutes else { return SeptaColor.transitOnTime.cgColor }

        if tripDelayMinutes > 0 {
            return SeptaColor.transitIsLate.cgColor
        } else {
            return SeptaColor.transitOnTime.cgColor
        }
    }
}
