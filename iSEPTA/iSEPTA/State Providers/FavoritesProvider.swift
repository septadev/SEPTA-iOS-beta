//
//  FavoritesProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

import Foundation
import CoreLocation
import ReSwift

enum FavoritesError: Error {

    case couldNotCreateTempFavoritesFile
    case couldNotCreateFavoritesFile
}

class FavoritesProvider: StoreSubscriber {

    typealias StoreSubscriberStateType = FavoritesState

    static let sharedInstance = FavoritesProvider()

    let fileManager = FileManager.default
    var initialLoadFavoritesFromDiskHasCompleted = false

    private init() {
        retrieveFavoritesFromDisk()
        subscribe()
    }

    func retrieveFavoritesFromDisk() {
        DispatchQueue.global(qos: .background).async { [weak self] in

            do {
                if let targetURL = self?.favoritesFileURL,
                    let fileManager = self?.fileManager,
                    fileManager.fileExists(atPath: targetURL.path) {

                    let jsonData = try Data(contentsOf: targetURL)
                    let favorites = try JSONDecoder().decode([Favorite].self, from: jsonData)
                    let action = LoadFavorites(favorites: favorites)
                    DispatchQueue.main.async { store.dispatch(action) }

                    print("retrieve favorites from \(targetURL.path) was successful")
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

    func newState(state: FavoritesState) {
        writeFavoritesToFile(state: state)
    }

    func writeFavoritesToFile(state: FavoritesState) {
        guard initialLoadFavoritesFromDiskHasCompleted else { return }
        DispatchQueue.global(qos: .background).async { [weak self] in

            do {
                if let targetURL = self?.favoritesFileURL,
                    let tempURL = self?.tempFavoritesFileURL,
                    let fileManager = self?.fileManager {
                    let jsonData = try JSONEncoder().encode(state)
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
