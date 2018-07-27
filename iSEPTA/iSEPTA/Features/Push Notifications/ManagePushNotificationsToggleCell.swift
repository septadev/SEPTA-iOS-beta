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
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var descriptionLabel: UILabel!

    @IBOutlet var toggleSwitch: UISwitch!

    @IBAction func toggleValueChanged(_: Any) {
    }

    var action: SeptaAction?
}
