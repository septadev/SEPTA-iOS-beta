//
//  SeptaUrl.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

struct SeptaUrlInfo {
    let url: URL
    let title: String
    let urlConnectionMode: URLConnectionMode
    init(url: URL, title: String, urlConnectionMode: URLConnectionMode) {
        self.url = url
        self.title = title
        self.urlConnectionMode = urlConnectionMode
    }
}

extension SeptaUrlInfo: Equatable {}
func == (lhs: SeptaUrlInfo, rhs: SeptaUrlInfo) -> Bool {
    var areEqual = true

    areEqual = lhs.url == rhs.url
    guard areEqual else { return false }

    areEqual = lhs.title == rhs.title
    guard areEqual else { return false }

    areEqual = lhs.urlConnectionMode == rhs.urlConnectionMode
    guard areEqual else { return false }

    return areEqual
}
