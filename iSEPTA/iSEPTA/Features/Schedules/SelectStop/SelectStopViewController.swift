// SEPTA.org, created on 8/1/17.

import UIKit
import SeptaSchedule

class SelectStopViewController: UITableViewController, UpdateableFromViewModel, UISearchBarDelegate {
    let cellId = "stopCell"
    var viewModel: SelectStopViewModel!

    var defaultColor: UIColor!
    @IBOutlet var headerView: UIView!
    @IBOutlet var scheduleTypeSelector: UIToolbar! {
        didSet {
            defaultColor = scheduleTypeSelector.items![0].tintColor
        }
    }

    @IBAction func weekdaysSelected(_ sender: Any) {
        viewModel.setScheduleType(.weekday)
        let item = sender as! UIBarButtonItem
        resetTintColors()
        item.tintColor = UIColor.darkText
    }

    @IBAction func saturdaySelected(_ sender: Any) {
        viewModel.setScheduleType(.weekday)
        resetTintColors()
        let item = sender as! UIBarButtonItem
        item.tintColor = UIColor.darkText
    }

    @IBAction func sundaySelected(_ sender: Any) {
        resetTintColors()
        viewModel.setScheduleType(.weekday)
        let item = sender as! UIBarButtonItem
        item.tintColor = UIColor.darkText
    }

    func resetTintColors() {
        for item in scheduleTypeSelector.items! {
            item.tintColor = defaultColor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = headerView
        let item = scheduleTypeSelector.items![0]
        item.tintColor = UIColor.green
    }

    override func viewWillAppear(_: Bool) {
        for item in scheduleTypeSelector.items! {
            item.width = view.frame.size.width / 3.0
        }
    }

    /// To pull off the query, we need routeType, route, selected stop (start or destination), stops that have already been selected
    func setRouteType(_ routeType: RouteType, route: Route, selectedStop: SelectStopRow, routeStops: RouteStops) {
        viewModel = SelectStopViewModel(routeType: routeType, route: route, selectedStop: selectedStop, routeStops: routeStops, delegate: self)
        if selectedStop == .selectStart {
            navigationItem.title = "Select Trip Start"
        } else {
            navigationItem.title = "Select Trip End"
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.stops.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SingleStringCell else { return UITableViewCell() }
        viewModel.configureDisplayable(cell, atRow: indexPath.row)
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(atRow: indexPath.row)
        performSegue(withIdentifier: "unwindToSelectStops", sender: self)
    }

    func viewModelUpdated() {
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let destination = segue.destination as? SelectStopsViewController {
            destination.routeStopSelected(viewModel.routeStops)
        }
    }
}
