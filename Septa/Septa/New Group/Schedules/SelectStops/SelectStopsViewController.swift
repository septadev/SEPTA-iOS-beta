// SEPTA.org, created on 8/1/17.

import UIKit
import SeptaSchedule

class SelectStopsViewController: UITableViewController, UpdateableFromViewModel {
    let segueId = "showStop"
    @IBOutlet var footerView: UIView!

    @IBAction func viewSchedulesTapped(_: Any) {
    }

    @IBOutlet weak var viewSchedulesButton: UIButton!
    var routeType: RouteType!
    var route: Route?
    var viewModel: SelectStopsViewModel!
    var routeStops: RouteStops?

    func setRouteType(_ routeType: RouteType, route _: Route) {
        self.routeType = routeType
        initializeViewModel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Bundle.main.loadNibNamed("SelectStopsFooterView", owner: self, options: nil)
        tableView.tableFooterView = footerView
        viewSchedulesButton.isEnabled = viewModel.canUserContinue()
    }

    fileprivate func initializeViewModel() {
        viewModel = SelectStopsViewModel(delegate: self, routeType: routeType)
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        routeStops = viewModel.routeStops
        performSegue(withIdentifier: segueId, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        guard
            let selectStopViewController = segue.destination as? SelectStopViewController,
            let routeType = routeType,
            let route = route, let routeStops = routeStops
        else { return }

        selectStopViewController.setRouteType(routeType, route: route, routeStops: routeStops)
    }
}
