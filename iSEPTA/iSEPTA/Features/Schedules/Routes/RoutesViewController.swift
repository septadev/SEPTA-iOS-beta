// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class RoutesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel, IdentifiableController {

    @IBOutlet weak var tableView: UITableView!
    static var viewController: ViewController = .routesViewController
    static var navigationController: NavigationController = .schedules

    @IBOutlet weak var searchTextBox: UITextField!

    @IBAction func cancelButtonPressed(_: Any) {
        let dismissAction = DismissModal(navigationController: .schedules, description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }

    typealias Data = [Route]
    let routeCellId = "routeCell"
    let segueId = "selectStops"
    @IBOutlet var viewModel: RoutesViewModel!
    var routeType: RouteType?
    var selectedRoute: Route?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: routeCellId, for: indexPath) as? RouteTableViewCell else { return UITableViewCell() }

        viewModel.configureDisplayable(cell, atRow: indexPath.row)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(row: indexPath.row)
    }

    func viewModelUpdated() {
        tableView.reloadData()
    }
}
