// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class TripScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel, IdentifiableController {

    func displayErrorMessage(message: String) {
        UIAlert.presentOKAlertFrom(viewController: self,
                                   withTitle: "View Trips",
                                   message: message) { [weak self] in
        }
    }

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
        updateLabels()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewHasAppeared = true
    }

    var shouldBeAnimatingActivityIndicator = true {
        didSet {
            updateActivityIndicator()
        }
    }

    func updateActivityIndicator(animating: Bool) {
        shouldBeAnimatingActivityIndicator = animating
    }

    var viewHasAppeared = false {
        didSet {
            updateActivityIndicator()
        }
    }

    func updateActivityIndicator() {
        if viewHasAppeared && shouldBeAnimatingActivityIndicator {
            activityIndicator.startAnimating()
        } else if viewHasAppeared && !shouldBeAnimatingActivityIndicator {
            activityIndicator.stopAnimating()
        }
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        if parent == navigationController?.parent {
            let action = UserPoppedViewController(navigationController: .schedules, description: "TripScheduleViewController has been popped")
            store.dispatch(action)
        }
    }
}
