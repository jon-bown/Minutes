//
//  GoalDashboard.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 1/17/21.
//

import SwiftUI

struct GoalDashboard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
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
    
    var body: some View {
        //NavigationView{
        ScrollView{
            
            VStack{
                //parameterize this to fit any watch screen
                ProgressRings(dateProvided: Date(), maxWidth: 150, maxLineWidth: 15, maxRingLimit: 3).padding(10)
                Divider()
                ForEach(goals, id: \.self) { goal in
                    //NavigationLink(destination: GoalDetailView(goal: goal)) {
                    //For all goals of today, show a individual progress
                    HStack{
                        NavigationLink(destination: WKGoalDetailView(goal: goal).environment(\.managedObjectContext, managedObjectContext)){
                            Text("\(goal.name!)").foregroundColor(.white)
                            //Spacer()
                        }
                        
                    }.padding().cornerRadius(15)
                    
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
