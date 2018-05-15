//
//  ConnectionCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

protocol ConnectionCellDisplayable {
    var startConnectionView: ConnectionView! { get }
    var endConnectionView: ConnectionView! { get }
    var connectionLabel: UILabel! { get }
}

class ConnectionCell: UITableViewCell, ConnectionCellDisplayable {

    var startConnectionView: ConnectionView!
    @IBOutlet var startConnectionViewWrapper: UIView! {
        didSet {
            startConnectionView = startConnectionViewWrapper.awakeInsertAndPinSubview(nibName: "ConnectionView")
        }
    }

    var endConnectionView: ConnectionView!
    @IBOutlet var endConnectionViewWrapper: UIView! {
        didSet {
            endConnectionView = endConnectionViewWrapper.awakeInsertAndPinSubview(nibName: "ConnectionView")
        }
    }

    @IBOutlet var connectionLabel: UILabel!
}

class BlueGradientView: UIView {

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectingGradientView(frame: rect)
    }
}
