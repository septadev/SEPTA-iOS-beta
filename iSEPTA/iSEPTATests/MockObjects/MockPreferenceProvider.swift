// Septa. 2017

import XCTest
@testable import Septa

/// MockPreferenceProvider purpose: returns made up user preferences
class MockPreferenceProvider: PreferencesProviderProtocol {
    func retrievePersistedState() -> UserPreferenceState {
        return UserPreferenceState()
    }

    func subscribe() {
    }

    var preferenceSet: [UserPreferenceKeys: String]?
    private let preferences: [UserPreferenceKeys: String]

    init(preferences: [UserPreferenceKeys: String]) {
        self.preferences = preferences
    }

    func setStringPreference(preference: String, forKey key: UserPreferenceKeys) {
        preferenceSet?[key] = preference
    }

    func stringPreference(forKey key: UserPreferenceKeys) -> String? {
        return preferences[key]
    }
}
