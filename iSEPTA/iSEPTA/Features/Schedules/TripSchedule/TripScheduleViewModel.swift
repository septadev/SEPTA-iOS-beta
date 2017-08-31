// Septa. 2017

import Foundation
import SeptaSchedule
import ReSwift

@objc class TripScheduleViewModel: NSObject, StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleTripState
    @IBOutlet weak var tripScheduleViewController: UpdateableFromViewModel!

    var scheduleRequest = store.state.scheduleState.scheduleRequest
    private var availableTrips: [Trip]? {
        didSet {
            scheduleRequest = store.state.scheduleState.scheduleRequest
            tripScheduleViewController?.viewModelUpdated()
        }
    }

    var tripStops: (String, String)? {
        guard let selectedStart = scheduleRequest.selectedStart,
            let selectedEnd = scheduleRequest.selectedEnd else { return nil }
        return (selectedStart.stopName, selectedEnd.stopName)
    }

    func numberOfRows() -> Int {
        guard let availableTrips = availableTrips else { return 0 }
        return availableTrips.count
    }

    func makeTripDisplayable(displayable: ScheduleDisplayable, atRow row: Int) {
        guard let availableTrips = availableTrips else { return }
        typealias formatters = DateFormatters
        let trip = availableTrips[row]
        if let departureDate = trip.departureDate,

            let depatureString = formatters.timeFormatter.string(for: departureDate),
            let arrivalDate = trip.arrivalDate,
            let arrivalString = formatters.timeFormatter.string(for: arrivalDate),
            let durationString = formatters.durationFormatter.string(for: trip.tripDuration) {

            // displayable.setTripText(text: String(trip.tripId))
            displayable.setDepartText(text: depatureString)
            displayable.setArriveText(text: arrivalString)
            displayable.setDurationText(text: durationString)
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.scheduleState.scheduleData.availableTrips
            }.skipRepeats { $0 == $1 }
        }
    }

    func newState(state: StoreSubscriberStateType) {

        if state.updateMode == .loadValues && state.trips.count == 0 {
            tripScheduleViewController?.displayErrorMessage(message: SeptaString.NoTripsAvailable)
            tripScheduleViewController?.updateActivityIndicator(animating: false)
        } else if state.updateMode == .clearValues {
            tripScheduleViewController?.updateActivityIndicator(animating: true)
        } else if state.updateMode == .loadValues && state.trips.count > 0 {
            tripScheduleViewController?.updateActivityIndicator(animating: false)
        }
        availableTrips = state.trips
    }

    deinit {
        store.unsubscribe(self)
    }
}
