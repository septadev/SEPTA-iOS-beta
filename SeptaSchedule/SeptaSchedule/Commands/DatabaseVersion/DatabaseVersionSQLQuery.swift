//
//  DatabaseVersionSQLQuery.swift
//  SeptaSchedule
//
//  Created by Mike Mannix on 6/20/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

class DatabaseVersionSQLQuery: SQLQueryProtocol {
    var sqlBindings: [[String]] = []
    var fileName = "databaseVersion"
}
