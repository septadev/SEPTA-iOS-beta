//
//  TransitViewOverviewViewController.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/10/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import SeptaSchedule
import UIKit

class TransitViewOverviewViewController: UIViewController, IdentifiableController {
    var viewController: ViewController = .transitViewMap

    @IBOutlet var favoriteBarButton: UIBarButtonItem!
    @IBOutlet var editFavoriteBarButton: UIBarButtonItem!
    @IBOutlet var refreshBarButton: UIBarButtonItem!

    var mapViewController: TransitViewMapViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = SeptaColor.navBarBlue
    }

    @IBAction func refreshTransitViewData(_: Any) {
        store.dispatch(RefreshTransitViewVehicleLocationData(description: "Request refresh of TransitView vehicle location data"))
    }

    @IBAction func favoriteButtonTapped(_: Any) {
        mapViewController?.favoriteButtonTapped()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "embedMapViewController" {
            if let mapViewController = segue.destination as? TransitViewMapViewController {
                self.mapViewController = mapViewController
                mapViewController.delegate = self
            }
        }
    }
}

extension TransitViewOverviewViewController: TransitViewMapDelegate {
    func selectionIsAFavorite(isAFavorite: Bool) {
        navigationItem.rightBarButtonItems?.removeAll()
        if isAFavorite {
            navigationItem.rightBarButtonItems = [editFavoriteBarButton, refreshBarButton]
        } else {
            navigationItem.rightBarButtonItems = [favoriteBarButton, refreshBarButton]
        }
    }
}
