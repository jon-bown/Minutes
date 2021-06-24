//
//  GoalDashboard.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 1/17/21.
//

import SwiftUI
import CoreData

struct GoalDashboard: View {
    @Environment(\.scenePhase) var scenePhase
    
    private var cal = Calendar.current
    
    @StateObject private var goalListVM = GoalListViewModel()
    @StateObject private var goalRecordListVM = GoalRecordListViewModel()
    
    
    var filteredGoals: [GoalViewModel] {
        return self.goalListVM.filterCurrentGoals()
    }
    
    
    
    var filteredGoalsNotToday: [GoalViewModel] {
        //if no goals outside of today then return empty
        let filteredArray = goalListVM.goals.filter({!filteredGoals.contains($0)})
        
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
            if(filteredGoals.isEmpty){
                        VStack{
                            Text("No Goals Set").padding()
                            Text("Use your phone to set a goal!").padding()
                        }
                    }
                    else {
            VStack{
                //parameterize this to fit any watch screen
                ProgressRings(dateProvided: Date(), maxWidth: 150, maxLineWidth: 15, maxRingLimit: 3).padding(10)
                Divider()
                Section(header: Text("Today").bold()){
                    ForEach(filteredGoals, id: \.id) { goal in
                        //NavigationLink(destination: GoalDetailView(goal: goal)) {
                        //For all goals of today, show a individual progress
                        HStack{
                            NavigationLink(destination: WKGoalDetailViewR(goal: goal)){
                                Text("\(goal.name)").foregroundColor(.white)
                                //Spacer()
                            }
                            
                        }.padding(.horizontal, 5).padding(.vertical, 2).cornerRadius(15)
                        
                    }
                }
                if(!filteredGoalsNotToday.isEmpty){
                    Section(header: Text("Other").bold()){
                        ForEach(filteredGoalsNotToday, id: \.id) { goal in
                            HStack{
                                NavigationLink(destination: WKGoalDetailViewR(goal: goal)){
                                    Text("\(goal.name)").foregroundColor(.white)
                                    //Spacer()
                                }
                                
                            }.padding(.horizontal, 5).padding(.vertical, 2).cornerRadius(15)
                            
                        }
                    }
                }

                
                

                
            }.navigationTitle("Today").aspectRatio(contentMode: .fit)
            
        }
        }.onChange(of: scenePhase) { newPhase in
//            if newPhase == .inactive {
//                #if DEBUG
//                print("Inactive")
//                #endif
//                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
//
//                fetchRequest.includesPropertyValues = false
//
//                do {
//                    let items = try managedObjectContext.fetch(fetchRequest) as! [Goal]
//
//                } catch {
//                    // Error Handling
//                    // ...
//                    #if DEBUG
//                    print("error")
//                    #endif
//                }
//            } else if newPhase == .active {
//                #if DEBUG
//                print("Active")
//                #endif
//                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
//
//                fetchRequest.includesPropertyValues = false
//
//                do {
//                    let items = try managedObjectContext.fetch(fetchRequest) as! [Goal]
//
//
//                } catch {
//                    // Error Handling
//                    // ...
//                    #if DEBUG
//                    print("error")
//                    #endif
//                }
//            } else if newPhase == .background {
//                print("Background")
//                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
//
//                fetchRequest.includesPropertyValues = false
//
//                do {
//                    let items = try managedObjectContext.fetch(fetchRequest) as! [Goal]
//
//
//                } catch {
//                    // Error Handling
//                    // ...
//                    #if DEBUG
//                    print("error")
//                    #endif
//                }
//            }
        }
      //}
    }
}

struct GoalDashboard_Previews: PreviewProvider {
    static var previews: some View {
        GoalDashboard()
    }
}
