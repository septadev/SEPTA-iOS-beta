//
//  ManagePushNotificationsViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/26/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

protocol ManagePushNotificationsCellViewModel {
    var cellIdentifier: String { get }
    var isSelectable: Bool { get }
    var rowIdentifier: ManagePushNotificationsViewModel.RowIdentifier { get }
    func configureCell(cell: ManagePushNotificationsCell)
    var action: SeptaAction { get }
}

protocol ToggleCellDelegate: class {
    func toggleChanged(rowIdentifier: ManagePushNotificationsViewModel.RowIdentifier, isOn: Bool)
}

class ManagePushNotificationsViewModel: ToggleCellDelegate {
    private var cellsViewModel: [[ManagePushNotificationsCellViewModel]]?

    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    enum RowIdentifier {
        case notDetermined
        case enableNotifications
        case specialSeptaAnnouncements
        case systemNotificationSettings
        case treatAsPriority
        case viewCustomNotifications
    }

    struct Keys {
        static let toggle = "toggle"
        static let push = "push"
    }

    private struct Strings {
        static let globalNotifications = "GLOBAL SETTINGS"
        static let myNotifications = "MY NOTIFICATIONS"
        static let enableNotificationsHeader = "Enable Notifications"
        static let enableNotificationsDetail = "Always show notifications from this app"
        static let specialAnnouncementsHeader = "Special SEPTA Announcements"
        static let specialAnnouncementsDetail = "Get notified about major disruptions in service, weather alerts and special events"
        static let systemNotificationHeader = "System Notification Settings"
        static let treatAsPriorityHeader = "Treat as Priority"
        static let treatAsPriorityDetail = "Let this app's notifications be heard when Do Not Disturb is set to Priority only"
        static let customNotificationsHeader = "My Custom Notifications"
    }

    let numberOfSections: Int = 2

    func numberOfRowsInSection(section: Int) -> Int {
        guard let cellsViewModel = cellsViewModel,
            section < cellsViewModel.count else { return 0 }
        return cellsViewModel[section].count
    }

    func sectionHeaderText(forSection section: Int) -> NSAttributedString? {
        var text = ""
        switch section {
        case 0: text = Strings.globalNotifications
        case 1: text = Strings.myNotifications
        default: return nil
        }

        return text.attributed(fontSize: 13, fontWeight: .regular, textColor: SeptaColor.black50, alignment: .left, kerning: -0.1, lineHeight: 18)
    }

    func shouldHighlightRowAtIndexPath(indexPath: IndexPath) -> Bool {
        guard let cellsViewModel = cellsViewModel, isIndexPathValid(indexPath) else { return false }
        let cellViewModel = cellsViewModel[indexPath.section][indexPath.row]
        return cellViewModel.isSelectable
    }

    func cellViewModelForRowAtIndexPath(indexPath: IndexPath) -> ManagePushNotificationsCellViewModel? {
        guard let cellsViewModel = cellsViewModel, isIndexPathValid(indexPath) else { return nil }
        return cellsViewModel[indexPath.section][indexPath.row]
    }

    func didSelectRowAtIndexPath(indexPath: IndexPath) {
        guard isIndexPathValid(indexPath),
            let cellViewModel = cellsViewModel?[indexPath.section][indexPath.row] as? PushCellViewModel else { return }
        let action = PushViewController(viewController: cellViewModel.viewControllerToPush, description: "Customizining Push Notification")
        store.dispatch(action)
    }

    private func isIndexPathValid(_ indexPath: IndexPath) -> Bool {
        guard let cellsViewModel = cellsViewModel, indexPath.section < cellsViewModel.count, indexPath.row < cellsViewModel[indexPath.section].count else { return false }
        return true
    }

    func stateUpdated(state: PushNotificationPreferenceState) {
        cellsViewModel = buildCellsArray(state: state)
    }

    private func buildCellsArray(state: PushNotificationPreferenceState) -> [[ManagePushNotificationsCellViewModel]] {
        guard let viewController = viewController else { return [[ManagePushNotificationsCellViewModel]]() }
        let cellsViewModel: [[ManagePushNotificationsCellViewModel]] = [
            [
                ToggleSwitchViewModel(
                    headerText: Strings.enableNotificationsHeader,
                    detailText: Strings.enableNotificationsDetail,
                    switchPositionOn: state.userWantsToEnablePushNotifications,
                    rowIdentifier: .enableNotifications,
                    action: UserWantsToSubscribeToPushNotifications(viewController: viewController),
                    delegate: self),
                ToggleSwitchViewModel(
                    headerText: Strings.specialAnnouncementsHeader,
                    detailText: Strings.specialAnnouncementsDetail,
                    switchPositionOn: state.userWantsToReceiveSpecialAnnoucements,
                    rowIdentifier: .specialSeptaAnnouncements,
                    action: UserWantsToSubscribeToSpecialAnnouncements(viewController: viewController),
                    delegate: self),
                ToggleSwitchViewModel(
                    headerText: Strings.treatAsPriorityHeader,
                    detailText: Strings.treatAsPriorityDetail,
                    switchPositionOn: state.userWantToReceiveNotificationsEvenWhenDoNotDisturbIsOn,
                    rowIdentifier: .treatAsPriority,
                    action: UserWantsToSubscribeToOverideDoNotDisturb(viewController: viewController),
                    delegate: self),
            ],
            [
                PushCellViewModel(
                    headerText: Strings.customNotificationsHeader,
                    viewControllerToPush: .customPushNotificationsController,
                    rowIdentifier: .viewCustomNotifications,
                    action: PushViewController(viewController: .customPushNotificationsController, description: "Push More View Controller")),
            ],
        ]
        return cellsViewModel
    }

    func toggleChanged(rowIdentifier: ManagePushNotificationsViewModel.RowIdentifier, isOn: Bool) {
        guard let cellsViewModel = cellsViewModel,
            let cellViewModel = cellsViewModel.flatMap({ $0 }).first(where: { $0.rowIdentifier == rowIdentifier }),
            var action = cellViewModel.action as? ToggleSwitchAction else { return }
        action.boolValue = isOn
        store.dispatch(action)
    }

    struct PushCellViewModel: ManagePushNotificationsCellViewModel {
        let isSelectable = true
        let cellIdentifier = Keys.push
        let headerText: String
        let viewControllerToPush: ViewController
        let rowIdentifier: RowIdentifier
        let action: SeptaAction

        func configureCell(cell: ManagePushNotificationsCell) {
            guard let cell = cell as? ManagePushNotificationsPushCell else { return }
            cell.titleLabel.text = headerText
            cell.accessoryType = .disclosureIndicator
            cell.rowIdentifier = rowIdentifier
        }
    }

    struct ToggleSwitchViewModel: ManagePushNotificationsCellViewModel {
        let isSelectable = false
        let cellIdentifier = Keys.toggle
        let headerText: String
        let detailText: String
        private(set) var switchPositionOn: Bool
        let rowIdentifier: RowIdentifier
        let action: SeptaAction
        weak var delegate: ToggleCellDelegate?

        func configureCell(cell: ManagePushNotificationsCell) {
            guard let cell = cell as? ManagePushNotificationsToggleCell else { return }
            cell.titleLabel.text = headerText
            cell.descriptionLabel.text = detailText
            cell.toggleSwitch.isOn = switchPositionOn
            cell.rowIdentifier = rowIdentifier
            cell.delegate = delegate
        }
    }
}
