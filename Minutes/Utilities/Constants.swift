//
//  Constants.swift
//  ActivityAppReplicating
//
//  Created by Dmitry Shipinev on 06.11.2019.
//  Copyright © 2019 Exyte. All rights reserved.
//
import CoreGraphics
import SwiftUI

struct Constants {
    
    static let navigationBarHeight: CGFloat = 65
    static let mainRingThickness: CGFloat = 30
    static let weekdayRingThickness: CGFloat = 4
    static let barChartColumns: Int = 96
    //static let barChartColumns: Int = 24
    static let barChartColumnWidth: CGFloat = 2.6
    //static let barChartColumnWidth: CGFloat = 10.4
    static let barChartColumnSpacing: CGFloat = 1
    //static let barChartColumnSpacing: CGFloat = 4
    static let standChartColumns: Int = 24
    static let standChartColumnWidth: CGFloat = 13.8
    static let standChartColumnSpacing: CGFloat = 1
    static let standChartGridColumnSpacing: CGFloat = 2.5
    
    static let miniBarChartColumns: Int = 96
    static let miniBarChartColumnWidth: CGFloat = 2.6
    static let miniBarChartColumnSpacing: CGFloat = 1
    
    
    
    //MARK: Progress Ring Sizes
    //Standard
    static let progressRingViewFrameHeightStandard: CGFloat = 150
    static let progressRingViewFrameWidthStandard: CGFloat = 150
    static let progressRingViewThicknessStandard: CGFloat = 15
    static let progressRingViewMaxRingLimitStandard: Int = 3
    
    static let progressRingViewCalendarMaxWidth: CGFloat = 15
    
    static let globalCornerRadius: CGFloat = 10
    
    //MARK: FONTS
    
    static let globalBodyTextFont: Font = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    
    static let stopWatchTimerFontSize: CGFloat = 44
    
    
    //MARK: COLORS
    
    static let checkMarkColor: Color = Color.green
    
    //MARK: USER DEFAULTS
    
    static let generalCompletionReminder: String = "CompletionReminder"
    
}
