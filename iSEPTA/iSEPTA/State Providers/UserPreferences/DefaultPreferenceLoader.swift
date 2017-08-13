//
//  DefaultPreferenceLoader.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class DefaultPreferenceLoader {
    let bundle = Bundle.main

    var defaultPreferenceURL: URL? {
        return bundle.url(forResource: "DefaultPreferences", withExtension: "plist")
    }
}
