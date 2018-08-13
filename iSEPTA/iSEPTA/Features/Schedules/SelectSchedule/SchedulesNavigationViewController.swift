// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class SchedulesNavigationController: BaseNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
    }

    override func viewDidAppear(_: Bool) {
        let inAppReview = InAppReview()
        inAppReview.promptIfAppropriate()
    }

    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.navigationState.appStackState[.schedules] }
        }
    }

    override func resetViewState(resetViewState: ResetViewState?) {
        guard let resetViewState = resetViewState else { return }

        var viewControllers = [UIViewController]()

        switch resetViewState.viewController {
        case .tripScheduleController:
            viewControllers = retrieveOrInstantiate(viewControllers: [.selectSchedules, .tripScheduleController])
        case .selectSchedules:
            viewControllers = retrieveOrInstantiate(viewControllers: [.selectSchedules])
        default: break
        }

        self.viewControllers = viewControllers

        store.dispatch(ResetViewStateHandled())
    }
}
