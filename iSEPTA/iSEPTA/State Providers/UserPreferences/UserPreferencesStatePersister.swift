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
            strongSelf.set(state.showDirectionInRoutes, forKey: .showDirectionInRoutes)
            strongSelf.set(state.showDirectionInStops, forKey: .showDirectionInStops)
            strongSelf.defaults.synchronize()
        }
    }

    func setTransitMode(state: UserPreferenceState) {
        guard let transitMode = state.startupTransitMode else { return }
        set(transitMode.rawValue, forKey: .startupTransitMode)
    }

    func setStartupNavigationControllder(state: UserPreferenceState) {
        guard let startupNavigationController = state.startupNavigationController else { return }
        set(startupNavigationController.rawValue, forKey: .startupNavigationController)
    }

    private func set(_ value: Any?, forKey key: UserPreferencesKeys) {
        defaults.set(value, forKey: key.rawValue)
    }
}
