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
        viewModel.registerViews(tableView: tableView)

        viewModel.delegate = self
        titleLabel.text = viewModel.viewTitle()
    }
}

extension NextToArriveInfoViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = viewModel.cellIdAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        viewModel.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewId = viewModel.viewIdForSection(section),
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: viewId) else { return nil }
        viewModel.configureSectionHeader(view: headerView, forSection: section)
        return headerView
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeaderInSection(section)
    }

    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection _: Int) {
        view.backgroundColor = UIColor.green
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
