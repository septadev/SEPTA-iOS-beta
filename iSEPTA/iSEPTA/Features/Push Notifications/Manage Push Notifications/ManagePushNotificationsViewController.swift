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
        static let footerView = "ManagePushNotificationsFooterView"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
        navigationController?.navigationBar.configureBackButton()
        viewModel = ManagePushNotificationsViewModel(viewController: self)
        let nib = UINib(nibName: Keys.tableHeaderViewNib, bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: Keys.tableHeaderViewId)

        loadFooterView()
    }

    func loadFooterView() {
        guard let footerView = Bundle.main.loadNibNamed(Keys.footerView, owner: self, options: nil)?.first as? UIView else { return }

        tableView.tableFooterView = footerView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        headerView.titleLabel.attributedText = viewModel?.sectionHeaderText(forSection: section)
        return headerView
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 37
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

    override func tableView(_: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let viewModel = viewModel else { return false }
        return viewModel.shouldHighlightRowAtIndexPath(indexPath: indexPath)
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        viewModel.didSelectRowAtIndexPath(indexPath: indexPath)
    }
}
