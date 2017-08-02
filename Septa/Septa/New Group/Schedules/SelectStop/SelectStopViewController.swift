// SEPTA.org, created on 8/1/17.

import UIKit
import SeptaSchedule

class SelectStopViewController: UITableViewController, UpdateableFromViewModel {
    let cellId = "stopCell"
    var viewModel: SelectStopViewModel!

    /// To pull off the query, we need routeType, route, selected stop (start or destination), stops that have already been selected
    func setRouteType(_ routeType: RouteType, route: Route, selectedStop: SelectStopRow, routeStops: RouteStops) {
        viewModel = SelectStopViewModel(routeType: routeType, route: route, selectedStop: selectedStop, routeStops: routeStops,  delegate: self)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.stops.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SingleStringCell else { return UITableViewCell() }
        viewModel.configureDisplayable(cell, atRow: indexPath.row)
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(atRow: indexPath.row)
    }

    func viewModelUpdated() {
        tableView.reloadData()
    }
}

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

    init(routeType: RouteType, route: Route, selectedStop:SelectStopRow, routeStops: RouteStops, delegate: UpdateableFromViewModel) {
        self.routeType = routeType
        self.route = route
        self.selectedStop = selectedStop
        self.routeStops = routeStops
        self.delegate = delegate
        retrieveStops()
    }

    func rowSelected(atRow _: Int) {
    }

    func retrieveStops() {
        let query: SQLQuery
        if StopSearchType.stopSearchType(routeStops: routeStops) == .start {
            query = SQLQuery.busStart(routeId: route.routeId, scheduleType: scheduleType)
        } else {
            guard let stop = routeStops.destinationStop else { return }
            query = SQLQuery.busEnd(routeId: route.routeId, scheduleType: scheduleType, startStopId: stop.stopId)
        }
        busCommands.busStops(withQuery: query) { [weak self] stops, _ in
            guard let strongSelf = self, let stops = stops else { return }
            strongSelf.stops = stops
            strongSelf.delegate?.viewModelUpdated()
        }
    }

    func configureDisplayable(_ displayable: SingleStringDisplayable, atRow row: Int) {
        displayable.setLabelText(text: stops[row].stopName)
    }
}
