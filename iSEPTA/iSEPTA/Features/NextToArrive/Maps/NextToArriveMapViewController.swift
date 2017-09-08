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
        let routeMap = RouteMap(maxLat: 40.040856, minLat: 39.950876, maxLon: -75.14876, minLon: -75.289491)
        mapView.region = routeMap.region

        let url = Bundle.main.url(forResource: "44", withExtension: "kml")

        var mapRect = MKMapRectNull

        mapView.delegate = self
        KMLDocument.parse(url!, callback: { [unowned self] kml in
            for overlay in kml.overlays {
                let overlayRegion = MKCoordinateRegionMakeWithDistance(overlay.coordinate, 1000, 1000)
                let overlayMapRect = self.mapRectForCoordinateRegion(region: overlayRegion)
                mapRect = MKMapRectUnion(mapRect, overlayMapRect)
            }
            self.mapView.addOverlays(kml.overlays)
            let expandedRect = self.mapView.mapRectThatFits(mapRect, edgePadding: UIEdgeInsetsMake(10, 10, 10, 10))
            self.mapView.setVisibleMapRect(expandedRect, animated: false)
        }
        )
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

    // 40.040856    39.950876    -75.14876    -75.289491
}
