//
//  UIButtonIBExtentions.swift
//  CalculatorPartTwo
//
//  Created by .jsber on 14/01/17.
//  Copyright © 2017 jo.on. All rights reserved.
//

import UIKit

@IBDesignable extension UIButton {
    @IBInspectable var highlightedBackgroundColor:UIColor? {
        set {
            setBackgroundColor(newValue!, for: .highlighted)
        }
        get {
            if let backgroundColor = self.backgroundImage(for: .highlighted) {
                return backgroundColor.getPixelColor(pos: CGPoint(x: 1, y: 1))
            } else {
                return nil
            }
        }
    }
    
    @IBInspectable var adjustFontSize: Bool {
        get {
            return titleLabel?.numberOfLines == 1 && titleLabel?.adjustsFontSizeToFitWidth == true && titleLabel?.lineBreakMode == .byClipping
        }
        set {
            if newValue {
                titleLabel?.numberOfLines = 1
                titleLabel?.adjustsFontSizeToFitWidth = true
                titleLabel?.lineBreakMode = .byClipping //<-- MAGIC LINE
                contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
            } else {
                titleLabel?.numberOfLines = 1
                titleLabel?.adjustsFontSizeToFitWidth = false
                titleLabel?.lineBreakMode = .byTruncatingTail
                contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
//    @IBInspectable var alignTextLeft: Bool {
//        get {
//            return self.contentHorizontalAlignment == .left
////            return self.titleLabel?.textAlignment == .left
//        }
//        set {
//            if newValue {
//                self.contentHorizontalAlignment = .left
//                contentEdgeInsets = UIEdgeInsets(top: 7, left: 23, bottom: 7, right: 7)
////            self.titleLabel?.textAlignment = .left
//            } else {
//                self.contentHorizontalAlignment = .center
//                contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            }
//        }
//    }
}

extension UIButton {
    private func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color), for: state)
    }
    
    func setThickBorder() {
        self.layer.borderWidth = 1.5
    }
    
    func setDefaultBorder() {
        self.layer.borderWidth = 0.5
    }
}
