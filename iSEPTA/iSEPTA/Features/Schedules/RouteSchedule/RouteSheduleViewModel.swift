// SEPTA.org, created on 8/1/17.

import Foundation
import SeptaSchedule

class RouteScheduleViewModel {
    let routeType: RouteType
    let route: Route
    let routeStops: RouteStops
    var scheduleType: ScheduleType = .weekday
    var trips = [Trip]()
    weak var delegate: UpdateableFromViewModel?

    let busCommands = BusCommands()

    init(routeType: RouteType, route: Route, routeStops: RouteStops, delegate: UpdateableFromViewModel) {
        self.routeType = routeType
        self.route = route
        self.routeStops = routeStops
        self.delegate = delegate
        retrieveSchedule()
    }

    func retrieveSchedule() {
        guard let startStop = routeStops.startStop, let endStop = routeStops.destinationStop else { fatalError() }
        let sqlQuery = SQLQuery.busTrip(routeId: route.routeId, scheduleType: scheduleType, startStopId: startStop.stopId, endStopId: endStop.stopId)
        busCommands.busTrips(withQuery: sqlQuery) { [weak self] trips, _ in
            guard let strongSelf = self else { return }
            strongSelf.trips = trips ?? [Trip]()
            strongSelf.delegate?.viewModelUpdated()
        }
    }

    func makeDisplayable(displayable: ScheduleDisplayable, atRow row: Int) {
        typealias formatters = DateFormatters
        let trip = trips[row]
        if  let departureDate = trip.departureDate,

            let depatureString = formatters.timeFormatter.string(for: departureDate),
            let arrivalDate = trip.arrivalDate ,
            let arrivalString =  formatters.timeFormatter.string(for: arrivalDate),
            let durationString = formatters.durationFormatter.string(for: trip.tripDuration) {


        //displayable.setTripText(text: String(trip.tripId))
        displayable.setDepartText(text: depatureString)
        displayable.setArriveText(text:arrivalString)
        displayable.setDurationText(text: durationString)
        }
    }
}

