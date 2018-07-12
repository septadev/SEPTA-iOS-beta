//
//  TransitViewMapViewController.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/10/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit
import MapKit
import SeptaSchedule

class TransitViewMapViewController: UIViewController {

    var viewModel = TransitViewMapRouteViewModel()
    var routesHaveBeenAdded = false
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            addOverlaysToMap()
            drawVehicleLocations()
            mapView.isRotateEnabled = false
            mapView.isAccessibilityElement = false
            mapView.accessibilityElementsHidden = true            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.showAnnotations(mapView.annotations, animated: false)
        mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0), animated: true)
    }
    
    private var overlaysToAdd = [MKOverlay]() {
        didSet {
            guard let _ = mapView else { return }
            addOverlaysToMap()
            overlaysToAdd.removeAll()
        }
    }
    
    var vehicleAnnotationsAdded = [TransitViewVehicleAnnotation]()
    private var vehiclesToAdd = [TransitViewVehicleLocation]() {
        didSet {
            guard let _ = mapView else { return }
            clearExistingVehicleLocations()
            drawVehicleLocations()
            mapView.showAnnotations(mapView.annotations, animated: false)
            mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0), animated: true)
            vehiclesToAdd.removeAll()
        }
    }
    
    private func clearExistingVehicleLocations() {
        mapView.removeAnnotations(vehicleAnnotationsAdded)
        vehicleAnnotationsAdded.removeAll()
    }
    
    private func drawVehicleLocations() {
        for vehicle in vehiclesToAdd {
            drawVehicle(vehicle)
        }
    }
    
    func drawVehicle(_ vehicleLocation: TransitViewVehicleLocation) {
        let annotation = TransitViewVehicleAnnotation(location: vehicleLocation)
        annotation.coordinate = vehicleLocation.coordinate
        if #available(iOS 11.0, *) {
            annotation.title = nil
        } else {
            annotation.title = vehicleLocation.mode.mapTitle()
        }
        
        mapView.addAnnotation(annotation)
        vehicleAnnotationsAdded.append(annotation)
    }

    
    private func addOverlaysToMap() {
        mapView.addOverlays(overlaysToAdd)
    }
    
    private func locateKMLFile(routeId: String) -> URL? {
        guard let url = Bundle.main.url(forResource: routeId, withExtension: "kml") else { return nil }
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        } else {
            print("Could not find kml file for route \(routeId)")
            return nil
        }
    }
    
    private func parseKMLForRoute(url: URL, routeId: String) {
        KMLDocument.parse(url) { [unowned self] kml in
            guard let overlays = kml.overlays as? [KMLOverlayPolyline] else { return }
            let routeOverlays = self.mapOverlaysToRouteOverlays(routeId: routeId, overlays: overlays)
            self.overlaysToAdd = self.overlaysToAdd + routeOverlays
        }
    }
    
    private func mapOverlaysToRouteOverlays(routeId: String, overlays: [KMLOverlayPolyline]) -> [RouteOverlay] {
        return overlays.map { overlay in
            let routeOverlay = RouteOverlay(points: overlay.points(), count: overlay.pointCount)
            routeOverlay.routeId = routeId
            return routeOverlay
        }
    }

}

extension TransitViewMapViewController: MKMapViewDelegate {
    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeOverlay = overlay as? RouteOverlay, let routeId = routeOverlay.routeId else { return MKOverlayRenderer(overlay: overlay) }
        let renderer: MKPolylineRenderer = MKPolylineRenderer(polyline: routeOverlay)
        
        renderer.strokeColor = Route.colorForRouteId(routeId, transitMode: .bus)
        renderer.lineWidth = 2.0
        
        return renderer
    }
    
    func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let transitAnnotation = annotation as? TransitViewVehicleAnnotation else { return nil }
        
        var annotationView: MKAnnotationView
        if let reusableView = mapView.dequeueReusableAnnotationView(withIdentifier: transitAnnotation.annotationId) {
            annotationView = reusableView
        } else {
            annotationView = buildNewAnnotationView(annotation: transitAnnotation)
        }
        annotationView.annotation = annotation
        return annotationView
    }
    
    func buildNewAnnotationView(annotation: TransitViewVehicleAnnotation) -> MKAnnotationView {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.annotationId)
        annotationView.accessibilityElementsHidden = false
        annotationView.accessibilityLabel = "Tap this pin to see vehicle information"
        annotationView.image = annotation.location.mode.mapPin()
        annotationView.canShowCallout = true
        annotationView.detailCalloutAccessoryView = UIView.loadNibView(nibName: "MapVehicleCalloutView")!
        return annotationView
    }
}

extension TransitViewMapViewController: TransitViewMapDataProviderDelegate {

    func drawRoutes(routeIds: [String]) {
        guard !routesHaveBeenAdded else { return }
        for routeId in routeIds {
            guard let url = locateKMLFile(routeId: routeId) else { return }
            parseKMLForRoute(url: url, routeId: routeId)
            routesHaveBeenAdded = true
        }
    }
    
    func drawVehicleLocations(locations: [TransitViewVehicleLocation]) {
        vehiclesToAdd = locations
    }
}
