//
//  UIColorExtension.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/18.
//

import UIKit

extension UIColor {
    static var rand : UIColor {
        let r = CGFloat.random(in: 0 ... 255) / 255.0
        let g = CGFloat.random(in: 0 ... 255) / 255.0
        let b = CGFloat.random(in: 0 ... 255) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
