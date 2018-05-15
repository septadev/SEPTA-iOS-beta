//
//  DatabaseActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

protocol DatabaseAction: SeptaAction {}

struct NewDatabaseState: DatabaseAction {
    let databaseState: DatabaseState
    let description = "State of the preloaded database has changed"
}
