//
//  DailyStatsViewStatic.swift
//  MinutesWidgetExtension
//
//  Created by Jonathan Bown on 6/11/23.
//

import Foundation
import SwiftUI

struct DailyStatsView: View {
    // MARK: - Variables
    var goalList: [Goal]
    var goalRecordList: [GoalRecord]
    
    var dateProvided: Date = Date()
    var type: String = "Horizontal"
    var maxStatLimit: Int = 3
    private var cal = Calendar.current
    
    // MARK: - INIT
    init(goalList: [Goal], goalRecordList: [GoalRecord], type: String = "Horizontal", maxStatLimit: Int = 3){
        self.dateProvided = Date()
        self.goalList = goalList
        self.goalRecordList = goalRecordList
        self.type = type
        self.maxStatLimit = maxStatLimit
    }

    var body: some View {
            Group {
                if AppUtil.filterGoalRecords(goalRecords: self.goalRecordList).isEmpty && AppUtil.filterGoalRecordsByDate(records: self.goalRecordList, date: self.dateProvided).isEmpty {
                    NoGoalsView()
                } else if AppUtil.filterGoalRecords(goalRecords: self.goalRecordList).isEmpty {
                    if type == "Horizontal" {
                        HorizontalGoalsView(maxStatLimit: maxStatLimit, dateProvided: dateProvided, goalList: goalList, goalRecordList: goalRecordList)
                    } else {
                        VerticalGoalsView(maxStatLimit: maxStatLimit, dateProvided: dateProvided, goalList: goalList, goalRecordList: goalRecordList)
                    }
                } else {
                    if type == "Horizontal" {
                        OtherGoalsView(maxStatLimit: maxStatLimit, dateProvided: dateProvided, goalList: goalList, goalRecordList: goalRecordList)
                    }
                }
            }
        }
    
    private func fetchGoalDayTimeFromRecord(goalRec: GoalRecord) -> Int {
    
            return Int(goalRec.dayTime/60)

    }
}

struct NoGoalsView: View {
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("No Goals Today").foregroundColor(Color.white)
                    .font(Font.system(size: 20, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(alignment:.center)
                    .padding(.trailing, 10)
            }
        }
    }
}

struct HorizontalGoalsView: View {
    var maxStatLimit: Int
    var dateProvided: Date = Date()
    var goalList: [Goal]
    var goalRecordList: [GoalRecord]
    
    var body: some View {
        EmptyView()
//        VStack(alignment: .leading){
//            ForEach(AppUtil.filterGoalRecordsByDate(records: self.goalRecordList, date: self.dateProvided), id: \.id){ goalRecord in
//                if let index = AppUtil.sortGoalRecordsByPriority(goalRecords: self.goalRecordList).firstIndex(where: {$0.id == goalRecord.id}){
//                    if(index < maxStatLimit){
//                        VStack{
//                            Text("\(goalRecord.name)").bold().foregroundColor(Color.white)
//                            if let goalTime = goalRecord.goal?.goalTime {
//                                Text("\(String(goalRecord.dayTime))/\(String(Int(goalTime))) MIN").foregroundColor(goalRecord.goal?.color ?? Color.black).bold().padding(.bottom, 4)
//                            }
//                        }
//                    }
//
//                }
//            }
//        }
    }
}


struct VerticalGoalsView: View {
    var maxStatLimit: Int
    var dateProvided: Date = Date()
    var goalList: [Goal]
    var goalRecordList: [GoalRecord]
    // here, we need to pass the necessary data and logic
    // I'm not providing a specific implementation as it's not clear from the existing code
    var body: some View {
        EmptyView()
//        HStack{
            //Row Names
//            VStack(alignment: .leading, spacing: 1){
//                Text("Goal").foregroundColor(Color.white)                           .font(Font.system(size: 15, weight: .semibold, design: .rounded))
//                Text("Today").foregroundColor(Color.white)                          .font(Font.system(size: 15, weight: .semibold, design: .rounded))
//                Text("Streak").foregroundColor(Color.white)
//                    .font(Font.system(size: 15, weight: .semibold, design: .rounded))
//                Text("Best").foregroundColor(Color.white).font(Font.system(size: 15, weight: .semibold, design: .rounded))
//                Text("Week").foregroundColor(Color.white)
//                    .font(Font.system(size: 15, weight: .semibold, design: .rounded))
//                Text("Total").foregroundColor(Color.white)
//                    .font(Constants.globalBodyTextFont)
//            }
//            HStack{
//                Divider().frame(width: 2).background(Color.white)
//            }.frame(height: 100)
//            //Columns
//            ForEach(AppUtil.filterCurrentGoals(goals: self.goalList, date: Date())){ goal in
//                if let index = AppUtil.filterCurrentGoals(goals: self.goalList, date: Date()).firstIndex(of: goal){
//                    if(index < maxStatLimit){
//                        //numerical limit here
//                        VStack(alignment: .leading, spacing: 1){
//                            Text("\(goal.name)").foregroundColor(Color.white).font(Font.system(size: 15, weight: .semibold, design: .rounded))
//                            Text("\(Int(AppUtil.fetchGoalDayTime(goal: goal)))/\(Int(goal.goalTime)) MIN").foregroundColor(goal.color).font(Font.system(size: 15, weight: .semibold, design: .rounded))
//                                .foregroundColor(goal.color)
////                                    Text(String(self.goalRecordListVM.calculateCurrentStreak(goalID: goal.uuid)))
////                                        .font(Constants.globalBodyTextFont)
////                                        .foregroundColor(goal.color)
////                                    Text(String(self.goalRecordListVM(goalID: goal.uuid)))
////                                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
////                                        .foregroundColor(goal.color)
////                                    Text(self.goalRecordListVM.calculateTimeThisWeek(goalID: goal.uuid))
////                                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
////                                        .foregroundColor(goal.color)
//                            //                                    Text(String(AppUtil.getTotalTimeString(seconds: Double(0.0))))
//                            //                                                                            .font(Font.system(size: 15, weight: .semibold, design: .rounded))
//                            //                                                                            .foregroundColor(Color(goal.color!))
//                        }
//                        //Spacer()
//                    }
//                    if(index < (maxStatLimit - 1)){
//                        HStack{
//                            Divider()
//                        }.frame(height: 100)
//
//                    }
//                }
//
//            }
//
//        }.padding(.bottom, 2)
        
    }
}

struct OtherGoalsView: View {
    var maxStatLimit: Int
    var dateProvided: Date = Date()
    var goalList: [Goal]
    var goalRecordList: [GoalRecord]
    // here, we need to pass the necessary data and logic
    // I'm not providing a specific implementation as it's not clear from the existing code
    var body: some View {
        EmptyView()
//        VStack(alignment: .leading){
//            ForEach(AppUtil.filterCurrentGoals(goals: self.goalList, date: Date())){ goal in
//                if let index = AppUtil.filterCurrentGoals(goals: self.goalList, date: Date()).firstIndex(of: goal){
//                    if(index < maxStatLimit){
//                        //numerical limit here
//                        Text("\(goal.name)").bold().foregroundColor(Color.white)
//                        Text("\(AppUtil.getDayTimeForGoal(goal: goal))/\(Int(goal.goalTime)) MIN").foregroundColor(goal.color).bold().padding(.bottom, 4)
//                    }
//                }
//
//            }
//        }
    }
}




struct DailyStatsViewDemo: View {
    
    
    private var cal = Calendar.current
    
    
    var type: String
    
    
    // MARK: - INIT
    init(type: String){
        self.type = type
    }
    
    
    var body: some View {
        
        
        if(type == "Horizontal"){
            VStack(alignment: .leading){
                Text("Goal1").bold().foregroundColor(Color.white)
                Text("0/10 MIN").foregroundColor(Color.red)
                Text("Goal2").bold().foregroundColor(Color.white)
                Text("0/10 MIN").foregroundColor(Color.red)
                Text("Goal3").bold().foregroundColor(Color.white)
                Text("0/10 MIN").foregroundColor(Color.red)
            }
        }
        else {
            HStack{
                //Row Names
                VStack(alignment: .leading, spacing: 1){
                    Text("Goal").foregroundColor(Color.white)                           .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                    Text("Today").foregroundColor(Color.white)                          .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                    Text("Streak").foregroundColor(Color.white)
                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                    Text("Best").foregroundColor(Color.white).font(Font.system(size: 15, weight: .semibold, design: .rounded))
                    Text("Week").foregroundColor(Color.white)
                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                    Text("Total").foregroundColor(Color.white)
                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                }
                HStack{
                    Divider().frame(width: 2).background(Color.white)
                }.frame(height: 100)
                //Columns
                generateGoalDetailDemo(color: .red, number: "1")
                generateGoalDetailDemo(color: .blue, number: "2")
                generateGoalDetailDemo(color: .green, number: "3")
                HStack{
                    Divider()
                }.frame(height: 100)
                
                
            }.padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))
            
        }
        
    }
    
    private func generateGoalDetailDemo(color: Color, number: String) -> some View{
        VStack(alignment: .leading, spacing: 1){
            Text("Goal\(number)").foregroundColor(Color.white).font(Font.system(size: 15, weight: .semibold, design: .rounded))
            Text("0/10 MIN").foregroundColor(color).font(Font.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            Text("0")
                .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            Text("0")
                .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            Text("00:00:00")
                .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            Text("00:00:00")
                .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

//struct DailyStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyStatsView()
//    }
//}


