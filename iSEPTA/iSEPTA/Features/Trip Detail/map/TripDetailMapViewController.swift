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

class TripDetailMapViewController: UIViewController, TripDetailState_TripDetailsWatcherDelegate {
    @IBOutlet var mapView: MKMapView! {
        didSet {
            mapView.tintColor = SeptaColor.navBarBlue
        }
    }

    var tripDetailWatcher: TripDetailState_TripDetailsWatcher?
    var vehiclesAnnotationsAdded = [VehicleLocationAnnotation]()
    let mapViewDelegate = TripDetailMapViewDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = mapViewDelegate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripDetailWatcher = TripDetailState_TripDetailsWatcher()
        tripDetailWatcher?.delegate = self
        showAnotations()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripDetailWatcher = nil
    }

    func tripDetailState_TripDetailsUpdated(nextToArriveStop: NextToArriveStop) {
        drawRoute(routeId: nextToArriveStop.routeId)
        drawVehicle(nextToArriveStop: nextToArriveStop)
        mapViewDelegate.tripDetails = nextToArriveStop
    }

    var routeHasBeenAdded = false
    func drawRoute(routeId: String) {
        guard !routeHasBeenAdded else { return }
        guard let url = locateKMLFile(routeId: routeId) else { return }
        parseKMLForRoute(url: url, routeId: routeId)
    }

    func parseKMLForRoute(url: URL, routeId: String) {
        print("Beginning to parse")
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

    func drawVehicle(nextToArriveStop: NextToArriveStop) {
        guard let vehicleLocationCoordinate = nextToArriveStop.vehicleLocationCoordinate else { return }
        clearExistingVehicleLocations()
        let vehicleLocation = VehicleLocation(location: vehicleLocationCoordinate, nextToArriveStop: nextToArriveStop)

        let annotation = VehicleLocationAnnotation(vehicleLocation: vehicleLocation)
        annotation.coordinate = vehicleLocationCoordinate
        if #available(iOS 11.0, *) {
            annotation.title = nil
        } else {
            annotation.title = nextToArriveStop.transitMode.mapTitle()
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
