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
    case showDirectionInRoutes
    case showDirectionInStops
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
        var userPreferenceState = UserPreferenceState()
        guard let dict = plistDictionary else { throw PreferenceError.couldNotReadPlist }
        defaultPreferencesDict = dict

        userPreferenceState.startupNavigationController = try startupNavigationController()
        userPreferenceState.startupTransitMode = try startupTransitMode()
        userPreferenceState.showDirectionInRoutes = try showDirectionInRoutes()
        userPreferenceState.showDirectionInStops = try showDirectionInStops()

        return userPreferenceState
    }

    fileprivate func startupNavigationController() throws -> NavigationController {
        let key = DefaultPreferenceKeys.startupNavigationController.rawValue
        guard let defaultValue = defaultPreferencesDict[key] as? Int,
            let navigationController = NavigationController(rawValue: defaultValue) else {
            throw PreferenceError.missingKey(key)
        }
        return navigationController
    }

    fileprivate func startupTransitMode() throws -> TransitMode {
        let key = DefaultPreferenceKeys.startupTransitMode.rawValue
        guard let defaultValue = defaultPreferencesDict[key] as? Int,

            let transitMode = TransitMode(rawValue: defaultValue) else {
            throw PreferenceError.missingKey(key)
        }
        return transitMode
    }

    fileprivate func showDirectionInRoutes() throws -> Bool {
        let key = DefaultPreferenceKeys.showDirectionInRoutes.rawValue
        guard let defaultValue = defaultPreferencesDict[key] as? Bool else {
            throw PreferenceError.missingKey(key)
        }
        return defaultValue
    }

    fileprivate func showDirectionInStops() throws -> Bool {
        let key = DefaultPreferenceKeys.showDirectionInStops.rawValue
        guard let defaultValue = defaultPreferencesDict[key] as? Bool else {
            throw PreferenceError.missingKey(key)
        }
        return defaultValue
    }
}
