// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class SelectSchedulesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel, IdentifiableController, SchedulesViewModelDelegate {
    @IBOutlet weak var tableViewWrapper: UIView!
    @IBOutlet var sectionHeaders: [UIView]!

    @IBOutlet weak var scheduleLabel: UILabel!
    static var viewController: ViewController = .selectSchedules

    @IBOutlet var section1View: UIView!
    @IBOutlet var section0View: UIView!
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBAction func ViewSchedulesButtonTapped(_: Any) {
        let action = PushViewController(navigationController: .schedules, viewController: .tripScheduleController, description: "Show Trip Schedule")
        store.dispatch(action)
    }

    @IBAction func resetButtonTapped(_: Any) {
        store.dispatch(ResetSchedule())
    }

    let cellId = "singleStringCell"
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
        return 3
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SingleStringCell else { return UITableViewCell() }
        let row = indexPath.section + indexPath.row
        viewModel.configureDisplayable(cell, atRow: row)
        viewModel.configureBorder(cell, atRow: row)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.section + indexPath.row
        viewModel.rowSelected(row)
    }

    func tableView(_: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let row = indexPath.section + indexPath.row
        return viewModel.canCellBeSelected(atRow: row)
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? section0View : section1View
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        switch section {
        case 0: return 37
        case 1: return 21
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
        buttonView.isHidden = !isComplete
    }

    deinit {
        viewModel.unsubscribe()
    }
}
