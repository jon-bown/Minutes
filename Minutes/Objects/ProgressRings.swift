//
//  ProgressRings.swift
//  Minutes
//
//  Created by Jonathan Bown on 8/20/20.
//

import SwiftUI


/*
 A collection of ProgressRingViews
 */
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
    var maxWidth: CGFloat = 100
    var maxLineWidth: CGFloat = 10
    var maxRingLimit: Int = 4
    var showClear: Bool = true
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
    
    var filteredGoalRecords: [GoalRecord] {
        return AppUtil.filterGoalRecordsByDate(goalRecords: self.goalRecordsArray, date: self.dateProvided)
        
    }
    
    private var cal = Calendar.current
    
    init(dateProvided: Date, maxWidth: CGFloat, maxLineWidth: CGFloat, maxRingLimit: Int, animate: Bool = true, showClear: Bool = true){
        self.dateProvided = dateProvided
        self.maxWidth = maxWidth
        self.maxLineWidth = maxLineWidth
        self.maxRingLimit = maxRingLimit
        self.animate = animate
        self.showClear = showClear
        //self.goalList = goalList
    }
    
    var body: some View {
        
        ZStack {
            if(filteredGoals.isEmpty && filteredGoalRecords.isEmpty){
                if(showClear){
                    ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color.clear, endColor: Color.clear, backgroundColor: UIColor.clear, empty: true).frame(width: calculateDim(index: 0), height: calculateDim(index: 0)).aspectRatio(contentMode: .fit)
                }
                else {
                    ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color.clear, endColor: Color.clear, backgroundColor: UIColor.white, empty: true).frame(width: calculateDim(index: 0), height: calculateDim(index: 0)).aspectRatio(contentMode: .fit)
                    ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color.clear, endColor: Color.clear, backgroundColor: UIColor.white, empty: true).frame(width: calculateDim(index: 1), height: calculateDim(index: 0)).aspectRatio(contentMode: .fit)
                    ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color.clear, endColor: Color.clear, backgroundColor: UIColor.white, empty: true).frame(width: calculateDim(index: 2), height: calculateDim(index: 0)).aspectRatio(contentMode: .fit)
                }
                
            }
            else if(filteredGoals.isEmpty) {
                
                ForEach(AppUtil.sortGoalRecordsByPriority(goalRecords: self.filteredGoalRecords, goals: self.goalsArray), id: \.self){ goalRecord in
                    if let index = AppUtil.sortGoalRecordsByPriority(goalRecords: self.filteredGoalRecords, goals: self.goalsArray).firstIndex(of: goalRecord){
                        if(index < maxRingLimit){
                            ProgressRingView(progress: goalRecord.progress, thickness: CGFloat(self.maxLineWidth), startColor: Color(AppUtil.getGoalColorFromRecord(goals: self.goalsArray, id: goalRecord.id!).darker(by: 10.0)!), endColor: Color(AppUtil.getGoalColorFromRecord(goals: self.goalsArray, id: goalRecord.id!).lighter(by: 15)!), backgroundColor: goalsArray.first(where: {$0.id! == goalRecord.id!})!.color!, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                        }
                        
                    }
                    
                }
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
                        EmptyView()
                    }
                }
            }
            
        }
        
        
        
        
    }
    
    private func calculateDim(index: Int) -> CGFloat{
        let differenceAmount = (self.maxLineWidth*2.0+4.0)*(CGFloat(index)-1.0)
        return self.maxWidth - differenceAmount
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
    var maxWidth: CGFloat = 100
    var maxLineWidth: CGFloat = 10
    var maxRingLimit: Int = 4
    var animate: Bool = false
    var tinted: Bool = false
    //var goalList: FetchedResults<Goal>
    
    var goalsArray: [Goal] {
        return goals.sorted(by: {$0.priority > $1.priority})
    }
    
    var goalRecordsArray: [GoalRecord] {
        return goalRecords.sorted(by: {$0.date! > $1.date!})
    }
    
    var filteredGoals: [Goal] {
        return AppUtil.filterCurrentGoals(goals: self.goalsArray, date: dateProvided)
        
    }
    
    var filteredGoalRecords: [GoalRecord] {
        return AppUtil.filterGoalRecordsByDate(goalRecords: self.goalRecordsArray, date: self.dateProvided)
    }
    
    private var cal = Calendar.current
    
    init(dateProvided: Date, maxWidth: CGFloat, maxLineWidth: CGFloat, maxRingLimit: Int, animate: Bool = true, tinted: Bool = false){
        self.dateProvided = dateProvided
        self.maxWidth = maxWidth
        self.maxLineWidth = maxLineWidth
        self.maxRingLimit = maxRingLimit
        self.animate = animate
        self.tinted = tinted
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
                                ProgressRingViewStatic(progress: 0.0, thickness: self.maxLineWidth, startColor: tinted ? Color.white: Color(goal.color!.darker(by: 10.0)!), endColor: tinted ? Color.white: Color(goal.color!.lighter(by: 15)!), backgroundColor: tinted ? UIColor(Color.gray):goal.color!, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                            }
                            else {
                                ProgressRingViewStatic(progress: filteredGoalRecords.first(where: { goal.id == $0.id }) == nil ? 0.0: filteredGoalRecords.first(where: { goal.id == $0.id})!.progress, thickness: self.maxLineWidth, startColor: tinted ? Color.white: Color(goal.color!.darker(by: 10.0)!), endColor: tinted ? Color.white: Color(goal.color!.lighter(by: 15)!), backgroundColor: tinted ? UIColor(Color.gray):goal.color!, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                            }
                            
                        }
                    }
                    
                }
            }
            
            
        }
        
    }
    
    private func calculateDim(index: Int) -> CGFloat{
        let differenceAmount = (self.maxLineWidth*2.0+4.0)*(CGFloat(index)-1.0)
        return self.maxWidth - differenceAmount
    }
    
}

