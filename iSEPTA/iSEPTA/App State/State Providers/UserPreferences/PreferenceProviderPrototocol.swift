//
//  PreferenceProviderPrototocol.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/9/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

protocol PreferencesProviderProtocol {
    func setStringPreference(preference: String, forKey key: UserPreferenceKeys)
    func stringPreference(forKey key: UserPreferenceKeys) -> String?
}
