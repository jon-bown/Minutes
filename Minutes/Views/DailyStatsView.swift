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
    var goalList: FetchedResults<Goal>
    private var cal = Calendar.current
    private var maxStatLimit: Int = 3
    
    var filteredGoals: [Goal] {
        return self.goalList.filter({(dateProvided > $0.startDate! ||  cal.isDate(dateProvided, inSameDayAs:$0.startDate!)) && ((dateProvided.dayOfTheWeek == $0.weekDay && $0.frequency == "Weekly") || ($0.frequency == "Monthly" && $0.monthDay == dateProvided.dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
    }
    
    var filteredGoalRecords: [GoalRecord] {
        return self.goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!)})
    }
    
    
    // MARK: - INIT
    
    init(goalList: FetchedResults<Goal>){
        self.dateProvided = Date()
        self.goalList = goalList
    }
    
    
    var body: some View {
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

//struct DailyStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyStatsView()
//    }
//}
