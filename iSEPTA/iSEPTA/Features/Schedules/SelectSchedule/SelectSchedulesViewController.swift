// Septa. 2017

import ReSwift
import SeptaSchedule
import UIKit

class SelectSchedulesViewController: UIViewController, IdentifiableController {

    // MARK: - Outlets
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var section0View: UIView!
    @IBOutlet var section1View: UIView!
    @IBOutlet var sectionHeaders: [UIView]!
    @IBOutlet var tableViewFooter: UIView!
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var scheduleLabel: UILabel!
    @IBOutlet var sectionHeaderLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewWrapper: UIView!

    @IBOutlet var mockDateTextField: UITextField!

    // MARK: - Properties
    let viewController: ViewController = .selectSchedules
    let buttonRow = 3
    var formIsComplete = false
    var targetForScheduleAction: TargetForScheduleAction! { return store.state.currentTargetForScheduleActions() }
    let cellId = "singleStringCell"
    let buttonCellId = "buttonViewCell"
    var viewModel: SelectSchedulesViewModel!
    var holidaySchedule: HolidaySchedule?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHolidaySchedules()
        viewModel = SelectSchedulesViewModel(delegate: self)
        view.backgroundColor = SeptaColor.navBarBlue
        tableView.tableFooterView = tableViewFooter

        viewModel.schedulesDelegate = self
        buttonView.isHidden = true
        UIView.addSurroundShadow(toView: tableViewWrapper)
    }

    override func viewWillAppear(_ annimated: Bool) {
        super.viewWillAppear(annimated)
        guard let navBar = navigationController?.navigationBar else { return }

        navBar.shadowImage = UIImage()
        navBar.setBackgroundImage(UIImage(), for: .default)
        viewModel.subscribe()
    }

    override func viewDidAppear(_ annimated: Bool) {
        super.viewDidAppear(annimated)
        if let holidaySchedule = holidaySchedule {
            if holidaySchedule.holidayMessage() != nil {
                UIAlert.presentHolidayAlertFrom(viewController: self, holidaySchedule: holidaySchedule)
            }
        }
        checkForHolidayAlert()
    }

    override func viewWillDisappear(_: Bool) {
        viewModel.unsubscribe()
    }

    // MARK: - Holiday Schedule Methods
    func configureHolidaySchedules() {
        holidaySchedule = HolidaySchedule.buildHolidaySchedule()
        configureOtherHolidays()
        configureRailHolidays()
    }
    
    func configureOtherHolidays() {
        HolidayForDateCommand.sharedInstance.holidays(forTransitMode: .bus) { [weak self] holidayArray, error in
            guard let strongSelf = self else { return }
            if let holidayArray = holidayArray {
                strongSelf.holidaySchedule?.setOtherHolidays(holidayArray: holidayArray)
                strongSelf.holidaySchedule?.setReferenceDate(Date())
                strongSelf.checkForHolidayAlert()
            }
        }
    }
    
    func configureRailHolidays() {
        HolidayForDateCommand.sharedInstance.holidays(forTransitMode: .rail) { [weak self] holidayArray, error in
            guard let strongSelf = self else { return }
            if let holidayArray = holidayArray {
                strongSelf.holidaySchedule?.setRailHolidays(holidayArray: holidayArray)
                strongSelf.holidaySchedule?.setReferenceDate(Date())
                strongSelf.checkForHolidayAlert()
            }
        }
    }
    
    func checkForHolidayAlert() {
        if let holidaySchedule = holidaySchedule {
            if holidaySchedule.holidayMessage() != nil {
                UIAlert.presentHolidayAlertFrom(viewController: self, holidaySchedule: holidaySchedule)
            }
        }
    }

    // MARK: - IBActions
    @IBAction func resetSearch(_: Any) {
        let action = ResetSchedule(targetForScheduleAction: targetForScheduleAction)
        store.dispatch(action)
    }

    func ViewSchedulesButtonTapped() {
        let action = PushViewController(viewController: .tripScheduleController, description: "Show Trip Schedule")
        store.dispatch(action)
    }

    @IBAction func resetButtonTapped(_: Any) {
        store.dispatch(ResetSchedule(targetForScheduleAction: targetForScheduleAction))
    }

    @IBAction func evalMockDateTapped(_: Any) {
        let formatter = DateFormatters.ymdFormatter
        if let holidaySchedule = holidaySchedule, let text = mockDateTextField.text, let date = formatter.date(from: text) {
            holidaySchedule.setReferenceDate(date)
            if holidaySchedule.holidayMessage() != nil {
                UIAlert.presentHolidayAlertFrom(viewController: self, holidaySchedule: holidaySchedule)
            }
        }
    }
    
}

extension SelectSchedulesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 4
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < buttonRow {
            let cellId = viewModel.cellIdForRow(indexPath.section)
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            viewModel.configureCell(cell, atRow: indexPath.section)
            return cell

        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: buttonCellId, for: indexPath) as? ButtonViewCell else { return ButtonViewCell() }
            cell.buttonText = SeptaString.selectScheduleButton
            cell.enabled = formIsComplete
            return cell
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < buttonRow {
            viewModel.rowSelected(indexPath.section)

        } else {
            ViewSchedulesButtonTapped()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section < buttonRow {
            return viewModel.canCellBeSelected(atRow: indexPath.section)

        } else {
            return formIsComplete
        }
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? section0View : section1View
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 37
        case 1, 3: return 21
        case 2: return 11
        default: return 0
        }
    }
}

extension SelectSchedulesViewController: UpdateableFromViewModel {
    func updateActivityIndicator(animating _: Bool) {
    }

    func viewModelUpdated() {
        scheduleLabel.text = viewModel.scheduleTitle()
        sectionHeaderLabel.text = viewModel.transitModeTitle()
        tableView.reloadData()
    }

    func displayErrorMessage(message: String, shouldDismissAfterDisplay _: Bool = false) {
        UIAlert.presentOKAlertFrom(viewController: self, withTitle: "Select Schedule", message: message)
    }
}

extension SelectSchedulesViewController: SchedulesViewModelDelegate {
    func formIsComplete(_ isComplete: Bool) {
        formIsComplete = isComplete
        tableView.reloadData()
    }
}
