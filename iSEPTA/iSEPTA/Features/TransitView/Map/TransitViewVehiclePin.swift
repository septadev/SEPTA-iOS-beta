//
//  TransitViewVehiclePin.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/13/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import SeptaSchedule

struct TransitViewVehiclePin {
    static func generate(mode: TransitMode, direction: Int, active: Bool) -> UIImage {
        guard let backgroundImage = directionImage(direction: direction, active: active) else { return UIImage() }
        guard let modeImage = imageForMode(mode: mode, active: active) else { return backgroundImage }
        guard let finalImage = layerImages(background: backgroundImage, foreground: modeImage) else { return backgroundImage }
        return finalImage
    }

    private static func directionImage(direction: Int, active: Bool) -> UIImage? {
        let color = active ? "blue" : "gray"
        var angle = ""

        if direction > 337 || direction <= 22 {
            angle = "0"
        } else if direction > 22 && direction <= 67 {
            angle = "045"
        } else if direction > 67 && direction <= 112 {
            angle = "090"
        } else if direction > 112 && direction <= 157 {
            angle = "135"
        } else if direction > 157 && direction <= 202 {
            angle = "180"
        } else if direction > 202 && direction <= 247 {
            angle = "225"
        } else if direction > 247 && direction <= 292 {
            angle = "270"
        } else if direction > 292 && direction <= 337 {
            angle = "315"
        }
        return UIImage(named: "rotate_bg_\(color)-\(angle)")
    }

    private static func imageForMode(mode: TransitMode, active: Bool) -> UIImage? {
        var modeImage: UIImage?
        if mode == .bus {
            modeImage = active ? UIImage(named: "busBlue") : UIImage(named: "busGray")
        } else if mode == .trolley {
            modeImage = active ? UIImage(named: "trolleyBlue") : UIImage(named: "trolleyGray")
        }
        return modeImage
    }

    private static func layerImages(background: UIImage, foreground: UIImage) -> UIImage? {
        let bgSize = background.size
        UIGraphicsBeginImageContextWithOptions(bgSize, false, 0.0)
        background.draw(in: CGRect(x: 0, y: 0, width: bgSize.width, height: bgSize.height))
        foreground.draw(in: CGRect(x: 0, y: 0, width: bgSize.width, height: bgSize.height))
        let layeredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return layeredImage
    }
}
