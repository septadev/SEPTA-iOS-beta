// Septa. 2017

import XCTest
@testable import Septa

/// MockPreferenceProvider purpose: returns made up user preferences
class MockPreferenceProvider: UserPreferencesProviderProtocol {
    func retrievePersistedState() -> UserPreferenceState {
        return UserPreferenceState()
    }

    func subscribe() {
    }

    var preferenceSet: [UserPreferencesKeys: String]?
    private let preferences: [UserPreferencesKeys: String]

    init(preferences: [UserPreferencesKeys: String]) {
        self.preferences = preferences
    }

    func setStringPreference(preference: String, forKey key: UserPreferencesKeys) {
        preferenceSet?[key] = preference
    }

    func stringPreference(forKey key: UserPreferencesKeys) -> String? {
        return preferences[key]
    }
}
