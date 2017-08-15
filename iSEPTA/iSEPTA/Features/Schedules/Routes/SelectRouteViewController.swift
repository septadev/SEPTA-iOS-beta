// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class SelectRouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel, IdentifiableController {
    @IBOutlet var viewModel: RoutesViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    static var viewController: ViewController = .routesViewController
    let routeCellId = "routeCell"
    @IBOutlet weak var searchTextBox: UITextField!

    @IBAction func cancelButtonPressed(_: Any) {
        let dismissAction = DismissModal(navigationController: .schedules, description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedTransitMode = store.state.scheduleState.scheduleRequest?.transitMode {
            titleLabel.text = selectedTransitMode.routeTitle()
        }
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

    deinit {
    }
}
