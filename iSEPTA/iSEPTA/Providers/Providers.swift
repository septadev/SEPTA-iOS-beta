//
//  Providers.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class StateProviders {
    let preferenceProvider: PreferencesProviderProtocol

    init(preferenceProvider: PreferencesProviderProtocol = PreferencesProvider.sharedInstance) {
        self.preferenceProvider = preferenceProvider
    }
}
