//
//  NextToArriveNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NextToArriveNavigationController: BaseNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
    }

    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.navigationState.appStackState[.nextToArrive] }
        }
    }

    override func resetViewState(resetViewState: ResetViewState?) {
        guard let resetViewState = resetViewState else { return }

        var viewControllers = [UIViewController]()

        switch resetViewState.viewController {
        case .nextToArriveController:
            viewControllers = retrieveOrInstantiate(viewControllers: [.nextToArriveController])
        case .nextToArriveDetailController:
            viewControllers = retrieveOrInstantiate(viewControllers: [.nextToArriveController, .nextToArriveDetailController])
        case .tripDetailViewController:
            viewControllers = retrieveOrInstantiate(viewControllers: [.nextToArriveController, .nextToArriveDetailController, .tripDetailViewController])
        default: break
        }

        self.viewControllers = viewControllers

        store.dispatch(ResetViewStateHandled())
    }
}
