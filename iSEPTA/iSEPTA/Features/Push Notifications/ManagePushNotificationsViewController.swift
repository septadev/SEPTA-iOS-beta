//
//  ManagePushNotificationsViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/26/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class ManagePushNotificationsViewController: UITableViewController, IdentifiableController, StoreSubscriber {
    var viewController: ViewController = .managePushNotficationsController

    typealias StoreSubscriberStateType = PushNotificationPreferenceState

    var viewModel: ManagePushNotificationsViewModel?

    struct Keys {
        static let tableHeaderViewNib = "ManagePushNotificationsHeaderView"
        static let tableHeaderViewId = "TableSectionHeader"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ManagePushNotificationsViewModel()
        let nib = UINib(nibName: Keys.tableHeaderViewNib, bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: Keys.tableHeaderViewId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.unsubscribe(self)
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.preferenceState.pushNotificationPreferenceState }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let viewModel = viewModel else { return }
        viewModel.stateUpdated(state: state)
        tableView.reloadData()
    }

    override func numberOfSections(in _: UITableView) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Keys.tableHeaderViewId)
            as? ManagePushNotificationsHeaderView else { return nil }
        headerView.titleLabel.text = viewModel?.sectionHeaderText(forSection: section)
        return headerView
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.numberOfRowsInSection(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel,
            let cellViewModel = viewModel.cellViewModelForRowAtIndexPath(indexPath: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellIdentifier) as? ManagePushNotificationsCell else { return UITableViewCell() }
        cellViewModel.configureCell(cell: cell)
        return cell as! UITableViewCell
    }
}
