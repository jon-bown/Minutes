//
//  GoalListViewModel.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/5/21.
//

import Foundation
import CoreData
import SwiftUI
import WidgetKit

class GoalListViewModel: ObservableObject, Equatable {
    
    static let sharedInstance = GoalListViewModel()
    
    static func == (lhs: GoalListViewModel, rhs: GoalListViewModel) -> Bool {
        return lhs.goals == rhs.goals
    }
    
    
    @Published var goals = [GoalViewModel]()
    let cal = Calendar.current
    
    
    init() {
        let didSaveNotification = NSManagedObjectContext.didSaveObjectsNotification
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSave(_:)), name: didSaveNotification, object: nil)
        
        self.getAllGoals()
    }
    
    @objc func didSave(_ notification: Notification){
        DispatchQueue.main.async {
            self.getAllGoals()
        }
        
    }
    
    @objc func didChange(_ notification: Notification){
        DispatchQueue.main.async {
            self.getAllGoals()
        }
    }
    
    func getGoalByID(id: NSManagedObjectID) -> Goal? {
        let goal = CoreDataManager.shared.getGoalByID(id: id)
        return goal
    }
    
    func deleteGoal(goal: GoalViewModel) {
        let goalObj = CoreDataManager.shared.getGoalByID(id: goal.id)
        if let goalToDelete = goalObj {
                CoreDataManager.shared.deleteGoal(goal: goalToDelete)
        }
    }
    
    func getAllGoals() {
        
        DispatchQueue.main.async {
            self.goals.removeAll()
            let core_goals = CoreDataManager.shared.getAllGoals()
            //print(core_goals)
            if(!core_goals.isEmpty){
                self.goals = core_goals.map(GoalViewModel.init).sorted(by: {$0.priority < $1.priority})
            }
            else {
                self.goals.removeAll()
                self.goals = []
            }
            
        }
        
    }
    
    func deleteAllGoals() {
        DispatchQueue.main.async {
            self.goals.removeAll()
            CoreDataManager.shared.deleteAllGoals()
        }
    }
    

    //MARK: FILTERING
    
    func filterCurrentGoalsByDate(date: Date) -> [GoalViewModel] {
        //self.getAllGoals()
        if(!self.goals.isEmpty){
            return goals.filter({(date > $0.startDate || cal.isDate(date, inSameDayAs:$0.startDate)) && ($0.endDate == nil || date <= $0.endDate!) && (($0.frequency == "Weekly" && $0.weekDay!.contains(date.dayOfTheWeek)) || ($0.frequency == "Monthly" && $0.monthDay == date.dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
        }
        else{
            return []
        }

    }
    
    func filterCurrentGoals() -> [GoalViewModel] {
        //self.getAllGoals()
        return filterCurrentGoalsByDate(date: Date())
    }
    
    
    func filteredGoalsNotToday() -> [GoalViewModel] {
        //if no goals outside of today then return empty
        let filteredArray = self.goals.filter({!filterCurrentGoals().contains($0)})
        
        if(!filteredArray.isEmpty){
            return filteredArray
        }
        else {
            return []
        }

    }
    
    func getGoalsArray() -> [GoalViewModel] {
        //self.getAllGoals()
        return self.goals.sorted(by: {$0.priority < $1.priority})
    }
    
    func resetGoalsPriority() {
        var start = 1
        for goal in self.getGoalsArray() {
            CoreDataManager.shared.changePriorityOfGoal(id: goal.id, priority: start)
            start += 1
        }
    }
    
}

struct GoalViewModel: Identifiable, Equatable {
    
    let goal: Goal
    
    var id: NSManagedObjectID {
        return goal.objectID
    }
    
    var uuid: UUID {
        if(goal.id == nil){
            return UUID()
        }
        else{
            return goal.id!
        }
    }
    
    var name: String {
        return goal.name
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
        if(goal.color == nil){
            return Color.white
        }
        else{
            return Color(goal.color!)
        }
        
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
        DispatchQueue.main.async {
            CoreDataManager.shared.changeTotalTimeOfGoal(id: self.id, time: time, add: add)
        }
        
    }
    
    func updateGoalTime(time: Double){
        DispatchQueue.main.async {
        CoreDataManager.shared.changeGoalTimeOfGoal(id: self.id, time: time)
        }
    }
    
    func updatePriority(new: Int){
        DispatchQueue.main.async {
            CoreDataManager.shared.changePriorityOfGoal(id: self.id, priority: new)
        }
        
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
