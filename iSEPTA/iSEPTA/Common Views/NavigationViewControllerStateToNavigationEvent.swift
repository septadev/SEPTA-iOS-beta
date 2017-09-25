//
//  NavigationStackStateToNavigationControllerEvent.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/21/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

enum ViewControllerStackEventNeeded {
    case noActionNeeded
    case rootViewController(ViewController)
    case push(ViewController)
    case pop
    case systemPop
    case replaceViewStack([ViewController])
    case appendToViewStack([ViewController])
    case truncateViewStack(Int)
}

class NavigationViewControllerStateToNavigationEvent {
    let currentControllers: [ViewController]
    let newControllers: [ViewController]
    let displayControllers: [ViewController]
    var commonControllers = [ViewController]()

    init(currentControllers: [ViewController], newControllers: [ViewController], displayControllers: [ViewController]) {
        self.currentControllers = currentControllers
        self.newControllers = newControllers
        self.displayControllers = displayControllers
        commonControllers = findCommonControllers(currentControllers: currentControllers, newControllers: newControllers)
    }

    func determineNecessaryStateAction() -> ViewControllerStackEventNeeded {
        guard let lastNewController = newControllers.last else { return .noActionNeeded }

        if shouldSetRootViewController() {
            return .rootViewController(lastNewController)
        }

        if didSystemPopOccur() {
            return .systemPop
        }

        if shouldPush() {
            return .push(lastNewController)
        }

        if shouldPop() {
            return .pop
        }

        if shouldReplaceViewStack() {
            return .replaceViewStack(newControllers)
        }

        if let controllersToAppend = findControllersToAppend() {
            return .appendToViewStack(controllersToAppend)
        }

        if let controllersToTrim = findControllersToTrim() {
            return .truncateViewStack(controllersToTrim)
        }

        return .noActionNeeded
    }

    private func didSystemPopOccur() -> Bool {
        return displayControllers == newControllers && currentControllers.count - newControllers.count == 1
    }

    private func shouldSetRootViewController() -> Bool {
        return displayControllers.count == 0
    }

    private func shouldPush() -> Bool {
        return newControllers.count - currentControllers.count == 1 && commonControllers.count == currentControllers.count
    }

    private func shouldPop() -> Bool {

        return currentControllers.count - newControllers.count == 1 && newControllers.count == commonControllers.count
    }

    private func shouldReplaceViewStack() -> Bool {
        return commonControllers.count == 0
    }

    private func findCommonControllers(currentControllers: [ViewController], newControllers: [ViewController]) -> [ViewController] {

        let minSize = min(currentControllers.count, newControllers.count)
        let trimmedCurrent = currentControllers[..<minSize]
        let trimmedNew = newControllers[..<minSize]

        var result = [ViewController]()

        for (i, viewController) in trimmedNew.enumerated() {
            if trimmedNew[i] == trimmedCurrent[i] {
                result.append(viewController)
            }
        }
        print(result)
        return result
    }

    private func findControllersToAppend() -> [ViewController]? {
        guard newControllers.count > currentControllers.count else { return nil }

        let slice = newControllers[commonControllers.count...]
        return Array(slice)
    }

    private func findControllersToTrim() -> Int? {
        guard currentControllers.count > newControllers.count, newControllers == commonControllers else { return nil }
        return newControllers.count
    }
}
