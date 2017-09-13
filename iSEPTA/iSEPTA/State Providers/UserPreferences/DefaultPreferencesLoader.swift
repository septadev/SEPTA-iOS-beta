// Septa. 2017

import Foundation
import SeptaSchedule

enum PreferenceError: Error {
    case couldNotReadPlist
    case missingKey(String)
}

fileprivate enum DefaultPreferenceKeys: String {
    case startupNavigationController
    case startupTransitMode
    case databaseVersion
}

class DefaultPreferencesLoader {
    let bundle = Bundle.main
    var defaultPreferencesDict = [String: AnyObject]()
    static let sharedInstance = DefaultPreferencesLoader()
    private init() {}

    fileprivate var defaultPreferenceURL: URL? {
        return bundle.url(forResource: "DefaultPreferences", withExtension: "plist")
    }

    private var plistDictionary: [String: AnyObject]? {
        guard let url = defaultPreferenceURL else { return nil }
        return NSDictionary(contentsOf: url) as? [String: AnyObject]
    }

    func generateDefaultUserPreferenceState() throws -> UserPreferenceState {
        return UserPreferenceState()
    }

    fileprivate func startupNavigationController() throws -> NavigationController {

        return NavigationController.nextToArrive
    }

    fileprivate func startupTransitMode() throws -> TransitMode {
        return TransitMode.bus
    }
}
