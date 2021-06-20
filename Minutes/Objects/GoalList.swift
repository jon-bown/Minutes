//
//  GoalList.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI


//Fetches all stored goals and displays them as a list
struct GoalList: View {
    
    @StateObject private var goalListVM = GoalListViewModel()

    
    var body: some View {

        if(goalListVM.getGoalsArray().isEmpty){
            Text("Tap '+' to create a new minute goal!")
        }else {
            
            List{ ForEach(goalListVM.getGoalsArray(), id: \.id) { goal in
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
