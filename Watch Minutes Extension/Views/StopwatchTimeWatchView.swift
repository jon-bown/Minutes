//
//  StopwatchTimeWatchView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 4/21/21.
//

import SwiftUI

struct StopwatchTimeWatchView: View {
    
    @StateObject private var goalRecordListVM = GoalRecordListViewModel()
    
    var filteredGoalRecords: [GoalRecordViewModel] {
        return self.goalRecordListVM.filterGoalRecords()

    }
    
    var goal: GoalViewModel
    @Binding var progress: Double
    @Binding var selectedTab: Int
    @Binding var totalTime: Double
    
    var body: some View {
        VStack{
            if(filteredGoalRecords.isEmpty){
                ProgressView(value: 0.0).progressViewStyle(LinearProgressViewStyle(tint: self.goal.color)).padding()
            }
            else{
                ProgressView(value: filteredGoalRecords[0].progress >= 1.0 ? 1.0:filteredGoalRecords[0].progress).progressViewStyle(LinearProgressViewStyle(tint: self.goal.color)).padding()
            }
            //Timer UI
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 90).padding()
                .foregroundColor(Color(UIColor.black.lighter(by: 20.0)!)).animatableStopWatchText(watchTime: AppUtil.getTotalTimeString(seconds: self.totalTime))

            
            Spacer()


        }.navigationTitle("Goals")
        
        
    }
    
}


struct StopWatchTextModifier: AnimatableModifier {
    var watchTime: String = ""
    var textColor: Color = .primary
    var animatableData: String {
        get { watchTime }
        set { watchTime = newValue }
    }
    func body(content: Content) -> some View {
        content
            .overlay(
                HStack{
                    Text(watchTime.components(separatedBy: ":")[0]).font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 40, height: 50, alignment: .center)
                    Text(":").font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 10, height: 50, alignment: .center)
                    Text(watchTime.components(separatedBy: ":")[1]).font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 40, height: 50, alignment: .center)
                    Text(":").font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 10, height: 50, alignment: .center)
                    Text(watchTime.components(separatedBy: ":")[2]).font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 40, height: 50, alignment: .center)
                }.frame(width: 300, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .center)

            ) }
}

extension View {
//    func animatableProgressText(progress: Double, textColor: Color = Color.primary)
//    -> some View {
//        self.modifier(ProgressTextModifier(progress: progress, textColor: textColor)) }
//
    func animatableStopWatchText(watchTime: String, textColor: Color = Color.primary)
    -> some View {
        self.modifier(StopWatchTextModifier(watchTime: watchTime, textColor: textColor)) }
}
