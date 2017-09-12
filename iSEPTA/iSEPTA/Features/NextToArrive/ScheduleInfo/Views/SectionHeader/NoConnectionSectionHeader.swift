//
//  ConnectingSectionView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NoConnectionSectionHeader: UITableViewHeaderFooterView {
    var tripHeaderView: TripHeaderView?

    @IBOutlet var tripHeaderWrapperView: UIView! {
        didSet {
            tripHeaderView = tripHeaderWrapperView.awakeInsertAndPinSubview(nibName: "TripHeaderView")
        }
    }

    override func awakeFromNib() {
        backgroundColor = UIColor.green
        contentView.backgroundColor = UIColor.white
    }
}
