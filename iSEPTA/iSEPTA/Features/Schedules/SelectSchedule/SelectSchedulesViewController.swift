// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class SelectSchedulesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel, IdentifiableController, SchedulesViewModelDelegate {
    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message _: String) {
    }

    @IBOutlet weak var tableViewWrapper: UIView!
    @IBOutlet var sectionHeaders: [UIView]!

    @IBOutlet weak var scheduleLabel: UILabel!
    static var viewController: ViewController = .selectSchedules
    let buttonRow = 3
    @IBOutlet var section1View: UIView!
    @IBOutlet var section0View: UIView!
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    var formIsComplete = false
    @IBOutlet var buttons: [UIButton]!

    @IBAction func resetButtonTapped(_: Any) {
        store.dispatch(ResetSchedule())
    }

    let cellId = "singleStringCell"
    let buttonCellId = "buttonViewCell"
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var tableViewFooter: UIView!
    var viewModel: SelectSchedulesViewModel!

    override func viewDidLoad() {
        viewModel = SelectSchedulesViewModel(delegate: self)
        view.backgroundColor = SeptaColor.navBarBlue
        tableView.tableFooterView = tableViewFooter
        viewModel.subscribe()
        viewModel.schedulesDelegate = self
        buttonView.isHidden = true
        UIView.addSurroundShadow(toView: tableViewWrapper)
    }

    override func viewWillAppear(_: Bool) {
        guard let navBar = navigationController?.navigationBar else { return }

        navBar.shadowImage = UIImage()
        navBar.setBackgroundImage(UIImage(), for: .default)
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 4
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section < buttonRow {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SingleStringCell else { return UITableViewCell() }
            viewModel.configureDisplayable(cell, atRow: indexPath.section)
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

    func viewModelUpdated() {
        scheduleLabel.text = viewModel.scheduleTitle()
        sectionHeaderLabel.text = viewModel.transitModeTitle()
        tableView.reloadData()
    }

    func formIsComplete(_ isComplete: Bool) {
        formIsComplete = isComplete
        tableView.reloadData()
    }

    func ViewSchedulesButtonTapped() {
        let action = PushViewController(navigationController: .schedules, viewController: .tripScheduleController, description: "Show Trip Schedule")
        store.dispatch(action)
    }

    deinit {
        viewModel.unsubscribe()
    }
}
