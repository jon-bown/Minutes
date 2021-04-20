//
//  ProgressRings.swift
//  Minutes
//
//  Created by Jonathan Bown on 8/20/20.
//

import SwiftUI



struct ProgressRings: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goalRecords: FetchedResults<GoalRecord>
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goals: FetchedResults<Goal>
    
    //Parameters for minimized Ring View
    var dateProvided: Date = Date()
    var maxWidth: Int = 100
    var maxLineWidth: Int = 10
    var maxRingLimit: Int = 4
    var animate: Bool = true
    //var goalList: FetchedResults<Goal>
    var filteredGoals: [Goal] {
        return AppUtil.filterCurrentGoals(goals: self.goalsArray, date: dateProvided)
    }
    
    var goalRecordsArray: [GoalRecord] {
        return goalRecords.sorted(by: {$0.date! > $1.date!})
    }
    
    
    var goalsArray: [Goal] {
        return goals.sorted(by: {$0.priority < $1.priority})
    }
    //
    
    
    //    var filteredGoals: [Goal] {
    //        return goals.filter({(dateProvided > $0.startDate! ||  cal.isDate(dateProvided, inSameDayAs:$0.startDate!)) && ((dateProvided.dayOfTheWeek == $0.weekDay && $0.frequency == "Weekly") || ($0.frequency == "Monthly" && $0.monthDay == dateProvided.dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
    //    }
    
    var filteredGoalRecords: [GoalRecord] {
        return AppUtil.filterGoalRecordsByDate(goalRecords: self.goalRecordsArray, date: self.dateProvided)
        
    }
    
    private var cal = Calendar.current
    
    init(dateProvided: Date, maxWidth: Int, maxLineWidth: Int, maxRingLimit: Int, animate: Bool = true){
        self.dateProvided = dateProvided
        self.maxWidth = maxWidth
        self.maxLineWidth = maxLineWidth
        self.maxRingLimit = maxRingLimit
        self.animate = animate
        //self.goalList = goalList
    }
    
    var body: some View {
        
        ZStack {
            if(filteredGoals.isEmpty){
                ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color.clear, endColor: Color.clear, backgroundColor: UIColor.clear).frame(width: calculateDim(index: 0), height: calculateDim(index: 0)).aspectRatio(contentMode: .fit)
            }
            else {
                ForEach(filteredGoals, id: \.self){ goal in
                    
                    
                    //Main progress view
                    if let index = filteredGoals.firstIndex(of: goal){
                        if(index < maxRingLimit){
                            if(filteredGoalRecords.isEmpty){
                                ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color(goal.color!.darker(by: 10.0)!), endColor: Color(goal.color!.lighter(by: 15)!), backgroundColor: goal.color!, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                            }
                            else {
                                ProgressRingView(progress: filteredGoalRecords.first(where: { goal.id == $0.id }) == nil ? 0.0: filteredGoalRecords.first(where: { goal.id == $0.id})!.progress, thickness: CGFloat(self.maxLineWidth), startColor: Color(goal.color!.darker(by: 10.0)!), endColor: Color(goal.color!.lighter(by: 15)!), backgroundColor: goal.color!, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                            }
                            
                        }
                    }
                    
                    else {
                        
                    }
                }
            }
            
            
        }
        
    }
    
    private func calculateDim(index: Int) -> CGFloat{
        return CGFloat(self.maxWidth - (self.maxLineWidth*2+4)*(index-1))
    }
    
}


struct ProgressRingsStatic: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goalRecords: FetchedResults<GoalRecord>
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goals: FetchedResults<Goal>
    
    //Parameters for minimized Ring View
    var dateProvided: Date = Date()
    var maxWidth: Int = 100
    var maxLineWidth: Int = 10
    var maxRingLimit: Int = 4
    var animate: Bool = true
    //var goalList: FetchedResults<Goal>
    
    var goalsArray: [Goal] {
        return goals.sorted(by: {$0.priority > $1.priority})
    }
    
    var filteredGoals: [Goal] {
        if(!goalsArray.isEmpty){
            return AppUtil.filterCurrentGoals(goals: self.goalsArray, date: dateProvided)
        }
        else{
            return []
        }
        
    }
    //
    
    
    //    var filteredGoals: [Goal] {
    //        return goals.filter({(dateProvided > $0.startDate! ||  cal.isDate(dateProvided, inSameDayAs:$0.startDate!)) && ((dateProvided.dayOfTheWeek == $0.weekDay && $0.frequency == "Weekly") || ($0.frequency == "Monthly" && $0.monthDay == dateProvided.dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
    //    }
    
    var filteredGoalRecords: [GoalRecord] {
        if(goalRecords.isEmpty){
            return []
        }
        else{
            return self.goalRecords.filter({cal.isDate(self.dateProvided, inSameDayAs:$0.date!)})
        }
        
    }
    
    private var cal = Calendar.current
    
    init(dateProvided: Date, maxWidth: Int, maxLineWidth: Int, maxRingLimit: Int, animate: Bool = true){
        self.dateProvided = dateProvided
        self.maxWidth = maxWidth
        self.maxLineWidth = maxLineWidth
        self.maxRingLimit = maxRingLimit
        self.animate = animate
        //self.goalList = goalList
    }
    
    var body: some View {
        
        ZStack {
            if(filteredGoals.isEmpty){
                ProgressRingView(progress: 0.0, startColor: Color.clear, endColor: Color.clear, backgroundColor: UIColor.black)
            }
            else {
                ForEach(filteredGoals, id: \.self){ goal in
                    
                    
                    //Main progress view
                    if let index = filteredGoals.firstIndex(of: goal){
                        if(index < maxRingLimit){
                            if(filteredGoalRecords.isEmpty){
                                ProgressRingViewStatic(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color(goal.color!.darker(by: 10.0)!), endColor: Color(goal.color!.lighter(by: 15)!), backgroundColor: goal.color!, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                            }
                            else {
                                ProgressRingViewStatic(progress: filteredGoalRecords.first(where: { goal.id == $0.id }) == nil ? 0.0: filteredGoalRecords.first(where: { goal.id == $0.id})!.progress, thickness: CGFloat(self.maxLineWidth), startColor: Color(goal.color!.darker(by: 10.0)!), endColor: Color(goal.color!.lighter(by: 15)!), backgroundColor: goal.color!, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                            }
                            
                        }
                    }
                    
                    else {
                        
                    }
                }
            }
            
            
        }
        
    }
    
    private func calculateDim(index: Int) -> CGFloat{
        return CGFloat(self.maxWidth - (self.maxLineWidth*2+4)*(index-1))
    }
    
}

