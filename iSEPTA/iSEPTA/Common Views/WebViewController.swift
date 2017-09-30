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

class WebViewController: UIViewController, IdentifiableController, WKNavigationDelegate {
    var viewController: ViewController = .webViewController
    var webView: WKWebView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        view.backgroundColor = SeptaColor.navBarBlue
        super.viewDidLoad()

        configureWebView()
        configureActivityIndicator()
        loadURL()
        navigationController?.navigationBar.configureBackButton()
    }

    func configureWebView() {
        webView = WKWebView(frame: view.frame)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        view.pinSubviewTopToNavBarBottom(webView, topLayoutGuide: topLayoutGuide)
    }

    func configureActivityIndicator() {
        view.bringSubview(toFront: activityIndicator)
    }

    func loadURL() {
        if let septaConnection = store.state.moreState.septaConnection {
            let request = URLRequest(url: septaConnection.url())
            webView.load(request)
            title = septaConnection.title()
        }
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        backButtonPopped(toParentViewController: parent)
    }
}
