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

class SelectStopViewController: UIViewController, StoreSubscriber, IdentifiableController, UpdateableFromViewModel, SearchModalHeaderDelegate {
    func updateActivityIndicator(animating: Bool) {
        if animating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func displayErrorMessage(message: String) {
        Alert.presentOKAlertFrom(viewController: self,
                                 withTitle: "SEPTA Alert",
                                 message: message,
                                 completion: nil)
    }

    static var viewController: ViewController = .selectStopController

    typealias StoreSubscriberStateType = ScheduleStopEdit?
    @IBOutlet weak var stopsViewModel: SelectStopViewModel! {
        didSet {
            headerViewController?.textField.delegate = stopsViewModel
        }
    }

    @IBOutlet var selectAddressViewModel: SelectAddressViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var headerViewController: SearchModalHeaderViewController?

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "embedHeader" {
            if let headerViewController = segue.destination as? SearchModalHeaderViewController {
                self.headerViewController = headerViewController
                headerViewController.delegate = self
                headerViewController.textFieldDelegate = stopsViewModel
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let state = state else { return }
        stopsViewModel.stopToSelect = state.stopToEdit
        if state.searchMode == .directLookup {
            tableView.dataSource = stopsViewModel
            tableView.delegate = stopsViewModel
            headerViewController?.textField.delegate = stopsViewModel
        }
        if state.searchMode == .byAddress {
            tableView.dataSource = selectAddressViewModel
            tableView.delegate = selectAddressViewModel
            headerViewController?.textField.delegate = selectAddressViewModel
        }
        tableView.reloadData()
    }

    override func viewWillAppear(_: Bool) {
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.scheduleState.scheduleStopEdit
            }.skipRepeats { $0 == $1 }
        }
    }

    func dismissModal() {
        let dismissAction = DismissModal(navigationController: .schedules, description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }

    override func viewWillDisappear(_: Bool) {
        stopsViewModel.unsubscribe()
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
