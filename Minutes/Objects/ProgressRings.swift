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

    @StateObject private var goalListVM = GoalListViewModel()
    @StateObject private var goalRecordListVM = GoalRecordListViewModel()
    //Parameters for minimized Ring View
    var dateProvided: Date = Date()
    var maxWidth: CGFloat = 100
    var maxLineWidth: CGFloat = 10
    var maxRingLimit: Int = 4
    var showClear: Bool = true
    var animate: Bool = true
    //var goalList: FetchedResults<Goal>
    var filteredGoals: [GoalViewModel] {
        return self.goalListVM.filterCurrentGoalsByDate(date: dateProvided)
    }
    
    var filteredGoalRecords: [GoalRecordViewModel] {
        return self.goalRecordListVM.filterGoalRecordsByDate(date: dateProvided)

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
        self.goalListVM.getAllGoals()
        self.goalRecordListVM.getAllGoalRecords()
    }
    
    var body: some View {
        
        ZStack {
            if(filteredGoals.isEmpty && filteredGoalRecords.isEmpty){
                if(showClear){
                    ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color.clear, endColor: Color.clear, backgroundColor: Color.clear, empty: true).frame(width: calculateDim(index: 0), height: calculateDim(index: 0)).aspectRatio(contentMode: .fit)
                }
                else {
                    ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color.clear, endColor: Color.clear, backgroundColor: Color.white, empty: true).frame(width: calculateDim(index: 0), height: calculateDim(index: 0)).aspectRatio(contentMode: .fit)
                    ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color.clear, endColor: Color.clear, backgroundColor: Color.white, empty: true).frame(width: calculateDim(index: 1), height: calculateDim(index: 0)).aspectRatio(contentMode: .fit)
                    ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: Color.clear, endColor: Color.clear, backgroundColor: Color.white, empty: true).frame(width: calculateDim(index: 2), height: calculateDim(index: 0)).aspectRatio(contentMode: .fit)
                }
                
            }
            else if(filteredGoals.isEmpty) {
                
                ForEach(self.filteredGoalRecords, id:\.id){ goalRecord in
                    if let index = goalRecordListVM.sortGoalRecordsByPriority().firstIndex(where: {$0.goal.id == goalRecord.goal.id})
                    {
                        if(index < maxRingLimit){
                            ProgressRingView(progress: goalRecord.progress, thickness: CGFloat(self.maxLineWidth), startColor: Color(goalRecord.goal.color).darker(by: 10.0), endColor: Color(goalRecord.goal.color).lighter(by: 15), backgroundColor: Color(goalRecord.goal.color), animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                        }
                        
                    }
                    
                }
            }
            
            else {
                ForEach(filteredGoals, id: \.id){ goal in
                    
                    
                    //Main progress view
                    if let index = filteredGoals.firstIndex(of: goal){
                        if(index < maxRingLimit){
                            if(filteredGoalRecords.isEmpty){
                                ProgressRingView(progress: 0.0, thickness: CGFloat(self.maxLineWidth), startColor: goal.color.darker(by: 10.0), endColor: goal.color.lighter(by: 15), backgroundColor: goal.color, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                            }
                            else {
                                ProgressRingView(progress: filteredGoalRecords.first(where: { goal.id == $0.id }) == nil ? 0.0: filteredGoalRecords.first(where: { goal.id == $0.id})!.progress, thickness: CGFloat(self.maxLineWidth), startColor: goal.color.darker(by: 10.0), endColor: goal.color.lighter(by: 15), backgroundColor: goal.color, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
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
    
    
    
    @StateObject private var goalListVM = GoalListViewModel()
    @StateObject private var goalRecordListVM = GoalRecordListViewModel()
    
    //Parameters for minimized Ring View
    var dateProvided: Date = Date()
    var maxWidth: CGFloat = 100
    var maxLineWidth: CGFloat = 10
    var maxRingLimit: Int = 4
    var animate: Bool = false
    var tinted: Bool = false
    //var goalList: FetchedResults<Goal>
    
    var filteredGoals: [GoalViewModel] {
        return self.goalListVM.filterCurrentGoalsByDate(date: self.dateProvided)
    }

    
    var filteredGoalRecords: [GoalRecordViewModel] {
        return self.goalRecordListVM.filterGoalRecordsByDate(date: self.dateProvided)

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
                ProgressRingView(progress: 0.0, startColor: Color.clear, endColor: Color.clear, backgroundColor: Color.black)
            }
            else {
                ForEach(filteredGoals, id: \.id){ goal in
                    
                    
                    //Main progress view
                    if let index = filteredGoals.firstIndex(of: goal){
                        if(index < maxRingLimit){
                            if(filteredGoalRecords.isEmpty){
                                ProgressRingViewStatic(progress: 0.0, thickness: self.maxLineWidth, startColor: tinted ? Color.white: goal.color.darker(by: 10.0), endColor: tinted ? Color.white: goal.color.lighter(by: 15), backgroundColor: tinted ? Color.gray:goal.color, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                            }
                            else {
                                ProgressRingViewStatic(progress: filteredGoalRecords.first(where: { goal.id == $0.id }) == nil ? 0.0: filteredGoalRecords.first(where: { goal.id == $0.id})!.progress, thickness: self.maxLineWidth, startColor: tinted ? Color.white: goal.color.darker(by: 10.0), endColor: tinted ? Color.white: goal.color.lighter(by: 15), backgroundColor: tinted ? Color.gray:goal.color, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
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

