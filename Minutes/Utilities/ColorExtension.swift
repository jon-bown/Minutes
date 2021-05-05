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
    
    
    static let moveRingWeekdayBackground = Color(red: 53 / 255, green: 17 / 255, blue: 22 / 255)
    static let moveRingBackground = Color(red: 33 / 255, green: 2 / 255, blue: 3 / 255)
    static let moveRingStartColor = Color(red: 210 / 255, green: 19 / 255, blue: 49 / 255)
    static let moveRingEndColor = Color(red: 255 / 255, green: 50 / 255, blue: 135 / 255)
    
    static let exerciseRingWeekdayBackground = Color(red: 31 / 255, green: 50 / 255, blue: 19 / 255)
    static let exerciseRingBackground = Color(red: 6 / 255, green: 34 / 255, blue: 1 / 255)
    static let exerciseRingStartColor = Color(red: 63 / 255, green: 212 / 255, blue: 0 / 255)
    static let exerciseRingEndColor = Color(red: 184 / 255, green: 255 / 255, blue: 0 / 255)
    
    static let standRingWeekdayBackground = Color(red: 22 / 255, green: 44 / 255, blue: 54 / 255)
    static let standRingBackground = Color(red: 1 / 255, green: 29 / 255, blue: 34 / 255)
    static let standRingStartColor = Color(red: 0 / 255, green: 186 / 255, blue: 225 / 255)
    static let standRingEndColor = Color(red: 0 / 255, green: 254 / 255, blue: 207 / 255)
    
    static let moveTextColor = Color(red: 241 / 255, green: 21 / 255, blue: 79 / 255)
    static let moveBarStartColor = Color(red: 210 / 255, green: 19 / 255, blue: 49 / 255)
    static let moveBarEndColor = Color(red: 255 / 255, green: 50 / 255, blue: 135 / 255)
    
    static let exerciseTextColor = Color(red: 165 / 255, green: 255 / 255, blue: 4 / 255)
    static let exerciseBarStartColor = Color(red: 55 / 255, green: 218 / 255, blue: 5 / 255)
    static let exerciseBarEndColor = Color(red: 181 / 255, green: 255 / 255, blue: 6 / 255)
    
    static let standTextColor = Color(red: 0 / 255, green: 255 / 255, blue: 245 / 255)
    static let standBarStartColor = Color(red: 0 / 255, green: 186 / 255, blue: 224 / 255)
    static let standBarEndColor = Color(red: 0 / 255, green: 250 / 255, blue: 208 / 255)

    static let chartLegendText = Color(red: 141 / 255, green: 141 / 255, blue: 149 / 255)
    
    static let activityValueText = Color(red: 170 / 255, green: 180 / 255, blue: 190 / 255)
    
    static let dividerBackground = Color(red: 46 / 255, green: 47 / 255, blue: 51 / 255)
    
}

