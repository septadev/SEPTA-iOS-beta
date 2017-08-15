//
//  OptionalCompare.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/14/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

public class Optionals {
    public static func optionalCompare<T: Equatable>(currentValue: T?, newValue: T?) -> OptionalCompareResult {
        switch (currentValue, newValue) {
        case (.some, .some):
            if currentValue == newValue {
                return .bothNonNilAndEqual
            } else {
                return .bothNonNilAndDifferent
            }
        case (.none, .some):
            return .currentIsNil
        case (.some, .none):
            return .newIsNil
        case (.none, .none):
            return .bothNil
        }
    }
}

public enum OptionalCompareResult {
    case currentIsNil
    case newIsNil
    case bothNil
    case bothNonNilAndEqual
    case bothNonNilAndDifferent

    func equalityResult() -> Bool {
        switch self {
        case .currentIsNil, .newIsNil, .bothNonNilAndDifferent: return false
        case .bothNil, .bothNonNilAndEqual: return false
        }
    }
}
