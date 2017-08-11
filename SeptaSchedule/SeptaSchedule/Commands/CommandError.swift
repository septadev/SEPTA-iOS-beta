//
//  CommandError.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

public enum SQLCommandError: Error {
    case noConnection
    case noCommand
}
