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

class PushNotificationTripDetailInfoViewController: UIViewController, PushNotificationTripDetailState_PushNotificationTripDetailDataWatcherDelegate {
    var tripDetailWatcher: PushNotificationTripDetailState_PushNotificationTripDetailDataWatcher?

    var routeId: String? = store.state.pushNotificationTripDetailState.routeId

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripDetailWatcher = PushNotificationTripDetailState_PushNotificationTripDetailDataWatcher()
        tripDetailWatcher?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripDetailWatcher = nil
    }

    func pushNotificationTripDetailState_PushNotificationTripDetailDataUpdated(pushNotificationTripDetailData data: PushNotificationTripDetailData?) {
        guard let data = data else { return }
        configureForTransitMode(transitMode: .rail)

        configureView(data: data)
    }

    func configureForTransitMode(transitMode: TransitMode) {
        transitModeIcon.image = transitMode.tripDetailIcon()
        navigationItem.title = transitMode.tripDetailTitle()
    }

    func configureView(data: PushNotificationTripDetailData) {
        infoStackView.clearSubviews()
        configureRoute(data: data)
        configureDestination(data: data)

        configureDelayView(data: data)

        configureHeaderViewForRail(data: data)
        configureNextStopViewForRail(data: data)
        configureCars(data: data)
        configureService(data: data)
        configureTwitter()

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    // MARK: - Header View

    func configureHeaderViewForRail(data: PushNotificationTripDetailData) {
        guard let tripId = data.tripId, let destinationStation = data.destinationStation, destinationStation.count > 0 else { return }
        routeLabel.text = "#\(tripId) to \(destinationStation)"
    }

    func configureHeaderViewForNoDetail(data: PushNotificationTripDetailData) {
        guard let lastStopName = data.destinationStation, let routeName = data.line else { return }
        routeLabel.text = "\(routeName)  to \(lastStopName)"
    }

    // MARK: - Delay View

    func configureDelayView(data: PushNotificationTripDetailData) {
        let onTimeColor = data.generateOnTimeColor()
        delayLabel.text = data.generateDelayString(prefixString: "")
        delayLabel.textColor = onTimeColor
        delayBoxView.layer.borderWidth = 1
        delayBoxView.layer.borderColor = onTimeColor.cgColor
    }

    // MARK: - Next Stop View

    func configureNextStopViewForRail(data: PushNotificationTripDetailData) {
        if let nextstopStation = data.nextstopStation {
            nextStopStationNameLabel.text = nextstopStation
        } else {
            nextStopStationNameLabel.text = "No data available"
        }
    }

    func configureNextStopViewForNoDetail() {
        nextStopStationNameLabel.text = "No data available"
    }

    // MARK: - Route

    func configureRoute(data: PushNotificationTripDetailData) {
        guard let line = data.line else { return }
        let itemView = newItemView()
        itemView.headerLabel.text = "\(TransitMode.rail.routeTitle()):"
        itemView.valueLabel.text = line
        infoStackView.addArrangedSubview(itemView)
    }

    // MARK: - Origination  -- Destination

    func configureDestination(data: PushNotificationTripDetailData) {
        guard let lastStopName = data.destinationStation, lastStopName.count > 0 else { return }
        let itemView = newItemView()
        itemView.headerLabel.text = "Destination:"
        itemView.valueLabel.text = lastStopName
        infoStackView.addArrangedSubview(itemView)
    }

    // MARK: -  cars and destination

    func configureCars(data: PushNotificationTripDetailData) {
        guard let vehicleIds = data.consist else { return }
        let itemView = newItemView()
        itemView.headerLabel.text = "# Train Cars:"
        let countString = String(vehicleIds.count)
        itemView.valueLabel.text = "\(countString) -"
        itemView.lightLabel.text = vehicleIds.joined(separator: ", ")

        infoStackView.addArrangedSubview(itemView)
    }

    func configureService(data: PushNotificationTripDetailData) {
        guard let service = data.service else { return }
        let itemView = newItemView()
        itemView.headerLabel.text = "Type:"
        itemView.valueLabel.text = service
        infoStackView.addArrangedSubview(itemView)
    }

    func configureTwitter() {
        guard let routeId = routeId else { return }
        twitterHandleLabel.text = Route.twiterHandleForRouteId(routeId: routeId, transitMode: .rail)
    }

    @IBAction func userTappedTwitter(_: Any) {
        guard let handle = twitterHandleLabel.text else { return }
        let app = UIApplication.shared
        twitterView.backgroundColor = SeptaColor.buttonHighlight
        let twitterUrl = URL(string: "twitter://\(handle)")!
        let webUrl = URL(string: "https://twitter.com/\(handle)")!
        if app.canOpenURL(twitterUrl) {
            app.open(twitterUrl, options: [:], completionHandler: nil)
        } else {
            app.open(webUrl, options: [:], completionHandler: nil)
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
