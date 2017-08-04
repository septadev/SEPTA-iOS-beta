// SEPTA.org, created on 8/1/17.

import UIKit
import SeptaSchedule

class RoutesViewController: UITableViewController, UpdateableFromViewModel {
    typealias Data = [Route]
    let routeCellId = "routeCell"
    let segueId = "selectStops"
    var viewModel: RoutesViewModel!
    var routeType: RouteType?
    var selectedRoute: Route?

    func setRouteType(_ routeType: RouteType) {
        self.routeType = routeType
        initializeViewModel()
    }

    fileprivate func initializeViewModel() {
        guard let routeType = routeType else { return }
        viewModel = RoutesViewModel(delegate: self, routeType: routeType)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.routesCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: routeCellId, for: indexPath) as? RouteTableViewCell else { return UITableViewCell() }

        viewModel.configureRoute(displayable: cell, atIndex: indexPath.row)
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRoute = viewModel.routeAtRow(row: indexPath.row)
        performSegue(withIdentifier: segueId, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        guard
            let selectStopsViewController = segue.destination as? SelectStopsViewController,
            let routeType = routeType,
            let selectedRoute = selectedRoute else { return }
        selectStopsViewController.setRouteType(routeType, route: selectedRoute)
    }

    func viewModelUpdated() {
        tableView.reloadData()
    }
}
