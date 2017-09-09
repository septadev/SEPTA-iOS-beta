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
            drawVehicleLocations()
        }
    }

    private var vehiclesToAdd = [VehicleLocation]() {
        didSet {
            guard let _ = mapView else { return }
            drawVehicleLocations()
            vehiclesToAdd.removeAll()
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
        let expandedRect = mapView.mapRectThatFits(mapRect, edgePadding: UIEdgeInsetsMake(100, 10, 10, 30))
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

    var stops = [ColorPointAnnotation]()
    func addStopToMap(stop: Stop, pinColor: UIColor) {
        let annotation = ColorPointAnnotation(pinColor: pinColor)
        annotation.coordinate = CLLocationCoordinate2D(latitude: stop.stopLatitude, longitude: stop.stopLongitude)
        annotation.title = stop.stopName
        stops.append(annotation)
        mapView.addAnnotation(annotation)
        let mapPoint = MKMapPointForCoordinate(annotation.coordinate)
        let annotationMapRect = MKMapRect(origin: mapPoint, size: MKMapSize(width: 1000, height: 1000))
        mapRect = MKMapRectUnion(mapRect, annotationMapRect)
    }

    func drawVehicleLocations(_ vehicleLocations: [VehicleLocation]) {
        vehiclesToAdd = vehicleLocations
    }

    func drawVehicleLocations() {
        for vehicle in vehiclesToAdd {
            if isPhillyCoordinate(vehicle.firstLegLocation) {
                drawVehicle(coordinate: vehicle.firstLegLocation)
            }

            if isPhillyCoordinate(vehicle.secondLegLocation) {
                drawVehicle(coordinate: vehicle.secondLegLocation)
            }
        }
    }

    let philly = CLLocation(latitude: 39.952583, longitude: -75.165222)
    func isPhillyCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return philly.distance(from: location) < 160_934 // 100 miles
    }

    func drawVehicle(coordinate: CLLocationCoordinate2D) {
        let annotation = VehicleLocationAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)

        let mapPoint = MKMapPointForCoordinate(annotation.coordinate)
        let annotationMapRect = MKMapRect(origin: mapPoint, size: MKMapSize(width: 1000, height: 1000))
        mapRect = MKMapRectUnion(mapRect, annotationMapRect)
        updateVisibleMap()
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

    deinit {
        _ = 1
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

    func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case let annotation as ColorPointAnnotation:
            return retrievePinAnnogationView(annotation: annotation)
        case let annotation as VehicleLocationAnnotation:
            return retrieveVehicleAnnogationView(annotation: annotation)
        default:
            return nil
        }
    }

    func retrievePinAnnogationView(annotation: ColorPointAnnotation) -> MKAnnotationView {
        let pinViewId = "pin"
        guard let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinViewId) as? MKPinAnnotationView else {
            return buildNewPinAnnotationView(annotation: annotation, pinViewId: pinViewId)
        }
        pinView.annotation = annotation
        return pinView
    }

    func buildNewPinAnnotationView(annotation: ColorPointAnnotation, pinViewId: String) -> MKPinAnnotationView {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinViewId)
        pinView.canShowCallout = true
        pinView.animatesDrop = true
        pinView.isEnabled = true
        pinView.isSelected = true
        pinView.pinTintColor = annotation.pinColor
        return pinView
    }

    func retrieveVehicleAnnogationView(annotation: VehicleLocationAnnotation) -> MKAnnotationView {
        let vehicleId = "vehicle"
        guard let vehicleView = mapView.dequeueReusableAnnotationView(withIdentifier: vehicleId) else {
            return buildNewVehicleAnnotationView(annotation: annotation, vehicleViewId: vehicleId)
        }
        vehicleView.annotation = annotation
        return vehicleView
    }

    func buildNewVehicleAnnotationView(annotation: VehicleLocationAnnotation, vehicleViewId: String) -> MKAnnotationView {
        let vehicleView = MKAnnotationView(annotation: annotation, reuseIdentifier: vehicleViewId)
        vehicleView.image = scheduleRequest?.transitMode.mapPin()
        return vehicleView
    }

    func mapView(_: MKMapView, didSelect _: MKAnnotationView) {
        print("User Selected a pin")
    }
}
