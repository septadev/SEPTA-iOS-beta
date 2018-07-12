//
//  NextToArriveMapViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import AEXML
import Foundation
import MapKit
import ReSwift
import SeptaRest
import SeptaSchedule
import UIKit

struct MappableScheduleRequest: Equatable {
    let transitMode: TransitMode
    let selectedStart: Stop
    let selectedEnd: Stop
    init?(scheduleRequest: ScheduleRequest?) {
        guard let scheduleRequest = scheduleRequest,
            let selectedStart = scheduleRequest.selectedStart,
            let selectedEnd = scheduleRequest.selectedEnd else { return nil }

        transitMode = scheduleRequest.transitMode
        self.selectedStart = selectedStart
        self.selectedEnd = selectedEnd
    }
}

/// Draws the current next to arrive view on a map.
/// Three things need to be drawn here: 1) starting and ending pins, 2) the routes, 3) the vehicles
class NextToArriveMapViewController: UIViewController, RouteDrawable {

    var nextToArriveMapRouteViewModel: NextToArriveMapRouteViewModel!
    var nextToArriveMapEndpointsViewModel: NextToArriveMapEndpointsViewModel!

    /// These annotations are for the begin and the ending stops on the map.
    var stops = [ColorPointAnnotation]()

    /// These annotations are for vehicles that have been added to the map
    var vehiclesAnnotationsAdded = [VehicleLocationAnnotation]()

    /// These are for the routes that have been added to the map
    var routeIds = [String]()

    private var mappableScheduleRequest: MappableScheduleRequest? {
        didSet {
            if oldValue != mappableScheduleRequest && mappableScheduleRequest != nil {
                removeScheduleRequestFromMap()
                addScheduleRequestToMap()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        nextToArriveMapRouteViewModel = NextToArriveMapRouteViewModel()
        nextToArriveMapRouteViewModel.delegate = self
        nextToArriveMapEndpointsViewModel = NextToArriveMapEndpointsViewModel()
        nextToArriveMapEndpointsViewModel.delegate = self
    }

    /// We need to wait for the mapView to load before we try to add anything to it.
    @IBOutlet private var mapView: MKMapView! {
        didSet {
            addOverlaysToMap()
            addScheduleRequestToMap()
            drawVehicleLocations()
            mapView.isRotateEnabled = false
            mapView.isAccessibilityElement = false
            mapView.accessibilityElementsHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.tintColor = SeptaColor.navBarBlue
    }

    override func viewWillAppear(_: Bool) {
        showAllAnnotations()
        mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0), animated: true)
    }

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

    func addOverlaysToMap() {
        guard let mapView = mapView else { return }
        mapView.addOverlays(overlaysToAdd)
    }

    func drawRoutes(routeIds newRouteIds: [String]) {

        let routeIdsToAdd = newRouteIds.filter { !routeIds.contains($0) }
        routeIds.append(contentsOf: routeIdsToAdd)

        for routeId in routeIdsToAdd {
            guard let url = locateKMLFile(routeId: routeId) else { return }
            parseKMLForRoute(url: url, routeId: routeId)
        }
    }

    /// When we get a schedule we need to update
    func drawTrip(scheduleRequest: ScheduleRequest) {
        mappableScheduleRequest = MappableScheduleRequest(scheduleRequest: scheduleRequest)
    }

    // MARK: - Schedule Request

    func removeScheduleRequestFromMap() {
        guard let mapView = mapView else { return }

        mapView.removeAnnotations(stops)
        stops.removeAll()
    }

    func addScheduleRequestToMap() {
        guard let mappableScheduleRequest = mappableScheduleRequest else { return }
        addStopToMap(stop: mappableScheduleRequest.selectedStart, colorPointAnnotationType: ColorPointAnnotationType.start)
        addStopToMap(stop: mappableScheduleRequest.selectedEnd, colorPointAnnotationType: ColorPointAnnotationType.end)
    }

    func addStopToMap(stop: Stop, colorPointAnnotationType: ColorPointAnnotationType) {
        guard let mapView = mapView else { return }
        let annotation = ColorPointAnnotation(colorPointAnnotationType: colorPointAnnotationType)
        annotation.coordinate = CLLocationCoordinate2D(latitude: stop.stopLatitude, longitude: stop.stopLongitude)
        annotation.title = stop.stopName
        stops.append(annotation)
        mapView.addAnnotation(annotation)
    }

    func showAllAnnotations() {
        guard let mapView = mapView else { return }
        mapView.showAnnotations(mapView.annotations, animated: false)
        // mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0), animated: true)
    }

    func drawVehicleLocations(_ vehicleLocations: [VehicleLocation]) {
        vehiclesToAdd = vehicleLocations
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
        if #available(iOS 11.0, *) {
            annotation.title = nil
        } else {
            if let transitMode = mappableScheduleRequest?.transitMode {
                annotation.title = transitMode.mapTitle()
            }
        }

        mapView.addAnnotation(annotation)
        vehiclesAnnotationsAdded.append(annotation)
    }

    func clearExistingVehicleLocations() {
        mapView.removeAnnotations(vehiclesAnnotationsAdded)
        vehiclesAnnotationsAdded.removeAll()
    }

    func parseKMLForRoute(url: URL, routeId: String) {
        print("Beginning to parse")
        KMLDocument.parse(url) { [weak self] kml in
            guard let strongSelf = self, let overlays = kml.overlays as? [KMLOverlayPolyline] else { return }
            let routeOverlays = strongSelf.mapOverlaysToRouteOverlays(routeId: routeId, overlays: overlays)
            strongSelf.overlaysToAdd = strongSelf.overlaysToAdd + routeOverlays
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

    func removeAllAnnotations() {

        let annotations = mapView.annotations.filter {
            $0 !== self.mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
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
            return retrieveVehicleAnnotationView(annotation: annotation)
        default:
            return nil
        }
    }

    func retrievePinAnnogationView(annotation: ColorPointAnnotation) -> MKAnnotationView {
        let pinViewId = annotation.colorPointAnnotationType.rawValue
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
        pinView.pinTintColor = annotation.colorPointAnnotationType.pinColor()
        return pinView
    }

    func retrieveVehicleAnnotationView(annotation: VehicleLocationAnnotation) -> MKAnnotationView {
        let vehicleId = "vehicle"
        let annotationView: MKAnnotationView
        if let vehicleView = mapView.dequeueReusableAnnotationView(withIdentifier: vehicleId) {
            annotationView = vehicleView
        } else {
            annotationView = buildNewVehicleAnnotationView(annotation: annotation, vehicleViewId: vehicleId)
        }

        if let calloutAccessoryView = annotationView.detailCalloutAccessoryView as? MapVehicleCalloutView {
            calloutAccessoryView.buildCalloutView(vehicleLocation: annotation.vehicleLocation)
        }
        annotationView.annotation = annotation

        return annotationView
    }

    func buildNewVehicleAnnotationView(annotation: VehicleLocationAnnotation, vehicleViewId: String) -> MKAnnotationView {
        let vehicleView = MKAnnotationView(annotation: annotation, reuseIdentifier: vehicleViewId)
        vehicleView.accessibilityElementsHidden = false
        vehicleView.accessibilityLabel = "Tap this pin to see vehicle information"
        vehicleView.image = mappableScheduleRequest?.transitMode.mapPin()
        vehicleView.canShowCallout = true
        vehicleView.detailCalloutAccessoryView = UIView.loadNibView(nibName: "MapVehicleCalloutView")!
        return vehicleView
    }

    func mapView(_: MKMapView, didSelect _: MKAnnotationView) {
        print("User Selected a pin")
    }

    func mapViewDidFinishLoadingMap(_: MKMapView) {
        print("Map View Finished Loading")
    }
}
