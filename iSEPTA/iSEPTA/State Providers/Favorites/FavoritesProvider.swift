//
//  FavoritesProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import CoreLocation
import ReSwift

enum FavoritesError: Error {

    case couldNotCreateTempFavoritesFile
    case couldNotCreateFavoritesFile
}

class FavoritesProvider: StoreSubscriber, FavoritesState_FavoriteToEditWatcherDelegate {

    typealias StoreSubscriberStateType = FavoritesState

    static let sharedInstance = FavoritesProvider()

    let fileManager = FileManager.default
    var initialLoadFavoritesFromDiskHasCompleted = false

    var favoriteToEditWatcher: FavoritesState_FavoriteToEditWatcher?

    private init() {
        retrieveFavoritesFromDisk()
        subscribe()

        favoriteToEditWatcher = FavoritesState_FavoriteToEditWatcher(delegate: self)

        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appLosingFocus(notification:)),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: app)
    }

    @objc func appLosingFocus(notification _: NSNotification) {
        guard let currentFavoriteState = self.currentFavoriteState else { return }
        writeFavoritesToFile(state: currentFavoriteState)
    }

    func favoritesState_FavoriteToEditUpdated(favorite _: Favorite?) {
        guard let currentFavoriteState = currentFavoriteState else { return }
    }

    func retrieveFavoritesFromDisk() {
        DispatchQueue.global(qos: .background).async { [weak self] in

            do {
                if let targetURL = self?.favoritesFileURL,
                    let fileManager = self?.fileManager,
                    fileManager.fileExists(atPath: targetURL.path) {

                    let jsonData = try Data(contentsOf: targetURL)
                    let favorites = try JSONDecoder().decode([Favorite].self, from: jsonData)

                    DispatchQueue.main.async {

                        print("retrieve favorites from \(targetURL.path) was successful")
                        if favorites.count > 0 {
                            let switcchTabsAction = SwitchTabs(activeNavigationController: .favorites, description: "Defaulting to Favorites because they exist")
                            store.dispatch(switcchTabsAction)
                        }
                        let action = LoadFavorites(favorites: favorites)
                        store.dispatch(action)
                    }
                }
                self?.initialLoadFavoritesFromDiskHasCompleted = true
            } catch {
                print(error.localizedDescription)
            }
        }
        initialLoadFavoritesFromDiskHasCompleted = true
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.favoritesState
            }.skipRepeats { $0 == $1 }
        }
    }

    deinit {
        unsubscribe()
    }

    private func unsubscribe() {
        store.unsubscribe(self)
    }

    var currentFavoriteState: FavoritesState?
    func newState(state: FavoritesState) {
        currentFavoriteState = state
    }

    func setStartupNavController(state _: FavoritesState) {
        // TODO: When there are favorites the startup controller should be set here.
    }

    func writeFavoritesToFile(state: FavoritesState) {
        guard initialLoadFavoritesFromDiskHasCompleted else { return }
        DispatchQueue.global(qos: .background).async { [weak self] in

            do {
                if let targetURL = self?.favoritesFileURL,
                    let tempURL = self?.tempFavoritesFileURL,
                    let fileManager = self?.fileManager {
                    let jsonData = try JSONEncoder().encode(state.favorites)
                    fileManager.createFile(atPath: tempURL.path, contents: jsonData, attributes: nil)
                    _ = try fileManager.replaceItemAt(targetURL, withItemAt: tempURL)
                    print("copy favorites to \(targetURL.path) was successful")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    fileprivate lazy var documentDirectoryURL: URL? = {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }()

    fileprivate lazy var favoritesFileURL: URL? = {
        documentDirectoryURL?.appendingPathComponent("favorites.json")
    }()

    fileprivate lazy var tempFavoritesFileURL: URL? = {
        documentDirectoryURL?.appendingPathComponent("Tempfavorites.json")
    }()
}
