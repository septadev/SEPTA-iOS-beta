// Septa. 2017

import Foundation
import SeptaSchedule

enum PreferenceError: Error {
    case couldNotReadPlist
    case missingKey(String)
}

fileprivate enum DefaultPreferenceKeys: String {
    case defaultNavigationController
    case defaultTransitMode
    case showDirectionInRoutes
    case showDirectionInStops
}

class DefaultPreferenceLoader {
    let bundle = Bundle.main
    var defaultPreferencesDict = [String: AnyObject]()

    private var defaultPreferenceURL: URL? {
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

        userPreferenceState.defaultNavigationController = try defaultNavigationController()
        userPreferenceState.defaultTransitMode = try defaultTransitMode()
        userPreferenceState.showDirectionInRoutes = try showDirectionInRoutes()
        userPreferenceState.showDirectioninStops = try showDirectionInStops()

        return userPreferenceState
    }

    func defaultNavigationController() throws -> NavigationController {
        let key = DefaultPreferenceKeys.defaultNavigationController.rawValue
        guard let defaultValue = defaultPreferencesDict[key] as? String,
            let navigationController = NavigationController(rawValue: defaultValue) else {
            throw PreferenceError.missingKey(key)
        }
        return navigationController
    }

    func defaultTransitMode() throws -> TransitMode {
        let key = DefaultPreferenceKeys.defaultTransitMode.rawValue
        guard let defaultValue = defaultPreferencesDict[key] as? String,
            let transitMode = TransitMode(rawValue: defaultValue) else {
            throw PreferenceError.missingKey(key)
        }
        return transitMode
    }

    func showDirectionInRoutes() throws -> Bool {
        let key = DefaultPreferenceKeys.showDirectionInRoutes.rawValue
        guard let defaultValue = defaultPreferencesDict[key] as? Bool else {
            throw PreferenceError.missingKey(key)
        }
        return defaultValue
    }

    func showDirectionInStops() throws -> Bool {
        let key = DefaultPreferenceKeys.showDirectionInStops.rawValue
        guard let defaultValue = defaultPreferencesDict[key] as? Bool else {
            throw PreferenceError.missingKey(key)
        }
        return defaultValue
    }
}
