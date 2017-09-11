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

    var trips = [NextToArriveTrip]()

    func newState(state: StoreSubscriberStateType) {
        trips = state
        delegate.viewModelUpdated()
    }

    deinit {
        unsubscribe()
    }

    func viewTitle() -> String {
        return scheduleRequest().transitMode.nextToArriveInfoDetailTitle()
    }
}

extension NextToArriveInfoViewModel { // Section Headers
    func configureSectionHeader(header: ConnectingSectionView) {
        guard let firstTrip = trips.first else { return }
        header.destinationLabel.text = firstTrip.startStop.routeName
        header.pillView.backgroundColor = transitMode().colorForPill()
    }
}

extension NextToArriveInfoViewModel { // Table View
    func numberOfSections() -> Int {

        return 1
    }

    func numberOfRows() -> Int {
        return trips.count
    }

    func cellIdAtIndexPath(_: IndexPath) -> String {
        return "noConnectionCell"
    }

    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        guard indexPath.row < trips.count, let cell = cell as? NoConnectionCell else { return }
        let trip = trips[indexPath.row]
        cell.startStopLabel.text = generateTimeString(trip: trip)
        cell.departingWhenLabel.text = generateTimeToDeparture(trip: trip)
        cell.onTimeLabel.text = generateOnTimeString(trip: trip)
        cell.onTimeLabel.textColor = generateOnTimeColor(trip: trip)
        cell.endStopLabel.text = generateLastStopName(trip: trip)
        cell.departingView.layer.borderColor = generateDepartingBoxColor(trip: trip)
    }

    func generateTimeString(trip: NextToArriveTrip) -> String? {

        return DateFormatters.formatDurationString(startDate: trip.startStop.departureTime, endDate: trip.startStop.arrivalTime)
    }

    func generateTimeToDeparture(trip: NextToArriveTrip) -> String? {
        return DateFormatters.formatTimeFromNow(date: trip.startStop.arrivalTime)
    }

    func generateOnTimeString(trip: NextToArriveTrip) -> String? {
        guard let tripDelayMinutes = trip.startStop.delayMinutes else { return "On Time" }
        let delayString = String(tripDelayMinutes)
        if tripDelayMinutes > 0 {
            return "\(delayString) min late"
        } else {
            return "On Time"
        }
    }

    func generateOnTimeColor(trip: NextToArriveTrip) -> UIColor {
        guard let tripDelayMinutes = trip.startStop.delayMinutes else { return SeptaColor.transitOnTime }

        if tripDelayMinutes > 0 {
            return SeptaColor.transitIsLate
        } else {
            return SeptaColor.transitOnTime
        }
    }

    func generateLastStopName(trip: NextToArriveTrip) -> String? {
        guard let lastStopName = trip.startStop.lastStopName else { return nil }

        return "to \(lastStopName)"
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
