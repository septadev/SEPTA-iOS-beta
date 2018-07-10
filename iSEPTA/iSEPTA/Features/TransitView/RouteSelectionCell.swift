//
//  RouteSelectionCell.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/5/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit

class RouteSelectionCell: UITableViewCell {

    @IBOutlet weak var routeId: UILabel!
    @IBOutlet weak var routeName: UILabel!
    @IBOutlet weak var selectRouteImage: UIImageView!
    
    var enabled: Bool = false
    
    var shouldFill: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        routeId.text = ""
        routeName.text = "Select a Bus Route or Trolley Line"
    }
    
    override func draw(_ rect: CGRect) {
        SeptaDraw.drawBlueGradientCell(frame: rect, shouldFill: shouldFill, enabled: enabled)
    }
    
    func setEnabled(_ enabled: Bool) {
        self.enabled = enabled
        routeName.alpha = enabled ? CGFloat(0.7) : CGFloat(0.3)
        if let selectRouteImage = selectRouteImage {
            selectRouteImage.alpha = enabled ? CGFloat(0.7) : CGFloat(0.3)
        }
        setNeedsDisplay()
    }

}
