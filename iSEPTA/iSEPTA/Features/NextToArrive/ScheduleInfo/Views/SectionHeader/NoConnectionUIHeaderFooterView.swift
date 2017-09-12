//
//  NoConnectionUIHeaderFooterView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NoConnectionUIHeaderFooterView: UITableViewHeaderFooterView {

    var noConnectionSectionHeader: NoConnectionSectionHeader!
    override func awakeFromNib() {
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        noConnectionSectionHeader = contentView.awakeInsertAndPinSubview(nibName: "NoConnectionSectionHeader")
    }

    required override init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
