//
//  ViewTransitions.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/9/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

enum ViewTransitionType: String, Codable {
    case push
    case pop
    case presentModal
    case dismissModal
}
