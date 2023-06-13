//
//  UIView+Extension.swift
//  Timesy
//
//  Created by Tommy De Andrade on 12/19/22.
//

import Foundation
import UIKit

extension UIView{
   @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.cornerRadius
        } set {
            self.layer.cornerRadius = newValue
        }
    }
}
