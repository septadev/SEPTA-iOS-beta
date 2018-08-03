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
        let returnError: Error? = nil
        var preferenceState: UserPreferenceState?
        let loader = DefaultPreferencesLoader.sharedInstance

        preferenceState = loader.generateDefaultUserPreferenceState()
        setValue(true, forKey: .defaultsLoaded)
        UserPreferencesStatePersister.sharedInstance.persistPreferenceState(preferenceState)

        DispatchQueue.main.async {
            completion(preferenceState, returnError)
        }
    }

    fileprivate func loadDevicePersistedDefaults(completion: @escaping (UserPreferenceState?, Error?) -> Void) {
        let defaultPreferenceState = UserPreferenceState()

        let defaultsLoaded = true
        let startupTransitMode = retrieveStartupTransitMode() ?? defaultPreferenceState.startupTransitMode
        let startupNavigationController = retrieveStartupNavigationController() ?? defaultPreferenceState.startupNavigationController
        let databaseVersion = retrieveDatabaseVersion() ?? defaultPreferenceState.databaseVersion
        let pushNotificationPreferenceState = retrievePushNotifications() ?? PushNotificationPreferenceState()

        let retrievedPreferenceState = UserPreferenceState(defaultsLoaded: defaultsLoaded, startupTransitMode: startupTransitMode, startupNavigationController: startupNavigationController, databaseVersion: databaseVersion, pushNotificationPreferenceState: pushNotificationPreferenceState)

        DispatchQueue.main.async {
            completion(retrievedPreferenceState, nil)
        }
    }

    fileprivate func retrieveStartupTransitMode() -> TransitMode? {
        guard let intValue = int(forKey: .startupTransitMode) else { return nil }

        return TransitMode(rawValue: intValue)
    }

    fileprivate func retrieveStartupNavigationController() -> NavigationController? {
        guard let intValue = int(forKey: .startupNavigationController) else { return nil }
        return NavigationController(rawValue: intValue)
    }

    fileprivate func retrieveDatabaseVersion() -> Int? {
        guard let intValue = int(forKey: .databaseVersion) else { return nil }
        return intValue
    }

    fileprivate func retrievePushNotifications() -> PushNotificationPreferenceState? {
        return decodable(forKey: .pushNotificationPreferenceState)
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

    fileprivate func decodable<T>(forKey key: UserPreferencesKeys) -> T? where T: Decodable {
        guard let data = defaults.data(forKey: key.rawValue),
            let jsonData = try? JSONDecoder().decode(T.self, from: data) else { return nil }
        return jsonData
    }

    fileprivate func int(forKey key: UserPreferencesKeys) -> Int? {
        return defaults.integer(forKey: key.rawValue)
    }

    fileprivate func setValue(_ value: Any?, forKey key: UserPreferencesKeys) {
        defaults.set(value, forKey: key.rawValue)
    }
}
