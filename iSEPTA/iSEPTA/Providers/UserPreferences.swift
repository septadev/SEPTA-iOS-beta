//
//  UserPreferences.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

protocol UserPreferencesProviderProtocol {
    func setStringPreference(preference: String, forKey key: String)
    func stringPreference(preference _: String, forKey key: String) -> String?
}

class UserPreferencesProvider: UserPreferencesProviderProtocol {
    private let defaults = UserDefaults.standard
    public static let sharedInstance = UserPreferencesProvider()

    private init() {}

    func setStringPreference(preference: String, forKey key: String) {
        defaults.set(preference, forKey: key)
    }

    func stringPreference(preference _: String, forKey key: String) -> String? {
        return defaults.string(forKey: key)
    }
}
