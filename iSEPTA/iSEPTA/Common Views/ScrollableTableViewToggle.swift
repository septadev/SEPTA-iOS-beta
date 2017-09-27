//
//  ScrollableTableViewToggle.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class ScrollableTableViewToggle: NSObject {

    @IBOutlet var tableView: UITableView!
    var shouldScroll: Bool = false {
        didSet {
            guard let tableView = tableView else { return }
            tableView.isScrollEnabled = shouldScroll
        }
    }

    func toggleTableViewScrolling() {
        guard let tableView = tableView else { return }
        shouldScroll = !shouldScroll
        tableView.isScrollEnabled = shouldScroll
    }
}
