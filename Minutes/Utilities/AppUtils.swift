//
//  AppUtils.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/8/21.
//

import Foundation
import CoreData
import UserNotifications
import UIKit

//Contains functions that are used throughout the app to prevent repretition and to consolidate filtering logic for lists of goals and goal records
class AppUtil {

    //MARK: - FILTERING
//    static func filterCurrentGoals(goals: [Goal], date: Date) -> [Goal] {
//        if(goals.isEmpty){
//            return []
//        }
//        let cal = Calendar.current
//        return goals.filter({(date > $0.startDate! || cal.isDate(date, inSameDayAs:$0.startDate!)) && ($0.endDate == nil || date <= $0.endDate!) && (($0.frequency == "Weekly" && $0.weekDay!.contains(date.dayOfTheWeek)) || ($0.frequency == "Monthly" && $0.monthDay == date.dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
//    }
//
//    static func filterGoalRecordsByGoalID(goalRecords: [GoalRecord], goalID: UUID?) -> [GoalRecord]{
//        if(goalRecords.isEmpty || goalID == nil){
//            return []
//        }
//        return goalRecords.filter({goalID! == $0.id!})
//    }
//
//
//    static func getRecordTodayForGoal(goalRecords: [GoalRecord], goalID: UUID?) -> GoalRecord? {
//        if let ID = goalID {
//            if(goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs: $0.date) && ID == $0.id}).isEmpty){
//                return nil
//            }
//            return goalRecords.first(where: {Calendar.current.isDate(Date(), inSameDayAs: $0.date!) && ID == $0.id})!
//        }
//        else{
//            return nil
//        }
//
//
//    }
    
//    static func filterGoalRecordsTodayForGoal(goalRecords: [GoalRecord], goalID: UUID?) -> [GoalRecord] {
//        if(goalRecords.isEmpty || goalID == nil){
//            return []
//        }
//        return goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs: $0.date!) && goalID! == $0.id})
//
//    }
    
//    static func filterGoalRecordsByDate(goalRecords: [GoalRecord], date: Date) -> [GoalRecord] {
//        if(goalRecords.isEmpty){
//            return []
//        }
//        return goalRecords.filter({Calendar.current.isDate(date, inSameDayAs:$0.date!)})
//
//    }
    
//    static func filterGoalRecordSavesTodayByID(goalRecords: [GoalRecord], goalID: UUID?) -> [Date: Double] {
//        if(goalRecords.isEmpty || goalID == nil){
//            return [:]
//        }
//        else if(goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!) && goalID == $0.id}).isEmpty){
//            return [:]
//        }
//        else {
//            
//            let firstItem = (goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!) && goalID == $0.id}).first!)
//            if(!(firstItem.goalSaves == nil)){
//                //it has goal saves
//                return firstItem.goalSaves!
//            }
//            else {
//                return [:]
//            }
//            
//            
//        }
//        
//    }
    
//    static func getGoalColorFromRecord(goals: [Goal], id: UUID) -> UIColor{
//        guard let goalColor = goals.first(where: {$0.id == id})?.color else {
//            return UIColor.blue
//        }
//        return  goalColor
//    }
    
    
    
//    static func sortGoalRecordsByPriority(goalRecords: [GoalRecord], goals: [Goal]) -> [GoalRecord]{
//        return goalRecords.sorted(by: {getGoalPriorityFromRecord(goals: goals, id: $0.id!) < getGoalPriorityFromRecord(goals: goals, id: $1.id!)})
//    }
    

    //MARK: DATES & TIMES
    static func getCurrentDate(with format: String = "EEEE, MMM d") -> String { let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
    }
    
    static func getSimplifiedDate() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        return calendar.date(from: components) ?? Date()
    }
    
    static func createWeekDaysString(days: [String]) -> String {
        var finalString = ""
        for goalDay in days {
            finalString += "\(goalDay), "
        }
        finalString = String(finalString.dropLast().dropLast())
        return finalString
    }
    
    static func calculateTimeThisWeek(goalRecords: [GoalRecord]) -> String {
        let goalRecordsThisWeek = goalRecords.filter({
            $0.date.isInSameWeek(as: Date())
        })
        var totalTime: Double = 0.0
        for goalRecord in goalRecordsThisWeek {
            totalTime+=goalRecord.dayTime
        }
        
        //Convert it to string
        return getTotalTimeString(seconds: totalTime)
    }
    
    static func getTotalTimeString(seconds: Double) -> String {
        return  "\(getHoursFromSeconds(seconds: seconds)):\(getMinutesFromSeconds(seconds: seconds)):\(getSecondsFromSeconds(seconds: seconds))"
    }
    
    
    static func getHoursFromSeconds(seconds: Double) -> String {
        let hours = Int(seconds/3600)
        if(String(hours).count == 1){
            return "0\(hours)"
        }
        else {
            return "\(hours)"
        }
    }
    
    static func getMinutesFromSeconds(seconds: Double) -> String {
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600))/60)
        if(String(minutes).count == 1){
            return "0\(minutes)"
        }
        else {
            return "\(minutes)"
        }
    }
    
    static func getSecondsFromSeconds(seconds: Double) -> String {
        let remSec = Int(abs(seconds).truncatingRemainder(dividingBy: 60))
        if(String(remSec).count == 1){
            return "0\(remSec)"
        }
        else {
            return "\(remSec)"
        }
    }

    
    //MARK: - NOTIFICATIONS
    static func getNotificationTime(id: UUID) -> String {
        var finalString = ""
        //Check if any notifications exist, if they do set reminders to true
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
            for notification:UNNotificationRequest in notificationRequests {
                if notification.identifier == id.uuidString {
                    if let calendarNotificationTrigger = notification.trigger as? UNCalendarNotificationTrigger,
                       let nextTriggerDate = calendarNotificationTrigger.nextTriggerDate()  {
                        //get date components
                        let components = Calendar.current.dateComponents([.hour, .minute], from: nextTriggerDate)
                        let hour = components.hour
                        let minute = components.minute
                        finalString = "\(String(describing: hour)):\(String(describing: minute))"
                    }
                    
                    return
                }
            }
        }
        return finalString
    }
    
    
    
    static func getPendingRequests(id: UUID, completion:@escaping (Int?, Int?)->Void){
        
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        
        queue.async(group: group) {
            group.enter()
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                for notification:UNNotificationRequest in notificationRequests {
                    if notification.identifier == id.uuidString {
                        guard let trigger = notification.trigger as? UNCalendarNotificationTrigger else {
                            //completion(nil, nil)
                            return
                        }
                        let nextTriggerDate = trigger.nextTriggerDate()!
                        //get date components
                        let components = Calendar.current.dateComponents([.hour, .minute], from: nextTriggerDate)
                        if let hour = components.hour {
                            if let minute = components.minute {
                                completion(hour, minute)
                                break
                            }
                        }
                        
                    }
                }
                //completion(nil, nil)
            }
            group.leave()
        }
        
        
    }
    
    static func removePendingRequests(id: UUID, completion:@escaping (Bool)->Void){
        
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        
        queue.async(group: group) {
            group.enter()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                var identifiers: [String] = []
                for notification:UNNotificationRequest in notificationRequests {
                    if notification.identifier == id.uuidString {
                        identifiers.append(notification.identifier)
                    }
                }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                completion(true)
            }
            group.leave()
        }
        
        
    }
    
    static func isNotificationsEnabled(completion:@escaping (UNAuthorizationStatus)->Void){
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { permission in
            //permissionResult = permission.authorizationStatus
            completion(permission.authorizationStatus)
            
        })
    }
    
    //MARK: DEVICE TYPE
    
//    static let isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad
//    static let isIphone: Bool = UIDevice.current.userInterfaceIdiom == .phone
//    

    
    
    //MARK: ID Strings
    
    static func getGoalNotificationSpecificIdString(id: UUID) -> String{
        return String(id.uuidString + "C")
    }
    
}


public enum AppGroup: String {
    case facts = "group.com.appfactorial.tempus.anulum"
    
    public var containerURL: URL {
        switch self {
        case .facts:
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: self.rawValue)!
        }
    }
    
}
