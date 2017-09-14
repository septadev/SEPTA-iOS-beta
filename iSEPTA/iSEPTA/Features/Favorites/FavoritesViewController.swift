//
//  FavoritesViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var viewModel: FavoritesViewModel!

    override func viewDidLoad() {
        view.backgroundColor = SeptaColor.navBarBlue
        viewModel = FavoritesViewModel(delegate: self, tableView: tableView)
    }
}

extension FavoritesViewController: UpdateableFromViewModel {
    func viewModelUpdated() {
        tableView.reloadData()
    }

    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message _: String, shouldDismissAfterDisplay _: Bool) {
    }
}
