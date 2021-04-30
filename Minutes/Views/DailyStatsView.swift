//
//  DailyStatsView.swift
//  Minutes
//
//  Created by Jonathan Bown on 1/14/21.
//

import SwiftUI

struct DailyStatsView: View {
    
    // MARK: - Variables
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goalRecords: FetchedResults<GoalRecord>
    
    var dateProvided: Date = Date()
    var goals: FetchedResults<Goal>
    var type: String = "Horizontal"
    var maxStatLimit: Int = 3
    private var cal = Calendar.current
    
    
    var filteredGoals: [Goal] {
        return AppUtil.filterCurrentGoals(goals: self.goalsArray, date: Date())
    }
    
    var goalsArray: [Goal] {
        return goals.sorted(by: {$0.priority > $1.priority})
    }
    
    var filteredGoalRecords: [GoalRecord] {
        return self.goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!)})
    }
    
    var goalRecordsArray: [GoalRecord] {
        return self.goalRecords.sorted(by: {$0.date! > $1.date!})
    }
    
    
    
    
    // MARK: - INIT
    
    init(goalList: FetchedResults<Goal>, type: String = "Horizontal", maxStatLimit: Int = 3){
        self.dateProvided = Date()
        self.goals = goalList
        self.type = type
        self.maxStatLimit = maxStatLimit
    }
    
    
    var body: some View {
        
        if(filteredGoals.isEmpty){
            Text("No Goals Today")
        }
        else {
            if(type == "Horizontal"){
                VStack(alignment: .leading){
                    ForEach(filteredGoals){ goal in
                        if let index = filteredGoals.firstIndex(of: goal){
                            if(index < maxStatLimit){
                                //numerical limit here
                                Text("\(goal.name!)").bold().foregroundColor(Color.white)
                                Text("\(Int(fetchGoalDayTime(goal: goal)))/\(Int(goal.goalTime)) MIN").foregroundColor(Color(goal.color!)).bold().padding(.bottom, 4)
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
                            .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    HStack{
                        Divider().frame(width: 2).background(Color.white)
                    }.frame(height: 100)
                    //Columns
                    ForEach(filteredGoals){ goal in
                        if let index = filteredGoals.firstIndex(of: goal){
                            if(index < maxStatLimit){
                                //numerical limit here
                                VStack(alignment: .leading, spacing: 1){
                                    Text("\(goal.name!)").foregroundColor(Color.white).font(Font.system(size: 15, weight: .semibold, design: .rounded))
                                    Text("\(Int(fetchGoalDayTime(goal: goal)))/\(Int(goal.goalTime)) MIN").foregroundColor(Color(goal.color!)).font(Font.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(goal.color!))
                                    Text(String(AppUtil.calculateGoalCurrentStreak(records: filteredGoalRecords, goalID: goal.id!)))
                                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(goal.color!))
                                    Text(String(AppUtil.calculateGoalBestStreak(goalID: goal.id!)))
                                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(goal.color!))
                                    Text(String(AppUtil.calculateTimeThisWeek(goalRecords: AppUtil.filterGoalRecordsByGoalID(goalRecords: self.goalRecordsArray, goalID: goal.id!))))
                                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(goal.color!))
                                    Text(String(AppUtil.getTotalTimeString(seconds: Double(0.0))))
                                                                            .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                                                                            .foregroundColor(Color(goal.color!))
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
    }
    
    
    
    // MARK: - HELPERS
    
    private func fetchGoalDayTime(goal: Goal) -> Int {
        if let goalRecord = filteredGoalRecords.first(where: {goal.name == $0.name}) {
            return Int(goalRecord.dayTime/60)
        }
        else {
            return 0
        }
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


