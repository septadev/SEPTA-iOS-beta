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

class BaseNextToArriveInfoViewModel: AlertViewDelegate {
    enum CellIds: String {
        case noConnectionCell
        case connectionCell
        case noConnectionSectionHeader
    }

    var alerts: AlertsByTransitModeThenRoute { return store.state.alertState.alertDict }

    var groupedTripData = [[NextToArriveTrip]]() {
        didSet {
            delegate.viewModelUpdated()
        }
    }

    func firstTrip() -> NextToArriveTrip? {
        if let firstRoute = groupedTripData.first, let firstTrip = firstRoute.first {
            return firstTrip
        } else {
            return nil
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
        view.accessibilityLabel = firstTripInSection.startStop.routeName
        let alert = alerts[transitMode()]?[routeId]
        tripHeaderView.alertStackView.addAlert(alert)
        tripHeaderView.alertViewDelegate = self
        tripHeaderView.nextToArriveStop = firstTripInSection.startStop
        tripHeaderView.transitMode = transitMode()
    }

    func didTapAlertView(nextToArriveStop: NextToArriveStop, transitMode: TransitMode) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: {
            let action = NavigateToAlertDetailsFromNextToArrive(
                scheduleRequest: ScheduleRequest(transitMode: transitMode, selectedRoute: self.scheduleRequest().selectedRoute),
                nextToArriveStop: nextToArriveStop)
            store.dispatch(action)
        })
    }

    func configureSectionHeader(firstTripInSection: NextToArriveTrip, headerView: NoConnectionSectionHeader) {
        let routeId = firstTripInSection.startStop.routeId
        guard let tripHeaderView = headerView.tripHeaderView else { return }
        tripHeaderView.pillView.backgroundColor = Route.colorForRouteId(routeId, transitMode: transitMode())
        tripHeaderView.lineNameLabel.text = firstTripInSection.startStop.routeName
        tripHeaderView.accessibilityLabel = firstTripInSection.startStop.routeName
        tripHeaderView.alertViewDelegate = self
        tripHeaderView.nextToArriveStop = firstTripInSection.startStop
        tripHeaderView.transitMode = transitMode()
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
        tripView.startStopLabel.text = generateTimeString(stop: trip.startStop)
        tripView.departingWhenLabel.text = trip.startStop.generateTimeToDepartureString()
        tripView.onTimeLabel.text = trip.startStop.generateDelayString(prefixString: "")
        tripView.onTimeLabel.textColor = trip.startStop.generateOnTimeColor()
        tripView.endStopLabel.text = generateLastStopName(stop: trip.startStop)
        tripView.chevronView.isHidden = !trip.startStop.hasRealTimeData
        tripView.departingBox.layer.borderColor = trip.startStop.generateOnTimeColor().cgColor
        tripView.nextToArriveStop = trip.startStop

        if let onTimeText = tripView.onTimeLabel.text,
            let departingWhen = tripView.departingWhenLabel.text,
            let scheduledTime = tripView.startStopLabel.text,
            let endStopLabel = tripView.endStopLabel.text {
            tripView.accessibilityLabel = "\(endStopLabel).  On Time Status: \(onTimeText).  Departing: \(departingWhen).  Scheduled Depature and Arrival: \(scheduledTime)"
        }
    }

    func configureConnectionCell(cell: ConnectionCellDisplayable, forTrip trip: NextToArriveTrip) {

        let firstLegTripView = cell.startConnectionView.tripView!

        firstLegTripView.startStopLabel.text = generateTimeString(stop: trip.startStop)
        firstLegTripView.departingWhenLabel.text = trip.startStop.generateTimeToDepartureString()
        firstLegTripView.onTimeLabel.text = trip.startStop.generateDelayString(prefixString: "")
        firstLegTripView.onTimeLabel.textColor = trip.startStop.generateOnTimeColor()
        firstLegTripView.endStopLabel.text = generateLastStopName(stop: trip.startStop)
        firstLegTripView.chevronView.isHidden = !trip.startStop.hasRealTimeData
        firstLegTripView.departingBox.layer.borderColor = trip.startStop.generateOnTimeColor().cgColor
        firstLegTripView.nextToArriveStop = trip.startStop

        if let onTimeText = firstLegTripView.onTimeLabel.text,
            let departingWhen = firstLegTripView.departingWhenLabel.text,
            let scheduledTime = firstLegTripView.startStopLabel.text,
            let endStopLabel = firstLegTripView.endStopLabel.text {
            firstLegTripView.accessibilityLabel = "\(endStopLabel).  On Time Status: \(onTimeText).  Departing: \(departingWhen).  Scheduled Depature and Arrival: \(scheduledTime)"
        }

        let secondLegTripView = cell.endConnectionView.tripView!

        secondLegTripView.startStopLabel.text = generateTimeString(stop: trip.endStop)
        secondLegTripView.departingWhenLabel.text = trip.endStop.generateTimeToDepartureString()
        secondLegTripView.onTimeLabel.text = trip.endStop.generateDelayString(prefixString: "")
        secondLegTripView.onTimeLabel.textColor = trip.endStop.generateOnTimeColor()
        secondLegTripView.endStopLabel.text = generateLastStopName(stop: trip.endStop)
        secondLegTripView.chevronView.isHidden = !trip.endStop.hasRealTimeData
        secondLegTripView.departingBox.layer.borderColor = trip.endStop.generateOnTimeColor().cgColor
        secondLegTripView.nextToArriveStop = trip.endStop

        if let onTimeText = secondLegTripView.onTimeLabel.text,
            let departingWhen = secondLegTripView.departingWhenLabel.text,
            let scheduledTime = secondLegTripView.startStopLabel.text,
            let endStopLabel = secondLegTripView.endStopLabel.text {
            firstLegTripView.accessibilityLabel = "\(endStopLabel).  On Time Status: \(onTimeText).  Departing: \(departingWhen).  Scheduled Depature and Arrival: \(scheduledTime)"
        }

        let connectionStation = trip.connectionLocation?.stopName ?? ""
        cell.connectionLabel.text = "Connect @\(connectionStation)"

        styleTripHeaderView(tripHeaderView: cell.startConnectionView.tripHeaderView, forStop: trip.startStop, trip: trip)
        styleTripHeaderView(tripHeaderView: cell.endConnectionView.tripHeaderView, forStop: trip.endStop, trip: trip)
    }

    func styleTripHeaderView(tripHeaderView: TripHeaderView, forStop stop: NextToArriveStop, trip _: NextToArriveTrip) {
        tripHeaderView.pillView.backgroundColor = Route.colorForRouteId(stop.routeId, transitMode: transitMode())
        tripHeaderView.lineNameLabel.text = stop.routeName
        tripHeaderView.accessibilityLabel = stop.routeName
        tripHeaderView.alertViewDelegate = self
        tripHeaderView.nextToArriveStop = stop
        tripHeaderView.transitMode = transitMode()
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
}
