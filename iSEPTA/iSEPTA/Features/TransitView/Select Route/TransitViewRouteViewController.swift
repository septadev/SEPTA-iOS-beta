//
//  TransitViewRouteViewController.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit
import ReSwift

class TransitViewRouteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = TransitViewRoutesViewModel()
    
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "embedHeader" {
            if let headerViewController = segue.destination as? SearchRoutesModalHeaderViewController {
                headerViewController.delegate = self
                headerViewController.textFieldDelegate = self
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribe()
        viewModel.updateableFromViewModelController = self
    }

    deinit {
        store.unsubscribe(self)
    }
}

extension TransitViewRouteViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = TransitViewModel
    
    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.transitViewState.transitViewModel }.skipRepeats { $0 == $1 }
        }
    }
    
    func newState(state: StoreSubscriberStateType) {
        viewModel.slotBeingChanged = state.slotBeingChanged
    }
}

extension TransitViewRouteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "transitRouteCell", for: indexPath) as? RouteTableViewCell else {
            return UITableViewCell()
        }
        viewModel.configure(cell: cell, atRow: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(row: indexPath.row)
    }
}

extension TransitViewRouteViewController: SearchModalHeaderDelegate {
    
    func dismissModal() {
        let dismissAction = DismissModal(description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }
    
    // Unimplemented functions
    func animatedLayoutNeeded(block: @escaping (() -> Void), completion: @escaping (() -> Void)) {}
    func layoutNeeded() {}
    func updateActivityIndicator(animating: Bool) {}
    func sortAlphaTapped(direction: SortOrder) {}
    func sortByStopOrderTapped() {}
    
}

extension TransitViewRouteViewController: UpdateableFromViewModel {
    func viewModelUpdated() {
        tableView.reloadData()
    }
    
    func displayErrorMessage(message: String, shouldDismissAfterDisplay: Bool) {
        print(message)
    }
    
}

extension TransitViewRouteViewController: UITextFieldDelegate {
    
}
