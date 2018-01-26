//
//  AlertsViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class AlertsViewController: UIViewController, IdentifiableController {
    let viewController: ViewController = .alertsViewController

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
    @IBOutlet var tableViewWrapperView: UIView!
    var genericAlertDetailCellView: GenericAlertDetailCellView!
    var appAlertDetailCellView: GenericAlertDetailCellView!

    var alertState_HasGenericAlertsWatcher: AlertState_HasGenericAlertsWatcher!
    var alertState_HasAppAlertsWatcher: AlertState_HasAppAlertsWatcher!

    @IBOutlet var genericAlertsTableViewWrapper: UIView! {
        didSet {
            genericAlertDetailCellView = genericAlertsTableViewWrapper.awakeInsertAndPinSubview(nibName: "GenericAlertDetailCellView")
            genericAlertDetailCellView.genericAlertType = .genericAlert
        }
    }

    @IBOutlet var appAlertsTableViewWrapper: UIView! {
        didSet {
            appAlertDetailCellView = appAlertsTableViewWrapper.awakeInsertAndPinSubview(nibName: "GenericAlertDetailCellView")
            appAlertDetailCellView.genericAlertType = .appAlert
        }
    }

    @IBOutlet var appAlertsTopConstraintToGenericAlertsView: NSLayoutConstraint!

    @IBOutlet var genericAlertsTableView: UITableView!
    let buttonRow = 1

    var formIsComplete = false
    var targetForScheduleAction: TargetForScheduleAction! {
        return store.state.targetForScheduleActions()
    }

    var viewModel: AlertsViewModel!

    @IBAction func resetButtonTapped(_: Any) {
        store.dispatch(ResetSchedule(targetForScheduleAction: targetForScheduleAction))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AlertsViewModel()
        viewModel.delegate = self
        viewModel.schedulesDelegate = self
        view.backgroundColor = SeptaColor.navBarBlue
        tableView.tableFooterView = tableViewFooter

        buttonView.isHidden = true
        UIView.addSurroundShadow(toView: tableViewWrapperView)

        updateHeaderLabels()

        genericAlertDetailCellView.isGenericAlert = true
        alertState_HasGenericAlertsWatcher = AlertState_HasGenericAlertsWatcher()
        alertState_HasGenericAlertsWatcher.delegate = self

        alertState_HasAppAlertsWatcher = AlertState_HasAppAlertsWatcher()
        alertState_HasAppAlertsWatcher.delegate = self
    }

    override func viewWillAppear(_: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            return
        }

        navBar.shadowImage = UIImage()
        navBar.setBackgroundImage(UIImage(), for: .default)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.formIsCompleteUpdateNeeded()
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "buttonViewCell", for: indexPath) as? ButtonViewCell else {
                return ButtonViewCell()
            }
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
        guard let tableView = tableView else {
            return
        }
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
        guard let tableView = tableView else {
            return
        }
        formIsComplete = isComplete
        tableView.reloadData()
    }
}

extension AlertsViewController: AlertState_HasGenericAlertsWatcherDelegate {
    func alertState_HasGenericAlertsUpdated(bool hasAlerts: Bool) {
        genericAlertsTableViewWrapper.isHidden = !hasAlerts
        appAlertsTopConstraintToGenericAlertsView.isActive = hasAlerts
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

extension AlertsViewController: AlertState_HasAppAlertsWatcherDelegate {
    func alertState_HasAppAlertsUpdated(bool hasAlerts: Bool) {
        appAlertsTableViewWrapper.isHidden = !hasAlerts
    }
}
