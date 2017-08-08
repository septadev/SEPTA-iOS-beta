// Septa. 2017

import Foundation

protocol PreferencesProviderProtocol {
    func setStringPreference(preference: String, forKey key: UserPreferenceKeys)
    func stringPreference(forKey key: UserPreferenceKeys) -> String?
}

typealias UserPreferencesForFeature = [String: [String: String]]

func ==(lhs: UserPreferencesForFeature, rhs: UserPreferencesForFeature) -> Bool {
    if lhs.count != rhs.count { return false }

    for (key, lhsub) in lhs {
        if let rhsub = rhs[key] {
            if lhsub != rhsub {
                return false
            }
        } else {
            return false
        }
    }

    return true
}

class PreferencesProvider: PreferencesProviderProtocol {
    // Defaults

    private let defaults = UserDefaults.standard
    static let sharedInstance = PreferencesProvider()

    private init() {}

    func setStringPreference(preference: String, forKey key: UserPreferenceKeys) {
        defaults.set(preference, forKey: key.rawValue)
    }

    func stringPreference(forKey key: UserPreferenceKeys) -> String? {
        if let preference = defaults.string(forKey: key.rawValue) {
            return preference
        } else {
            return key.defaultValue()
        }
    }
}
