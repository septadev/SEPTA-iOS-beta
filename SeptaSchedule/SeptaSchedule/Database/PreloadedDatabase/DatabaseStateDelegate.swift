//
//  DatabaseStateDelegate.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

public protocol DatabaseStateDelegate: AnyObject {
    func databaseStateUpdated(databaseState: DatabaseState)
}
