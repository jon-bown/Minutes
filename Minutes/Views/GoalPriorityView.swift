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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var goalListVM: GoalListViewModel
    @EnvironmentObject var goalRecordListVM: GoalRecordListViewModel
    
    @State private var showError: Bool = false
    @State private var isEditable = false
    @State private var refreshingID = UUID()
    
    var body: some View {
        
        List {
            ForEach(goalListVM.getGoalsArray(), id: \.id) { goal in
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
            
            for goal in goalsArray {
                let marker = goalsArray.firstIndex(of: goalListVM.goals.first(where: {$0.id == goal.id})!)
                goal.updatePriority(new: Int(marker!)+1)
            }
            
            
        }
        
    }
    
    func onDelete(at offsets: IndexSet) {
        
        for index in offsets {
            let goal = self.goalListVM.goals.sorted(by: {$0.priority < $1.priority})[index]
            DispatchQueue.main.async {
                
                var goalsArray = goalListVM.getGoalsArray()
                goalsArray.remove(at: index)
                goalListVM.deleteGoal(goal: goal)
                for goal in goalsArray {
                    let marker = goalsArray.firstIndex(of: goalListVM.goals.first(where: {$0.id == goal.id})!)
                    goal.updatePriority(new: Int(marker!)+1)
                }
            }
            
            
        }

        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
}

#if DEBUG
struct GoalPriorityView_Previews: PreviewProvider {
    static var previews: some View {
        GoalPriorityView()
    }
}
#endif
