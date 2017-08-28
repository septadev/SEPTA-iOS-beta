//
//  SelectAddressRelativeStopViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import UIKit
import ReSwift
import CoreLocation

struct StopWithDistance {
    let stop: Stop
    let distanceString: String
    let distanceMeasurement: CLLocationDistance

    init(stop: Stop, distanceMeasurement: CLLocationDistance, distanceString: String) {
        self.stop = stop
        self.distanceMeasurement = distanceMeasurement
        self.distanceString = distanceString
    }
}

class SelectAddressRelativeStopViewModel: NSObject, StoreSubscriber, UITableViewDataSource, UITableViewDelegate {
    typealias StoreSubscriberStateType = ScheduleStopEdit?
    let cellId = "relativeStopCell"
    var stopToEdit: StopToSelect?
    @IBOutlet weak var selectStopViewController: UpdateableFromViewModel?

    var stopsWithDistance = [StopWithDistance]()

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

        guard let stopToEdit = stopToEdit, indexPath.row < stopsWithDistance.count else { return }
        let stopWithDistance = stopsWithDistance[indexPath.row]
        if stopToEdit == .starts {
            let action = TripStartSelected(selectedStart: stopWithDistance.stop)
            store.dispatch(action)
        } else {
            let action = TripEndSelected(selectedEnd: stopWithDistance.stop)
            store.dispatch(action)
        }
        let dismissAction = DismissModal(navigationController: .schedules, description: "Stop should be dismissed")
        store.dispatch(dismissAction)
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.scheduleState.scheduleStopEdit
            }.skipRepeats { $0 == $1 }
        }
    }

    override func awakeFromNib() {
        subscribe()
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }

    var measurementFormatter: MeasurementFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.positiveFormat = "0.00"
        let formatter = MeasurementFormatter()
        formatter.numberFormatter = numberFormatter

        formatter.unitStyle = .short
        return formatter

    }()

    func newState(state: StoreSubscriberStateType) {
        stopToEdit = state?.stopToEdit
        var optionalStops: [Stop]?
        if state?.stopToEdit == .starts {
            optionalStops = store.state.scheduleState.scheduleData?.availableStarts
        } else {
            optionalStops = store.state.scheduleState.scheduleData?.availableStops
        }

        guard let stops = optionalStops else { return }

        if let placemark = state?.selectedAddress?.placemark, let location = placemark.location {

            let unsortedStopsWithDistance: [StopWithDistance] = stops.map { stop in

                let stopCoordinates = CLLocation(latitude: stop.stopLatitude, longitude: stop.stopLongitude)
                let distanceInMeters = stopCoordinates.distance(from: location)
                let metersMeasurement = Measurement(value: distanceInMeters, unit: UnitLength.meters)
                let milesMeasurement = metersMeasurement.converted(to: UnitLength.miles)
                let measurementString = measurementFormatter.string(from: milesMeasurement)
                return StopWithDistance(stop: stop, distanceMeasurement: distanceInMeters, distanceString: measurementString)
            }

            stopsWithDistance = unsortedStopsWithDistance.sorted { $0.distanceMeasurement < $1.distanceMeasurement }
            selectStopViewController?.viewModelUpdated()
        }
    }

    deinit {
        unsubscribe()
    }
}
