// Septa. 2017

import UIKit

public class SeptaDraw: NSObject {

    //// Drawing Methods

    @objc public dynamic class func drawTranssitModeToolbar(frame: CGRect = CGRect(x: 36, y: 36, width: 148, height: 30), transitMode: String = "Trolley", highlighted: Bool = true) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        //// Color Declarations
        let highlightedTextColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let disabledTextColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.000)
        let toolbarBackground = UIColor(red: 0.600, green: 0.600, blue: 0.600, alpha: 1.000)
        let highlightBar = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let transparent = highlightBar.withAlphaComponent(0)

        //// Variable Declarations
        let textColor = highlighted ? highlightedTextColor : disabledTextColor
        let highlightBarColor = highlighted ? highlightBar : transparent

        //// BackgroundView Drawing
        let backgroundViewPath = UIBezierPath(rect: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height))
        toolbarBackground.setFill()
        backgroundViewPath.fill()

        //// HighlightRect Drawing
        let highlightRectPath = UIBezierPath(rect: CGRect(x: frame.minX, y: frame.minY + frame.height - 2, width: frame.width, height: 2))
        highlightBarColor.setFill()
        highlightRectPath.fill()

        //// Text Drawing
        let textRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height - 2)
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let textFontAttributes = [
            .font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
            .foregroundColor: textColor,
            .paragraphStyle: textStyle,
        ] as [NSAttributedStringKey: Any]

        let textTextHeight: CGFloat = transitMode.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: textRect)
        transitMode.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        context.restoreGState()
    }
}
