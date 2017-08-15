// Septa. 2017

import Foundation
import SeptaSchedule

class TripScheduleViewModel {
    var trips = [Trip]()

    func makeDisplayable(displayable: ScheduleDisplayable, atRow row: Int) {
        typealias formatters = DateFormatters
        let trip = trips[row]
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
}
