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
    
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var records: FetchedResults<GoalRecord>
    
    
    var body: some View {
        
        //if goals is empty present a text over
        if(goals.isEmpty){
            Text("Tap '+' to create a new minute goal!")
        }else {
            
            List{ ForEach(goals, id: \.id) { goal in
                //NavigationLink(destination: GoalDetailView(goal: goal)) {
                
                GoalRow(goal: goal)
                //}
                
            }.onDelete(perform: deleteGoal)
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
        for index in offsets {
            //            let recordSubset = records.filter({$0.name == goals[index].name})
            //            for record in recordSubset {
            //                managedObjectContext.delete(records[records.firstIndex(of: record)!])
            //            }
            
            managedObjectContext.delete(goals[index])
            
        }
        DispatchQueue.main.async {
            saveContext()
        }
        
    }
    
}

struct GoalList_Previews: PreviewProvider {
    static var previews: some View {
        GoalList()
    }
}
