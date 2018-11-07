//
//  NextToArriveDetailInfoViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import SeptaSchedule
import UIKit

class PushNotificationTripDetailInfoViewController: UIViewController, TripDetailState_TripDetailsWatcherDelegate {
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
        infoStackView.clearSubviews()
        configureRoute(nextToArriveStop: nextToArriveStop)
        configureDestination(nextToArriveStop: nextToArriveStop)
        configureTwitter(nextToArriveStop: nextToArriveStop)
        configureDelayView(nextToArriveStop: nextToArriveStop)

        if let railDetails = nextToArriveStop.nextToArriveDetail as? NextToArriveRailDetails {
            configureHeaderViewForRail(railDetails: railDetails)
            configureNextStopViewForRail(railDetails: railDetails)
            configureCars(nextToArriveStop: nextToArriveStop)
            configureService(nextToArriveStop: nextToArriveStop)
        } else if let busDetails = nextToArriveStop.nextToArriveDetail as? NextToArriveBusDetails {
            configureHeaderViewForBus(busDetails: busDetails)
            configureCarsForBus(busDetails: busDetails)
        } else {
            configureHeaderViewForNoDetail(nextToArriveStop: nextToArriveStop)
            configureNextStopViewForNoDetail(nextToArriveStop: nextToArriveStop)
        }

        if nextToArriveStop.transitMode.useRailForDetails() {} else if nextToArriveStop.transitMode.useBusForDetails() {
            configureNextStopViewForBus()
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    // MARK: - Header View

    func configureHeaderViewForRail(railDetails: NextToArriveRailDetails) {
        guard let tripId = railDetails.tripid, let destinationStation = railDetails.destinationStation, destinationStation.count > 0 else { return }
        routeLabel.text = "#\(tripId) to \(destinationStation)"
    }

    func configureHeaderViewForBus(busDetails: NextToArriveBusDetails) {
        guard let blockId = busDetails.blockid, let line = busDetails.line, let destinationStation = busDetails.destinationStation, destinationStation.count > 0 else { return }
        routeLabel.text = "#\(blockId) on \(line) to \(destinationStation)"
    }

    func configureHeaderViewForNoDetail(nextToArriveStop: NextToArriveStop) {
        guard let lastStopName = nextToArriveStop.lastStopName else { return }
        routeLabel.text = "\(nextToArriveStop.routeName)  to \(lastStopName)"
    }

    // MARK: - Delay View

    func configureDelayView(nextToArriveStop: NextToArriveStop) {
        let onTimeColor = nextToArriveStop.generateOnTimeColor()
        delayLabel.text = nextToArriveStop.generateDelayString(prefixString: "")
        delayLabel.textColor = onTimeColor
        delayBoxView.layer.borderWidth = 1
        delayBoxView.layer.borderColor = onTimeColor.cgColor
    }

    // MARK: - Next Stop View

    func configureNextStopViewForRail(railDetails: NextToArriveRailDetails) {
        if let nextstopStation = railDetails.nextstopStation {
            nextStopStationNameLabel.text = nextstopStation
        } else {
            nextStopStationNameLabel.text = "No data available"
        }
    }

    func configureNextStopViewForBus() {
        infoStackView.removeSubview(subview: nextStopView)
    }

    func configureNextStopViewForNoDetail(nextToArriveStop _: NextToArriveStop) {
        nextStopStationNameLabel.text = "No data available"
    }

    // MARK: - Route

    func configureRoute(nextToArriveStop: NextToArriveStop) {
        let itemView = newItemView()
        itemView.headerLabel.text = "\(nextToArriveStop.transitMode.routeTitle()):"
        itemView.valueLabel.text = nextToArriveStop.routeName
        infoStackView.addArrangedSubview(itemView)
    }

    // MARK: - Origination  -- Destination

    func configureDestination(nextToArriveStop: NextToArriveStop) {
        guard let lastStopName = nextToArriveStop.lastStopName, lastStopName.count > 0 else { return }
        let itemView = newItemView()
        itemView.headerLabel.text = "Destination:"
        itemView.valueLabel.text = lastStopName
        infoStackView.addArrangedSubview(itemView)
    }

    // MARK: -  cars and destination

    func configureCars(nextToArriveStop: NextToArriveStop) {
        guard let vehicleIds = nextToArriveStop.vehicleIds else { return }
        let itemView = newItemView()
        itemView.headerLabel.text = "# Train Cars:"
        let countString = String(vehicleIds.count)
        itemView.valueLabel.text = "\(countString) -"
        itemView.lightLabel.text = vehicleIds.joined(separator: ", ")

        infoStackView.addArrangedSubview(itemView)
    }

    func configureCarsForBus(busDetails: NextToArriveBusDetails) {
        if let vehicleId = busDetails.vehicleid {
            let itemView = newItemView()
            itemView.headerLabel.text = "Vehicle Number:"
            itemView.valueLabel.text = vehicleId
            infoStackView.addArrangedSubview(itemView)
        }

        if let blockId = busDetails.blockid {
            let itemView = newItemView()
            itemView.headerLabel.text = "Block Number:"
            itemView.valueLabel.text = blockId
            infoStackView.addArrangedSubview(itemView)
        }
    }

    func configureService(nextToArriveStop: NextToArriveStop) {
        guard let service = nextToArriveStop.service else { return }
        let itemView = newItemView()
        itemView.headerLabel.text = "Type:"
        itemView.valueLabel.text = service
        infoStackView.addArrangedSubview(itemView)
    }

    func configureTwitter(nextToArriveStop: NextToArriveStop) {
        twitterHandleLabel.text = Route.twiterHandleForRouteId(routeId: nextToArriveStop.routeId, transitMode: nextToArriveStop.transitMode)
    }

    @IBAction func userTappedTwitter(_: Any) {
        guard let handle = twitterHandleLabel.text else { return }
        let app = UIApplication.shared
        twitterView.backgroundColor = SeptaColor.buttonHighlight
        let twitterUrl = URL(string: "twitter://\(handle)")!
        let webUrl = URL(string: "https://twitter.com/\(handle)")!
        if app.canOpenURL(twitterUrl) {
            app.openURL(twitterUrl)
        } else {
            app.openURL(webUrl)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: {
            self.twitterView.backgroundColor = SeptaColor.twitterBackground
        })
    }

    func newItemView() -> TripDetailItemView {
        let itemView: TripDetailItemView = UIView.loadNibView(nibName: "TripDetailItemView")!
        itemView.translatesAutoresizingMaskIntoConstraints = false
        return itemView
    }

    @IBOutlet var stackView: UIStackView!

    @IBOutlet var transitModeIcon: UIImageView!

    @IBOutlet var routeLabel: UILabel!

    @IBOutlet var nextStopStationNameLabel: UILabel!

    @IBOutlet var twitterHandleLabel: UILabel!
    @IBOutlet var infoStackView: UIStackView!
    @IBOutlet var delayBoxView: UIView!
    @IBOutlet var nextStopView: UIView!
    @IBOutlet var delayLabel: UILabel!

    @IBOutlet var twitterView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func configureIcone() {}

    func generateOnTimeColor(delayMinutes: Int?) -> UIColor {
        guard let delayMinutes = delayMinutes else { return SeptaColor.transitIsScheduled }

        if delayMinutes > 0 {
            return SeptaColor.transitIsLate
        } else {
            return SeptaColor.transitOnTime
        }
    }
}
