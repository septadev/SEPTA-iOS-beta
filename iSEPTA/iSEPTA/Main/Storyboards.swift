// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation
import UIKit
import Septa

// swiftlint:disable file_length
// swiftlint:disable line_length
// swiftlint:disable type_body_length

protocol StoryboardSceneType {
  static var storyboardName: String { get }
}

extension StoryboardSceneType {
  static func storyboard() -> UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: Bundle(for: BundleToken.self))
  }

  static func initialViewController() -> UIViewController {
    guard let vc = storyboard().instantiateInitialViewController() else {
      fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
    }
    return vc
  }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
  func viewController() -> UIViewController {
    return Self.storyboard().instantiateViewController(withIdentifier: self.rawValue)
  }
  static func viewController(identifier: Self) -> UIViewController {
    return identifier.viewController()
  }
}

protocol StoryboardSegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: StoryboardSegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    performSegue(withIdentifier: segue.rawValue, sender: sender)
  }
}

enum StoryboardScene {
  enum LaunchScreen: StoryboardSceneType {
    static let storyboardName = "LaunchScreen"
  }
  enum Main: StoryboardSceneType {
    static let storyboardName = "Main"

    static func initialViewController() -> UITabBarController {
      guard let vc = storyboard().instantiateInitialViewController() as? UITabBarController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }
  }
  enum About: StoryboardSceneType {
    static let storyboardName = "about"

    static func initialViewController() -> UINavigationController {
      guard let vc = storyboard().instantiateInitialViewController() as? UINavigationController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }
  }
  enum Alerts: StoryboardSceneType {
    static let storyboardName = "alerts"

    static func initialViewController() -> UINavigationController {
      guard let vc = storyboard().instantiateInitialViewController() as? UINavigationController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }
  }
  enum Contact: StoryboardSceneType {
    static let storyboardName = "contact"

    static func initialViewController() -> UINavigationController {
      guard let vc = storyboard().instantiateInitialViewController() as? UINavigationController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }
  }
  enum Fares: StoryboardSceneType {
    static let storyboardName = "fares"

    static func initialViewController() -> UINavigationController {
      guard let vc = storyboard().instantiateInitialViewController() as? UINavigationController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }
  }
  enum Favorites: String, StoryboardSceneType {
    static let storyboardName = "favorites"

    static func initialViewController() -> UINavigationController {
      guard let vc = storyboard().instantiateInitialViewController() as? UINavigationController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }

    case favoritesScene = "favorites"
    static func instantiateFavorites() -> UINavigationController {
      guard let vc = StoryboardScene.Favorites.favoritesScene.viewController() as? UINavigationController
      else {
        fatalError("ViewController 'favorites' is not of the expected class UINavigationController.")
      }
      return vc
    }
  }
  enum NextToArrive: String, StoryboardSceneType {
    static let storyboardName = "nextToArrive"

    static func initialViewController() -> UINavigationController {
      guard let vc = storyboard().instantiateInitialViewController() as? UINavigationController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }

    case nextToArriveScene = "nextToArrive"
    static func instantiateNextToArrive() -> Septa.NextToArriveViewController {
      guard let vc = StoryboardScene.NextToArrive.nextToArriveScene.viewController() as? Septa.NextToArriveViewController
      else {
        fatalError("ViewController 'nextToArrive' is not of the expected class Septa.NextToArriveViewController.")
      }
      return vc
    }
  }
  enum Schedules: StoryboardSceneType {
    static let storyboardName = "schedules"

    static func initialViewController() -> UINavigationController {
      guard let vc = storyboard().instantiateInitialViewController() as? UINavigationController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }
  }
  enum Settings: StoryboardSceneType {
    static let storyboardName = "settings"

    static func initialViewController() -> UINavigationController {
      guard let vc = storyboard().instantiateInitialViewController() as? UINavigationController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }
  }
}

enum StoryboardSegue {
  enum Schedules: String, StoryboardSegueType {
    case selectStop
    case selectStops
    case showRoutes
    case showSchedule
    case unwindToSelectStops
  }
}

private final class BundleToken {}

