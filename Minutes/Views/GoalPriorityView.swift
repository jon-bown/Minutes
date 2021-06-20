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
    
    @StateObject private var goalListVM = GoalListViewModel()
    @StateObject private var goalRecordListVM = GoalRecordListViewModel()
    
    @State private var showError: Bool = false
    @State private var isEditable = false
    @State private var refreshingID = UUID()
    
    var body: some View {
            
            List {
                ForEach(goalListVM.getGoalsArray(), id: \.priority) { goal in
                    GroupBox{
                        HStack{
                            Text(goal.name)
                            Spacer()
                            Text("\(goal.priority)")
                        }
                    }
                    
                }
                .onMove(perform: onMove).onDelete(perform: onDelete).id(self.refreshingID)
            }
            .alert(isPresented: self.$showError) {
                return Alert(title: Text("Error Saving Goal"), message: Text("Try again!"), dismissButton: .default(Text("Ok")))
                
            }
            .environment(\.editMode, isEditable ? .constant(.active) : .constant(.inactive)).padding().toolbar{
            ToolbarItem(placement: .primaryAction) {
                Button(self.isEditable ? "Done":"Edit"){
                    self.isEditable.toggle()
                }
            }
        }.navigationBarTitleDisplayMode(.inline)
        
    }
    
    //Moves the priorities and the goal items
    func onMove(from source: IndexSet, to destination: Int) {
        
        for index in source {
            if(index == destination){
                return
            }
            let sourceGoal = goalListVM.getGoalsArray().first(where: {$0.priority == (index+1)})!
            
            
            var goalsArray = goalListVM.getGoalsArray()
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
            
            for goal in goalListVM.getGoalsArray() {
                let marker = goalListVM.goals.firstIndex(of: goalListVM.goals.first(where: {$0.id == goal.id})!)
                goal.updatePriority(new: Int(marker!)+1) 
            }
            
            
        }
        
        DispatchQueue.main.async {
            CoreDataManager.shared.saveContext()
        }
        
        //        withAnimation {
        //            isEditable = false
        //        }
    }
    
    func onDelete(at offsets: IndexSet) {
        
        for index in offsets {
            let goal = self.goalListVM.getGoalsArray().first(where: {$0.id == goalListVM.goals[index].id})!
            
            if(!self.goalRecordListVM.goalRecords.isEmpty){
                let goalRecords = self.goalRecordListVM.goalRecords.filter({$0.id == goalListVM.goals[index].id})
                for record in goalRecords {
                    goalRecordListVM.deleteGoalRecord(record: record)
                    
                }
            }
            let priorityMark = goal.priority
            goalListVM.deleteGoal(goal: goal)
            //managedObjectContext.reset()
            for goal in goalListVM.getGoalsArray() {
                if(goal.priority > priorityMark){
                    goalListVM.goals[goalListVM.goals.firstIndex(where: {goal.id == $0.id})!].priority = goal.priority - 1
                }
            }
            
            
            
        }
        CoreDataManager.shared.saveContext()
        
        
        
    }
    
}

#if DEBUG
struct GoalPriorityView_Previews: PreviewProvider {
    static var previews: some View {
        GoalPriorityView()
    }
}
#endif
