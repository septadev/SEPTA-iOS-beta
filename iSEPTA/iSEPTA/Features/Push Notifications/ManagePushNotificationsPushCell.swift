//
//  ManagePushNotificationsPushCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/26/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

protocol ManagePushNotificationsCell where Self: UITableViewCell {
    var action: SeptaAction? { get set }
}

class ManagePushNotificationsPushCell: UITableViewCell, ManagePushNotificationsCell {
    @IBOutlet var titleLabel: UILabel!

    var action: SeptaAction?
}
