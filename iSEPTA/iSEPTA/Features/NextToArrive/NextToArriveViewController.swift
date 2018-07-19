// Septa. 2017

import ReSwift
import SeptaSchedule
import UIKit

class NextToArriveViewController: BaseNonModalViewController, IdentifiableController {
    let viewController: ViewController = .nextToArriveController
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

    let buttonRow = 3

    var formIsComplete = false
    var targetForScheduleAction: TargetForScheduleAction! { return store.state.targetForScheduleActions() }

    @IBOutlet var viewModel: NextToArriveViewModel!

    @IBAction func resetButtonTapped(_: Any) {
        store.dispatch(ResetSchedule(targetForScheduleAction: targetForScheduleAction))
    }

    override func viewDidLoad() {

        view.backgroundColor = SeptaColor.navBarBlue
        tableView.tableFooterView = tableViewFooter

        buttonView.isHidden = true
        UIView.addSurroundShadow(toView: tableViewWrapper)

        updateHeaderLabels()
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
        let action = PushViewController(viewController: .nextToArriveDetailController, description: "Show Trip Schedule")
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "buttonViewCell", for: indexPath) as? ButtonViewCell else { return ButtonViewCell() }
            cell.buttonText = SeptaString.NextToArriveTitle
            cell.enabled = formIsComplete
            cell.lastCellDelegate = viewModel
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
        if viewModel.shouldDisplayBlankSectionHeaderForSection(section) {
            return section1View
        } else {
            return section0View
        }
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForSectionHeader(atRow: section)
    }

    func updateHeaderLabels() {
        scheduleLabel.text = viewModel.scheduleTitle()
        scheduleLabel.accessibilityTraits = UIAccessibilityTraitHeader
        sectionHeaderLabel.text = viewModel.transitModeTitle()
    }

}

extension NextToArriveViewController: UpdateableFromViewModel {

    func viewModelUpdated() {
        guard let tableView = tableView else { return }
        updateHeaderLabels()
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
