// SEPTA.org, created on 8/1/17.

import UIKit
import SeptaSchedule

class RouteScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel {
    func viewModelUpdated() {
        tableView.reloadData()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.trips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell") as? ScheduleTableViewCell else { return UITableViewCell() }
        viewModel.makeDisplayable(displayable: cell, atRow: indexPath.row)
        return cell
    }

    @IBOutlet weak var startingPoint: UILabel!
    @IBOutlet weak var endingPoint: UILabel!
    var defaultColor: UIColor!
    var viewModel: RouteScheduleViewModel!

    @IBOutlet var scheduleTypeSelector: UIToolbar! {
        didSet {
            defaultColor = scheduleTypeSelector.items![0].tintColor
        }
    }

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var header: UIView!
    @IBAction func weekdaysSelected(_ sender: Any) {
        //  viewModel.setScheduleType(.weekday)
        let item = sender as! UIBarButtonItem
        resetTintColors()
        item.tintColor = UIColor.darkText
    }

    @IBAction func saturdaySelected(_ sender: Any) {
        //     viewModel.setScheduleType(.weekday)
        resetTintColors()
        let item = sender as! UIBarButtonItem
        item.tintColor = UIColor.darkText
    }

    @IBAction func sundaySelected(_ sender: Any) {
        resetTintColors()
        //    viewModel.setScheduleType(.weekday)
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
        tableView.tableHeaderView = header
        let item = scheduleTypeSelector.items![0]
        item.tintColor = UIColor.green
        startingPoint.text = viewModel.routeStops.startStop?.stopName
        endingPoint.text = viewModel.routeStops.destinationStop?.stopName
    }

    override func viewWillAppear(_: Bool) {
        for item in scheduleTypeSelector.items! {
            item.width = view.frame.size.width / 3.0
        }
    }

    func setRouteType(routeType: RouteType, route: Route, routeStops: RouteStops) {

        viewModel = RouteScheduleViewModel(routeType: routeType, route: route, routeStops: routeStops, delegate: self)
    }
}
