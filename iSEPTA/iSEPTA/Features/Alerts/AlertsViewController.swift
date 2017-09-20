//
//  AlertsViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class AlertsViewController: UIViewController {
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

    let buttonRow = 1

    var formIsComplete = false
    var targetForScheduleAction: TargetForScheduleAction! { return store.state.targetForScheduleActions() }

    var viewModel: AlertsViewModel!

    @IBAction func resetButtonTapped(_: Any) {
        store.dispatch(ResetSchedule(targetForScheduleAction: targetForScheduleAction))
    }

    override func viewDidLoad() {
        viewModel = AlertsViewModel()
        viewModel.delegate = self
        viewModel.schedulesDelegate = self
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

    func ViewAlertDetailButtonTapped() {
        let action = PushViewController(viewController: .alertDetailViewController, description: "Show Trip Schedule")
        store.dispatch(action)
    }
}

extension AlertsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in _: UITableView) -> Int {
        return 2
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
            cell.buttonText = "View Status"
            cell.enabled = formIsComplete
            return cell
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section < buttonRow {
            viewModel.rowSelected(indexPath.section)

        } else {
            ViewAlertDetailButtonTapped()
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
        return viewModel.heightForSectionHeader(atRow: section)
    }

    func updateHeaderLabels() {
        scheduleLabel.text = viewModel.scheduleTitle()
        sectionHeaderLabel.text = viewModel.transitModeTitle()
    }
}

extension AlertsViewController: UpdateableFromViewModel {

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

extension AlertsViewController: SchedulesViewModelDelegate {

    func formIsComplete(_ isComplete: Bool) {
        guard let tableView = tableView else { return }
        formIsComplete = isComplete
        tableView.reloadData()
    }
}
