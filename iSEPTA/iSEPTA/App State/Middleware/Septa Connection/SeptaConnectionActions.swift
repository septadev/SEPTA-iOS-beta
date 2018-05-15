//
//  SeptaConnectionActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/30/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

protocol SeptaConnectionAction: SeptaAction {}

struct MakeSeptaConnection: SeptaConnectionAction {
    let septaConnection: SEPTAConnection
    let description: String = "User views URL"
}
