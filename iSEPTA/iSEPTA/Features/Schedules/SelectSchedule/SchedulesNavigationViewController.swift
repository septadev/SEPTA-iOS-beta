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
}
