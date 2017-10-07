// Septa. 2017

import UIKit

protocol ScheduleDisplayable {

    func setTripText(text: String)
    func setDepartText(text: String)
    func setArriveText(text: String)
    func setDurationText(text: String)
    func setVehicleTitle(text: String)
    func setVehicleText(text: String)
    func hideVehicleTitle(_ isHiden: Bool)
}

class ScheduleTableViewCell: UITableViewCell, ScheduleDisplayable {

    @IBOutlet private weak var tripLabel: UILabel!
    @IBOutlet private weak var departLabel: UILabel!
    @IBOutlet private weak var arriveLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet weak var vehicleTitleLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!

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

    func setVehicleTitle(text: String) {
        vehicleTitleLabel.text = text
    }

    func setVehicleText(text: String) {
        vehicleLabel.text = text
    }

    func hideVehicleTitle(_: Bool) {
        vehicleTitleLabel.isHidden = isHidden
    }
}
