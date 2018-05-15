//
//  AlertDetailCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

protocol AlertDetailCellDelegate: AnyObject {
    func didTapButton(sectionNumber: Int)
    func constraintsChanged(sectionNumber: Int)
}

class AlertDetailCell: UITableViewCell {

    var cellView: GenericAlertDetailCellView!

    override func awakeFromNib() {
        super.awakeFromNib()
        cellView = contentView.awakeInsertAndPinSubview(nibName: "AlertDetailCellView")
        cellView.isGenericAlert = false
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
    }

    var sectionNumber: Int! {
        set {
            cellView.sectionNumber = newValue
        }
        get {
            return cellView.sectionNumber
        }
    }

    weak var delegate: AlertDetailCellDelegate? {
        didSet {
            cellView.delegate = delegate
        }
    }

    var alertImage: UIImageView { return cellView.alertImage }

    var advisoryLabel: UILabel { return cellView.advisoryLabel }

    var disabledAdvisoryLabel: UILabel { return cellView.disabledAdvisoryLabel }

    var textView: UITextView { return cellView.textView }

    func setEnabled(_ enabled: Bool) {
        cellView.setEnabled(enabled)
    }

    func initializeCellAsClosed() {
        cellView.initializeCellAsClosed()
    }
}
