// SEPTA.org, created on 8/1/17.

import Foundation
import SeptaSchedule

class RoutesViewModel {

    fileprivate var routes: [Route]
    let busCommands = BusCommands()

    private weak var delegate: UpdateableFromViewModel?

    init(delegate: UpdateableFromViewModel, routeType: RouteType) {
        routes = [Route]()
        self.delegate = delegate
        retrieveRoutes(routeType: routeType)
    }

    var routesCount: Int {
        return routes.count
    }

    func routeAtRow(row: Int) -> Route {
        return routes[row]
    }

    func configureRoute(displayable: RouteCellDisplayable, atIndex index: Int) {
        let route = routes[index]
        displayable.setLongName(text: route.routeLongName)
        displayable.setShortName(text: route.routeShortName)
    }

    private func retrieveRoutes(routeType: RouteType) {

        let query = SQLQuery.busRoute(routeType: routeType)
        busCommands.busRoutes(withQuery: query) { [weak self] routes, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let strongSelf = self else { return }
            guard let routes = routes else {
                strongSelf.routes = [Route]()
                return
            }
            strongSelf.routes = routes
            strongSelf.delegate?.viewModelUpdated()
        }
    }
}
