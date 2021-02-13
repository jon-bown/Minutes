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
        // 2
        entity: Goal.entity(),
        // 3
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
        // 4
    ) var goals: FetchedResults<Goal>
    
    //Parameters for minimized Ring View
    var dateProvided: Date = Date()
    var maxWidth: Int = 100
    var maxLineWidth: Int = 10
    var maxRingLimit: Int = 4
    //var goalList: FetchedResults<Goal>
    var filteredGoals: [Goal] {
        if(!goals.isEmpty){
            return self.goals.filter({(dateProvided > $0.startDate! ||  cal.isDate(dateProvided, inSameDayAs:$0.startDate!)) && ($0.endDate == nil || dateProvided <= $0.endDate!) && ((dateProvided.dayOfTheWeek == $0.weekDay && $0.frequency == "Weekly") || ($0.frequency == "Monthly" && $0.monthDay == dateProvided.dayOfTheMonth) || $0.frequency == "Daily")})
        }
        else{
            return []
        }

    }
    
    private var cal = Calendar.current
    
    init(dateProvided: Date, maxWidth: Int, maxLineWidth: Int, maxRingLimit: Int){
        self.dateProvided = dateProvided
        self.maxWidth = maxWidth
        self.maxLineWidth = maxLineWidth
        self.maxRingLimit = maxRingLimit
        //self.goalList = goalList
    }
    
    var body: some View {
        
        ZStack {
            if(filteredGoals.isEmpty){
                ProgressRingView(progress: .constant(0.0), startColor: Color.clear, endColor: Color.clear, backgroundColor: UIColor.black)
            }
            else {
                ForEach(filteredGoals, id: \.self){ goal in
                    
                    
                    //Main progress view
                    if let index = filteredGoals.firstIndex(of: goal){
                        if(index < maxRingLimit){
                            ProgressRingView(progress: .constant(goalRecords.first(where: { cal.isDate(dateProvided, inSameDayAs:$0.date!) && goal.name == $0.name }) == nil ? 0.0: goalRecords.first(where: { cal.isDate(dateProvided, inSameDayAs:$0.date!) && goal.name == $0.name})!.progress), thickness: CGFloat(self.maxLineWidth), startColor: Color(goal.color!.darker(by: 10.0)!), endColor: Color(goal.color!.lighter(by: 15)!), backgroundColor: goal.color!).frame(width: calculateDim(index: index), height: calculateDim(index: index)).aspectRatio(contentMode: .fit)
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


