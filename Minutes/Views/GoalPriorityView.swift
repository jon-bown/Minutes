//
//  GoalPriorityView.swift
//  Minutes
//
//  Created by Jonathan Bown on 1/16/21.
//

import SwiftUI

//Shows the list of goals and allows the user to reprioritize

struct GoalPriorityView: View {
    
    // MARK: - Properties
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
    ) var goalRecords: FetchedResults<GoalRecord>
    
    var filteredGoals: [Goal] {
        if(!goals.isEmpty){
            return goals.sorted(by: {$0.priority < $1.priority})
        }
        else{
            return []
        }

    }
    
    @State private var isEditable = false
    
    var body: some View {
        NavigationView{

                List {
                    ForEach(filteredGoals, id: \.priority) { goal in
                        GroupBox{
                            HStack{
                                Text(goal.name!)
                                Spacer()
                                Text("\(goal.priority)")
                            }
                        }
                        
                    }
                    .onMove(perform: onMove).onDelete(perform: onDelete)
                }.environment(\.editMode, isEditable ? .constant(.active) : .constant(.inactive)).padding()

            
            
            //Spacer()
        }.navigationBarItems(trailing: Button(self.isEditable ? "Done":"Edit"){
            self.isEditable.toggle()
        }).navigationBarTitleDisplayMode(.inline)

    }
    
    //Moves the priorities and the goal items
    func onMove(from source: IndexSet, to destination: Int) {
        guard let maxPriority = goals.map({$0.priority}).max() else { return }
        for index in source {
            let sourceGoal = goals.first(where: {$0.priority == index})
            //Upward swap or downward swap
            switch index <= destination {
            case true:
                if(destination > maxPriority){

                    sourceGoal?.priority = maxPriority
                    for goal in goals {
                        if(goal.priority < maxPriority){
                            goal.priority -= 1
                        }
                    }
                }
                else {

                    let destinationGoal = goals.first(where: {$0.priority == destination})
                    sourceGoal?.priority = Int64(destination)
                    destinationGoal?.priority -= 1
                    for goal in goals {
                        if(goal.priority < destination){
                            goal.priority -= 1
                        }
                    }
                }
                break
            case false:

                    let destinationGoal = goals.first(where: {$0.priority == destination})
                    sourceGoal?.priority = Int64(destination)
                    destinationGoal?.priority += 1
                    for goal in goals {
                        if(goal.priority > destination){
                            goal.priority += 1
                        }
                    }
                break
            }
        }
    
        DispatchQueue.main.async {
            saveContext()
        }
        
        withAnimation {
            isEditable = false
        }
    }
    
    func onDelete(at offsets: IndexSet) {
        //order.items.remove(atOffsets: offsets)
        //let items = try managedObjectContext.fetch(fetchRequest) as! [Goal]
        
//        for index in offsets {
//            managedObjectContext.delete(items[index])
//        }
        do {
            for index in offsets {
                let goal = self.goals.first(where: {$0.id == goals[index].id})!
                
                if(!goalRecords.isEmpty){
                    let goalRecords = self.goalRecords.filter({$0.id == goals[index].id})
                    for record in goalRecords {
                        managedObjectContext.delete(record)
                    }
                }
                let priorityMark = goal.priority
                managedObjectContext.delete(goal)
                for goal in goals {
                    if(goal.priority > priorityMark){
                        goal.priority = goal.priority - 1
                    }
                }

                

            }
            try managedObjectContext.save()
        }
        catch {
            
        }
        

    }
    
    private func saveContext() {
      do {
        try managedObjectContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
      }
    }
    

}

#if DEBUG
struct GoalPriorityView_Previews: PreviewProvider {
    static var previews: some View {
        GoalPriorityView()
    }
}
#endif
