//
//  WebViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController, IdentifiableController {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.frame)
        view.pinSubview(webView)
    }

    var viewController: ViewController = .webViewController
}
