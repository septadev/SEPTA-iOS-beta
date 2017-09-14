//
//  CellConnectionView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/14/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class CellConnectionView: UIView, ConnectionCellDisplayable {

    var startConnectionView: ConnectionView!
    @IBOutlet weak var startConnectionViewWrapper: UIView! {
        didSet {
            startConnectionView = startConnectionViewWrapper.awakeInsertAndPinSubview(nibName: "ConnectionView")
        }
    }

    var endConnectionView: ConnectionView!
    @IBOutlet weak var endConnectionViewWrapper: UIView! {
        didSet {
            endConnectionView = endConnectionViewWrapper.awakeInsertAndPinSubview(nibName: "ConnectionView")
        }
    }

    @IBOutlet weak var connectionLabel: UILabel!
}
