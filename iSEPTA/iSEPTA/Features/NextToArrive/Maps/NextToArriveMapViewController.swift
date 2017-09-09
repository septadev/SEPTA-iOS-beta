//
//  NextToArriveMapViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import AEXML
import UIKit
import MapKit
import SeptaSchedule
import ReSwift

class NextToArriveMapViewController: UIViewController, RouteDrawable {

    var nextToArriveMapRouteViewModel: NextToArriveMapRouteViewModel!
    var nextToArriveMapEndpointsViewModel: NextToArriveMapEndpointsViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        nextToArriveMapRouteViewModel = NextToArriveMapRouteViewModel()
        nextToArriveMapRouteViewModel.delegate = self
        nextToArriveMapEndpointsViewModel = NextToArriveMapEndpointsViewModel()
        nextToArriveMapEndpointsViewModel.delegate = self
    }

    @IBOutlet private weak var mapView: MKMapView! {
        didSet {
            addOverlaysToMap()
            addScheduleRequestToMap()
        }
    }

    private var overlaysToAdd = [MKOverlay]() {
        willSet {
            updateMapRect(overlays: newValue)
        }

        didSet {
            guard let _ = mapView else { return }
            addOverlaysToMap()
            overlaysToAdd.removeAll()
        }
    }

    private var scheduleRequest: ScheduleRequest? {
        didSet {
            guard let _ = mapView else { return }
            addScheduleRequestToMap()
        }
    }

    var mapRect = MKMapRectNull

    func updateMapRect(overlays: [MKOverlay]) {
        for overlay in overlays {
            mapRect = MKMapRectUnion(mapRect, overlay.boundingMapRect)
        }
    }

    func addOverlaysToMap() {
        mapView.addOverlays(overlaysToAdd)
        // updateVisibleMap()
    }

    func updateVisibleMap() {
        let expandedRect = mapView.mapRectThatFits(mapRect, edgePadding: UIEdgeInsetsMake(100, 10, 10, 10))
        mapView.setVisibleMapRect(expandedRect, animated: false)
    }

    func drawRoute(routeId: String) {
        guard let url = locateKMLFile(routeId: routeId) else { return }
        parseKMLForRoute(url: url, routeId: routeId)
    }

    func drawTrip(scheduleRequest: ScheduleRequest) {
        if self.scheduleRequest == nil {
            self.scheduleRequest = scheduleRequest
        }
    }

    func addScheduleRequestToMap() {
        guard let scheduleRequest = scheduleRequest,
            let selectedStart = scheduleRequest.selectedStart,
            let selectedEnd = scheduleRequest.selectedEnd else { return }
        addStopToMap(stop: selectedStart, pinColor: UIColor.green)
        addStopToMap(stop: selectedEnd, pinColor: UIColor.red)
        updateVisibleMap()
    }

    func addStopToMap(stop: Stop, pinColor: UIColor) {
        let annotation = ColorPointAnnotation(pinColor: pinColor)
        annotation.coordinate = CLLocationCoordinate2D(latitude: stop.stopLatitude, longitude: stop.stopLongitude)
        annotation.title = stop.stopName

        mapView.addAnnotation(annotation)
        let mapPoint = MKMapPointForCoordinate(annotation.coordinate)
        let annotationMapRect = MKMapRect(origin: mapPoint, size: MKMapSize(width: 1000, height: 1000))
        mapRect = MKMapRectUnion(mapRect, annotationMapRect)
    }

    func parseKMLForRoute(url: URL, routeId: String) {
        print("Beginning to parse")
        KMLDocument.parse(url) { [unowned self] kml in
            guard let overlays = kml.overlays as? [KMLOverlayPolyline] else { return }
            let routeOverlays = self.mapOverlaysToRouteOverlays(routeId: routeId, overlays: overlays)
            self.overlaysToAdd = self.overlaysToAdd + routeOverlays
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
}

extension NextToArriveMapViewController: MKMapViewDelegate {

    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeOverlay = overlay as? RouteOverlay, let routeId = routeOverlay.routeId else { return MKOverlayRenderer(overlay: overlay) }
        let renderer: MKPolylineRenderer = MKPolylineRenderer(polyline: routeOverlay)

        renderer.strokeColor = Route.colorForRouteId(routeId, transitMode: .bus)
        renderer.lineWidth = 4.0

        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.isEnabled = true
            let colorPointAnnotation = annotation as! ColorPointAnnotation
            pinView?.pinTintColor = colorPointAnnotation.pinColor
        } else {
            pinView?.annotation = annotation
        }

        return pinView
    }

    func mapView(_: MKMapView, didSelect _: MKAnnotationView) {
        print("User Selected a pin")
    }
}
