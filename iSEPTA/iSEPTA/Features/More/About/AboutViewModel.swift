//
//  AboutViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

struct AboutViewModelItem {
    let title: String
    let value: String
}

class AboutViewModel {

    var viewItems: [AboutViewModelItem]!

    init() {
        buildViewItems()
    }

    func buildViewItems() {
        viewItems = [AboutViewModelItem]()
        viewItems.append(AboutViewModelItem(title: "App Version:", value: AppInfoProvider.versionNumber()))
        viewItems.append(AboutViewModelItem(title: "Build Number:", value: AppInfoProvider.buildNumber()))

        let lastScheduleUpdate = AppInfoProvider.lastDatabaseUpdate()
        let lastScheduleUpdateString = DateFormatters.uiDateFormatter.string(from: lastScheduleUpdate)
        viewItems.append(AboutViewModelItem(title: "Schedule Updated:", value: lastScheduleUpdateString))
    }
}
