// Septa. 2017

import ReSwift
import SeptaSchedule
import UIKit

class TripScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel, IdentifiableController {
    let viewController: ViewController = .tripScheduleController
    func displayErrorMessage(message: String, shouldDismissAfterDisplay: Bool = false) {
        UIAlert.presentOKAlertFrom(viewController: self,
                                   withTitle: "View Trips Error",
                                   message: message) {
            if shouldDismissAfterDisplay {
                let action = DismissModal(description: "dismissing trip schedules")
                store.dispatch(action)
            }
        }
    }

    var tripScheduleFavoritesIconController: TripScheduleFavoritesIconController!

    @IBOutlet var favoritesButton: UIButton! {
        didSet {
            tripScheduleFavoritesIconController = TripScheduleFavoritesIconController(favoritesButton: favoritesButton)
            tripScheduleFavoritesIconController.favoritesButton = favoritesButton
        }
    }

    @IBOutlet var routeIcon: UIImageView! {
        didSet {
            routeIcon.image = RouteIcon.get(for: route.routeId, transitMode: transitMode)
        }
    }

    @IBOutlet var scheduleTypeTopWhenAlerts: NSLayoutConstraint!
    @IBOutlet var scheduleTypeTopWhenNoAlerts: NSLayoutConstraint!
    @IBOutlet var transitAlertViews: UIView!

    @IBOutlet var routeShortNameLabel: UILabel! {
        didSet {
            routeShortNameLabel.text = route.routeShortName
        }
    }

    @IBOutlet var routeLongNameLabel: UILabel! {
        didSet {
            routeLongNameLabel.text = route.routeLongName
        }
    }

    @IBOutlet var insetWhiteView: UIView! {
        didSet {
            UIView.addSurroundShadow(toView: insetWhiteView, withCornerRadius: 4)
        }
    }

    var septaAlertsViewController: SeptaAlertsViewController!

    @IBOutlet var shadowView: UIView!

    var scheduleRequest: ScheduleRequest { return store.state.scheduleState.scheduleRequest }

    var transitMode: TransitMode { return scheduleRequest.transitMode }

    var route: Route {
        return scheduleRequest.selectedRoute ??
            Route(routeId: "", routeShortName: "", routeLongName: "", routeDirectionCode: .inbound) }

    @IBOutlet var startingPoint: UILabel!
    @IBOutlet var endingPoint: UILabel!
    @IBOutlet var tableViewFooter: UIView!
    var defaultColor: UIColor!
    @IBOutlet var viewModel: TripScheduleViewModel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var weekdayBarButtonItem: UIBarButtonItem!

    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var header: UIView!

    @IBAction func navigateToNextToArrive(_: Any) {
        let action = NavigateToNextToArriveFromSchedules()
        store.dispatch(action)
    }

    func viewModelUpdated() {
        updateLabels()
        reverseStopsButton.isEnabled = true
        tableView.reloadData()
    }

    func updateLabels() {
        guard let labels = viewModel.tripStops else { return }
        startingPoint.text = labels.0
        endingPoint.text = labels.1
        let route = store.state.scheduleState.scheduleRequest.selectedRoute!
        routeShortNameLabel.text = route.routeShortName

        routeLongNameLabel.text = route.routeLongName
    }

    @IBOutlet var alertsIcon: UIBarButtonItem!

    @IBAction func reverseStopsButtonTapped(_: ReverseTripButton) {
        reverseStopsButton.isEnabled = false
        store.dispatch(ReverseStops(targetForScheduleAction: targetForScheduleAction))
    }

    @IBOutlet var reverseStopsButton: ReverseTripButton!

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        let rowCount = viewModel.numberOfRows()
        tableViewFooter.isHidden = rowCount == 0
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

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let scheduleType = mapSegmentsToScheduleType(segmentedControl: sender) else { return }
        dispatchScheduleTypeAction(scheduleType)
    }

    func mapSegmentsToScheduleType(segmentedControl: UISegmentedControl) -> ScheduleType? {
        return scheduleTypeSegments[segmentedControl.selectedSegmentIndex]
    }

    var targetForScheduleAction: TargetForScheduleAction! { return store.state.targetForScheduleActions() }
    func dispatchScheduleTypeAction(_ scheduleType: ScheduleType) {
        store.dispatch(ClearTrips(targetForScheduleAction: targetForScheduleAction))

        let action = ScheduleTypeSelected(targetForScheduleAction: targetForScheduleAction, scheduleType: scheduleType)
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
        view.backgroundColor = SeptaColor.navBarBlue
        navigationItem.title = "Schedules: \(transitMode.name())"
        updateLabels()
        navigationController?.navigationBar.configureBackButton()

        configureSegementedControl()
        septaAlertsViewController.setTransitMode(transitMode, route: route)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        backButtonPopped(toParentViewController: parent)
    }

    override func viewDidLayoutSubviews() {
        if !septaAlertsViewController.hasAlerts {
            scheduleTypeTopWhenAlerts.isActive = false
            scheduleTypeTopWhenNoAlerts.isActive = true
        }
    }

    func configureSegementedControl() {
        segmentedControl.removeAllSegments()
        scheduleTypeSegments = transitMode.scheduleTypeSegments()
        let reversedSegments = scheduleTypeSegments.reversed()
        for scheduleType in reversedSegments {
            segmentedControl.insertSegment(withTitle: scheduleType.stringForSegments(), at: 0, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
    }

    func showHideAlertViewifNecessary() {
    }

    var scheduleTypeSegments: [ScheduleType]!

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

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "embedTransitAlerts" {
            septaAlertsViewController = segue.destination as! SeptaAlertsViewController
        }
    }
}
