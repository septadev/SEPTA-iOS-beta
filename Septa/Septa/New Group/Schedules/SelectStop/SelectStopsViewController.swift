// SEPTA.org, created on 8/1/17.

import UIKit
import SeptaSchedule

class SelectStopsViewController: UITableViewController, UpdateableFromViewModel {

    @IBOutlet var footerView: UIView!

    @IBAction func viewSchedulesTapped(_: Any) {
    }

    @IBOutlet weak var viewSchedulesButton: UIButton!
    var routeType: RouteType!
    var route: Route?
    var viewModel: SelectStopsViewModel!

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
}
