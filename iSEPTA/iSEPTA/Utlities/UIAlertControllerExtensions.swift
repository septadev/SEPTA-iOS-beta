//
//  UIAlertControllerExtensions.swift
//  iSEPTA
//
//  Created by Mike Mannix on 6/20/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit

public extension UIAlertController {
    func show() {
        let mainWindow = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        mainWindow.rootViewController = vc
        mainWindow.windowLevel = UIWindowLevelAlert + 1
        mainWindow.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
