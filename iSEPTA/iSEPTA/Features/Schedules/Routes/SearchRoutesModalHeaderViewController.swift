//
//  SearchModalHeaderView.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/25/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import SeptaSchedule
import ReSwift

class SearchRoutesModalHeaderViewController: UIViewController, UIGestureRecognizerDelegate {

    let transitMode: TransitMode! = store.state.scheduleState.scheduleRequest?.transitMode

    weak var delegate: SearchModalHeaderDelegate?

    var textFieldDelegate: UITextFieldDelegate!

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = textFieldDelegate
        }
    }

    @IBOutlet weak var searchByTextView: UIView!

    @IBOutlet weak var dismissIcon: UIView!

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
        // addCornersAndBorders()

        view.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - View Life Cycle
    @IBAction func didTapDismiss(_: Any) {
        delegate?.dismissModal()
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRequireFailureOf _: UIGestureRecognizer) -> Bool {
        delegate?.dismissModal()
        return false
    }
}
