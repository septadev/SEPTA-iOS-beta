// Septa. 2017

import UIKit

protocol ScheduleDisplayable {

    func setTripText(text: String)
    func setDepartText(text: String)
    func setArriveText(text: String)
    func setDurationText(text: String)
}

class ScheduleTableViewCell: UITableViewCell, ScheduleDisplayable {

    @IBOutlet private weak var tripLabel: UILabel!
    @IBOutlet private weak var departLabel: UILabel!
    @IBOutlet private weak var arriveLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!

    func setTripText(text: String) {
        tripLabel.text = text
    }

    func setDepartText(text: String) {
        departLabel.text = text
    }

    func setArriveText(text: String) {
        arriveLabel.text = text
    }

    func setDurationText(text: String) {
        durationLabel.text = text
    }
}
