//
//  MinutesUtils.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/13/23.
//

import UIKit

class MinutesUtils: NSObject {
    
    static func filterCurrentGoals(goals: [GoalViewModel], date: Date) -> [GoalViewModel] {
        if(goals.isEmpty){
            return []
        }
        let cal = Calendar.current
        return goals.filter({(date > $0.startDate || cal.isDate(date, inSameDayAs:$0.startDate)) && ($0.endDate == nil || date <= $0.endDate!) && (($0.frequency == "Weekly" && $0.weekDay!.contains(date.dayOfTheWeek)) || ($0.frequency == "Monthly" && $0.monthDay == date.dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
    }
    
    static func filterGoalRecordsByDate(records: [GoalRecordViewModel], date: Date) -> [GoalRecordViewModel] {
        let cal = Calendar.current
        if(!records.isEmpty){
            return records.filter({cal.isDate(date, inSameDayAs: $0.date)})
        }
        else{
            return []
        }
    }

}
