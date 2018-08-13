//
//  MoreViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/28/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Crashlytics
import Foundation
import UIKit

class MoreViewController: UIViewController, IdentifiableController, UITableViewDelegate, UITableViewDataSource {
    let cellId = "moreCell"
    let viewController: ViewController = .moreViewController
    var tapCrashCount = 0

    var viewModel: MoreViewModel!

    override func viewDidLoad() {
        view.backgroundColor = SeptaColor.navBarBlue
    }

    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.backgroundColor = SeptaColor.navBarBlue
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTap(_:))))
            imageView.isUserInteractionEnabled = true
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
        return 9
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
            let pushAction = PushViewController(viewController: .transitViewSelectionViewController, description: "Will view TransitView")
            store.dispatch(pushAction)
        case 3:
            let mapConnection = MakeSeptaConnection(septaConnection: .trainView)
            store.dispatch(mapConnection)
        case 4:
            let pushAction = PushViewController(viewController: .managePushNotficationsController, description: "Push Notification Preferences")
            store.dispatch(pushAction)
        case 5:
            let pushAction = PushViewController(viewController: .perksViewController, description: "Will view pass perks")
            store.dispatch(pushAction)
        case 6:
            openElerts()
        case 7:
            let pushAction = PushViewController(viewController: .contactViewController, description: "Will View How to Contact SEPTA")
            store.dispatch(pushAction)
        case 8:
            let pushAction = PushViewController(viewController: .aboutViewController, description: "About the Septa App")
            store.dispatch(pushAction)
        default:
            UIAlert.presentComingSoonAlertFrom(self)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            tableView.deselectRow(at: indexPath, animated: true)
        })
    }

    @objc func imageTap(_: UITapGestureRecognizer) {
        if tapCrashCount == 10 {
            Crashlytics.sharedInstance().crash()
        } else {
            tapCrashCount += 1
        }
    }

    private func openElerts() {
        if let urlScheme = URL(string: "SEPTA://"),
            let appStoreURL = URL(string: "https://itunes.apple.com/us/app/septa-transit-watch/id1231139910") {
            if UIApplication.shared.canOpenURL(urlScheme) {
                UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        }
    }
}
