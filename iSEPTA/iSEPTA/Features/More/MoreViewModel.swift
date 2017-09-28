//
//  MoreViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/28/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class MoreViewModel {

    func numberOfRows() -> Int {
        return 4
    }

    func configureCell(cell: MoreTableViewCell, indexPath: IndexPath) {
        switch indexPath.row {
        case 0: configureFaresCell(cell: cell)
        case 1: configureSubwayMapCell(cell: cell)
        case 2: configureEventsCell(cell: cell)
        case 3: configureConnectCell(cell: cell)
        default: break
        }
    }

    func configureFaresCell(cell: MoreTableViewCell) {
        cell.moreLabel.text = "Fares"
        cell.moreImageView.image = UIImage(named: "faresCell")
    }

    func configureSubwayMapCell(cell: MoreTableViewCell) {
        cell.moreLabel.text = "Subway Map"
        cell.moreImageView.image = UIImage(named: "subwayMapCell")
    }

    func configureEventsCell(cell: MoreTableViewCell) {
        cell.moreLabel.text = "Events"
        cell.moreImageView.image = UIImage(named: "eventsCell")
    }

    func configureConnectCell(cell: MoreTableViewCell) {
        cell.moreLabel.text = "Connect with SEPTA"
        cell.moreImageView.image = UIImage(named: "connectCell")
    }
}
