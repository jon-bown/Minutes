//
//  GoalListViewModel.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/5/21.
//

import Foundation
import CoreData
import SwiftUI

class GoalListViewModel: ObservableObject, Equatable {
    
    static func == (lhs: GoalListViewModel, rhs: GoalListViewModel) -> Bool {
        return lhs.goals == rhs.goals
    }
    
    
    @Published var goals = [GoalViewModel]()
    let cal = Calendar.current
    
    
    init() {
        let didSaveNotification = NSManagedObjectContext.didSaveObjectsNotification
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSave(_:)), name: didSaveNotification, object: nil)
        
        
        let didChangeNotification = NSManagedObjectContext.didChangeObjectsNotification
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSave(_:)), name: didChangeNotification, object: nil)
        
        self.getAllGoals()
    }
    
    @objc func didSave(_ notification: Notification){
        self.getAllGoals()
    }
    
    func deleteGoal(goal: GoalViewModel) {
        let goal = CoreDataManager.shared.getGoalByID(id: goal.id)
        if let goal = goal {
            CoreDataManager.shared.deleteGoal(goal: goal)
        }
    }
    
    func getAllGoals() {
        
        DispatchQueue.main.async {
            let goals = CoreDataManager.shared.getAllGoals()
            if(!goals.isEmpty){
                self.goals = goals.map(GoalViewModel.init)
            }
            
        }
    }
    
    //MARK: FILTERING
    
    func filterCurrentGoalsByDate(date: Date) -> [GoalViewModel] {
        //self.getAllGoals()
        return goals.filter({(date > $0.startDate || cal.isDate(date, inSameDayAs:$0.startDate)) && ($0.endDate == nil || date <= $0.endDate!) && (($0.frequency == "Weekly" && $0.weekDay!.contains(date.dayOfTheWeek)) || ($0.frequency == "Monthly" && $0.monthDay == date.dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
    }
    
    func filterCurrentGoals() -> [GoalViewModel] {
        //self.getAllGoals()
        return filterCurrentGoalsByDate(date: Date())
    }
    
    func getGoalsArray() -> [GoalViewModel] {
        //self.getAllGoals()
        return self.goals
    }

//    func addNewGoal(name: String, color: Color, goalTime: Double, frequency: String, startDate: Date, dotw: WeekDays, endDate: Date?) {
//        
//        var priority = 1
//        if !goals.isEmpty {
//            priority = goals.map { $0.priority }.max()! + 1
//        }
//        
//        CoreDataManager.shared.addGoal(name: name, color: color, goalTime: goalTime, frequency: frequency, startDate: startDate, priority: priority, dotw: dotw, id: <#UUID#>, endDate: endDate)
//        self.getAllGoals()
//    }
    
    
}

struct GoalViewModel: Identifiable, Equatable {
    
    let goal: Goal
    
    var id: NSManagedObjectID {
        return goal.objectID
    }
    
    var uuid: UUID {
        return goal.id
    }
    
    var name: String {
        return goal.name ?? ""
    }
    
    var priority: Int {
        get {
            return Int(goal.priority)
        }
        set(newValue){
            goal.priority = Int16(newValue)
        }
        
    }
    
    var color: Color {
        return Color(goal.color!)
    }
    
    var endDate: Date? {
        return goal.endDate
    }
    
    var frequency: String? {
        return goal.frequency
    }
    
    var goalTime: Double {
        return goal.goalTime
    }
    
    var monthDay: Int {
        return Int(goal.monthDay)
    }
    
    var startDate: Date {
        return goal.startDate
    }
    
    var totalTime: Double {
            return goal.totalTime
    }
    
    var weekDay: [String]? {
        return goal.weekDay
    }
    
    var records: [GoalRecord]? {
        if let records = goal.records {
            return records
        }
        else {
            return nil
        }
    }
    
    static func ==(lhs: GoalViewModel, rhs: GoalViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func updateTotalTime(time: Double, add: Bool){
        CoreDataManager.shared.changeTotalTimeOfGoal(id: self.id, time: time, add: add)
    }
    
    func updateGoalTime(time: Double){
        CoreDataManager.shared.changeGoalTimeOfGoal(id: self.id, time: time)
    }
    
    func updatePriority(new: Int){
        CoreDataManager.shared.changePriorityOfGoal(id: self.id, priority: new)
    }
    
    func filterGoalRecordToday() -> GoalRecordViewModel? {
        if(records != nil){
            if let record = self.records!.first(where: {Calendar.current.isDate($0.date, inSameDayAs: Date())}) {
                return GoalRecordViewModel(record: record)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }


    }

}
