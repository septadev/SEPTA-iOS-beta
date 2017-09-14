//
//  ConnectionCellDisplayable.swift
//  FavoritesCell
//
//  Created by Mark Broski on 9/14/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

import Foundation
import UIKit

protocol ConnectionCellDisplayable {
    var startConnectionView: ConnectionView! { get }
    var endConnectionView: ConnectionView! { get }
    var connectionLabel: UILabel! { get }
}
