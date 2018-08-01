//
//  CustomNotificationsViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/27/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class CustomPushNotificationsViewController: UITableViewController, IdentifiableController {
    var viewController: ViewController = .customPushNotificationsController

    var headerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        headerView = UIView.instanceFromNib(named: "MyNotificationsHeaderView")
        tableView.tableHeaderView = headerView
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
