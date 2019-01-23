// Septa. 2017

import UIKit

protocol ScheduleDisplayable {
    func setTripText(text: String)
    func setDepartText(text: String)
    func getDepartText() -> String
    func setArriveText(text: String)
    func setDurationText(text: String)
    func setVehicleTitle(text: String)
    func setVehicleText(text: String)
    func hideVehicleTitle(_ isHiden: Bool)
}

class ScheduleTableViewCell: UITableViewCell, ScheduleDisplayable {
    
    @IBOutlet private var tripLabel: UILabel!
    @IBOutlet private var departLabel: UILabel!
    @IBOutlet private var arriveLabel: UILabel!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var vehicleTitleLabel: UILabel!
    @IBOutlet private var vehicleLabel: UILabel!

    func setTripText(text: String) {
        tripLabel.text = text
    }

    func setDepartText(text: String) {
        departLabel.text = text
    }
    func getDepartText(text: String) {
        if let departText = departLabel.text {
        return departLabel.text
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
