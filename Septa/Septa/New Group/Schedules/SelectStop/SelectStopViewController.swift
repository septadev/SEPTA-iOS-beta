// SEPTA.org, created on 8/1/17.

import UIKit
import SeptaSchedule

class SelectStopViewController: UITableViewController, UpdateableFromViewModel {




    var viewModel : SelectStopViewModel!

    func setRouteType(_ routeType: RouteType, route: Route, routeStops : RouteStops) {
        viewModel = SelectStopViewModel(routeType: routeType, route: route, routeStops: routeStops, delegate: self)
    }

 func viewModelUpdated() {
        self.tableView.reloadData()
    }

}

class SelectStopViewModel {

    enum StopSearchType{
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
    var scheduleType = ScheduleType.weekday
    weak var delegate: UpdateableFromViewModel?
    var stops = [Stop]()

    init(routeType: RouteType, route: Route, routeStops : RouteStops, delegate: UpdateableFromViewModel){
        self.routeType = routeType
        self.route = route
        self.routeStops = routeStops
        self.delegate = delegate
    }


    func retrieveStops(){
        let query: SQLQuery
        if StopSearchType.stopSearchType(routeStops: routeStops) == .start {
            query = SQLQuery.busStart(routeId: route.routeId, scheduleType: scheduleType)
        } else {
            guard let stop = routeStops.destinationStop else {return}
            query = SQLQuery.busEnd(routeId: route.routeId, scheduleType: scheduleType,startStopId: stop.stopId)
        }
        busCommands.busStops(withQuery: query) { [weak self] stops, error in
            guard let strongSelf = self ,let  stops = stops else { return }
            strongSelf.stops = stops
            strongSelf.delegate?.viewModelUpdated()

}
    }



}
