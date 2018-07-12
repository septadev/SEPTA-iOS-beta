//
//  TransitViewOverviewViewController.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/10/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit
import SeptaSchedule

class TransitViewOverviewViewController: UIViewController, IdentifiableController {

    var viewController: ViewController = .transitViewMap
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = SeptaColor.navBarBlue
    }

    
    @IBAction func refreshTransitViewData(_ sender: Any) {
        store.dispatch(RefreshTransitViewVehicleLocationData(description: "Request refresh of TransitView vehicle location data"))
    }
    
}
