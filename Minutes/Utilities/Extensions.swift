//
//  Extensions.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import CoreData
import UIKit
import SwiftUI



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

