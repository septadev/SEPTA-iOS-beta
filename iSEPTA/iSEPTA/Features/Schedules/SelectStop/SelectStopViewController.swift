//
//  SelectStopViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/14/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class SelectStopViewController: UIViewController, StoreSubscriber, IdentifiableController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel, SearchModalHeaderDelegate {
    static var viewController: ViewController = .selectStopController

    typealias StoreSubscriberStateType = ScheduleStopEdit?
    @IBOutlet weak var viewModel: SelectStopViewModel! {
        didSet {
            headerViewController?.textField.delegate = viewModel
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var headerViewController: SearchModalHeaderViewController?

    let cellId = "stopCell"

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        let rowCount = viewModel.numberOfRows()
        if rowCount > 0 {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SelectStopCell else { return UITableViewCell() }

        viewModel.configureDisplayable(cell, atRow: indexPath.row)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(row: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "embedHeader" {
            if let headerViewController = segue.destination as? SearchModalHeaderViewController {
                self.headerViewController = headerViewController
                headerViewController.delegate = self
                headerViewController.textFieldDelegate = viewModel
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let state = state else { return }
        viewModel.stopToSelect = state.stopToEdit
    }

    override func viewWillAppear(_: Bool) {
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.scheduleState.scheduleStopEdit
            }
        }
    }

    func dismissModal() {
        let dismissAction = DismissModal(navigationController: .schedules, description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }

    override func viewWillDisappear(_: Bool) {
        viewModel.unsubscribe()
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }

    func viewModelUpdated() {

        tableView.reloadData()
    }

    func animatedLayoutNeeded(block: @escaping (() -> Void), completion: @escaping (() -> Void)) {

        UIView.animate(withDuration: 0.25, animations: {
            block()
            self.view.layoutIfNeeded()

        }, completion: {
            _ in completion()
        })
    }
}
