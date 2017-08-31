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
    typealias StoreSubscriberStateType = ScheduleStopEdit?

    static var viewController: ViewController = .selectStopController

    @IBOutlet weak var stopsViewModel: SelectStopViewModel! {
        didSet {
            headerViewController?.textField.delegate = stopsViewModel
        }
    }

    @IBOutlet var selectAddressRelativeStopViewModel: SelectAddressRelativeStopViewModel!
    @IBOutlet var selectAddressViewModel: SelectAddressViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var headerViewController: SearchStopsModalHeaderViewController?

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "embedHeader" {
            if let headerViewController = segue.destination as? SearchStopsModalHeaderViewController {
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

        } else if state.searchMode == .byAddress {
            tableView.dataSource = selectAddressViewModel
            tableView.delegate = selectAddressViewModel
            headerViewController?.textField.delegate = selectAddressViewModel
        } else {
            tableView.dataSource = selectAddressRelativeStopViewModel
            tableView.delegate = selectAddressRelativeStopViewModel
        }
        tableView.reloadData()
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

    override func viewWillAppear(_: Bool) {
        subscribe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewHasAppeared = true
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }

    func viewModelUpdated() {

        tableView.reloadData()
    }

    var shouldBeAnimatingActivityIndicator = true {
        didSet {
            updateActivityIndicator()
        }
    }

    var viewHasAppeared = false {
        didSet {
            updateActivityIndicator()
        }
    }

    func updateActivityIndicator() {
        if viewHasAppeared && shouldBeAnimatingActivityIndicator {
            activityIndicator.startAnimating()
        } else if viewHasAppeared && !shouldBeAnimatingActivityIndicator {
            activityIndicator.stopAnimating()
        }
    }

    func updateActivityIndicator(animating: Bool) {
        shouldBeAnimatingActivityIndicator = animating
    }

    func displayErrorMessage(message: String) {
        UIAlert.presentOKAlertFrom(viewController: self,
                                   withTitle: "Select Stop",
                                   message: message) { [weak self] in
            self?.dismissModal()
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

    func layoutNeeded() {
        view.layoutIfNeeded()
    }
}
