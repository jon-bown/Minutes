//
//  DailyStatsView.swift
//  Minutes
//
//  Created by Jonathan Bown on 1/14/21.
//

import SwiftUI

struct DailyStatsView: View {
    
    // MARK: - Variables
    @StateObject private var goalListVM = GoalListViewModel.sharedInstance
    @StateObject private var goalRecordListVM = GoalRecordListViewModel.sharedInstance
    
    var dateProvided: Date = Date()
    var goals: [GoalViewModel]
    var type: String = "Horizontal"
    var maxStatLimit: Int = 3
    private var cal = Calendar.current
    
    // MARK: - INIT
    
    init(goalList: [GoalViewModel], type: String = "Horizontal", maxStatLimit: Int = 3){
        self.dateProvided = Date()
        self.goals = goalList
        self.type = type
        self.maxStatLimit = maxStatLimit
    }
    
    
    var body: some View {
        
        if(goalListVM.filterCurrentGoals().isEmpty && goalRecordListVM.filterGoalRecordsByDate(date: self.dateProvided).isEmpty){
            VStack(alignment: .center){
                HStack{
                    
                    Text("No Goals Today").foregroundColor(Color.white)
                        .font(Font.system(size: 20, weight: .bold, design: .rounded)).multilineTextAlignment(.center).frame(alignment:.center).padding(.trailing, 10)
                }
                
            }
            
        }
        else if (goalListVM.filterCurrentGoals().isEmpty) {
            if(type == "Horizontal"){
                VStack(alignment: .leading){
                    ForEach(goalRecordListVM.filterGoalRecordsByDate(date: self.dateProvided), id: \.id){ goalRecord in
                        if let index = goalRecordListVM.sortGoalRecordsByPriority().firstIndex(where: {$0.id == goalRecord.id}){
                            if(index < maxStatLimit){
                                Text("\(goalRecord.name)").bold().foregroundColor(Color.white)
                                Text("\(goalRecord.dayTime)/\(Int(goalRecord.goal.goalTime)) MIN").foregroundColor(goalRecord.goal.color).bold().padding(.bottom, 4)
                            }
                            
                        }
                        
                    }
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
                            .font(Constants.globalBodyTextFont)
                    }
                    HStack{
                        Divider().frame(width: 2).background(Color.white)
                    }.frame(height: 100)
                    //Columns
                    ForEach(goalListVM.filterCurrentGoals()){ goal in
                        if let index = goalListVM.filterCurrentGoals().firstIndex(of: goal){
                            if(index < maxStatLimit){
                                //numerical limit here
                                VStack(alignment: .leading, spacing: 1){
                                    Text("\(goal.name)").foregroundColor(Color.white).font(Font.system(size: 15, weight: .semibold, design: .rounded))
                                    Text("\(Int(fetchGoalDayTime(goal: goal)))/\(Int(goal.goalTime)) MIN").foregroundColor(goal.color).font(Font.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(goal.color)
//                                    Text(String(self.goalRecordListVM.calculateCurrentStreak(goalID: goal.uuid)))
//                                        .font(Constants.globalBodyTextFont)
//                                        .foregroundColor(goal.color)
//                                    Text(String(self.goalRecordListVM(goalID: goal.uuid)))
//                                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
//                                        .foregroundColor(goal.color)
//                                    Text(self.goalRecordListVM.calculateTimeThisWeek(goalID: goal.uuid))
//                                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
//                                        .foregroundColor(goal.color)
                                    //                                    Text(String(AppUtil.getTotalTimeString(seconds: Double(0.0))))
                                    //                                                                            .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                                    //                                                                            .foregroundColor(Color(goal.color!))
                                }
                                //Spacer()
                            }
                            if(index < (maxStatLimit - 1)){
                                HStack{
                                    Divider()
                                }.frame(height: 100)
                                
                            }
                        }
                        
                    }
                    
                }.padding(.bottom, 2)
                
            }
            
        }
        //Filtered goals is NOT empty act as normal
        else {
            if(type == "Horizontal"){
                VStack(alignment: .leading){
                    ForEach(goalListVM.filterCurrentGoals()){ goal in
                        if let index = goalListVM.filterCurrentGoals().firstIndex(of: goal){
                            if(index < maxStatLimit){
                                //numerical limit here
                                Text("\(goal.name)").bold().foregroundColor(Color.white)
                                Text("\(goalRecordListVM.getDayTimeForGoal(goal: goal))/\(Int(goal.goalTime)) MIN").foregroundColor(goal.color).bold().padding(.bottom, 4)
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    // MARK: - HELPERS
    
    private func fetchGoalDayTime(goal: GoalViewModel) -> Int {
        if let goalRecord = goal.filterGoalRecordToday() {
            return Int(goalRecord.dayTime/60)
        }
        else {
            return 0
        }
    }
    
    private func fetchGoalDayTimeFromRecord(goalRec: GoalRecord) -> Int {
        
            return Int(goalRec.dayTime/60)

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


