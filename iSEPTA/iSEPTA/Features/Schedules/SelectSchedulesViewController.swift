// Septa. 2017

import UIKit
import SeptaSchedule
import ReSwift

class SelectSchedulesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel {
    let cellId = "singleStringCell"
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var tableViewFooter: UIView!
    var viewModel: SelectSchedulesViewModel!
    override func viewDidLoad() {
        viewModel = SelectSchedulesViewModel(delegate: self)
        view.backgroundColor = UIColor(red: 0.600, green: 0.600, blue: 0.600, alpha: 1.000)
    }

    override func viewWillAppear(_: Bool) {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.backgroundColor = UIColor.clear
        navBar.shadowImage = UIImage()
        navBar.setBackgroundImage(UIImage(), for: .default)
        viewModel.subscribe()
    }

    override func viewWillDisappear(_: Bool) {
        viewModel.unsubscribe()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SingleStringCell else { return UITableViewCell() }

        viewModel.configureDisplayable(cell, atRow: indexPath.row)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(indexPath.row)
    }

    func tableView(_: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return viewModel.canCellBeSelected(atRow: indexPath.row) ? indexPath : nil
    }

    func viewModelUpdated() {
        tableView.reloadData()
    }
}
