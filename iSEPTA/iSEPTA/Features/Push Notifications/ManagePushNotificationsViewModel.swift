//
//  ManagePushNotificationsViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/26/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

protocol ManagePushNotificationsCellViewModel {
    var cellIdentifier: String { get }
    func configureCell(cell: ManagePushNotificationsCell)
}

class ManagePushNotificationsViewModel {
    private var cellsViewModel: [[ManagePushNotificationsCellViewModel]]?

    let numberOfSections: Int = 2

    func numberOfRowsInSection(section: Int) -> Int {
        guard let cellsViewModel = cellsViewModel,
            section < cellsViewModel.count else { return 0 }
        return cellsViewModel[section].count
    }

    func sectionHeaderText(forSection section: Int) -> String? {
        switch section {
        case 0: return "GLOBAL SETTINGS"
        case 1: return "My Notifications"
        default: return nil
        }
    }

    func cellViewModelForRowAtIndexPath(indexPath: IndexPath) -> ManagePushNotificationsCellViewModel? {
        guard let cells = cellsViewModel, indexPath.section < cells.count, indexPath.row < cells[indexPath.section].count else { return nil }
        return cells[indexPath.section][indexPath.row]
    }

    func stateUpdated(state: PushNotificationPreferenceState) {
        cellsViewModel = buildCellsArray(state: state)
    }

    private func buildCellsArray(state: PushNotificationPreferenceState) -> [[ManagePushNotificationsCellViewModel]] {
        let cells: [[ManagePushNotificationsCellViewModel]] = [
            [
                ToggleSwitchViewModel(
                    headerText: "Enable Notifications",
                    detailText: "Always show notifications from this app",
                    switchPositionOn: state.userWantsToEnablePushNotifications),
                ToggleSwitchViewModel(
                    headerText: "Special SEPTA Announcements",
                    detailText: "Get notified about major disruptions in service, weather alerts and special events",
                    switchPositionOn: state.userWantsToReceiveSpecialAnnoucements),
                PushCellViewModel(
                    headerText: "System Notification Settings",
                    viewControllerToPush: .moreViewController),
                ToggleSwitchViewModel(
                    headerText: "Treat as Priority",
                    detailText: "Let this app's notifications be heard when Do Not Disturb is set to Priority only",
                    switchPositionOn: state.userWantToReceiveNotificationsEvenWhenDoNotDisturbIsOn),
            ],
            [
                PushCellViewModel(
                    headerText: "My Custom Notifications",
                    viewControllerToPush: .moreViewController),
            ],
        ]
        return cells
    }

    struct ToggleSwitchViewModel: ManagePushNotificationsCellViewModel {
        let cellIdentifier = "toggle"
        let headerText: String
        let detailText: String
        private(set) var switchPositionOn: Bool

        init(headerText: String, detailText: String, switchPositionOn: Bool) {
            self.headerText = headerText
            self.detailText = detailText
            self.switchPositionOn = switchPositionOn
        }

        func configureCell(cell: ManagePushNotificationsCell) {
            guard let cell = cell as? ManagePushNotificationsToggleCell else { return }
            cell.titleLabel.text = headerText
            cell.descriptionLabel.text = detailText
            cell.toggleSwitch.isOn = switchPositionOn
        }
    }

    struct PushCellViewModel: ManagePushNotificationsCellViewModel {
        let cellIdentifier = "push"
        let headerText: String
        let viewControllerToPush: ViewController

        init(headerText: String, viewControllerToPush: ViewController) {
            self.headerText = headerText
            self.viewControllerToPush = viewControllerToPush
        }

        func configureCell(cell: ManagePushNotificationsCell) {
            guard let cell = cell as? ManagePushNotificationsPushCell else { return }
            cell.titleLabel.text = headerText
        }
    }
}
