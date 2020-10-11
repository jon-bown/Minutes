//
//  ColorExtension.swift
//  Minutes
//
//  Created by Jonathan Bown on 9/16/20.
//

import Foundation
import SwiftUI


extension Color {

    public static var outlineRed: Color {
        return Color(decimalRed: 34, green: 0, blue: 3)
    }
    
    public static var darkRed: Color {
        return Color(decimalRed: 221, green: 31, blue: 59)
    }
    
    public static var lightRed: Color {
        return Color(decimalRed: 239, green: 54, blue: 128)
    }
    
    public init(decimalRed red: Double, green: Double, blue: Double) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255)
    }
    
    public static var outlineGreen: Color {
        return Color(decimalRed: 0, green: 34, blue: 3)
    }
    
    public static var darkGreen: Color {
        return Color(decimalRed: 20, green: 221, blue: 59)
    }
    
    public static var lightGreen: Color {
        return Color(decimalRed: 54, green: 239, blue: 128)
    }
    
    
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> Color {
        let red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
            return Color(red: Double(min(red + percentage/100, 1.0)),
                           green: Double(min(green + percentage/100, 1.0)),
                           blue: Double(min(blue + percentage/100, 1.0)))
    }
    
}
