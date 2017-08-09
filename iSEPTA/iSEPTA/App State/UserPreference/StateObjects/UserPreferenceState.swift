// Septa. 2017

import Foundation

struct UserPreferenceState {
    let transitMode: TransitMode?

    init(transitMode: TransitMode? = nil) {
        self.transitMode = transitMode
    }
}

extension UserPreferenceState: Equatable {}
func ==(lhs: UserPreferenceState, rhs: UserPreferenceState) -> Bool {
    var areEqual = true

    switch (lhs.transitMode, rhs.transitMode) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.transitMode! == rhs.transitMode!
    default:
        return false
    }
    return areEqual
}
