//
//  SelectAddressRelativeStopViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreLocation
import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class SelectAddressRelativeStopViewModel: NSObject, StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleStopEdit?

    @IBOutlet var selectStopViewController: UpdateableFromViewModel?

    var targetForScheduleAction: TargetForScheduleAction! { return store.state.currentTargetForScheduleActions() }
    var stopsWithDistance = [StopWithDistance]()
    let cellId = "relativeStopCell"
    var scheduleStopEdit = ScheduleStopEdit()

    func newState(state: StoreSubscriberStateType) {
        guard let state = state else { return }
        scheduleStopEdit = state
        let stops = retrieveStops()

        if let placemark = state.selectedAddress?.placemark, let location = placemark.location {
            let unsortedStopsWithDistance: [StopWithDistance] = stops.map { stop in

                let stopCoordinates = CLLocation(latitude: stop.stopLatitude, longitude: stop.stopLongitude)
                let distanceInMeters = stopCoordinates.distance(from: location)
                let distanceString = NumberFormatters.metersToMilesFormatter.string(from: NSNumber(value: distanceInMeters)) ?? ""
                return StopWithDistance(stop: stop, distanceMeasurement: distanceInMeters, distanceString: distanceString)
            }

            stopsWithDistance = unsortedStopsWithDistance.sorted { $0.distanceMeasurement < $1.distanceMeasurement }
            selectStopViewController?.viewModelUpdated()
        }
    }

    func retrieveStops() -> [Stop] {
        var stops = [Stop]()
        guard let scheduleData = retrieveScheduleData() else { return stops }
        if scheduleStopEdit.stopToEdit == .starts {
            stops = scheduleData.availableStarts.stops
        } else {
            stops = scheduleData.availableStops.stops
        }
        return stops
    }

    func retrieveScheduleData() -> ScheduleData? {
        if store.state.currentTargetForScheduleActions() == .schedules {
            return store.state.scheduleState.scheduleData
        } else if store.state.currentTargetForScheduleActions() == .nextToArrive {
            return store.state.nextToArriveState.scheduleState.scheduleData

        } else {
            return nil
        }
    }

    deinit {
        unsubscribe()
    }
}

extension SelectAddressRelativeStopViewModel: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return stopsWithDistance.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SelectStopCell else { return UITableViewCell() }

        configureCell(cell, atRow: indexPath.row)
        return cell
    }

    func configureCell(_ cell: SelectStopCell, atRow row: Int) {
        guard row < stopsWithDistance.count else { return }
        let stopWithDistance = stopsWithDistance[row]

        cell.setLabelText(stopWithDistance.stop.stopName)
        cell.distanceLabel.text = stopWithDistance.distanceString
        cell.distanceLabel.isHidden = false
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < stopsWithDistance.count else { return }
        let stopWithDistance = stopsWithDistance[indexPath.row]
        if scheduleStopEdit.stopToEdit == .starts {
            let action = TripStartSelected(targetForScheduleAction: targetForScheduleAction, selectedStart: stopWithDistance.stop)
            store.dispatch(action)
        } else {
            let action = TripEndSelected(targetForScheduleAction: targetForScheduleAction, selectedEnd: stopWithDistance.stop)
            store.dispatch(action)
        }
        let dismissAction = DismissModal(description: "Stop should be dismissed")
        store.dispatch(dismissAction)
    }
}

extension SelectAddressRelativeStopViewModel: SubscriberUnsubscriber {
    override func awakeFromNib() {
        subscribe()
    }

    func subscribe() {
        if targetForScheduleAction == .schedules {
            store.subscribe(self) {
                $0.select {
                    $0.scheduleState.scheduleStopEdit
                }.skipRepeats { $0 == $1 }
            }
        } else if targetForScheduleAction == .nextToArrive {
            store.subscribe(self) {
                $0.select {
                    $0.nextToArriveState.scheduleState.scheduleStopEdit
                }.skipRepeats { $0 == $1 }
            }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
