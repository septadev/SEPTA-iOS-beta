//
//  CustomNotificationsViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/27/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class CustomPushNotificationsViewController: UITableViewController, IdentifiableController, StoreSubscriber {
    var viewController: ViewController = .customPushNotificationsController
    typealias StoreSubscriberStateType = [PushNotificationRoute]

    var headerView: UIView!
    var viewModel = CustomPushNotificationsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        headerView = UIView.instanceFromNib(named: "MyNotificationsHeaderView")
//
//        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView
//        headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
//        headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
//        headerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.register(UINib(nibName: "PushNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "pushCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) {
            $0.select { $0.preferenceState.pushNotificationPreferenceState.routeIds }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    func newState(state: StoreSubscriberStateType) {
        viewModel.routes = state
        tableView.reloadData()
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfRows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pushCell") as? PushNotificationTableViewCell else { return UITableViewCell() }
        viewModel.configureCellAtRow(cell: cell, row: indexPath.row)
        return cell
    }
}
