//
//  SeptaDraw.swift
//  Septa
//
//  Created by Mark Broski on 8/19/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//

import UIKit

public class SeptaDraw: NSObject {

    //// Drawing Methods

    @objc public dynamic class func drawBlueGradientView(frame: CGRect = CGRect(x: 17, y: 49, width: 106, height: 59)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        //// Color Declarations
        let blueGradientTop = UIColor(red: 0.788, green: 0.890, blue: 1.000, alpha: 1.000)
        let blueGradientBottom = UIColor(red: 0.976, green: 0.988, blue: 1.000, alpha: 1.000)

        //// Gradient Declarations
        let blueGradient = CGGradient(colorsSpace: nil, colors: [blueGradientTop.cgColor, blueGradientBottom.cgColor] as CFArray, locations: [0, 1])!

        //// View Drawing
        let viewRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let viewPath = UIBezierPath(rect: viewRect)
        context.saveGState()
        viewPath.addClip()
        context.drawLinearGradient(blueGradient,
                                   start: CGPoint(x: viewRect.midX, y: viewRect.minY),
                                   end: CGPoint(x: viewRect.midX, y: viewRect.maxY),
                                   options: [])
        context.restoreGState()
    }

    @objc public dynamic class func drawBlueGradientCell(frame: CGRect = CGRect(x: 0, y: 0, width: 76, height: 32), shouldFill: Bool = true) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        //// Color Declarations
        let blueGradientLeft = UIColor(red: 0.871, green: 0.933, blue: 1.000, alpha: 1.000)
        let blueGradientRight = UIColor(red: 0.976, green: 0.988, blue: 1.000, alpha: 1.000)
        let cellBorder = UIColor(red: 0.514, green: 0.635, blue: 0.765, alpha: 1.000)
        let white = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// Gradient Declarations
        let blueGradientLeftToRight = CGGradient(colorsSpace: nil, colors: [blueGradientLeft.cgColor, blueGradientLeft.blended(withFraction: 0.5, of: blueGradientRight).cgColor, blueGradientRight.cgColor] as CFArray, locations: [0, 0.24, 1])!
        let whiteGradient = CGGradient(colorsSpace: nil, colors: [white.cgColor, UIColor.white.cgColor] as CFArray, locations: [0, 1])!

        //// Shadow Declarations
        let cellShadow = NSShadow()
        cellShadow.shadowColor = UIColor.black.withAlphaComponent(0.14)
        cellShadow.shadowOffset = CGSize(width: 0, height: 0)
        cellShadow.shadowBlurRadius = 2

        //// Variable Declarations
        let cellFill = shouldFill ? blueGradientLeftToRight : whiteGradient

        //// Rectangle Drawing
        let rectangleRect = CGRect(x: frame.minX + 0.5, y: frame.minY + 0.5, width: frame.width - 1, height: frame.height - 1)
        let rectanglePath = UIBezierPath(roundedRect: rectangleRect, cornerRadius: 4)
        context.saveGState()
        context.setShadow(offset: cellShadow.shadowOffset, blur: cellShadow.shadowBlurRadius, color: (cellShadow.shadowColor as! UIColor).cgColor)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        rectanglePath.addClip()
        context.drawLinearGradient(cellFill,
                                   start: CGPoint(x: rectangleRect.maxX, y: rectangleRect.midY),
                                   end: CGPoint(x: rectangleRect.minX, y: rectangleRect.midY),
                                   options: [])
        context.endTransparencyLayer()
        context.restoreGState()

        cellBorder.setStroke()
        rectanglePath.lineWidth = 1
        rectanglePath.lineJoinStyle = .round
        rectanglePath.stroke()
    }
}

private extension UIColor {
    func blended(withFraction fraction: CGFloat, of color: UIColor) -> UIColor {
        var r1: CGFloat = 1, g1: CGFloat = 1, b1: CGFloat = 1, a1: CGFloat = 1
        var r2: CGFloat = 1, g2: CGFloat = 1, b2: CGFloat = 1, a2: CGFloat = 1

        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(red: r1 * (1 - fraction) + r2 * fraction,
                       green: g1 * (1 - fraction) + g2 * fraction,
                       blue: b1 * (1 - fraction) + b2 * fraction,
                       alpha: a1 * (1 - fraction) + a2 * fraction)
    }
}
