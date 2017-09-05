// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class TripScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel, IdentifiableController {

    func displayErrorMessage(message: String, shouldDismissAfterDisplay: Bool = false) {
        UIAlert.presentOKAlertFrom(viewController: self,
                                   withTitle: "View Trips Error",
                                   message: message) {
            if shouldDismissAfterDisplay {
                let action = DismissModal(navigationController: .schedules, description: "dismissing trip schedules")
                store.dispatch(action)
            }
        }
    }

    var tripScheduleFavoritesIconController: TripScheduleFavoritesIconController?

    @IBOutlet weak var favoritesIcon: UIBarButtonItem! {
        didSet {
            tripScheduleFavoritesIconController = TripScheduleFavoritesIconController(favoritesBarButtonItem: favoritesIcon)
        }
    }

    @IBOutlet weak var routeIcon: UIImageView! {
        didSet {
            routeIcon.image = route.iconForRoute(transitMode: transitMode)
        }
    }

    @IBOutlet var scheduleTypeTopWhenAlerts: NSLayoutConstraint!
    @IBOutlet var scheduleTypeTopWhenNoAlerts: NSLayoutConstraint!
    @IBOutlet weak var transitAlertViews: UIView!

    @IBOutlet weak var routeShortNameLabel: UILabel! {
        didSet {
            routeShortNameLabel.text = route.routeShortName
        }
    }

    @IBOutlet weak var routeLongNameLabel: UILabel! {
        didSet {
            routeLongNameLabel.text = route.routeLongName
        }
    }

    @IBOutlet weak var insetWhiteView: UIView! {
        didSet {
            UIView.addSurroundShadow(toView: insetWhiteView, withCornerRadius: 4)
        }
    }

    var septaAlertsViewController: SeptaAlertsViewController!

    @IBOutlet weak var shadowView: UIView!

    let scheduleRequest = store.state.scheduleState.scheduleRequest

    let transitMode = store.state.scheduleState.scheduleRequest.transitMode!

    let route = store.state.scheduleState.scheduleRequest.selectedRoute!

    static var viewController: ViewController = .tripScheduleController
    @IBOutlet weak var startingPoint: UILabel!
    @IBOutlet weak var endingPoint: UILabel!
    @IBOutlet weak var tableViewFooter: UIView!
    var defaultColor: UIColor!
    @IBOutlet var viewModel: TripScheduleViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weekdayBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var header: UIView!

    @IBAction func navigateToNextToArrive(_: Any) {

        let switchTabsAction = SwitchTabs(activeNavigationController: .nextToArrive, description: "User tapped on alert")
        store.dispatch(switchTabsAction)
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

    @IBOutlet weak var reverseStopsButton: ReverseTripButton!

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

    let targetForScheduleAction = TargetForScheduleAction.schedules
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
        navigationController?.navigationBar.tintColor = UIColor.white
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        shadowView.backgroundColor = SeptaColor.navBarBlue
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        shadowView.layer.shadowRadius = 7
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowColor = SeptaColor.navBarShadowColor.cgColor

        configureSegementedControl()
        septaAlertsViewController.setTransitMode(transitMode, route: route)
    }

    override func viewDidLayoutSubviews() {
        if !septaAlertsViewController.hasAlerts {
            scheduleTypeTopWhenAlerts.isActive = false
            scheduleTypeTopWhenNoAlerts.isActive = true
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func updateViewConstraints() {

        super.updateViewConstraints()
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

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        if parent == navigationController?.parent {
            let action = UserPoppedViewController(navigationController: .schedules, description: "TripScheduleViewController has been popped")
            store.dispatch(action)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "embedTransitAlerts" {
            septaAlertsViewController = segue.destination as! SeptaAlertsViewController
        }
    }
}
