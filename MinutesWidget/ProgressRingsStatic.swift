//
//  ProgressRingsStatic.swift
//  MinutesWidgetExtension
//
//  Created by Jonathan Bown on 6/11/23.
//

import Foundation
import SwiftUI


struct ProgressRingsStatic: View {
    
    
    //Parameters for minimized Ring View
    var dateProvided: Date = Date()
    var maxWidth: CGFloat = 100
    var maxLineWidth: CGFloat = 10
    var maxRingLimit: Int = 4
    var animate: Bool = false
    var tinted: Bool = false
    //var goalList: FetchedResults<Goal>
        
    
    private var cal = Calendar.current
    
    var goalList: [Goal]
    var goalRecordList: [GoalRecord]

    // ... Rest of your variables

    // Here, we expect the view models to be passed in when this View is instantiated.
    // These view models should be previously fetched from the shared data source.
    init(goals: [Goal], goalRecords: [GoalRecord], dateProvided: Date, maxWidth: CGFloat, maxLineWidth: CGFloat, maxRingLimit: Int, animate: Bool = true, tinted: Bool = false) {
        
        self.goalList = AppUtil.filterCurrentGoalsByDate(goals: goals, date: dateProvided)
        self.goalRecordList = AppUtil.filterGoalRecordsByDate(records: goalRecords, date: dateProvided)
        self.dateProvided = dateProvided
        self.maxWidth = maxWidth
        self.maxLineWidth = maxLineWidth
        self.maxRingLimit = maxRingLimit
        self.animate = animate
        self.tinted = tinted
    }
    
    var body: some View {
        //EmptyView()
        ZStack {
            if(self.goalList.isEmpty){
                ProgressRingView(progress: 0.0, startColor: Color.clear, endColor: Color.clear, backgroundColor: Color.black)
            }
            else {
                ForEach(goalList.prefix(maxRingLimit), id: \.id) { goal in
                    let progress = self.goalRecordList.first(where: { goal.id == $0.goal.id })?.progress ?? 0.0
                    ProgressRingViewStatic(progress: progress, thickness: self.maxLineWidth, startColor: tinted ? Color.white: Color(goal.color!), endColor: tinted ? Color.white: Color(goal.color!), backgroundColor: tinted ? Color.gray:Color(goal.color!), animate: animate)
                        .frame(width: calculateDim(index: goalList.firstIndex(where: { $0.id == goal.id }) ?? 0), height: calculateDim(index: goalList.firstIndex(where: { $0.id == goal.id }) ?? 0))
                        .aspectRatio(contentMode: .fit)
                }


                }
            


        }
    }
    
    private func calculateDim(index: Int) -> CGFloat{
        let differenceAmount = (self.maxLineWidth*2.0+4.0)*(CGFloat(index)-1.0)
        return self.maxWidth - differenceAmount
    }
    
}
