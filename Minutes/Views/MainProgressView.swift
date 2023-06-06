//
//  MainProgressView.swift
//  Minutes
//
//  Created by Jonathan Bown on 8/20/20.
//

import SwiftUI
import CoreData

struct MainProgressView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var goalListVM = GoalListViewModel.sharedInstance
    @StateObject private var goalRecordListVM = GoalRecordListViewModel.sharedInstance
        
    @State private var showNewGoalForm: Bool = false
    @State private var goalFilterCriteria: String = "Today"
    @State private var goalAddSuccess: Bool = false
    @State var selection: Int?
    //List variables
    @State private var selectedItem: String?
    @State private var listViewId = UUID()
    @State private var isDetailActive = false
    
    
    
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
                    if(!goalListVM.goals.isEmpty){
                        NavigationLink(destination: EmptyView()){
                            EmptyView()
                        }
                        NavigationLink(destination: OverallProgressView(dateProvided: Date())){
                            GroupBox{
                                HStack{
                                    DailyStatsView(goalList: self.goalListVM.goals)
                                    Spacer()
                                    ProgressRings(dateProvided: Date(), maxWidth: 135,
                                                  maxLineWidth: Constants.progressRingViewThicknessStandard, maxRingLimit: Constants.progressRingViewMaxRingLimitStandard, showClear: false).frame(width: Constants.progressRingViewFrameWidthStandard, height: Constants.progressRingViewFrameHeightStandard).aspectRatio(contentMode: .fit)
                                }

                            }.cornerRadius(15).padding()
                        }

                    }
                    VStack(alignment: .center){
                        if(goalListVM.goals.isEmpty){
                            
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
                                List(self.goalListVM.filterCurrentGoals()) { goal in
                                        GoalRow(goal: goal)
                                }.id(listViewId)
       
                            }
                            else {
                                List(goalListVM.getGoalsArray()) { goal in
                                 
                                        GoalRow(goal: goal)
                                                                             
                                }.id(listViewId)
                            }
                       

                    }.padding()
                        
                    //}.padding()
                }.onAppear {
                    if selectedItem != nil {
                        
                        listViewId = UUID()
                    }
                }
                
                //self.createNavigationBar(geometry.size)
            
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                                        
                                        self.showNewGoalForm = true
                                        
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
                
                GoalForm(editing: false, isPresented: self.$showNewGoalForm, success: self.$goalAddSuccess )
                
        }
            .navigationTitle("Summary").navigationBarTitleDisplayMode(.large)
            
//            .toolbar(content: {
//                ToolbarItem(placement: .navigationBarTrailing){
//                    Button(action: {
//                        self.showNewGoalForm = true
//                    }){
//                        Image(systemName: "plus.circle").resizable().font(Font.system(.title))
//                            .frame(width: 45, height: 45)
//                            .foregroundColor(Color.white)
//                            //.font(Font.system(size: 50, weight: .bold))
//                    }.disabled(false)
//                }
//            }).navigationTitle("Summary").navigationBarTitleDisplayMode(.large)

        }.navigationViewStyle(DefaultNavigationViewStyle())
        
    }
    
    
    func createNavigationBar(_ geometrySize: CGSize) -> some View {
        ZStack(alignment: .top) {
            
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
                            
                            GoalForm(editing: false, isPresented: self.$showNewGoalForm, success: self.$goalAddSuccess )
                            
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
