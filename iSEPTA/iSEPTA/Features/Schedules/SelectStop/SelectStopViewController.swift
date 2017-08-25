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

class SelectStopViewController: UIViewController, StoreSubscriber, IdentifiableController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel {
    typealias StoreSubscriberStateType = StopToSelect?
    @IBOutlet weak var viewModel: SelectStopViewModel!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var searchbyTextView: UIView!
    @IBOutlet var tableFooterView: UIView!
    @IBOutlet weak var dismissIcon: UIView!

    static var viewController: ViewController = .routesViewController
    let cellId = "stopCell"
    @IBOutlet weak var searchTextBox: UITextField!

    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            let font = UIFont.systemFont(ofSize: 11, weight: .medium)
            segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: font],
                                                    for: .normal)
        }
    }

    @IBAction func DismissViewTapped(_: Any) {
        let dismissAction = DismissModal(navigationController: .schedules, description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBAction func cancelButtonPressed(_: Any) {
    }

    @IBAction func searchMethodToggled(_: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchbyTextView.layer.cornerRadius = 3.0
        searchbyTextView.layer.borderColor = SeptaColor.subSegmentBlue.cgColor
        searchbyTextView.layer.borderWidth = 1.0
        dismissIcon.layer.cornerRadius = 3.0
    }

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

    override func viewWillDisappear(_: Bool) {
        viewModel.unsubscribe()
    }

    override func viewWillAppear(_: Bool) {
        subscribe()
    }

    func subscribe() {

        store.subscribe(self) {
            $0.select {
                $0.scheduleState.scheduleRequest?.stopToEdit
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let state = state else { return }
        viewModel.stopToSelect = state

        store.unsubscribe(self)
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }

    func viewModelUpdated() {

        tableView.reloadData()
    }
}
