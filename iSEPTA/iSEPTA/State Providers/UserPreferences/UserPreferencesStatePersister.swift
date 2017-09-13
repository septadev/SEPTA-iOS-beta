//
//  PreferenceStatePersister.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

class UserPreferencesStatePersister {
    let defaults = UserDefaults.standard
    static let sharedInstance = UserPreferencesStatePersister()
    private init() {}

    func persistPreferenceState(_ state: UserPreferenceState?) {
        guard let state = state else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.setTransitMode(state: state)
            strongSelf.setStartupNavigationControllder(state: state)
            strongSelf.setDatabaseVersion(state: state)
            strongSelf.defaults.synchronize()
        }
    }

    func setTransitMode(state: UserPreferenceState) {
        set(state.startupTransitMode.rawValue, forKey: .startupTransitMode)
    }

    func setStartupNavigationControllder(state: UserPreferenceState) {
        set(state.startupNavigationController.rawValue, forKey: .startupNavigationController)
    }

    func setDatabaseVersion(state: UserPreferenceState) {
        set(state.databaseVersion, forKey: .databaseVersion)
    }

    private func set(_ value: Any?, forKey key: UserPreferencesKeys) {
        defaults.set(value, forKey: key.rawValue)
    }
}
