// SEPTA.org, created on 8/1/17.

import UIKit
import SeptaSchedule

class SelectStopsViewController: UITableViewController, UpdateableFromViewModel {
    let segueId = "selectStop"

    @IBOutlet var footerView: UIView!
    @IBOutlet weak var viewSchedulesButton: UIButton!

    var viewModel: SelectStopsViewModel!

    func setRouteType(_ routeType: RouteType, route: Route) {
        viewModel = SelectStopsViewModel(routeType: routeType, route: route, delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Bundle.main.loadNibNamed("SelectStopsFooterView", owner: self, options: nil)
        tableView.tableFooterView = footerView
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard

            let cellIdentifier = viewModel.cellIdentifierAtRow(indexPath.row),
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SingleStringCell
        else { return UITableViewCell() }
        viewModel.configureDisplayable(cell, atRow: indexPath.row)
        return cell
    }

    func viewModelUpdated() {
        tableView.reloadData()
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedRow =  SelectStopRow(rawValue: indexPath.row)!
        performSegue(withIdentifier: segueId, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let destinationViewController = segue.destination as? SelectStopViewController {
            destinationViewController.setRouteType(viewModel.routeType, route: viewModel.route, selectedStop: viewModel.selectedRow, routeStops: viewModel.routeStops)
        }
    }

    @IBAction func viewSchedulesTapped(_: Any) {
    }
}
