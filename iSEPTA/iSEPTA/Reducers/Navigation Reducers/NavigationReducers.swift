//
//  NavigationReducers.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class NavigationReducers {
    class func main(action: Action, state: NavigationState?) -> NavigationState {
        let newState = state ?? NavigationState(selectedFeature: .noneSelected, activeFeature: .noneSelected)
        return switchTabs(action: action, state: newState)
    }

    class func switchTabs(action: Action, state: NavigationState) -> NavigationState {

        switch action {
        case let action as SwitchFeature:
            return NavigationState(selectedFeature: action.selectedFeature, activeFeature: .noneSelected)
        case let action as SwitchFeatureCompleted:
            return NavigationState(selectedFeature: state.selectedFeature, activeFeature: action.activeFeature)
        default:
            return NavigationState(selectedFeature: .noneSelected, activeFeature: .noneSelected)
        }
    }
}
