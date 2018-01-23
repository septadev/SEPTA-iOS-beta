// Septa. 2017

import SeptaSchedule
import UIKit

enum RouteType {
    case rail
    case wheels
}

class SelectStopsViewController: UITableViewController, UpdateableFromViewModel {
    let selectStopSegueId = "selectStop"
    let showSheduleSegueId = "showSchedule"

    @IBOutlet var footerView: UIView!
    @IBOutlet var viewSchedulesButton: UIButton!

    @IBOutlet var resetSearch: UIBarButtonItem!
    var viewModel: SelectStopsViewModel!

    func setRouteType(_ routeType: RouteType, route: Route) {
        viewModel = SelectStopsViewModel(routeType: routeType, route: route, delegate: self)
    }

    @IBAction func cancelSearch(_: Any) {
        viewModel.routeStops = RouteStops(startStop: nil, destinationStop: nil)
        viewSchedulesButton.isEnabled = viewModel.canUserContinue()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Bundle.main.loadNibNamed("SelectStopsFooterView", owner: self, options: nil)
        tableView.tableFooterView = footerView
        viewSchedulesButton.isEnabled = false
        navigationItem.rightBarButtonItem = resetSearch
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
        viewModel.selectedRow = SelectStopRow(rawValue: indexPath.row)!
        performSegue(withIdentifier: selectStopSegueId, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let destinationViewController = segue.destination as? SelectStopViewController {
            destinationViewController.setRouteType(viewModel.routeType, route: viewModel.route, selectedStop: viewModel.selectedRow, routeStops: viewModel.routeStops)
        }
        if let scheduleViewController = segue.destination as? RouteScheduleViewController {
            // func setRouteType(_ routeType: RouteType, route: Route, routeStops: RouteStops) {

            scheduleViewController.setRouteType(routeType: viewModel.routeType, route: viewModel.route, routeStops: viewModel.routeStops)
        }
    }

    func routeStopSelected(_ routeStops: RouteStops) {
        viewModel.routeStops = routeStops
        viewSchedulesButton.isEnabled = viewModel.canUserContinue()
    }

    @IBAction func viewSchedulesTapped(_: Any) {
        performSegue(withIdentifier: showSheduleSegueId, sender: self)
    }

    @IBAction func unwindSeguefromSelectStop(_: UIStoryboardSegue) {
    }
}
