// Septa. 2017

import Foundation
import SeptaSchedule

class SelectStopViewModel {

    enum StopSearchType {
        case start
        case end

        static func stopSearchType(routeStops: RouteStops) -> StopSearchType {
            if routeStops.startStop == nil {
                return .start
            } else {
                return .end
            }
        }
    }

    let busCommands = BusCommands()

    let routeType: RouteType
    let route: Route
    var routeStops: RouteStops
    let selectedStop: SelectStopRow
    var scheduleType = ScheduleType.weekday
    weak var delegate: UpdateableFromViewModel?
    var stops = [Stop]()

    init(routeType: RouteType, route: Route, selectedStop: SelectStopRow, routeStops: RouteStops, delegate: UpdateableFromViewModel) {
        self.routeType = routeType
        self.route = route
        self.selectedStop = selectedStop
        self.routeStops = routeStops
        self.delegate = delegate
        retrieveStops()
    }

    func setScheduleType(_ scheduleType: ScheduleType) {
        self.scheduleType = scheduleType
        retrieveStops()
    }

    func rowSelected(atRow row: Int) {
        let stop = stops[row]
        let newRouteStops: RouteStops
        if selectedStop == .selectStart {
            newRouteStops = RouteStops(startStop: stop, destinationStop: routeStops.destinationStop)
        } else {
            newRouteStops = RouteStops(startStop: routeStops.startStop, destinationStop: stop)
        }
        routeStops = newRouteStops
    }

    func retrieveStops() {
        let query: SQLQuery
        if StopSearchType.stopSearchType(routeStops: routeStops) == .start {
            query = SQLQuery.busStart(routeId: route.routeId, scheduleType: scheduleType)
        } else {
            guard let stop = routeStops.startStop else { return }
            query = SQLQuery.busEnd(routeId: route.routeId, scheduleType: scheduleType, startStopId: stop.stopId)
        }
        busCommands.busStops(withQuery: query) { [weak self] stops, _ in
            guard let strongSelf = self, let stops = stops else { return }
            strongSelf.stops = stops
            strongSelf.delegate?.viewModelUpdated()
        }
    }

    func configureDisplayable(_ displayable: SingleStringDisplayable, atRow row: Int) {
        displayable.setLabelText(stops[row].stopName)
    }
}
