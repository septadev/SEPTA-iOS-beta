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

class SelectStopViewController: UIViewController, StoreSubscriber, IdentifiableController {
    typealias StoreSubscriberStateType = ScheduleStopEdit?
    let viewController: ViewController = .selectStopController

    @IBOutlet var selectAddressRelativeStopViewModel: SelectAddressRelativeStopViewModel!
    @IBOutlet var selectAddressViewModel: SelectAddressViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var stopsViewModel: SelectStopViewModel! {
        didSet {
            headerViewController?.textField.delegate = stopsViewModel
        }
    }

    var locationListener: LocationServicesListener?
    var headerViewController: SearchStopsModalHeaderViewController?

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

    override func awakeFromNib() {
        locationListener = LocationServicesListener()
        locationListener?.delegate = self
    }

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

    func displayErrorMessage(message: String, shouldDismissAfterDisplay: Bool = false) {
        UIAlert.presentOKAlertFrom(viewController: self,
                                   withTitle: "Select Stop",
                                   message: message) { [weak self] in
            if shouldDismissAfterDisplay {
                self?.dismissModal()
            }
        }
    }

    func updateActivityIndicator(animating: Bool) {
        shouldBeAnimatingActivityIndicator = animating
    }
}

extension SelectStopViewController: UpdateableFromViewModel {
    func viewModelUpdated() {
        guard let tableView = tableView else { return }
        tableView.reloadData()
    }

    func updateActivityIndicator() {
        if viewHasAppeared && shouldBeAnimatingActivityIndicator {
            activityIndicator.startAnimating()
        } else if viewHasAppeared && !shouldBeAnimatingActivityIndicator {
            activityIndicator.stopAnimating()
        }
    }
}

extension SelectStopViewController: SubscriberUnsubscriber {

    override func viewWillAppear(_: Bool) {
        subscribe()
    }

    func subscribe() {
        if store.state.navigationState.activeNavigationController == .schedules {
            store.subscribe(self) {
                $0.select {
                    $0.scheduleState.scheduleStopEdit
                }.skipRepeats { $0 == $1 }
            }
        } else if store.state.navigationState.activeNavigationController == .nextToArrive {
            store.subscribe(self) {
                $0.select {
                    $0.nextToArriveState.scheduleState.scheduleStopEdit
                }.skipRepeats { $0 == $1 }
            }
        }
    }

    override func viewWillDisappear(_: Bool) {
        stopsViewModel.unsubscribe()
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}

extension SelectStopViewController: SearchModalHeaderDelegate {
    func animatedLayoutNeeded(block: @escaping (() -> Void), completion: @escaping (() -> Void)) {
        UIView.animate(withDuration: 0.25, animations: {
            block()
            self.view.layoutIfNeeded()
            self.tableView.reloadData()
        }, completion: {
            _ in completion()
        })
    }

    func layoutNeeded() {
        view.layoutIfNeeded()
    }

    func dismissModal() {

        let dismissAction = DismissModal(description: "Stop should be dismissed")
        store.dispatch(dismissAction)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewHasAppeared = true
    }
}
