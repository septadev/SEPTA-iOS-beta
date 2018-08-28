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

    var saveButton = UIBarButtonItem()

    var headerView: MyNotificationsHeaderView!
    var viewModel = CustomPushNotificationsViewModel()

    var rowsToDelete = [PushNotificationRoute]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        configureNavBar()

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

    private func configureNavBar() {
        // Left side
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back(_:)))
        navigationItem.leftBarButtonItem = backButton

        // Right side
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
        navigationItem.setRightBarButton(saveButton, animated: false)
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

    var firstPass = true
    func newState(state: StoreSubscriberStateType) {
        saveButton.isEnabled = state.synchronizationStatus == .pendingSave
        viewModel.routes = state.routeIds
        tableView.tableHeaderView = headerView
        if state.routeIds.count == 0 {
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 100))
        } else {
            tableView.tableFooterView = nil
        }

        tableView.reloadData()
    }

    @objc func back(_: Any) {
        // If changes have been made
        if saveButton.isEnabled {
            let alert = UIAlertController(title: "Unsaved Changes", message: "Would you like to save your modified push notification preferences?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
                DispatchQueue.main.async {
                    store.dispatch(PushNotificationPreferenceSynchronizationFail())
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.saveButton.isEnabled = false
                    store.dispatch(PostPushNotificationPreferences(postNow: true, showSuccess: true, viewController: nil))
                }
            }))
            present(alert, animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc func save(_: Any) {
        saveButton.isEnabled = false
        store.dispatch(PostPushNotificationPreferences(postNow: true, showSuccess: true, viewController: nil))
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

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }
}
