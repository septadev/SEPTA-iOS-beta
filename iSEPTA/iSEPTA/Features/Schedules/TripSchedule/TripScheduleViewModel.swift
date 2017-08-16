// Septa. 2017

import Foundation
import SeptaSchedule
import ReSwift

@objc class TripScheduleViewModel: NSObject, StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleState?
    @IBOutlet weak var tripScheduleViewController: UpdateableFromViewModel!

    var scheduleRequest: ScheduleRequest?
    private var availableTrips: [Trip]?

    var tripStops: (String, String)? {
        guard let scheduleRequest = scheduleRequest,
            let selectedStart = scheduleRequest.selectedStart,
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
                $0.scheduleState
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let scheduleState = state else { return }
        if let scheduleRequest = scheduleState.scheduleRequest {
            self.scheduleRequest = scheduleRequest
        }
        availableTrips = scheduleState.scheduleData?.availableTrips

        tripScheduleViewController?.viewModelUpdated()
    }

    deinit {
        store.unsubscribe(self)
    }
}
