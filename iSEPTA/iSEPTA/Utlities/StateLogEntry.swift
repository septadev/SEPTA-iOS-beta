// Septa. 2017

import Foundation

struct StateLogEntry: Codable {
    let stateBefore: AppState?
    let action: SeptaAction
    let stateAfter: AppState

    enum CodingKeys: String, CodingKey {
        case stateBefore
        case stateAfter
        case actionName
        case action
    }

    init(stateBefore: AppState?, action: SeptaAction, stateAfter: AppState) {
        self.stateBefore = stateBefore
        self.action = action
        self.stateAfter = stateAfter
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stateBefore, forKey: .stateBefore)
        try container.encode(stateAfter, forKey: .stateAfter)

        let actionName = "\(type(of: action))"
        switch action {

        case let action as InitializeNavigationState:
            try container.encode(action, forKey: .action)
        case let action as TransitionView:
            try container.encode(action, forKey: .action)
        case let action as SwitchTabs:
            try container.encode(action, forKey: .action)
        case let action as DismissModal:
            try container.encode(action, forKey: .action)
        case let action as PresentModal:
            try container.encode(action, forKey: .action)
        case let action as TransitModeSelected:
            try container.encode(action, forKey: .action)
        case let action as RoutesLoaded:
            try container.encode(action, forKey: .action)
        case let action as RouteSelected:
            try container.encode(action, forKey: .action)
        case let action as TripStartsLoaded:
            try container.encode(action, forKey: .action)
        case let action as PreferencesRetrievedAction:
            try container.encode(action, forKey: .action)
        case let action as TripStartSelected:
            try container.encode(action, forKey: .action)
        case let action as NewTransitModeAction:
            try container.encode(action, forKey: .action)
        case let action as TripEndsLoaded:
            try container.encode(action, forKey: .action)
        default:
            fatalError("YOu need to add the action here")
            // throw LoggingError.missingActionWhileEncoding(actionName)
        }
        try container.encode(actionName, forKey: .actionName)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        stateBefore = try values.decode(AppState.self, forKey: .stateBefore)
        stateAfter = try values.decode(AppState.self, forKey: .stateAfter)

        let actionName = try values.decode(String.self, forKey: .actionName)

        switch actionName {

        case "InitializeNavigationState":
            action = try values.decode(InitializeNavigationState.self, forKey: .action)
        case "TransitionView":
            action = try values.decode(TransitionView.self, forKey: .action)
        case "SwitchTabs":
            action = try values.decode(SwitchTabs.self, forKey: .action)
        case "DismissModal":
            action = try values.decode(DismissModal.self, forKey: .action)
        case "PresentModal":
            action = try values.decode(PresentModal.self, forKey: .action)
        case "TransitModeSelected":
            action = try values.decode(TransitModeSelected.self, forKey: .action)
        case "RoutesLoaded":
            action = try values.decode(RoutesLoaded.self, forKey: .action)
        case "RouteSelected":
            action = try values.decode(RouteSelected.self, forKey: .action)
        default:
            throw LoggingError.missingActionWhileDecoding(actionName)
        }
    }
}
