//
//  GoalList.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI


//Fetches all stored goals and displays them as a list
struct GoalList: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Goal.priority, ascending: true)
        ]
    ) var goals: FetchedResults<Goal>

    
    var body: some View {

        if(goals.isEmpty){
            Text("Tap '+' to create a new minute goal!")
        }else {
            
            List{ ForEach(goals, id: \.id) { goal in
                GoalRow(goal: goal)
            }
            }
            
        }
    }
    
}

struct GoalList_Previews: PreviewProvider {
    static var previews: some View {
        GoalList()
    }
}
