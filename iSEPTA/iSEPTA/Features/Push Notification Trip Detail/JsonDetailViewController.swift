//
//  JsonDetailViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/12/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class JsonDetailViewController: UIViewController, IdentifiableController{
    var viewController: ViewController = .jsonDetailViewController
    @IBOutlet var label: UILabel!

    var labelText: String? {
        didSet {
            guard let label = label else {return}
            label.text = labelText
        }

    }

    func displayEncodable(encodable: PushNotificationTripDetailState){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try? encoder.encode(encodable)
        labelText = String(data: json!, encoding: .utf8)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        label.text = labelText

    }



}
