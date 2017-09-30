//
//  AlertDetailViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import SeptaSchedule
import SeptaRest

class AlertDetailViewController: UIViewController, IdentifiableController {
    let viewController: ViewController = .alertDetailViewController

    let watcher = AlertState_AlertDetailsWatcher()
    var alertDetails = [AlertDetails_Alert]() {
        didSet {
            tableView.reloadData()
        }
    }

    let cellId = "alertDetailCell"
    @IBOutlet weak var routeNameLabel: UILabel! {
        didSet {
        }
    }

    @IBOutlet weak var tableView: UITableView! {
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

    @IBOutlet weak var pillView: UIView!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        watcher.delegate = self
        view.backgroundColor = SeptaColor.navBarBlue

        setTitle()
        alertDetails = store.state.alertState.alertDetails
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
        return 4
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
        self.tableView.reloadData()
    }
}

private extension String {

    var htmlAttributedString: NSAttributedString? {
        let htmlString = "<html>\(self)</html>"
        do {
            guard let data = htmlString.data(using: .utf8) else { return nil }
            return try NSAttributedString(data: data, options: [
                NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            ], documentAttributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
}

extension AlertDetailViewController {

    func configureForServiceAdvisories(cell: AlertDetailCell) {

        cell.alertImage.image = UIImage(named: "advisoryAlert")
        cell.advisoryLabel.text = "Service Advisories"
        cell.disabledAdvisoryLabel.text = "No Service Advisories"
        let message = renderMessage(alertDetails: alertDetails) { return $0.advisory_message }
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
        let message = renderMessage(alertDetails: alertDetails) { return $0.message }
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
        let message = renderMessage(alertDetails: alertDetails) { return $0.detour?.message }
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

    func renderMessage(alertDetails: [AlertDetails_Alert], filter: ((AlertDetails_Alert) -> String?)) -> NSAttributedString? {
        let message: String = alertDetails.filter({
            guard let message = filter($0) else { return false }
            return message.count > 0
        }).map({ filter($0)! }).joined(separator: "")

        if message.count > 0 {
            return message.htmlAttributedString
        } else {
            return nil
        }
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
