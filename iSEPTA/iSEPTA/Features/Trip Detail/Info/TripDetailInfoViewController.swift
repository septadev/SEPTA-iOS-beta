//
//  NextToArriveDetailInfoViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import UIKit
import SeptaSchedule

class TripDetailInfoViewController: UIViewController, TripDetailState_TripDetailsWatcherDelegate {

    var tripDetailWatcher: TripDetailState_TripDetailsWatcher?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripDetailWatcher = TripDetailState_TripDetailsWatcher()
        tripDetailWatcher?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripDetailWatcher = nil
    }

    func tripDetailState_TripDetailsUpdated(nextToArriveStop: NextToArriveStop) {
        configureForTransitMode(transitMode: nextToArriveStop.transitMode)
        configureView(nextToArriveStop: nextToArriveStop)
    }

    func configureForTransitMode(transitMode: TransitMode) {
        transitModeIcon.image = transitMode.tripDetailIcon()
        navigationItem.title = transitMode.tripDetailTitle()
    }

    func configureView(nextToArriveStop: NextToArriveStop) {
        if let railDetails = nextToArriveStop.nextToArriveDetail as? NextToArriveRailDetails {
            configureHeaderViewForRail(railDetails: railDetails)
            configureDelayViewForRail(railDetails: railDetails)
            configureNextStopViewForRail(railDetails: railDetails)
        } else if let busDetails = nextToArriveStop.nextToArriveDetail as? NextToArriveBusDetails {
            configureHeaderViewForBus(busDetails: busDetails)
            configureDelayViewForBus(busDetails: busDetails)
            configureNextStopViewForBus(busDetails: busDetails)
        } else {
            configureHeaderViewForNoDetail(nextToArriveStop: nextToArriveStop)
            configureDelayViewForNoDetail(nextToArriveStop: nextToArriveStop)
            configureNextStopViewForNoDetail(nextToArriveStop: nextToArriveStop)
        }
    }

    // MARK: - Header View

    func configureHeaderViewForRail(railDetails: NextToArriveRailDetails) {
        guard let tripId = railDetails.tripid, let destinationStation = railDetails.destinationStation else { return }
        routeLabel.text = "#\(tripId) to \(destinationStation)"
    }

    func configureHeaderViewForBus(busDetails: NextToArriveBusDetails) {
        guard let blockId = busDetails.blockid, let line = busDetails.line, let destinationStation = busDetails.destinationStation else { return }
        routeLabel.text = "#\(blockId) on \(line) to \(destinationStation)"
    }

    func configureHeaderViewForNoDetail(nextToArriveStop: NextToArriveStop) {
        guard let lastStopName = nextToArriveStop.lastStopName else { return }
        routeLabel.text = "\(nextToArriveStop.routeName)  to \(lastStopName)"
    }

    // MARK: - Delay View

    func configureDelayViewForRail(railDetails: NextToArriveRailDetails) {
        guard let delayMinutes = railDetails.destinationDelay else { return }
        configureDelayView(delayMinutes: delayMinutes)
    }

    func configureDelayViewForBus(busDetails: NextToArriveBusDetails) {
        guard let delayMinutes = busDetails.destinationDelay else { return }
        configureDelayView(delayMinutes: delayMinutes)
    }

    func configureDelayViewForNoDetail(nextToArriveStop: NextToArriveStop) {
        guard let delayMinutes = nextToArriveStop.delayMinutes else { return }
        configureDelayView(delayMinutes: delayMinutes)
    }

    func configureDelayView(delayMinutes: Int?) {
        let color = generateOnTimeColor(delayMinutes: delayMinutes)
        delayLabel.text = generateOnTimeString(delayMinutes: delayMinutes)
        delayLabel.textColor = color
        delayBoxView.layer.borderWidth = 1
        delayBoxView.layer.borderColor = color.cgColor
    }

    // MARK: - Next Stop View

    func configureNextStopViewForRail(railDetails: NextToArriveRailDetails) {
        if let destinationStation = railDetails.destinationStation {
            nextStopStationNameLabel.text = destinationStation
        } else {
            nextStopStationNameLabel.text = "No data available"
        }
    }

    func configureNextStopViewForBus(busDetails _: NextToArriveBusDetails) {
        infoStackView.removeSubview(subview: nextStopView)
    }

    func configureNextStopViewForNoDetail(nextToArriveStop _: NextToArriveStop) {
        nextStopStationNameLabel.text = "No data available"
    }

    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var transitModeIcon: UIImageView!

    @IBOutlet weak var routeLabel: UILabel!

    @IBOutlet weak var nextStopStationNameLabel: UILabel!

    @IBOutlet weak var twitterHandleLabel: UILabel!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var delayBoxView: UIView!
    @IBOutlet var nextStopView: UIView!
    @IBOutlet weak var delayLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func configureIcone() {
    }

    func generateOnTimeString(delayMinutes: Int?) -> String? {
        guard let delayMinutes = delayMinutes else { return "No Real Time Data" }
        let delayString = String(delayMinutes)
        if delayMinutes > 0 {
            return "\(delayString) min late"
        } else {
            return "On Time"
        }
    }

    func generateOnTimeColor(delayMinutes: Int?) -> UIColor {
        guard let delayMinutes = delayMinutes else { return SeptaColor.transitIsScheduled }

        if delayMinutes > 0 {
            return SeptaColor.transitIsLate
        } else {
            return SeptaColor.transitOnTime
        }
    }
}
