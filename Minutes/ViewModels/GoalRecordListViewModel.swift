//
//  GoalRecordListViewModel.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/6/21.
//

import Foundation
import CoreData
import SwiftUI

class GoalRecordListViewModel: ObservableObject, Equatable {
    static func == (lhs: GoalRecordListViewModel, rhs: GoalRecordListViewModel) -> Bool {
        return lhs.goalRecords == rhs.goalRecords
    }
    
    static let sharedInstance = GoalRecordListViewModel()
    
    @Published var goalRecords = [GoalRecordViewModel]()
    let cal = Calendar.current
    
    
    init() {
        let didSaveNotification = NSManagedObjectContext.didSaveObjectsNotification
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeRecords(_:)), name: didSaveNotification, object: nil)
        
        
        let didChangeNotification = NSManagedObjectContext.didChangeObjectsNotification
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeRecords(_:)), name: didChangeNotification, object: nil)
        
        self.getAllGoalRecords()
    }
    
    @objc func didChangeRecords(_ notification: Notification){
        DispatchQueue.main.async {
        self.getAllGoalRecords()
        }
    }
    
    
    func deleteGoalRecord(record: GoalRecordViewModel) {
        let record = CoreDataManager.shared.getGoalRecordByID(id: record.id)
        if let record = record {
            CoreDataManager.shared.deleteGoalRecord(goalRecord: record)
        }
        //self.getAllGoalRecords()
    }
    

    
    func deleteGoal(goal: GoalViewModel) {
        let goalObj = CoreDataManager.shared.getGoalByID(id: goal.id)
        if let goalToDelete = goalObj {
            DispatchQueue.main.async {
                CoreDataManager.shared.deleteGoal(goal: goalToDelete)
            }
        }
    }
    
    
    func deleteAllGoalRecords() {
        DispatchQueue.main.async {
            self.goalRecords.removeAll()
            CoreDataManager.shared.deleteAllGoalRecords()
        }
    }
    
    func getAllGoalRecords() {
        
        DispatchQueue.main.async {
            let goalRecords = CoreDataManager.shared.getAllGoalRecords()
            self.goalRecords.removeAll()
            if(!goalRecords.isEmpty){
                self.goalRecords = goalRecords.map(GoalRecordViewModel.init)
            }
            
        }
    }
    
    func filterGoalRecordsByGoal(goal: GoalViewModel) -> [GoalRecordViewModel]{
        //self.getAllGoalRecords()
        return goalRecords.filter({goal == $0.goal})
    }
    
    func getRecordTodayForGoal(goal: GoalViewModel) -> GoalRecordViewModel? {
        //self.getAllGoalRecords()
        if(!goalRecords.isEmpty){
            return goalRecords.first(where:({cal.isDate(Date(), inSameDayAs: $0.date) && $0.goal.id == goal.id}))
        }
        else{
            return nil
        }

    }
    
    func filterGoalRecordsByDate(date: Date) -> [GoalRecordViewModel] {
        //self.getAllGoalRecords()
        if(!goalRecords.isEmpty){
            return goalRecords.filter({cal.isDate(date, inSameDayAs: $0.date)})
        }
        else{
            return []
        }
        
    }
    
    func filterGoalRecords() -> [GoalRecordViewModel] {
        //self.getAllGoalRecords()
        return self.filterGoalRecordsByDate(date: Date())
    }

    func filterGoalRecordSavesTodayForGoal(goal: GoalViewModel) -> [Date: Double] {
        //self.getAllGoalRecords()
        if(self.getRecordTodayForGoal(goal: goal) == nil){
            return [:]
        }
        else {
            return self.getRecordTodayForGoal(goal: goal)!.goalSaves!
        }
        
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
    
    func calculateTimeThisWeekForGoal(goalID: UUID) -> String {
        let goalRecords = CoreDataManager.shared.getAllGoalRecords()
        let goalRecordsThisWeek = goalRecords.filter({
            $0.date.isInSameWeek(as: Date())
                && $0.goal.id == goalID})
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
    
    func getDayTimeForGoal(goal: GoalViewModel) -> Int {
        if let record = self.getRecordTodayForGoal(goal: goal) {
            return Int(record.dayTime/60)
        }
        else {
            return 0
        }
        
        
        
    }
    
    func removeTimeFromGoalRecord(id: NSManagedObjectID, datesToRemove: [Date]){
        CoreDataManager.shared.removeTimeFromGoalRecord(id: id, datesToRemove: datesToRemove)
    }
}

struct GoalRecordViewModel: Identifiable, Equatable {
    
    let record: GoalRecord
    
    var id: NSManagedObjectID {
        return record.objectID
    }
    
    var name: String {
        return record.goal.name
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
    
    var goal: GoalViewModel {
        return GoalViewModel(goal: record.goal)
    }

}
