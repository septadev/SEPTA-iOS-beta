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

class RouteOverlay: KMLOverlayPolyline {

    var routeId: String?
}

struct RouteMap {
    let maxLat: CLLocationDegrees
    let minLat: CLLocationDegrees
    let maxLon: CLLocationDegrees
    let minLon: CLLocationDegrees

    var center: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: (maxLat + minLat) / 2.0, longitude: (maxLon + minLon) / 2.0)
    }

    var coordinateSpan: MKCoordinateSpan {
        return MKCoordinateSpan(latitudeDelta: ((maxLat - minLat) / 2.0), longitudeDelta: ((maxLon - minLon) / 2.0))
    }

    var region: MKCoordinateRegion {
        return MKCoordinateRegion(center: center, span: coordinateSpan)
    }
}

class NextToArriveMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        drawRoute(routeId: "44")
    }

    func mapRectForCoordinateRegion(region: MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta / 2), longitude: region.center.longitude - (region.span.longitudeDelta / 2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta / 2), longitude: region.center.longitude + (region.span.longitudeDelta / 2))

        let a = MKMapPointForCoordinate(topLeft)
        let b = MKMapPointForCoordinate(bottomRight)

        return MKMapRect(origin: MKMapPoint(x: min(a.x, b.x), y: min(a.y, b.y)), size: MKMapSize(width: abs(a.x - b.x), height: abs(a.y - b.y)))
    }

    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeOverlay = overlay as? RouteOverlay, let routeId = routeOverlay.routeId else { return MKOverlayRenderer(overlay: overlay) }
        let renderer: MKPolylineRenderer = MKPolylineRenderer(polyline: routeOverlay)

        renderer.strokeColor = Route.colorForRouteId(routeId, transitMode: .bus)
        renderer.lineWidth = 4.0

        return renderer
    }

    func drawRoute(routeId: String) {
        guard let url = locateKMLFile(routeId: routeId) else { return }
        parseKMLForRoute(url: url, routeId: routeId)
    }

    func parseKMLForRoute(url: URL, routeId: String) {
        var mapRect = MKMapRectNull
        KMLDocument.parse(url) { [unowned self] kml in
            guard let overlays = kml.overlays as? [KMLOverlayPolyline] else { return }
            let routeOverlays = self.mapOverlaysToRouteOverlays(routeId: routeId, overlays: overlays)

            for overlay in routeOverlays {
                let overlayRegion = MKCoordinateRegionMakeWithDistance(overlay.coordinate, 1000, 1000)
                let overlayMapRect = self.mapRectForCoordinateRegion(region: overlayRegion)
                mapRect = MKMapRectUnion(mapRect, overlayMapRect)
            }
            self.mapView.addOverlays(routeOverlays)
            let expandedRect = self.mapView.mapRectThatFits(mapRect, edgePadding: UIEdgeInsetsMake(10, 10, 10, 10))
            self.mapView.setVisibleMapRect(expandedRect, animated: false)
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

/*

 import ObjectiveC

 // Declare a global var to produce a unique address as the assoc object handle
 var AssociatedObjectHandle: UInt8 = 0

 extension MyClass {
 var stringProperty:String {
 get {
 return objc_getAssociatedObject(self, &AssociatedObjectHandle) as String
 }
 set {
 objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
 }
 }
 }
 */

class NextToArriveMapPrimaryRouteViewModel {
}

class NextToArriveMapSecondaryRouteViewModel {
}
