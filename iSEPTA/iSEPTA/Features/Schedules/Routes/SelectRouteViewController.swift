// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class SelectRouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchModalHeaderDelegate, UpdateableFromViewModel, IdentifiableController {
    func animatedLayoutNeeded(block _: @escaping (() -> Void), completion _: @escaping (() -> Void)) {
    }

    func layoutNeeded() {
    }

    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message _: String) {
    }

    @IBOutlet var viewModel: RoutesViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    static var viewController: ViewController = .routesViewController
    let routeCellId = "routeCell"
    @IBOutlet weak var searchTextBox: UITextField!

    func dismissModal() {
        let dismissAction = DismissModal(navigationController: .schedules, description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }

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

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        // viewModel.rowSelected(row: indexPath.row)
    }

    func viewModelUpdated() {
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "embedHeader" {
            if let headerViewController = segue.destination as? SearchRoutesModalHeaderViewController {
                headerViewController.delegate = self
                headerViewController.textFieldDelegate = viewModel
            }
        }
    }

    deinit {
    }
}
