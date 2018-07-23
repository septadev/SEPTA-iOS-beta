// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class SchedulesNavigationController: BaseNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
        initializeNavStackState()
        let stateProvider = SchedulesNavigationControllerStateProvider()
        stateProvider.navigationController = self
        stateProvider.subscribe()
        super.stateProvider = stateProvider
    }

    override func viewDidAppear(_: Bool) {
        let inAppReview = InAppReview()
        inAppReview.promptIfAppropriate()
    }

    func initializeNavStackState() {
        currentStackState = NavigationStackState(viewControllers: [.selectSchedules], modalViewController: nil)

        let action = InitializeNavigationState(navigationController: .schedules, navigationStackState: currentStackState, description: "Initializing stack state for Schedules")
        store.dispatch(action)
    }
}
