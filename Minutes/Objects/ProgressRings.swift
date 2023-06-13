//
//  ProgressRings.swift
//  Minutes
//
//  Created by Jonathan Bown on 8/20/20.
//

import SwiftUI


struct ProgressRingViewWrapper: View {
    var progress: Double
    var thickness: CGFloat
    var startColor: Color
    var endColor: Color
    var backgroundColor: Color
    var animate: Bool
    var dim: CGFloat

    var body: some View {
        ProgressRingView(progress: progress,
                         thickness: thickness,
                         startColor: startColor,
                         endColor: endColor,
                         backgroundColor: backgroundColor,
                         animate: animate)
            .frame(width: dim, height: dim)
            .aspectRatio(contentMode: .fit)
    }
}


struct EmptyProgressRingView: View {
    var showClear: Bool
    var dim: CGFloat
    var thickness: CGFloat

    var body: some View {
        Group {
            if showClear {
                ProgressRingViewWrapper(progress: 0.0,
                                       thickness: thickness,
                                       startColor: Color.clear,
                                       endColor: Color.clear,
                                       backgroundColor: Color.clear,
                                       animate: false,
                                       dim: dim)
            } else {
                ForEach(0..<3) { index in
                    ProgressRingViewWrapper(progress: 0.0,
                                           thickness: thickness,
                                           startColor: Color.clear,
                                           endColor: Color.clear,
                                           backgroundColor: Color.clear,
                                           animate: false,
                                           dim: dim)
                }
            }
        }
    }
}

struct GoalRecordRingView: View {
    var goalRecordList: [GoalRecordViewModel]
    var maxRingLimit: Int
    var thickness: CGFloat
    var animate: Bool
    var dim: CGFloat

    var body: some View {
        ForEach(goalRecordList, id: \.id) { goalRecord in
            if let index = goalRecordList.firstIndex(where: {$0.id == goalRecord.id}), index < maxRingLimit {
                ProgressRingViewWrapper(progress: goalRecord.progress,
                                       thickness: thickness,
                                       startColor: goalRecord.goal.color.darker(by: 10.0),
                                       endColor: goalRecord.goal.color.lighter(by: 15),
                                       backgroundColor: goalRecord.goal.color,
                                       animate: animate,
                                       dim: dim)
            }
        }
    }
}

struct GoalRingView: View {
    
    @EnvironmentObject var goalListVM: GoalListViewModel
    @EnvironmentObject var goalRecordListVM: GoalRecordListViewModel
    
    
    var goal: GoalViewModel
    var goalRecordList: [GoalRecordViewModel]
    var maxRingLimit: Int
    var thickness: CGFloat
    var animate: Bool
    var dim: CGFloat

    var body: some View {
        let goal_index = Int(goal.priority) - 1
        if goal_index < maxRingLimit {
            let progress = self.calculateProgress()
            ProgressRingViewWrapper(progress: progress,
                                    thickness: thickness,
                                    startColor: goal.color,
                                    endColor: goal.color,
                                    backgroundColor: goal.color,
                                    animate: animate,
                                    dim: calculateDim(index: goal_index)) // calculateDim now based on priority
        }
    }
    
    private func calculateProgress() -> Double {
        let progress = goalRecordList.isEmpty ? 0.0 : (goalRecordList.first(where: { $0.goal.id == goal.id })?.progress ?? 0.0)
        print(goalRecordList)
        print("Progress: \(progress)")
        return progress
    }
    
    private func calculateDim(index: Int) -> CGFloat{
        let differenceAmount = (self.thickness * 2.0 + 4.0) * CGFloat(index)
        return self.dim - differenceAmount
    }
}




/*
 A collection of ProgressRingViews
 */
struct ProgressRings: View {

    //@StateObject private var goalListVM = GoalListViewModel.sharedInstance
    //@StateObject private var goalRecordListVM = GoalRecordListViewModel.sharedInstance
    @EnvironmentObject var goalListVM: GoalListViewModel
    @EnvironmentObject var goalRecordListVM: GoalRecordListViewModel
    //Parameters for minimized Ring View
    var dateProvided: Date = Date()
    var goals: [GoalViewModel]
    var goalRecords: [GoalRecordViewModel]
    var maxWidth: CGFloat = 100
    var maxLineWidth: CGFloat = 10
    var maxRingLimit: Int = 4
    var showClear: Bool = true
    var animate: Bool = true
    
    private var cal = Calendar.current
    
    init(goalList: [GoalViewModel], goalRecordList: [GoalRecordViewModel], dateProvided: Date, maxWidth: CGFloat, maxLineWidth: CGFloat, maxRingLimit: Int, animate: Bool = true, showClear: Bool = true, source: String = "Other"){
        self.dateProvided = dateProvided
        self.maxWidth = maxWidth
        self.maxLineWidth = maxLineWidth
        self.maxRingLimit = maxRingLimit
        self.animate = animate
        self.showClear = showClear
        self.goals = goalList
        self.goalRecords = goalRecordList
        //self.goalList = goalList
//        self.goalListVM.getAllGoals()
//        self.goalRecordListVM.getAllGoalRecords()
    }
    
    
    var body: some View {
        ZStack {
            
            if filterGoals(dateProvided: self.dateProvided).isEmpty
                && filterGoalRecords(dateProvided: self.dateProvided).isEmpty {
                EmptyProgressRingView(showClear: showClear,
                                      dim: calculateDim(index: 0),
                                      thickness: maxLineWidth)
            }
            else {
                
                ForEach(filterGoals(dateProvided: self.dateProvided), id: \.id) { goal in
                    GoalRingView(goal: goal,
                                 goalRecordList: filterGoalRecords(dateProvided: self.dateProvided),
                                 maxRingLimit: maxRingLimit,
                                 thickness: maxLineWidth,
                                 animate: animate,
                                 dim: calculateDim(index: 0))
                }
                
            }
        }
    }
    
    private func filterGoals(dateProvided: Date) -> [GoalViewModel]{
        return MinutesUtils.filterCurrentGoals(goals: self.goals, date: self.dateProvided)
    }
    
    private func filterGoalRecords(dateProvided: Date) -> [GoalRecordViewModel] {
        return MinutesUtils.filterGoalRecordsByDate(records: self.goalRecords, date: self.dateProvided)
    }
    

    private func calculateDim(index: Int) -> CGFloat{
        let differenceAmount = (self.maxLineWidth*2.0+4.0)*(CGFloat(index)-1.0)
        return self.maxWidth - differenceAmount
    }
    
}





struct ProgressRingsStatic: View {
    
    @EnvironmentObject var goalListVM: GoalListViewModel
    @EnvironmentObject var goalRecordListVM: GoalRecordListViewModel
    
    //Parameters for minimized Ring View
    var dateProvided: Date = Date()
    var maxWidth: CGFloat = 100
    var maxLineWidth: CGFloat = 10
    var maxRingLimit: Int = 4
    var animate: Bool = false
    var tinted: Bool = false
    //var goalList: FetchedResults<Goal>
        
    
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
            if(self.goalListVM.filterCurrentGoalsByDate(date: self.dateProvided).isEmpty){
                ProgressRingView(progress: 0.0, startColor: Color.clear, endColor: Color.clear, backgroundColor: Color.black)
            }
            else {
                ForEach(self.goalListVM.filterCurrentGoalsByDate(date: self.dateProvided), id: \.id){ goal in
                    
                    
                    //Main progress view
                    if let index = self.goalListVM.filterCurrentGoalsByDate(date: self.dateProvided).firstIndex(of: goal){
                        if(index < maxRingLimit){
                            if(self.goalListVM.filterCurrentGoalsByDate(date: self.dateProvided).isEmpty){
                                ProgressRingViewStatic(progress: 0.0, thickness: self.maxLineWidth, startColor: tinted ? Color.white: goal.color, endColor: tinted ? Color.white: goal.color, backgroundColor: tinted ? Color.gray:goal.color, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
                            }
                            else {
                                ProgressRingViewStatic(progress: self.goalRecordListVM.filterGoalRecordsByDate(date: self.dateProvided).first(where: { goal.id == $0.id }) == nil ? 0.0: self.goalRecordListVM.filterGoalRecordsByDate(date: self.dateProvided).first(where: { goal.id == $0.id})!.progress, thickness: self.maxLineWidth, startColor: tinted ? Color.white: goal.color, endColor: tinted ? Color.white: goal.color, backgroundColor: tinted ? Color.gray:goal.color, animate: animate).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
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

