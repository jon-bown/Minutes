//
//  Extensions.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import CoreData
import UIKit
import SwiftUI

/*
 Contains all necessary extensions for Minutes App
 */

@objc(UIColorValueTransformer)
final class UIColorValueTransformer: NSSecureUnarchiveFromDataTransformer {

    static let name = NSValueTransformerName(rawValue: String(describing: UIColorValueTransformer.self))

    override static var allowedTopLevelClasses: [AnyClass] {
        return [UIColor.self]
    }

    public static func register() {
        let transformer = UIColorValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

extension TimeZone {
    static let gmt = TimeZone(secondsFromGMT: 0)!
}
extension Formatter {
    static let date = DateFormatter()
}

extension Date {
    func localizedDescription(dateStyle: DateFormatter.Style = .medium,
                              timeStyle: DateFormatter.Style = .medium,
                           in timeZone : TimeZone = .current,
                              locale   : Locale = .current) -> String {
        Formatter.date.locale = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.dateStyle = dateStyle
        Formatter.date.timeStyle = timeStyle
        return Formatter.date.string(from: self)
    }
    var localizedDescription: String { localizedDescription() }
    
    
    var fullDate: String   { localizedDescription(dateStyle: .full,   timeStyle: .none) }
    var longDate: String   { localizedDescription(dateStyle: .long,   timeStyle: .none) }
    var mediumDate: String { localizedDescription(dateStyle: .medium, timeStyle: .none) }
    var shortDate: String  { localizedDescription(dateStyle: .short,  timeStyle: .none) }

    var fullTime: String   { localizedDescription(dateStyle: .none,   timeStyle: .full) }
    var longTime: String   { localizedDescription(dateStyle: .none,   timeStyle: .long) }
    var mediumTime: String { localizedDescription(dateStyle: .none,   timeStyle: .medium) }
    var shortTime: String  { localizedDescription(dateStyle: .none,   timeStyle: .short) }

    var fullDateTime: String   { localizedDescription(dateStyle: .full,   timeStyle: .full) }
    var longDateTime: String   { localizedDescription(dateStyle: .long,   timeStyle: .long) }
    var mediumDateTime: String { localizedDescription(dateStyle: .medium, timeStyle: .medium) }
    var shortDateTime: String  { localizedDescription(dateStyle: .short,  timeStyle: .short) }
    
    
    var dayOfTheWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let dayOfTheWeekString = dateFormatter.string(from: self)
        return dayOfTheWeekString
    }
    
    var dayOfTheMonth: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self)
        let dayOfMonth = components.day
        return dayOfMonth!
    }
    
    
    var minuteQuadrant: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: self)
        let minute = components.minute!
        var quadrant = 0
        if(minute == 0){
            quadrant = 0
        }
        else if(minute > 0 && minute < 15) {
            quadrant = 1
        }
        else if(minute >= 15 && minute < 30){
            quadrant = 2
        }
        else if(minute >= 30 && minute < 45){
            quadrant = 3
        }
        else {
            quadrant = 4
        }
        return quadrant
    }
    
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
          calendar.isDate(self, equalTo: date, toGranularity: component)
      }
    
    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
        func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
        func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

        func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

        var isInThisYear:  Bool { isInSameYear(as: Date()) }
        var isInThisMonth: Bool { isInSameMonth(as: Date()) }
        var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

        var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
        var isInToday:     Bool { Calendar.current.isDateInToday(self) }
        var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

        var isInTheFuture: Bool { self > Date() }
        var isInThePast:   Bool { self < Date() }
    
    
    
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }
}


extension UIColor {
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}


extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        return dates
    }
}

extension TimeInterval{

        func stringFromTimeInterval() -> String {

            let time = NSInteger(self)

            let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
            let seconds = time % 60
            let minutes = (time / 60) % 60
            let hours = (time / 3600)

            return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds,ms)
            
            //return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)

        }
    
    
    func seconds() -> Float {
        let time = NSInteger(self)

        let seconds = time
        
        return Float(seconds)
    }
    
    
    func minutes() -> Float {
        let time = NSInteger(self)

        let minutes = (time / 60) % 60
        
        return Float(minutes)
    }
    
    
    }




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
    
    public static var lightBlack: Color {
        return Color.black.lighter(by: 10)
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



public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
