// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class TripScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel, IdentifiableController {
    static var viewController: ViewController = .tripScheduleController
    @IBOutlet weak var startingPoint: UILabel!
    @IBOutlet weak var endingPoint: UILabel!
    @IBOutlet weak var tableViewFooter: UIView!
    var defaultColor: UIColor!
    @IBOutlet var viewModel: TripScheduleViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weekdayBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var header: UIView!

    func viewModelUpdated() {
        updateLabels()

        tableView.reloadData()
    }

    func updateLabels() {
        guard let labels = viewModel.tripStops else { return }
        startingPoint.text = labels.0
        endingPoint.text = labels.1
    }

    @IBOutlet var alertsIcon: UIBarButtonItem!

    @IBAction func reverseStopsButtonTapped(_: Any) {
        store.dispatch(ReverseStops())
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        let rowCount = viewModel.numberOfRows()
        if rowCount > 0 {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell") as? ScheduleTableViewCell else { return UITableViewCell() }
        viewModel.makeTripDisplayable(displayable: cell, atRow: indexPath.row)
        return cell
    }

    @IBOutlet var scheduleTypeSelector: UIToolbar! {
        didSet {
            defaultColor = scheduleTypeSelector.items![0].tintColor
        }
    }

    @IBAction func weekdaysSelected(_ sender: Any) {
        //  viewModel.setScheduleType(.weekday)
        let item = sender as! UIBarButtonItem
        resetTintColors()
        item.tintColor = UIColor.darkText
        dispatchScheduleTypeAction(.weekday)
    }

    @IBAction func saturdaySelected(_ sender: Any) {
        //     viewModel.setScheduleType(.weekday)
        resetTintColors()
        let item = sender as! UIBarButtonItem
        item.tintColor = UIColor.darkText
        dispatchScheduleTypeAction(.saturday)
    }

    @IBAction func sundaySelected(_ sender: Any) {
        resetTintColors()
        //    viewModel.setScheduleType(.weekday)
        let item = sender as! UIBarButtonItem
        item.tintColor = UIColor.darkText

        dispatchScheduleTypeAction(.sunday)
    }

    func dispatchScheduleTypeAction(_ scheduleType: ScheduleType) {

        let action = ScheduleTypeSelected(scheduleType: scheduleType)
        store.dispatch(action)
        //        activityIndicator.startAnimating()
    }

    func resetTintColors() {
        for item in scheduleTypeSelector.items! {
            item.tintColor = defaultColor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.subscribe()
        tableView.tableFooterView = tableViewFooter
        weekdayBarButtonItem.tintColor = UIColor.darkText
        //        tableView.tableHeaderView = header
        //        let item = scheduleTypeSelector.items![0]
        //        item.tintColor = UIColor.green
        //        startingPoint.text = viewModel.routeStops.startStop?.stopName
        //        endingPoint.text = viewModel.routeStops.destinationStop?.stopName
    }

    override func viewWillAppear(_: Bool) {
        //        super.viewWillAppear(animated)
        //        for item in scheduleTypeSelector.items! {
        //            item.width = view.frame.size.width / 3.0
        //        }
    }

    override func viewWillDisappear(_: Bool) {
    }

    //    override func didMove(toParentViewController parent: UIViewController?) {
    //        super.didMove(toParentViewController: parent)
    //        if parent == nil {
    //            let action = UserPoppedViewController(navigationController: .schedules, description: "TripScheduleViewController has been popped")
    //            store.dispatch(action)
    //        }
    //    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        if parent == navigationController?.parent {
            let action = UserPoppedViewController(navigationController: .schedules, description: "TripScheduleViewController has been popped")
            store.dispatch(action)
        }
    }
}
