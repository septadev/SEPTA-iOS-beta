//
//  Providers.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class StateProviders {
    let preferenceProvider: UserPreferencesProviderProtocol

    init(preferenceProvider: UserPreferencesProviderProtocol = UserPreferencesProvider.sharedInstance) {
        self.preferenceProvider = preferenceProvider
    }
}
