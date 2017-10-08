//
//  StartupViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/28/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class StartupViewController: UIViewController {
    @IBOutlet weak var buildNumber: UILabel!

    override func viewDidLoad() {
        let buildNumberText = AppInfoProvider.buildNumber()
        buildNumber.text = "Build Number \(buildNumberText)"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(timerFired(timer:)), userInfo: nil, repeats: true)
    }

    @objc func timerFired(timer: Timer) {
        timer.invalidate()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateInitialViewController()
        view.window?.rootViewController = mainViewController
    }
}
