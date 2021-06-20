//
//  GoalRecordListViewModel.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/6/21.
//

import Foundation
import CoreData
import SwiftUI

class GoalRecordListViewModel: ObservableObject {
    
    @Published var goalRecords = [GoalRecordViewModel]()
    let cal = Calendar.current
    
    func deleteGoalRecord(record: GoalRecordViewModel) {
        let record = CoreDataManager.shared.getGoalRecordByID(id: record.id)
        if let record = record {
            CoreDataManager.shared.deleteGoalRecord(goalRecord: record)
        }
    }
    
    func getAllGoalRecords() {
        let goalRecords = CoreDataManager.shared.getAllGoalRecords()
        DispatchQueue.main.async {
            self.goalRecords = goalRecords.map(GoalRecordViewModel.init)
        }
    }
    
    func filterGoalRecordsByGoal(goal: Goal) -> [GoalRecordViewModel]{
        return goalRecords.filter({goal == $0.goal!})
    }
    
    func getRecordTodayForGoal(goal: GoalViewModel) -> GoalRecordViewModel? {
        return goalRecords.first(where:({cal.isDate(Date(), inSameDayAs: $0.date)}))
    }
    
    func filterGoalRecordsByDate(date: Date) -> [GoalRecordViewModel] {
        return goalRecords.filter({cal.isDate(Date(), inSameDayAs: $0.date)})
    }
    
    func filterGoalRecords() -> [GoalRecordViewModel] {
        return self.filterGoalRecordsByDate(date: Date())
    }
    
    static func getGoalColorFromRecord(goalRecord: GoalRecordViewModel) -> UIColor? {
        return goalRecord.goal?.color
    }
    
    func filterGoalRecordSavesToday() -> [Date: Double]? {
        return goalRecords.first(where: {cal.isDate(Date(), inSameDayAs: $0.date)})?.goalSaves
    }
    
    func sortGoalRecordsByPriority() -> [GoalRecordViewModel] {
        let goalRecords = CoreDataManager.shared.getAllGoalRecords()
        if(!goalRecords.isEmpty){
            let sorted = goalRecords.sorted(by: {$0.goal.priority < $1.goal.priority})
                return sorted.map(GoalRecordViewModel.init)
            
        }
        else{
            return []
        }
    }
    
    func calculateTimeThisWeek() -> String {
        let goalRecords = CoreDataManager.shared.getAllGoalRecords()
        let goalRecordsThisWeek = goalRecords.filter({
            $0.date.isInSameWeek(as: Date())
        })
        var totalTime: Double = 0.0
        for goalRecord in goalRecordsThisWeek {
            totalTime+=goalRecord.dayTime
        }
        
        //Convert it to string
        return AppUtil.getTotalTimeString(seconds: totalTime)
    }
    
    
    func calculateCurrentStreak(goalID: NSManagedObjectID) -> Int {
        let recordsByName = self.goalRecords.filter({$0.id == goalID})
        
        if(recordsByName.count == 0){
            //User can't have best streak if there are no records available
            UserDefaults.standard.set(0, forKey: "Best\(goalID)")
            
            return 0
            
        }
        else {
            var count = 0
            //most recent goal record where progress of greater than 1 was achieved
            guard let first = recordsByName.sorted(by: {$0.date > $1.date}).first(where: {$0.progress >= 1}) else {
                //no streaks possible
                UserDefaults.standard.set(count, forKey: "Best\(goalID)")
                return count
            }
            if(Calendar.current.isDate(Date(), inSameDayAs:first.date)){
                //The users first goal completion was today for this particular goal
                let bestStreak = UserDefaults.standard.integer(forKey: "Best\(goalID)")
                count+=1
                if(count > bestStreak){
                    UserDefaults.standard.set(count, forKey: "Best\(goalID)")
                }
                //print("current count: \(count) current best: \(bestStreak)")
                return count
            }
            else if(Calendar.current.isDateInYesterday(first.date)){
                let completedGoals = recordsByName.sorted(by: {$0.date > $1.date}).filter({$0.progress >= 1})
                var tempDate = first.date
                for record in completedGoals {
                    let dayDiff = Calendar.current.numberOfDaysBetween(record.date, and: tempDate)
                    if(dayDiff <= 1){
                        count+=1
                    }
                    else {
                        let bestStreak = UserDefaults.standard.integer(forKey: "Best\(goalID)")
                        if(count > bestStreak){
                            UserDefaults.standard.set(count, forKey: "Best\(goalID)")
                        }
                        return count
                    }
                    tempDate = record.date
                }
                let bestStreak = UserDefaults.standard.integer(forKey: "Best\(goalID)")
                if(count > bestStreak){
                    UserDefaults.standard.set(count, forKey: "Best\(goalID)")
                }
                return count
            }
            else {
                //user is not on a streak
                return 0
            }
            
        }
    }
    
    func calculateBestStreak(goalID: NSManagedObjectID) -> Int {
        let best = UserDefaults.standard.integer(forKey: "Best\(goalID)")
        return best
    }
    
    
    func updateGoalRecord(goalRecordID: NSManagedObjectID, seconds: Double) {
        CoreDataManager.shared.updateGoalRecord(id: goalRecordID, secondsToAdd: seconds)
        self.getAllGoalRecords()
    }
    
    func addNewGoalRecord(name: String, date: Date, progress: Double, seconds: Double, id: NSManagedObjectID) {
        CoreDataManager.shared.addGoalRecord(name: name, date: date, progress: progress, seconds: seconds, parentGoalID: id)
        self.getAllGoalRecords()
    }
    
    func removeTimeFromGoalRecord(id: NSManagedObjectID, datesToRemove: [Date]){
        CoreDataManager.shared.removeTimeFromGoalRecord(id: id, datesToRemove: datesToRemove)
        self.getAllGoalRecords()
    }
}

struct GoalRecordViewModel: Identifiable {
    
    let record: GoalRecord
    
    var id: NSManagedObjectID {
        return record.objectID
    }
    
    var name: String {
        return record.goal.name ?? ""
    }
    
    var date: Date {
        return record.date
    }
    
    var dayTime: Double {
        return record.dayTime
    }
    
    var goalUpdates: [Int:Double]? {
        return record.goalUpdates
    }
    
    var progress: Double {
        return record.progress
    }
    
    var goalSaves: [Date:Double]? {
        return record.goalSaves
    }
    
    var goal: Goal? {
        return record.goal
    }

}
