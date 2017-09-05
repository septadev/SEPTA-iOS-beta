// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class SelectSchedulesViewController: UIViewController, IdentifiableController {
    // MARK: - Outlets
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var section0View: UIView!
    @IBOutlet var section1View: UIView!
    @IBOutlet var sectionHeaders: [UIView]!
    @IBOutlet var tableViewFooter: UIView!
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewWrapper: UIView!

    // MARK: - Properties
    static var viewController: ViewController = .selectSchedules
    let buttonRow = 3
    var formIsComplete = false
    let targetForScheduleAction = store.state.targetForScheduleActions()
    let cellId = "singleStringCell"
    let buttonCellId = "buttonViewCell"
    var viewModel: SelectSchedulesViewModel!

    override func viewDidLoad() {
        viewModel = SelectSchedulesViewModel(delegate: self)
        view.backgroundColor = SeptaColor.navBarBlue
        tableView.tableFooterView = tableViewFooter

        viewModel.schedulesDelegate = self
        buttonView.isHidden = true
        UIView.addSurroundShadow(toView: tableViewWrapper)
    }

    override func viewWillAppear(_: Bool) {
        guard let navBar = navigationController?.navigationBar else { return }

        navBar.shadowImage = UIImage()
        navBar.setBackgroundImage(UIImage(), for: .default)
        viewModel.subscribe()
    }

    override func viewWillDisappear(_: Bool) {
        viewModel.unsubscribe()
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
