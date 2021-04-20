//
//  AppUtils.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/8/21.
//

import Foundation
import CoreData
import UserNotifications


class AppUtil {
    static func calculateMinuteQuadrant() {
        
    }
    
    //MARK: - FILTERING
    static func filterCurrentGoals(goals: [Goal], date: Date) -> [Goal] {
        if(goals.isEmpty){
            return []
        }
        let cal = Calendar.current
        return goals.filter({(date > $0.startDate! || cal.isDate(date, inSameDayAs:$0.startDate!)) && ($0.endDate == nil || date <= $0.endDate!) && (($0.frequency == "Weekly" && $0.weekDay!.contains(date.dayOfTheWeek)) || ($0.frequency == "Monthly" && $0.monthDay == date.dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
    }
    
    static func filterGoalRecordsByGoal(goalRecords: [GoalRecord], goalName: String) -> [GoalRecord]{
        if(goalRecords.isEmpty){
            return []
        }
        return goalRecords.filter({goalName == $0.name})
    }
    
    static func filterGoalRecordsTodayByName(goalRecords: [GoalRecord], goalName: String) -> [GoalRecord] {
        if(goalRecords.isEmpty){
            return []
        }
        return goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!) && goalName == $0.name})
    }
    
    static func filterGoalRecordsToday(goalRecords: [GoalRecord], goalName: String) -> [GoalRecord] {
        if(goalRecords.isEmpty){
            return []
        }
            return goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!)})
        
    }
    
    static func filterGoalRecordsByDate(goalRecords: [GoalRecord], date: Date) -> [GoalRecord] {
        if(goalRecords.isEmpty){
            return []
        }
            return goalRecords.filter({Calendar.current.isDate(date, inSameDayAs:$0.date!)})

    }
    
    static func filterGoalRecordSavesTodayByName(goalRecords: [GoalRecord], goalName: String) -> [Date: Double] {
        if(goalRecords.isEmpty){
            return [:]
        }
        else if(goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!) && goalName == $0.name}).isEmpty){
            return [:]
        }
        else {
            
            let firstItem = (goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!) && goalName == $0.name}).first!)
            if(!(firstItem.goalSaves == nil)){
                //it has goal saves
                return firstItem.goalSaves!
            }
            else {
                return [:]
            }
            
            
        }
        
    }
    
    //MARK: DATES & TIMES
    static func getCurrentDate(with format: String = "EEEE, MMM d") -> String { let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
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
            $0.date!.isInSameWeek(as: Date())
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
        let sec = seconds.truncatingRemainder(dividingBy: 3600)
        let remSec = Int(sec.truncatingRemainder(dividingBy: 60))
        if(String(remSec).count == 1){
            return "0\(remSec)"
        }
        else {
            return "\(remSec)"
        }
        
    }
    
    //MARK: STREAKS
    
    //Calculates current streak of the user for the goal with name 'goalName'
    static func calculateGoalCurrentStreak(records: [GoalRecord], goalName: String) -> Int {
        
        let recordsByName = records.filter({$0.name == goalName})
        
        if(recordsByName.count == 0){
            //User can't have best streak if there are no records available
            UserDefaults.standard.set(0, forKey: "Best\(goalName)")
            
            return 0
            
        }
        else {
            var count = 0
            //most recent goal record where progress of greater than 1 was achieved
            guard let first = recordsByName.sorted(by: {$0.date! > $1.date!}).first(where: {$0.progress >= 1}) else {
                //no streaks possible
                UserDefaults.standard.set(count, forKey: "Best\(goalName)")
                return count
            }
            if(Calendar.current.isDate(Date(), inSameDayAs:first.date!)){
                //The users first goal completion was today for this particular goal
                let bestStreak = UserDefaults.standard.integer(forKey: "Best\(goalName)")
                count+=1
                if(count > bestStreak){
                    UserDefaults.standard.set(count, forKey: "Best\(goalName)")
                }
                //print("current count: \(count) current best: \(bestStreak)")
                return count
            }
            else if(Calendar.current.isDateInYesterday(first.date!)){
                let completedGoals = recordsByName.sorted(by: {$0.date! > $1.date!}).filter({$0.progress >= 1})
                var tempDate = first.date!
                for record in completedGoals {
                    let dayDiff = Calendar.current.numberOfDaysBetween(record.date!, and: tempDate)
                    if(dayDiff <= 1){
                        count+=1
                    }
                    else {
                        let bestStreak = UserDefaults.standard.integer(forKey: "Best\(goalName)")
                        if(count > bestStreak){
                            UserDefaults.standard.set(count, forKey: "Best\(goalName)")
                        }
                        print("current count: \(count) current best: \(bestStreak)")
                        return count
                    }
                    tempDate = record.date!
                }
                let bestStreak = UserDefaults.standard.integer(forKey: "Best\(goalName)")
                if(count > bestStreak){
                    UserDefaults.standard.set(count, forKey: "Best\(goalName)")
                }
                //print("current count: \(count) current best: \(bestStreak)")
                return count
            }
            else {
                //you are not on a streak
                return 0
            }
            
        }
        
        
    }
    
    static func calculateGoalBestStreak(goalName: String) -> Int {
        let best = UserDefaults.standard.integer(forKey: "Best\(goalName)")
        return best
    }
    
    //NOTIFICATIONS
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
