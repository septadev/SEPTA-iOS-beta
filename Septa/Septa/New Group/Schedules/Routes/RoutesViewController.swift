// SEPTA.org, created on 8/1/17.

import UIKit
import SeptaSchedule

class RoutesViewController: UITableViewController, ViewModelUpdateable {
    typealias Data = [Route]
    let routeCellId = "routeCell"
    var viewModel: RoutesViewModel!

    func setRouteType(routeType: RouteType) {
        initializeViewModel(routeType: routeType)
    }

    fileprivate func initializeViewModel(routeType: RouteType) {
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

    func viewModelUpdated() {
        tableView.reloadData()
    }
}
