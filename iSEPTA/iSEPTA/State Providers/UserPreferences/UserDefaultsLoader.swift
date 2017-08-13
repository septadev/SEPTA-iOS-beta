//
//  UserDefaultsLoader.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

class UserDefaultsLoader {
    private let defaults = UserDefaults.standard

    func loadDefaults(completion: @escaping (UserPreferenceState?, Error?) -> Void) {

        var preferenceState: UserPreferenceState?
        let defaultsLoaded = bool(forKey: .defaultsLoaded)
        if !defaultsLoaded {
            loadPreloadedDefaults(completion: completion)
        } else {
            loadDevicePersistedDefaults(completion: completion)
        }
    }

    func loadPreloadedDefaults(completion: @escaping (UserPreferenceState?, Error?) -> Void) {
        var returnError: Error?
        var preferenceState: UserPreferenceState?
        do { let loader = DefaultPreferenceLoader()

            preferenceState = try loader.generateDefaultUserPreferenceState()
            setValue(true, forKey: .defaultsLoaded)

        } catch {
            returnError = error
        }

        DispatchQueue.main.async {
            completion(preferenceState, returnError)
        }
    }

    func loadDevicePersistedDefaults(completion: @escaping (UserPreferenceState?, Error?) -> Void) {

        var preferenceState = UserPreferenceState()

        preferenceState.startupTransitMode = startupTransitMode()
        preferenceState.startupNavigationController = startupNavigtationController()
        preferenceState.showDirectionInRoutes = showDirectionInRoutes()
        preferenceState.showDirectionInStops = showDirectionInStops()

        DispatchQueue.main.async {
            completion(preferenceState, nil)
        }
    }

    func startupTransitMode() -> TransitMode? {
        guard let stringValue = string(forKey: .startupTransitMode) else { return nil }
        return TransitMode(rawValue: stringValue)
    }

    func startupNavigtationController() -> NavigationController? {
        guard let stringValue = string(forKey: .startupNavigtationController) else { return nil }
        return NavigationController(rawValue: stringValue)
    }

    func showDirectionInRoutes() -> Bool {
        return bool(forKey: .showDirectionInRoutes)
    }

    func showDirectionInStops() -> Bool {
        return bool(forKey: .showDirectionInStops)
    }

    func bool(forKey key: UserPreferenceKeys) -> Bool {
        return defaults.bool(forKey: key.rawValue)
    }

    func string(forKey key: UserPreferenceKeys) -> String? {
        return defaults.string(forKey: key.rawValue)
    }

    func array(forKey key: UserPreferenceKeys) -> String? {
        return defaults.string(forKey: key.rawValue)
    }

    func int(forKey key: UserPreferenceKeys) -> Int? {
        return defaults.integer(forKey: key.rawValue)
    }

    func setValue(_ value: Any?, forKey key: UserPreferenceKeys) {
        defaults.set(value, forKey: key.rawValue)
    }
}
