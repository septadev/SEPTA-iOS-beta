//
//  BaseWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/16/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class BaseWatcher {

    deinit {
        unsubscribe()
    }

    func unsubscribe() {}
}
