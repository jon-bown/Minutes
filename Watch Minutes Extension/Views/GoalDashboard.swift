//
//  GoalDashboard.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 1/17/21.
//

import SwiftUI

struct GoalDashboard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    private var cal = Calendar.current
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Goal.priority, ascending: true)
        ]
    ) var goals: FetchedResults<Goal>
    
    
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var records: FetchedResults<GoalRecord>
    
    
    var filteredGoalsToday: [Goal] {
        let filteredArray = goals.filter({(Date() > $0.startDate! ||  cal.isDate(Date(), inSameDayAs:$0.startDate!)) && ((Date().dayOfTheWeek == $0.weekDay && $0.frequency == "Weekly") || ($0.frequency == "Monthly" && $0.monthDay == Date().dayOfTheMonth) || $0.frequency == "Daily")})
        if(!filteredArray.isEmpty){
            return filteredArray
        }
        else {
            return []
        }
    }
    
    
    var filteredGoalsNotToday: [Goal] {
        //if no goals outside of today then return empty
        let filteredArray = goals.filter({!filteredGoalsToday.contains($0)})
        
        if(!filteredArray.isEmpty){
            return filteredArray
        }
        else {
            return []
        }

    }
    
    var body: some View {
        //NavigationView{
        ScrollView{
            
            VStack{
                //parameterize this to fit any watch screen
                ProgressRings(dateProvided: Date(), maxWidth: 150, maxLineWidth: 15, maxRingLimit: 3).padding(10)
                Divider()
                Section(header: Text("Today")){
                    ForEach(filteredGoalsToday, id: \.self) { goal in
                        //NavigationLink(destination: GoalDetailView(goal: goal)) {
                        //For all goals of today, show a individual progress
                        HStack{
                            NavigationLink(destination: WKGoalDetailView(goal: goal).environment(\.managedObjectContext, managedObjectContext)){
                                Text("\(goal.name!)").foregroundColor(.white)
                                //Spacer()
                            }
                            
                        }.padding(.horizontal, 5).padding(.vertical, 2).cornerRadius(15)
                        
                    }
                }
                
                Section(header: Text("Other")){
                    ForEach(filteredGoalsNotToday, id: \.self) { goal in
                        HStack{
                            NavigationLink(destination: WKGoalDetailView(goal: goal).environment(\.managedObjectContext, managedObjectContext)){
                                Text("\(goal.name!)").foregroundColor(.white)
                                //Spacer()
                            }
                            
                        }.padding(.horizontal, 5).padding(.vertical, 2).cornerRadius(15)
                        
                    }
                }

                
            }.navigationTitle("Today").aspectRatio(contentMode: .fit)
            
        }
    }
}

struct GoalDashboard_Previews: PreviewProvider {
    static var previews: some View {
        GoalDashboard()
    }
}
