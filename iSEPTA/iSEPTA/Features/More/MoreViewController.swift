//
//  MoreViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/28/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
class MoreViewController: UIViewController, IdentifiableController, UITableViewDelegate, UITableViewDataSource {
    let cellId = "moreCell"
    let viewController: ViewController = .moreViewController

    var viewModel: MoreViewModel!

    override func viewDidLoad() {
        view.backgroundColor = SeptaColor.navBarBlue
    }

    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.backgroundColor = SeptaColor.navBarBlue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel = MoreViewModel()
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? MoreTableViewCell else { return UITableViewCell() }
        viewModel.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let pushAction = PushViewController(viewController: .faresViewController, description: "Will View Fares")
            store.dispatch(pushAction)
        case 1:
            let mapConnection = MakeSeptaConnection(septaConnection: .map)
            store.dispatch(mapConnection)
        case 2:
            let mapConnection = MakeSeptaConnection(septaConnection: .transitView)
            store.dispatch(mapConnection)
        case 3:
            let mapConnection = MakeSeptaConnection(septaConnection: .trainView)
            store.dispatch(mapConnection)
        case 4:
            let commentConnection = MakeSeptaConnection(septaConnection: .events)
            store.dispatch(commentConnection)
        case 5:
            let pushAction = PushViewController(viewController: .contactViewController, description: "Will View How to Contact SEPTA")
            store.dispatch(pushAction)
        case 6:
            let pushAction = PushViewController(viewController: .aboutViewController, description: "About the Septa App")
            store.dispatch(pushAction)
        default:
            UIAlert.presentComingSoonAlertFrom(self)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            tableView.deselectRow(at: indexPath, animated: true)
        })
    }
}
