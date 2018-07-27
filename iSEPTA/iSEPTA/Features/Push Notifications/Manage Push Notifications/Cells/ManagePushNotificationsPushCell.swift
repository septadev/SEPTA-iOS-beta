//
//  ManagePushNotificationsPushCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/26/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class ManagePushNotificationsPushCell: UITableViewCell, ManagePushNotificationsCell {
    @IBOutlet var titleLabel: UILabel!

    var rowIdentifier: ManagePushNotificationsViewModel.RowIdentifier = .notDetermined
}
