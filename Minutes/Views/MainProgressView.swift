//
//  MainProgressView.swift
//  Minutes
//
//  Created by Jonathan Bown on 8/20/20.
//

import SwiftUI
import CoreData

struct MainProgressView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
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
        return AppUtil.filterCurrentGoals(goals: self.goalsArray, date: Date())
    }
    
    var goalsArray: [Goal] {
        return goals.sorted(by: {$0.priority < $1.priority})
    }
    
    @State private var showNewGoalForm: Bool = false
    @State private var goalFilterCriteria: String = "Today"
    @State private var goalAddSuccess: Bool = false
    @State var selection: Int?
    //List variables
    @State private var selectedItem: String?
    @State private var listViewId = UUID()
    
    
    
    private var cal = Calendar.current
    
    
    var body: some View {
        NavigationView{
            GeometryReader{geometry in
                VStack{
//                    Spacer(minLength: Constants.navigationBarHeight+20).frame(width: geometry.size.width, height: Constants.navigationBarHeight+40, alignment: .top)
                    HStack{
                        Text(AppUtil.getCurrentDate().uppercased())
                            .font(.headline)
                            .foregroundColor(.secondary).padding(.leading, 20)
                        Spacer()
                        
                    }
                    if(!goals.isEmpty){
                        NavigationLink(destination: OverallProgressView(dateProvided: Date())){
                            GroupBox{
                                HStack{
                                    DailyStatsView(goalList: self.goals)
                                    Spacer()
                                    ProgressRings(dateProvided: Date(), maxWidth: 120,
                                                  maxLineWidth: Constants.progressRingViewThicknessStandard, maxRingLimit: Constants.progressRingViewMaxRingLimitStandard, showClear: false).frame(width: Constants.progressRingViewFrameWidthStandard, height: Constants.progressRingViewFrameHeightStandard).aspectRatio(contentMode: .fit)
                                }

                            }.cornerRadius(15).padding()
                        }

                    }
                    VStack(alignment: .center){
                        if(goals.isEmpty){
                            
                                Text("Tap '+' to create a new minute goal!").font(.system(.title2, design: .rounded)).padding(.top, 10)
                            
                        }
                        else {
                            Picker("", selection: self.$goalFilterCriteria){
                                Text("Today").font(.system(.subheadline, design: .rounded)).tag("Today")
                                        Text("All").font(.system(.subheadline, design: .rounded)).tag("All")
                            }.pickerStyle(SegmentedPickerStyle()).padding()
                        }
                        //ScrollView{
                            if(self.goalFilterCriteria == "Today"){
                                List(filteredGoals) { goal in
                                    GroupBox{
                                        NavigationLink(destination: GoalDetailView(goal: goal), tag: "\(goal.id!)", selection: $selectedItem) {
                                            
                                            GoalRow(goal: goal)
                                        }
                                    }
                                            
                                        //Goal}
                                }.id(listViewId)
       
                            }
                            else {
                                List(goalsArray) { goal in
                                    GroupBox{
                                        NavigationLink(destination: GoalDetailView(goal: goal), tag: "\(goal.id!)", selection: $selectedItem) {
                                            
                                            GoalRow(goal: goal)
                                        }
                                    }
                                            
                                }.id(listViewId)
                            }
                       

                    }.padding()
                        
                    //}.padding()
                }.onAppear {
                    if selectedItem != nil {
                        selectedItem = nil
                        listViewId = UUID()
                    }
                }
                //self.createNavigationBar(geometry.size)
            
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                                        self.showNewGoalForm.toggle()
                                    }){
                                        Image(systemName: "plus.circle").resizable().font(Font.system(.title))
                                            .frame(width: 35, height: 35)
                                            .foregroundColor(Color.white)
                                            //.font(Font.system(size: 50, weight: .bold))
                                    }
            
            )
        .sheet(
                isPresented: self.$showNewGoalForm
            ) {
                
                GoalForm(editing: false, isPresented: self.$showNewGoalForm, success: self.$goalAddSuccess ).environment(\.managedObjectContext, self.managedObjectContext)
                
            }.navigationTitle("Summary").navigationBarTitleDisplayMode(.large)

        }.navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    func createNavigationBar(_ geometrySize: CGSize) -> some View {
        ZStack(alignment: .top) {
            //BlurView(style: .dark).edgesIgnoringSafeArea(.top)
            
                    HStack(alignment: .firstTextBaseline) {
                        
                        VStack(alignment: .leading) {
                            Text(AppUtil.getCurrentDate().uppercased())
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Summary")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                        }.padding()
                        Spacer()
                        Button(action: {
                            self.showNewGoalForm.toggle()
                        }){
                            Image(systemName: "plus.circle.fill").font(Font.system(size: 40, weight: .regular))
                        }.padding(10).popover(
                            isPresented: self.$showNewGoalForm
                        ) {
                            
                            GoalForm(editing: false, isPresented: self.$showNewGoalForm, success: self.$goalAddSuccess ).environment(\.managedObjectContext, self.managedObjectContext)
                            
                        }.padding()

                    }
        }
        .frame(width: geometrySize.width, height: Constants.navigationBarHeight, alignment: .top)

    }
    
    

}

#if DEBUG
struct MainProgressView_Previews: PreviewProvider {
    static var previews: some View {
        MainProgressView()
    }
}
#endif
