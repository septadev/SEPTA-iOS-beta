//
//  AlertDetailViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import SeptaSchedule
import UIKit

class AlertDetailViewController: UIViewController, IdentifiableController {
    let viewController: ViewController = .alertDetailViewController

    var watcher: AlertState_AlertDetailsWatcher!
    var alertDetails = [AlertDetails_Alert]() {
        didSet {
        }
    }

    let cellId = "alertDetailCell"
    @IBOutlet var routeNameLabel: UILabel! {
        didSet {
        }
    }

    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            let cellNib = UINib(nibName: "AlertDetailCell", bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: cellId)
            tableView.estimatedRowHeight = 80
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.backgroundColor = UIColor.clear
            tableView.allowsSelection = false
        }
    }

    var advisoryCell: AlertDetailCell?
    var alertCell: AlertDetailCell?
    var detourCell: AlertDetailCell?
    var weatherCell: AlertDetailCell?

    override func viewDidDisappear(_: Bool) {
        advisoryCell = nil
        alertCell = nil
        detourCell = nil
        weatherCell = nil
    }

    @IBOutlet var pillView: UIView!

    func updateHeaderViews() {
        guard let route = route else { return }
        pillView.layer.cornerRadius = 7
        pillView.backgroundColor = Route.colorForRoute(route, transitMode: transitMode)
        routeNameLabel.text = route.routeAlertTitle()
        navigationItem.title = transitMode.alertDetailTitle()
    }

    var transitMode: TransitMode {
        return scheduleRequest.transitMode
    }

    var scheduleRequest: ScheduleRequest {
        return store.state.alertState.scheduleState.scheduleRequest
    }

    var route: Route? {
        return scheduleRequest.selectedRoute
    }

    var alertDetailFooterView: AlertDetailFooterView! {
        didSet {
            guard let view = alertDetailFooterView else { return }
            view.translatesAutoresizingMaskIntoConstraints = false
            alertDetailFooterViewFooterCell = UITableViewCell(style: .default, reuseIdentifier: "footerCell")
            alertDetailFooterViewFooterCell.contentView.addSubview(view)
            alertDetailFooterViewFooterCell.contentView.pinSubview(view)
            alertDetailFooterViewFooterCell.backgroundColor = UIColor.clear
        }
    }

    var alertDetailFooterViewFooterCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = SeptaColor.navBarBlue

        setTitle()
        alertDetails = store.state.alertState.alertDetails

        configureFooterViewData()

        watcher = AlertState_AlertDetailsWatcher()
        watcher.delegate = self
    }

    func configureFooterViewData() {
        alertDetailFooterView = UIView.instanceFromNib(named: "AlertDetailFooterView")
        guard let route = route else { return }
        let routeId = route.routeId
        let routeName = route.shortNameOverrideForRoute(transitMode: transitMode) ?? route.routeShortName
        alertDetailFooterView.pushNotificationRoute = PushNotificationRoute(routeId: routeId, routeName: routeName, transitMode: transitMode)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        backButtonPopped(toParentViewController: parent)
    }

    func setTitle() {
        navigationItem.title = transitMode.alertDetailTitle()
    }
}

extension AlertDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 5
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return 5
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        view.backgroundColor = UIColor.clear
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AlertDetailCell else { return UITableViewCell() }
        cell.sectionNumber = indexPath.section
        cell.delegate = self
        cell.initializeCellAsClosed()
        cell.setEnabled(false)
        switch indexPath.section {
        case 0:
            if let advisoryCell = advisoryCell {
                configureForServiceAdvisories(cell: advisoryCell)
                cell = advisoryCell
            } else {
                configureForServiceAdvisories(cell: cell)
            }
        case 1:
            if let alertCell = alertCell {
                configureForServiceAlerts(cell: alertCell)
                cell = alertCell
            } else {
                configureForServiceAlerts(cell: cell)
            }
        case 2:
            if let detourCell = detourCell {
                configureForDetours(cell: detourCell)
                cell = detourCell
            } else {
                configureForDetours(cell: cell)
            }
        case 3:
            if let weatherCell = weatherCell {
                configureForWeather(cell: weatherCell)
                cell = weatherCell
            } else {
                configureForWeather(cell: cell)
            }
        case 4:
            return alertDetailFooterViewFooterCell
        default: break
        }

        return cell
    }
}

extension AlertDetailViewController: AlertState_AlertDetailsWatcherDelegate {
    func alertState_AlertDetailsUpdated(alertDetails: [AlertDetails_Alert]) {
        if alertDetails.count == 0 {
            print("We got a failed alert details back")
        }
        updateHeaderViews()
        self.alertDetails = alertDetails
        tableView.reloadData()
    }
}

extension AlertDetailViewController {
    func configureForServiceAdvisories(cell: AlertDetailCell) {
        cell.alertImage.image = UIImage(named: "advisoryAlert")
        cell.advisoryLabel.text = "Service Advisories"
        cell.disabledAdvisoryLabel.text = "No Service Advisories"
        let message = AlertDetailsViewModel.renderMessage(alertDetails: alertDetails) { return $0.advisory_message }
        if let message = message {
            cell.setEnabled(true)
            cell.textView.attributedText = message
        } else {
            cell.textView.text = nil
            cell.setEnabled(false)
        }
        advisoryCell = cell
    }

    func configureForServiceAlerts(cell: AlertDetailCell) {
        cell.alertImage.image = UIImage(named: "alertAlert")
        cell.advisoryLabel.text = "Service Alerts"
        cell.disabledAdvisoryLabel.text = "No Service Alerts"
        let message = AlertDetailsViewModel.renderMessage(alertDetails: alertDetails) { return $0.message }
        if let message = message {
            cell.setEnabled(true)
            cell.textView.attributedText = message
        } else {
            cell.textView.text = nil
            cell.setEnabled(false)
        }
        alertCell = cell
    }

    func configureForDetours(cell: AlertDetailCell) {
        cell.alertImage.image = UIImage(named: "detourAlert")
        cell.advisoryLabel.text = "Active Detours"
        cell.disabledAdvisoryLabel.text = "No Active Detours"
        let message = AlertDetailsViewModel.renderMessage(alertDetails: alertDetails) { return $0.detour?.wrappedMessage }
        if let message = message {
            cell.setEnabled(true)
            cell.textView.attributedText = message
        } else {
            cell.textView.text = nil
            cell.setEnabled(false)
        }
        detourCell = cell
    }

    func configureForWeather(cell: AlertDetailCell) {
        cell.alertImage.image = UIImage(named: "weatherAlert")
        cell.advisoryLabel.text = "Weather Alerts"
        cell.disabledAdvisoryLabel.text = "No Weather Alerts"

        cell.textView.text = nil
        cell.setEnabled(false)
        weatherCell = cell
    }
}

extension AlertDetailViewController: AlertDetailCellDelegate {
    func didTapButton(sectionNumber _: Int) {
        tableView.beginUpdates()
    }

    func constraintsChanged(sectionNumber _: Int) {
        tableView.endUpdates()
    }
}
