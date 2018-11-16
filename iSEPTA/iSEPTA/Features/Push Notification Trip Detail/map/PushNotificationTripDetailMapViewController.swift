//
//  NextToArriveDetailMapViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import MapKit
import ReSwift
import SeptaSchedule
import UIKit

class PushNotificationTripDetailMapViewController: UIViewController, PushNotificationTripDetailState_PushNotificationTripDetailDataWatcherDelegate {
    @IBOutlet var mapView: MKMapView! {
        didSet {
            mapView.tintColor = SeptaColor.navBarBlue
        }
    }

    var tripDetailWatcher: PushNotificationTripDetailState_PushNotificationTripDetailDataWatcher?
    var vehiclesAnnotationsAdded = [MKPointAnnotation]()
    let mapViewDelegate = PushNotificationTripDetailMapViewDelegate()

    var routeId = store.state.pushNotificationTripDetailState.routeId

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = mapViewDelegate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripDetailWatcher = PushNotificationTripDetailState_PushNotificationTripDetailDataWatcher()
        tripDetailWatcher?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripDetailWatcher?.unsubscribe()
    }

    func pushNotificationTripDetailState_PushNotificationTripDetailDataUpdated(pushNotificationTripDetailData data: PushNotificationTripDetailData?) {
        guard let data = data else { return }
        drawRoute()
        drawVehicle(data: data)
    }

    func drawRoute() {
        guard let routeId = routeId,
            let url = locateKMLFile(routeId: routeId) else { return }
        parseKMLForRoute(url: url, routeId: routeId)
    }

    var routeHasBeenAddedToMap = false
    func parseKMLForRoute(url: URL, routeId: String) {
        print("MB:Beginning to parse")
        KMLDocument.parse(url) { [weak self] kml in
            guard let overlays = kml.overlays as? [KMLOverlayPolyline] else { return }
            if let routeOverlays = self?.mapOverlaysToRouteOverlays(routeId: routeId, overlays: overlays) {
                self?.mapView.addOverlays(routeOverlays)
                self?.routeHasBeenAddedToMap = true
            }
        }
    }

    func locateKMLFile(routeId: String) -> URL? {
        guard let url = Bundle.main.url(forResource: routeId, withExtension: "kml") else { return nil }
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        } else {
            print("Could not find kml file for route \(routeId)")
            return nil
        }
    }

    func mapOverlaysToRouteOverlays(routeId: String, overlays: [KMLOverlayPolyline]) -> [RouteOverlay] {
        return overlays.map { overlay in
            let routeOverlay = RouteOverlay(points: overlay.points(), count: overlay.pointCount)
            routeOverlay.routeId = routeId
            return routeOverlay
        }
    }

    var shouldAnimateMap = false
    func drawVehicle(data: PushNotificationTripDetailData) {
        clearExistingVehicleLocations()

        let vehicleLocationCoordinate = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)

        let annotation = PushNotificationTripDetailVehicleLocationAnnotation(tripDetailData: data)
        annotation.coordinate = vehicleLocationCoordinate
        if #available(iOS 11.0, *) {
            annotation.title = nil
        } else {
            annotation.title = TransitMode.rail.mapTitle()
        }

        mapView.addAnnotation(annotation)
        vehiclesAnnotationsAdded.append(annotation)

        let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1600 * 3, 1600 * 3)  // that gives you six miles in view
        mapView.setRegion(region, animated: shouldAnimateMap) // no animation the first time
        shouldAnimateMap = true
    }

    func clearExistingVehicleLocations() {
        mapView.removeAnnotations(vehiclesAnnotationsAdded)
        vehiclesAnnotationsAdded.removeAll()
    }
}
