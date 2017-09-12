//
//  NextToArriveInfoViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NextToArriveInfoViewController: UIViewController {

    @IBOutlet var upSwipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var downSwipeGestureRecognizer: UISwipeGestureRecognizer!

    @IBOutlet weak var tableView: UITableView!
    weak var nextToArriveDetailViewController: NextToArriveDetailViewController?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var tableFooterView: UIView!
    var viewModel: NextToArriveInfoViewModel!

    override func viewDidLoad() {

        nextToArriveDetailViewController?.upSwipeGestureRecognizer = upSwipeGestureRecognizer
        nextToArriveDetailViewController?.downSwipeGestureRecognizer = downSwipeGestureRecognizer

        viewModel = NextToArriveInfoViewModel()
        viewModel.delegate = self
        titleLabel.text = viewModel.viewTitle()
        tableView.tableFooterView = tableFooterView
    }
}

extension NextToArriveInfoViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = viewModel.cellIdAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        viewModel.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 60
    }
}

extension NextToArriveInfoViewController: UpdateableFromViewModel {
    func viewModelUpdated() {
        tableView.reloadData()
    }

    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message _: String, shouldDismissAfterDisplay _: Bool) {
    }
}
