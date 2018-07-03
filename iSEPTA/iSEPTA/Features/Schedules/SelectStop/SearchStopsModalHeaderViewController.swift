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

class SearchStopsModalHeaderViewController: UIViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleStopEdit?

    @IBOutlet var resetTextBoxGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var dismissIcon: UIView!
    @IBOutlet var searchByLocationButton: UIButton!
    @IBOutlet var searchByTextView: UIView!
    @IBOutlet var searchView: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var selectNearbyLabel: UILabel!
    @IBOutlet weak var alphaSortButton: StopSortOrderButton!
    @IBOutlet weak var stopOrderSortButton: StopSortOrderButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet var textField: UITextField! {
        didSet {
            textField.delegate = textFieldDelegate
        }
    }

    weak var delegate: SearchModalHeaderDelegate?
    var textFieldDelegate: UITextFieldDelegate!
    var transitMode: TransitMode! = TransitMode.currentTransitMode()
    var targetForScheduleAction: TargetForScheduleAction! = store.state.targetForScheduleActions()

    @IBAction func userTappedSearchByStops(_: Any) {
        if searchMode == .directLookupWithAddress {
            store.dispatch(ClearLookupAddresses())
            store.dispatch(StopSearchModeChanged(targetForScheduleAction: targetForScheduleAction, searchMode: .byAddress))
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let state = state else { return }
        searchMode = state.searchMode
        if let selectedAddress = state.selectedAddress {
            textField.text = selectedAddress.street
            textField.resignFirstResponder()
        }

        switch searchMode {
        case .directLookup:
            textField.clearButtonMode = .never
            textField.isEnabled = true
            textField.text = nil
            searchByLocationButton.isHidden = true
            segmentedControl.selectedSegmentIndex = 0
        case .byAddress:
            textField.clearButtonMode = .never
            textField.isEnabled = true
            textField.text = nil
            searchByLocationButton.isHidden = false
            segmentedControl.selectedSegmentIndex = 1
        case .directLookupWithAddress:
            textField.clearButtonMode = .always
            textField.isEnabled = false
            searchByLocationButton.isHidden = true
        default: break
        }
    }

    func addCornersAndBorders() {
        searchByTextView.layer.cornerRadius = 3.0
        searchByTextView.layer.borderColor = SeptaColor.subSegmentBlue.cgColor
        searchByTextView.layer.borderWidth = 1.0
        dismissIcon.layer.cornerRadius = 3.0
    }

    @IBAction func SearchByLocation(_: Any) {
        store.dispatch(RequestLocation())
        delegate?.updateActivityIndicator(animating: true)
    }

    @IBAction func didToggleSegmentedControl(_ sender: Any) {
        guard let segmentedControl = sender as? UISegmentedControl else { return }
        searchMode = mapSelectedSegmentToSearchMode(index: segmentedControl.selectedSegmentIndex)
    }

    func mapSelectedSegmentToSearchMode(index: Int) -> StopEditSearchMode {
        return index == 0 ? .directLookup : .byAddress
    }

    // MARK: - Search Mode

    var searchMode: StopEditSearchMode! {
        didSet {
            if oldValue != searchMode {
                store.dispatch(StopSearchModeChanged(targetForScheduleAction: targetForScheduleAction, searchMode: searchMode))
                selectNearbyLabel.isHidden = self.searchMode != .directLookupWithAddress
                updateTextFieldPlaceholderText()
            }
            if searchMode == .directLookup {
                adjustViewHeight(expanded: true)
                sortButtonsShouldBeVisible(showButtons: true)
            }
            if searchMode == .byAddress {
                adjustViewHeight(expanded: false)
                sortButtonsShouldBeVisible(showButtons: false)
            }
            if searchMode == .directLookupWithAddress {
                adjustViewHeight(expanded: true)
                sortButtonsShouldBeVisible(showButtons: false)
            }
            
        }
    }

    func updateTextFieldPlaceholderText() {
        textField.placeholder = searchMode.textFieldPlaceHolderText(transitMode: transitMode)
    }

    // MARK: - Initial Layout

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        addCornersAndBorders()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        selectNearbyLabel.text = transitMode.addressSearchPrompt()
        selectNearbyLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let activeTab = store.state.navigationState.activeNavigationController
        if activeTab == .nextToArrive && transitMode == .rail {
            sortButtonsShouldBeVisible(showButtons: false)
            adjustViewHeight(expanded: false)
        } else {
            initSortButtons()
            adjustViewHeight(expanded: true)
        }
    }
    
    private func adjustViewHeight(expanded: Bool) {
        heightConstraint.constant = expanded ? 168 : 121
    }
    
    private func sortButtonsShouldBeVisible(showButtons: Bool) {
        alphaSortButton.isHidden = !showButtons
        stopOrderSortButton.isHidden = !showButtons
    }
    
    private func initSortButtons() {
        alphaSortButton.buttonImage.image = UIImage(named: "alphaSortIcon")
        stopOrderSortButton.buttonImage.image = UIImage(named: "clipboardIcon")
        
        let stopSortGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleStopSortTap(_:)))
        stopOrderSortButton.addGestureRecognizer(stopSortGestureRecognizer)
        let alphaSortGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleAlphaSortTap(_:)))
        alphaSortButton.addGestureRecognizer(alphaSortGestureRecognizer)
    }
    
    @objc private func handleStopSortTap(_ sender: UITapGestureRecognizer) {
        activateStopSortButton()
        delegate?.sortByStopOrderTapped()
    }
    
    @objc private func handleAlphaSortTap(_ sender: UITapGestureRecognizer) {
        if alphaSortButton.active {
            handleAlphaButtonSwap()
        } else {
            alphaSortButton.active = true
            stopOrderSortButton.active = false
        }
        delegate?.sortAlphaTapped(direction: alphaSortButton.order)
    }
    
    func activateStopSortButton() {
        stopOrderSortButton.active = true
        alphaSortButton.active = false
    }
    
    private func handleAlphaButtonSwap() {
        if alphaSortButton.order == .alphaAscending {
            activateAlphaSortButtonDescending()
        } else {
            activateAlphaSortButtonAscending()
        }
    }
    
    private func activateAlphaSortButtonAscending() {
        alphaSortButton.active = true
        alphaSortButton.order = .alphaAscending
        alphaSortButton.buttonImage.image = UIImage(named: "alphaSortIcon")
        stopOrderSortButton.active = false
    }
    
    private func activateAlphaSortButtonDescending() {
        alphaSortButton.active = true
        alphaSortButton.order = .alphaDescending
        alphaSortButton.buttonImage.image = UIImage(named: "alphaSortIconReverse")
    }
    
    func activateButton(for sortOrder: SortOrder) {
        switch sortOrder {
        case .alphaAscending:
            activateAlphaSortButtonAscending()
        case .alphaDescending:
            activateAlphaSortButtonDescending()
        case .stopSequence:
            activateStopSortButton()
        }
    }

    // MARK: - View Life Cycle

    @IBAction func didTapDismiss(_: Any) {
        delegate?.dismissModal()
    }
}

extension SearchStopsModalHeaderViewController: SubscriberUnsubscriber {

    func subscribe() {
        if store.state.navigationState.activeNavigationController == .schedules {
            store.subscribe(self) {
                $0.select {
                    $0.scheduleState.scheduleStopEdit
                }.skipRepeats { $0 == $1 }
            }
        } else if store.state.navigationState.activeNavigationController == .nextToArrive {
            store.subscribe(self) {
                $0.select {
                    $0.nextToArriveState.scheduleState.scheduleStopEdit
                }.skipRepeats { $0 == $1 }
            }
        }
    }

    override func viewWillDisappear(_: Bool) {
        unsubscribe()
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}

extension SearchStopsModalHeaderViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRequireFailureOf _: UIGestureRecognizer) -> Bool {
        delegate?.dismissModal()
        return false
    }
}
