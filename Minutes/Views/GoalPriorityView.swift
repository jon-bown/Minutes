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
    @State private var showError: Bool = false
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
                }.alert(isPresented: self.$showError) {
                    return Alert(title: Text("Error Saving Goal"), message: Text("Try again!"), dismissButton: .default(Text("Ok")))
                    
                }.environment(\.editMode, isEditable ? .constant(.active) : .constant(.inactive)).padding()

            
            
            //Spacer()
        }.navigationBarItems(trailing: Button(self.isEditable ? "Done":"Edit"){
            self.isEditable.toggle()
        }).navigationBarTitleDisplayMode(.inline)

    }
    
    //Moves the priorities and the goal items
    func onMove(from source: IndexSet, to destination: Int) {

        for index in source {
            if(index == destination){
                return
            }
            let sourceGoal = goals.first(where: {$0.priority == (index+1)})!
            
            
            var goalsArray = filteredGoals
            goalsArray.remove(at: index)
            if(goalsArray.count == (destination-1)){
                goalsArray.append(sourceGoal)
            }
            else {
                if(index < destination){
                    goalsArray.insert(sourceGoal, at: (destination-1))
                }
                else {
                    goalsArray.insert(sourceGoal, at: (destination))
                }
                
            }
            
            for goal in filteredGoals {
                let marker = goalsArray.firstIndex(of: goalsArray.first(where: {$0.id == goal.id!})!)
                goal.priority = Int64(Int(marker!)+1)
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
            saveContext()
        
        

    }
    
    private func saveContext() {
      do {
        try managedObjectContext.save()
      } catch {
        self.showError = true
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
