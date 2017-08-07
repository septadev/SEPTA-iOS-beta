//
//  ScheduleViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

enum FeatureViewController {
    /// Initial screen in schedules.  Holds the toolbar.  Navigation Controller
    case transitModesViewController
    /// Fills the frame in TransitModes when a bus transit mode is selected
    case busTransitModesViewController
    /// Fills the frame in TransitModes when a rail transit mode is selected
    case railTransitModesViewController
}
