//
//  NoConnectionCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

protocol NoConnectionCellDisplayable {
    var tripView: TripView! { get }
}

class NoConnectionCell: UITableViewCell, NoConnectionCellDisplayable {
    var tripView: TripView!
    override func awakeFromNib() {
        super.awakeFromNib()
        tripView = contentView.awakeInsertAndPinSubview(nibName: "TripView")
    }
}
