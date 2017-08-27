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
    typealias StoreSubscriberStateType = ScheduleStopEdit?
    @IBOutlet weak var viewModel: SelectStopViewModel! {
        didSet {
            headerViewController?.textField.delegate = viewModel
        }
    }

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var searchbyTextView: UIView!

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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func dismissModal() {
        let dismissAction = DismissModal(navigationController: .schedules, description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBAction func cancelButtonPressed(_: Any) {
    }

    @IBAction func searchMethodToggled(_: Any) {
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

    var headerViewController: SearchModalHeaderViewController?

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "embedHeader" {
            if let headerViewController = segue.destination as? SearchModalHeaderViewController {
                self.headerViewController = headerViewController
                headerViewController.delegate = self
                headerViewController.textFieldDelegate = viewModel
            }
        }
    }

    func animatedLayoutNeeded(block: @escaping (() -> Void), completion: @escaping (() -> Void)) {

        UIView.animate(withDuration: 0.25, animations: {
            block()
            self.view.layoutIfNeeded()

        }, completion: {
            _ in completion()

        })
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
                $0.scheduleState.scheduleStopEdit
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let state = state else { return }
        viewModel.stopToSelect = state.stopToEdit
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }

    func viewModelUpdated() {

        tableView.reloadData()
    }
}
