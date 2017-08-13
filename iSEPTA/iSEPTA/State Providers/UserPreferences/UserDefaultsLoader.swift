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
    static let sharedInstance = UserDefaultsLoader()
    private init() {}

    func loadDefaults(completion: @escaping (UserPreferenceState?, Error?) -> Void) {

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            let defaultsLoaded = strongSelf.bool(forKey: .defaultsLoaded)
            if !defaultsLoaded {
                strongSelf.loadPreloadedDefaults(completion: completion)
            } else {
                strongSelf.loadDevicePersistedDefaults(completion: completion)
            }
        }
    }

    fileprivate func loadPreloadedDefaults(completion: @escaping (UserPreferenceState?, Error?) -> Void) {
        var returnError: Error?
        var preferenceState: UserPreferenceState?
        do { let loader = DefaultPreferencesLoader.sharedInstance

            preferenceState = try loader.generateDefaultUserPreferenceState()
            setValue(true, forKey: .defaultsLoaded)
            UserPreferencesStatePersister.sharedInstance.persistPreferenceState(preferenceState)
        } catch {
            returnError = error
        }

        DispatchQueue.main.async {
            completion(preferenceState, returnError)
        }
    }

    fileprivate func loadDevicePersistedDefaults(completion: @escaping (UserPreferenceState?, Error?) -> Void) {

        var preferenceState = UserPreferenceState()

        preferenceState.startupTransitMode = startupTransitMode()
        preferenceState.startupNavigationController = startupNavigationController()
        preferenceState.showDirectionInRoutes = showDirectionInRoutes()
        preferenceState.showDirectionInStops = showDirectionInStops()

        DispatchQueue.main.async {
            completion(preferenceState, nil)
        }
    }

    fileprivate func startupTransitMode() -> TransitMode? {
        guard let stringValue = string(forKey: .startupTransitMode) else { return nil }
        return TransitMode(rawValue: stringValue)
    }

    fileprivate func startupNavigationController() -> NavigationController? {
        guard let stringValue = string(forKey: .startupNavigationController) else { return nil }
        return NavigationController(rawValue: stringValue)
    }

    fileprivate func showDirectionInRoutes() -> Bool {
        return bool(forKey: .showDirectionInRoutes)
    }

    fileprivate func showDirectionInStops() -> Bool {
        return bool(forKey: .showDirectionInStops)
    }

    fileprivate func bool(forKey key: UserPreferencesKeys) -> Bool {
        return defaults.bool(forKey: key.rawValue)
    }

    fileprivate func string(forKey key: UserPreferencesKeys) -> String? {
        return defaults.string(forKey: key.rawValue)
    }

    fileprivate func array(forKey key: UserPreferencesKeys) -> String? {
        return defaults.string(forKey: key.rawValue)
    }

    fileprivate func int(forKey key: UserPreferencesKeys) -> Int? {
        return defaults.integer(forKey: key.rawValue)
    }

    fileprivate func setValue(_ value: Any?, forKey key: UserPreferencesKeys) {
        defaults.set(value, forKey: key.rawValue)
    }
}
