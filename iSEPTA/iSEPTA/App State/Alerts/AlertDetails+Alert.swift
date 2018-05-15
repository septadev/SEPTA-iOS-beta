//
//  AlertDetails+Alert.swift
//  iSEPTA
//
//  Created by Mark Broski on 1/23/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

extension AlertDetails_Alert {

    func isActiveAlert() -> Bool {
        return !(message.isBlank && advisory_message.isBlank)
    }
}
