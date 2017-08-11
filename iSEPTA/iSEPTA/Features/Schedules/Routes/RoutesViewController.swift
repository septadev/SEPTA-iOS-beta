// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class RoutesViewController: UITableViewController, UpdateableFromViewModel, IdentifiableController {
    static var viewController: ViewController = .routesViewController
    static var navigationController: NavigationController = .schedules

    typealias Data = [Route]
    let routeCellId = "routeCell"
    let segueId = "selectStops"
    var viewModel: RoutesViewModel!
    var routeType: RouteType?
    var selectedRoute: Route?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RoutesViewModel(delegate: self)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfRows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: routeCellId, for: indexPath) as? RouteTableViewCell else { return UITableViewCell() }

        viewModel.configureDisplayable(cell, atRow: indexPath.row)
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(row: indexPath.row)
    }

    func viewModelUpdated() {
        tableView.reloadData()
    }
}
