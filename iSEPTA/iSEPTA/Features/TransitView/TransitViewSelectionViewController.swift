//
//  TransitViewSelectionViewController.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/3/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit
import ReSwift

class TransitViewSelectionViewController: UIViewController, IdentifiableController {

    var viewController: ViewController = .transitViewSelectionViewController
    var viewModel: TransitViewSelectionViewModel?
    
    @IBOutlet var resetHeaderView: UIView!
    @IBOutlet weak var tableWrapperView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = TransitViewSelectionViewModel(delegate: self)
        view.backgroundColor = SeptaColor.navBarBlue
        UIView.addSurroundShadow(toView: tableWrapperView)
    }
    
    @IBAction func resetForm(_ sender: Any) {
        store.dispatch(ResetTransitView(description: "Reset TransitView form"))
    }
}

extension TransitViewSelectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
            let action = PresentModal(viewController: .transitViewSelectRouteViewController, description: "User wishes to pick a TransitView route")
            store.dispatch(action)
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
    
    func updateActivityIndicator(animating: Bool) {}
    
    func displayErrorMessage(message: String, shouldDismissAfterDisplay: Bool) {}
    
}
