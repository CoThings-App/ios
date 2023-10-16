//
//  UIKit+Mix.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/06.
//  Copyright © 2020 CoThings. All rights reserved.
//

import UIKit

extension UIColor {
    func mixLighter (amount: CGFloat = 0.25) -> UIColor {
        return mixWithColor(UIColor.white, amount:amount)
    }
    
    func mixDarker (amount: CGFloat = 0.25) -> UIColor {
        return mixWithColor(UIColor.black, amount:amount)
    }
    
    func mixWithColor(_ color: UIColor, amount: CGFloat = 0.25) -> UIColor {
        var r1     : CGFloat = 0
        var g1     : CGFloat = 0
        var b1     : CGFloat = 0
        var alpha1 : CGFloat = 0
        var r2     : CGFloat = 0
        var g2     : CGFloat = 0
        var b2     : CGFloat = 0
        var alpha2 : CGFloat = 0
        
        self.getRed (&r1, green: &g1, blue: &b1, alpha: &alpha1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &alpha2)
        return UIColor( red:r1*(1.0-amount)+r2*amount,
                        green:g1*(1.0-amount)+g2*amount,
                        blue:b1*(1.0-amount)+b2*amount,
                        alpha: alpha1 )
    }
}
