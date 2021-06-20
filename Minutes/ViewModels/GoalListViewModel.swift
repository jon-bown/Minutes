//
//  GoalListViewModel.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/5/21.
//

import Foundation
import CoreData
import SwiftUI

class GoalListViewModel: ObservableObject {
    
    @Published var goals = [GoalViewModel]()
    let cal = Calendar.current
    
    func deleteGoal(goal: GoalViewModel) {
        let goal = CoreDataManager.shared.getGoalByID(id: goal.id)
        if let goal = goal {
            CoreDataManager.shared.deleteGoal(goal: goal)
        }
    }
    
    func getAllGoals() {
        let goals = CoreDataManager.shared.getAllGoals()
        DispatchQueue.main.async {
            self.goals = goals.map(GoalViewModel.init)
        }
    }
    
    //MARK: FILTERING
    
    func filterCurrentGoalsByDate(date: Date) -> [GoalViewModel] {
        return goals.filter({(date > $0.startDate || cal.isDate(date, inSameDayAs:$0.startDate)) && ($0.endDate == nil || date <= $0.endDate!) && (($0.frequency == "Weekly" && $0.weekDay!.contains(date.dayOfTheWeek)) || ($0.frequency == "Monthly" && $0.monthDay == date.dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
    }
    
    func filterCurrentGoals() -> [GoalViewModel] {
        return filterCurrentGoalsByDate(date: Date())
    }
    
    func getGoalsArray() -> [GoalViewModel] {
        self.getAllGoals()
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
            return goal.priority
        }
        set(newValue){
            goal.priority = newValue
        }
        
    }
    
    var color: Color {
        return Color(goal.color)
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
        return goal.monthDay
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
    
    var records: [GoalRecordViewModel]? {
        return goal.records?.map(GoalRecordViewModel.init)
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
        return self.records?.first(where: {Calendar.current.isDate($0.date, inSameDayAs: Date())})
    }

}
