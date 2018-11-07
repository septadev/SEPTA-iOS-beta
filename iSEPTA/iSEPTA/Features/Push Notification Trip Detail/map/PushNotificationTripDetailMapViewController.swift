//
//  NextToArriveDetailMapViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import MapKit
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

    var routes: [Route]? {
        didSet {
            drawRoute()
        }
    }
    var routeId: String?
    var lineName: String? {
        didSet {
            drawRoute()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = mapViewDelegate
        loadRoutes()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripDetailWatcher = PushNotificationTripDetailState_PushNotificationTripDetailDataWatcher()
        tripDetailWatcher?.delegate = self
    }

    func loadRoutes() {
        RoutesCommand.sharedInstance.routes(forTransitMode: .rail) { [weak self] routes, _ in
            guard let strongSelf = self else { return }
            strongSelf.routes = routes
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripDetailWatcher?.unsubscribe()
    }

    func pushNotificationTripDetailState_PushNotificationTripDetailDataUpdated(pushNotificationTripDetailData data: PushNotificationTripDetailData?) {
        guard let data = data else { return }
        lineName = data.line
        drawVehicle(data: data)
//        mapViewDelegate.tripDetails = nextToArriveStop
    }


    var routeHasBeenAdded = false

    func drawRoute() {
        guard !routeHasBeenAdded,
        let routeId = fetchRouteId(lineName: lineName),
        let url = locateKMLFile(routeId: routeId) else { return }
        parseKMLForRoute(url: url, routeId: routeId)
    }

    func fetchRouteId(lineName: String?) -> String? {
        guard let routes = routes,  // routes exists
        let lineName = lineName,  // non nill was passed in
        let matchingRoute = routes.first(where: {$0.routeShortName == "\(lineName) Line"}) else { return nil }  //matching route id exists
        return matchingRoute.routeId
    }


    func parseKMLForRoute(url: URL, routeId: String) {
        print("MB:Beginning to parse")
        KMLDocument.parse(url) { [weak self] kml in
            guard let overlays = kml.overlays as? [KMLOverlayPolyline] else { return }
            if let routeOverlays = self?.mapOverlaysToRouteOverlays(routeId: routeId, overlays: overlays), let firstOverlay = routeOverlays.first {
                let boundingRect = firstOverlay.boundingMapRect
                self?.mapView.addOverlays(routeOverlays)
                self?.mapView.visibleMapRect = self!.mapView.mapRectThatFits(boundingRect, edgePadding: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
                self?.routeHasBeenAdded = true
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

    func drawVehicle(data: PushNotificationTripDetailData) {
        clearExistingVehicleLocations()
        guard let lat = data.latitude, let lon = data.longitude else { return }
        let vehicleLocationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

        let annotation = PushNotificationTripDetailVehicleLocationAnnotation(tripDetailData: data)
        annotation.coordinate = vehicleLocationCoordinate
        if #available(iOS 11.0, *) {
            annotation.title = nil
        } else {
            annotation.title = TransitMode.rail.mapTitle()
        }

        mapView.addAnnotation(annotation)
        vehiclesAnnotationsAdded.append(annotation)

        let visibleMapRect = mapView.visibleMapRect
        let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
        let annotationRect = MKMapRect(origin: annotationPoint, size: MKMapSize(width: 1, height: 1))
        if !MKMapRectContainsRect(visibleMapRect, annotationRect) {
            showAnotations()
        }
        
    }

    func showAnotations() {
        mapView.showAnnotations(mapView.annotations, animated: true)

        //        mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0), animated: true)
    }

    func clearExistingVehicleLocations() {
        mapView.removeAnnotations(vehiclesAnnotationsAdded)
        vehiclesAnnotationsAdded.removeAll()
    }
}
