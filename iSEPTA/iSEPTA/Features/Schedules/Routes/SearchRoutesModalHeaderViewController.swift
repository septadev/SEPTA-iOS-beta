//
//  SearchModalHeaderView.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/25/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class SearchRoutesModalHeaderViewController: UIViewController {
    @IBOutlet var dismissIcon: UIView!
    @IBOutlet var searchByTextView: UIView!
    var textFieldDelegate: UITextFieldDelegate!
    weak var delegate: SearchModalHeaderDelegate?

    var transitMode = TransitMode.currentTransitMode()!

    @IBOutlet var textField: UITextField! {
        didSet {
            textField.delegate = textFieldDelegate
            textField.isEnabled = true
        }
    }

    func addCornersAndBorders() {
        searchByTextView.layer.cornerRadius = 3.0
        searchByTextView.layer.borderColor = SeptaColor.subSegmentBlue.cgColor
        searchByTextView.layer.borderWidth = 1.0
        dismissIcon.layer.cornerRadius = 3.0
    }

    func updateTextFieldPlaceholderText() {
        textField.placeholder = transitMode.routePlaceholderText()
    }

    // MARK: - Initial Layout

    override func viewDidLoad() {
        super.viewDidLoad()
        addCornersAndBorders()
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - View Life Cycle

    @IBAction func didTapDismiss(_: Any) {
        delegate?.dismissModal()
    }
}

extension SearchRoutesModalHeaderViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRequireFailureOf _: UIGestureRecognizer) -> Bool {
        delegate?.dismissModal()
        return false
    }
}
