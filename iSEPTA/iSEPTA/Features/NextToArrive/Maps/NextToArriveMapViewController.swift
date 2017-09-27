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

    override func viewWillAppear(_: Bool) {
        mapView.showAnnotations(mapView.annotations, animated: false)

        mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0), animated: true)
    }

    @IBOutlet private weak var mapView: MKMapView! {
        didSet {
            addOverlaysToMap()
            addScheduleRequestToMap()
            drawVehicleLocations()
            mapView.isRotateEnabled = false
        }
    }

    var vehiclesAnnotationsAdded = [VehicleLocationAnnotation]()
    private var vehiclesToAdd = [VehicleLocation]() {
        didSet {
            guard let _ = mapView else { return }
            clearExistingVehicleLocations()
            drawVehicleLocations()
            vehiclesToAdd.removeAll()
        }
    }

    private var overlaysToAdd = [MKOverlay]() {

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

    func addOverlaysToMap() {
        mapView.addOverlays(overlaysToAdd)
    }

    var routesHaveBeenAdded = false
    func drawRoutes(routeIds: [String]) {
        guard !routesHaveBeenAdded else { return }
        for routeId in routeIds {
            guard let url = locateKMLFile(routeId: routeId) else { return }
            parseKMLForRoute(url: url, routeId: routeId)
            routesHaveBeenAdded = true
        }
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
    }

    var stops = [ColorPointAnnotation]()
    func addStopToMap(stop: Stop, pinColor: UIColor) {
        let annotation = ColorPointAnnotation(pinColor: pinColor)
        annotation.coordinate = CLLocationCoordinate2D(latitude: stop.stopLatitude, longitude: stop.stopLongitude)
        annotation.title = stop.stopName
        stops.append(annotation)
        mapView.addAnnotation(annotation)
    }

    func drawVehicleLocations(_ vehicleLocations: [VehicleLocation]) {
        self.vehiclesToAdd = vehicleLocations
    }

    func drawVehicleLocations() {
        for vehicle in vehiclesToAdd {
            drawVehicle(vehicle)
        }
    }

    func drawVehicle(_ vehicleLocation: VehicleLocation) {
        guard let location = vehicleLocation.location else { return }
        let annotation = VehicleLocationAnnotation(vehicleLocation: vehicleLocation)
        annotation.coordinate = location

        mapView.addAnnotation(annotation)
        vehiclesAnnotationsAdded.append(annotation)
    }

    func clearExistingVehicleLocations() {
        mapView.removeAnnotations(vehiclesAnnotationsAdded)
        vehiclesAnnotationsAdded.removeAll()
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
        renderer.lineWidth = 2.0

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
        //        if annotation.vehicleLocation.isMoving, let bearing = annotation.vehicleLocation.bearing {
        //            let startingTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        //            let transformForBearing = startingTransform.rotated(by: CGFloat(bearing))
        //            //            vehicleView.transform = transformForBearing
        //        }
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

    func mapViewDidFinishLoadingMap(_: MKMapView) {
        print("Map View Finished Loading")
    }
}
