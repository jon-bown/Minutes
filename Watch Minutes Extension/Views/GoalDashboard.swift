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
    
    @EnvironmentObject var goalListVM: GoalListViewModel
    @EnvironmentObject var goalRecordListVM: GoalRecordListViewModel

    
    var body: some View {
        //NavigationView{

        ScrollView{
            if(goalListVM.filterCurrentGoals().isEmpty){
                        VStack{
                            Text("No Goals Set").padding()
                            Text("Use your phone to set a goal!").padding()
                        }
                    }
                    else {
            VStack{
                //parameterize this to fit any watch screen
                ProgressRings(goalList: self.goalListVM.goals, goalRecordList: self.goalRecordListVM.goalRecords, dateProvided: Date(), maxWidth: 150, maxLineWidth: 15, maxRingLimit: 3).padding(10)
                Divider()
                Section(header: Text("Today").bold()){
                    ForEach(goalListVM.filterCurrentGoals(), id: \.id) { goal in
                        //NavigationLink(destination: GoalDetailView(goal: goal)) {
                        //For all goals of today, show a individual progress
                        HStack{
//                            NavigationLink(destination: EmptyView()){
//                                EmptyView()
//                            }
                            NavigationLink(destination: WKGoalDetailViewR(goal: goal)){
                                Text("\(goal.name)").foregroundColor(.white)
                                //Spacer()
                            }
                            
                        }.padding(.horizontal, 2).padding(.vertical, 2).cornerRadius(15)
                        
                    }
                }
                if(!goalListVM.filteredGoalsNotToday().isEmpty){
                    Section(header: Text("Other").bold()){
                        ForEach(goalListVM.filteredGoalsNotToday(), id: \.id) { goal in
                            HStack{
                                NavigationLink(destination: EmptyView()){
                                    EmptyView()
                                }
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
