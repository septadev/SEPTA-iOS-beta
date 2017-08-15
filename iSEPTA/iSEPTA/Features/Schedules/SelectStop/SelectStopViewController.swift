//
//  SelectStopViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/14/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class SelectStopViewController: UIViewController, IdentifiableController, UITableViewDelegate, UITableViewDataSource, UpdateableFromViewModel {
    @IBOutlet var viewModel: SelectStopViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    static var viewController: ViewController = .routesViewController
    let cellId = "stopCell"
    @IBOutlet weak var searchTextBox: UITextField!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func cancelButtonPressed(_: Any) {
        let dismissAction = DismissModal(navigationController: .schedules, description: "Route should be dismissed")
        store.dispatch(dismissAction)
    }

    @IBAction func searchMethodToggled(_: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Select Start"
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SingleStringCell else { return UITableViewCell() }

        viewModel.configureDisplayable(cell, atRow: indexPath.row)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(row: indexPath.row)
    }

    func viewModelUpdated() {
        activityIndicator.removeFromSuperview()
        tableView.reloadData()
    }

    deinit {
    }
}
