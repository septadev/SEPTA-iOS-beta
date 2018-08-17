//
//  TransitViewSelectionViewController.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/3/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift
import UIKit

class TransitViewSelectionViewController: UIViewController, IdentifiableController {
    var viewController: ViewController = .transitViewSelectionViewController
    var viewModel: TransitViewSelectionViewModel?

    @IBOutlet var resetHeaderView: UIView!
    @IBOutlet var tableWrapperView: UIView!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = TransitViewSelectionViewModel(delegate: self)
        view.backgroundColor = SeptaColor.navBarBlue
        UIView.addSurroundShadow(toView: tableWrapperView)
    }

    @IBAction func resetForm(_: Any) {
        store.dispatch(ResetTransitView(description: "Reset TransitView form"))
    }
}

extension TransitViewSelectionViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 4
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let viewModel = viewModel {
            return viewModel.cellFor(tableView: tableView, indexPath: indexPath)
        }
        return UITableViewCell()
    }
}

extension TransitViewSelectionViewController: UITableViewDelegate {
    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? resetHeaderView : UIView()
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 38
        } else if section == 3 {
            return 22
        } else {
            return 14
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < 3 {
            var slot: TransitViewRouteSlot
            switch indexPath.section {
            case 0:
                slot = .first
            case 1:
                slot = .second
            case 2:
                slot = .third
            default:
                return
            }
            let slotAction = TransitViewSlotChange(slot: slot, description: "User wishes to change TransitView slot route")
            store.dispatch(slotAction)
            let modalAction = PresentModal(viewController: .transitViewSelectRouteViewController, description: "User wishes to pick a TransitView route")
            store.dispatch(modalAction)
        } else if indexPath.section == 3 {
            let pushAction = PushViewController(viewController: .transitViewMap, description: "Will view TransitView map")
            store.dispatch(pushAction)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let viewModel = viewModel else { return false }
        return viewModel.canSelectRow(row: indexPath.section)
    }
}

extension TransitViewSelectionViewController: UpdateableFromViewModel {
    func viewModelUpdated() {
        tableView.reloadData()
    }

    func updateActivityIndicator(animating _: Bool) {}

    func displayErrorMessage(message _: String, shouldDismissAfterDisplay _: Bool) {}
}
