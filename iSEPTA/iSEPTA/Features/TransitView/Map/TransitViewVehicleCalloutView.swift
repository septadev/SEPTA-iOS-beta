//
//  TransitViewVehicleCalloutView.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/18/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit

class TransitViewVehicleCalloutView: UIView {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    var vehicleLocation: TransitViewVehicleLocation? {
        didSet {
            configure()
        }
    }
    
    private func configure() {
        guard let location = vehicleLocation else { return }
        
        let mode = location.mode == .bus ? "Bus" : "Trolley"
        
        label1.attributedText = NSMutableAttributedString().bold(mode).normal(": \(location.routeId) to \(location.destination)")
        label2.attributedText = NSMutableAttributedString().bold("Block ID").normal(": \(location.block)")
        label3.attributedText = NSMutableAttributedString().bold("Vehicle Number").normal(": \(location.vehicleId)")
        label4.attributedText = NSMutableAttributedString().bold("Status").normal(": \(statusDetail(late: location.late))")
    }
    
    private func statusDetail(late: Int) -> String {
        if late == 0 {
            return "on time"
        }
        if late < 0 {
            return "\(abs(late)) min early"
        } else {
            return "\(late) min late"
        }
    }
}
