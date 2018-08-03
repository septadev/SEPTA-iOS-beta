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

class CustomPushNotificationsViewController: UITableViewController, IdentifiableController, StoreSubscriber, CustomNotificationEditDelegate {
    var viewController: ViewController = .customPushNotificationsController
    typealias StoreSubscriberStateType = PushNotificationPreferenceState

    var headerView: MyNotificationsHeaderView!
    var viewModel = CustomPushNotificationsViewModel()

    var rowsToDelete = [PushNotificationRoute]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        headerView = UIView.instanceFromNib(named: "MyNotificationsHeaderView")
        guard let addEditView = headerView.addEditViewWrapper.contentView as? AddEditView else { return }
        addEditView.editDelegate = self
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(headerView)

        tableView.tableHeaderView = containerView
        containerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.register(UINib(nibName: "PushNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "pushCell")
        tableView.allowsMultipleSelectionDuringEditing = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) {
            $0.select { $0.preferenceState.pushNotificationPreferenceState }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isCurrentlyEditing(false)
        store.unsubscribe(self)
    }

    func newState(state: StoreSubscriberStateType) {
        viewModel.routes = state.routeIds
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = nil
        tableView.tableHeaderView = headerView
        if state.routeIds.count == 0 {
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 100))

        } else {
            tableView.tableFooterView = nil
        }

        tableView.reloadData()
    }

    func isCurrentlyEditing(_ editing: Bool) {
        tableView.setEditing(editing, animated: true)

        if !editing && rowsToDelete.count > 0 {
            let action = RemovePushNotificationRoute(routes: rowsToDelete, viewController: self)
            store.dispatch(action)
            rowsToDelete.removeAll()
        }
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

    override func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }

    override func tableView(_: UITableView, titleForDeleteConfirmationButtonForRowAt _: IndexPath) -> String? {
        return "Remove"
    }

    override func tableView(_: UITableView, commit _: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let routeToDelete = viewModel.routes[indexPath.row]
        rowsToDelete.append(routeToDelete)
        viewModel.routes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        backButtonPopped(toParentViewController: parent)
    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }
}
