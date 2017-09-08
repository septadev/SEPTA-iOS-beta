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

class RouteOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D

    var boundingMapRect: MKMapRect

    var routeId: String

    init(routeId: String, boundingMapRect: MKMapRect, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.boundingMapRect = boundingMapRect
        self.routeId = routeId
    }
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
        guard let polyline = overlay as? KMLOverlayPolyline else { return MKOverlayRenderer(overlay: overlay) }
        let renderer: MKPolylineRenderer = MKPolylineRenderer(polyline: polyline)

        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0

        return renderer
    }

    func drawRoute(routeId: String) {
        guard let url = locateKMLFile(routeId: routeId) else { return }
        parseKMLForRoute(url: url, routeId: routeId)
    }

    func parseKMLForRoute(url: URL, routeId _: String) {
        var mapRect = MKMapRectNull
        KMLDocument.parse(url) { [unowned self] kml in
            for overlay in kml.overlays {
                let overlayRegion = MKCoordinateRegionMakeWithDistance(overlay.coordinate, 1000, 1000)
                let overlayMapRect = self.mapRectForCoordinateRegion(region: overlayRegion)
                mapRect = MKMapRectUnion(mapRect, overlayMapRect)
            }
            self.mapView.addOverlays(kml.overlays)
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
}

class NextToArriveMapPrimaryRouteViewModel {
}

class NextToArriveMapSecondaryRouteViewModel {
}
