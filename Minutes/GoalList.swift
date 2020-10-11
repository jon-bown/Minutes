//
//  GoalList.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI

struct GoalList: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // 1
    @FetchRequest(
      // 2
      entity: Goal.entity(),
      // 3
      sortDescriptors: [
        NSSortDescriptor(keyPath: \Goal.name, ascending: true)
      ]
    // 4
    ) var goals: FetchedResults<Goal>
    
    
    
    var body: some View {
        
        //if goals is empty present a text over
        if(goals.isEmpty){
            Text("Tap '+' to create a new minute goal!")
        }else {
            List(goals, id: \.id) { goal in
                NavigationLink(destination: GoalDetailView(goal: goal)) {
                    
                    GoalRow(goal: goal)
                }
                
            }
        }

    }
    
    
    private func saveContext() {
      do {
        try managedObjectContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
      }
    }
    

    // remove a goal from the list
    func deleteGoal(at offsets: IndexSet){
        
    }

}

struct GoalList_Previews: PreviewProvider {
    static var previews: some View {
        GoalList()
    }
}
