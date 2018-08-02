//
//  ManagePushNotificationsToggleCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/26/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class ManagePushNotificationsToggleCell: UITableViewCell, ManagePushNotificationsCell {
    var rowIdentifier: ManagePushNotificationsViewModel.RowIdentifier = .notDetermined

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var descriptionLabel: UILabel!

    @IBOutlet var toggleSwitch: UISwitch!

    var action: ToggleSwitchAction?

    weak var delegate: ToggleCellDelegate?

    @IBAction func toggleValueChanged(_: Any) {
        guard let delegate = delegate else { return }
        delegate.toggleChanged(rowIdentifier: rowIdentifier, isOn: toggleSwitch.isOn)
    }
}
