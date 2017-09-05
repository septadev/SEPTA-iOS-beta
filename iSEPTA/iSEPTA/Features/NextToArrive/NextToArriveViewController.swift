// Septa. 2017

import UIKit
import ReSwift

class NextToArriveViewController: BaseNonModalViewController, IdentifiableController {

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

    let buttonCellId = "buttonViewCell"
    let buttonRow = 3
    let cellId = "singleStringCell"
    static var viewController: ViewController = .selectSchedules
    var formIsComplete = false
    var targetForScheduleAction: TargetForScheduleAction { return store.state.targetForScheduleActions() }

    @IBOutlet var viewModel: NextToArriveViewModel!

    @IBAction func resetButtonTapped(_: Any) {
        store.dispatch(ResetSchedule(targetForScheduleAction: targetForScheduleAction))
    }

    override func viewDidLoad() {

        view.backgroundColor = SeptaColor.navBarBlue
        tableView.tableFooterView = tableViewFooter

        buttonView.isHidden = true
        UIView.addSurroundShadow(toView: tableViewWrapper)
        super.viewDidLoad()
    }

    override func viewWillAppear(_: Bool) {
        guard let navBar = navigationController?.navigationBar else { return }

        navBar.shadowImage = UIImage()
        navBar.setBackgroundImage(UIImage(), for: .default)
    }

    @IBAction func resetSearch(_: Any) {
        let action = ResetSchedule(targetForScheduleAction: targetForScheduleAction)
        store.dispatch(action)
    }

    func ViewSchedulesButtonTapped() {
        let action = PushViewController(viewController: .tripScheduleController, description: "Show Trip Schedule")
        store.dispatch(action)
    }
}

extension NextToArriveViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfRows()
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

extension NextToArriveViewController: UpdateableFromViewModel {

    func viewModelUpdated() {
        guard let tableView = tableView else { return }
        scheduleLabel.text = viewModel.scheduleTitle()
        sectionHeaderLabel.text = viewModel.transitModeTitle()
        tableView.reloadData()
    }

    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message: String, shouldDismissAfterDisplay _: Bool = false) {
        UIAlert.presentOKAlertFrom(viewController: self, withTitle: "Select Schedule", message: message)
    }
}

extension NextToArriveViewController: SchedulesViewModelDelegate {

    func formIsComplete(_ isComplete: Bool) {
        guard let tableView = tableView else { return }
        formIsComplete = isComplete
        tableView.reloadData()
    }
}
