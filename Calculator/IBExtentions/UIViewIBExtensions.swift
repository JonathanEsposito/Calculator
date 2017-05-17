//
//  UIViewIBExtentions.swift
//  CalculatorPartTwo
//
//  Created by .jsber on 14/01/17.
//  Copyright © 2017 jo.on. All rights reserved.
//

import UIKit

@IBDesignable extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}

//extension CALayer {
//    var borderUIColor: UIColor {
//        set {
//            self.borderColor = newValue.cgColor
//        }
//        
//        get {
//            return UIColor(cgColor: self.borderColor!)
//        }
//    }
//}
