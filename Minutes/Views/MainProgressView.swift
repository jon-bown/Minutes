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
        return goals.filter({(Date() > $0.startDate! ||  cal.isDate(Date(), inSameDayAs:$0.startDate!)) && ((Date().dayOfTheWeek == $0.weekDay && $0.frequency == "Weekly") || ($0.frequency == "Monthly" && $0.monthDay == Date().dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
    }
    
    @State private var showNewGoalForm: Bool = false
    @State private var goalFilterCriteria: String = "Today"
    @State private var goalAddSuccess: Bool = false
    private var cal = Calendar.current
    
    
    var body: some View {
        NavigationView{
            GeometryReader{geometry in
                VStack{
                    Spacer(minLength: Constants.navigationBarHeight+20).frame(width: geometry.size.width, height: Constants.navigationBarHeight+40, alignment: .top)
                    if(!goals.isEmpty){
                        NavigationLink(destination: OverallProgressView(dateProvided: Date())){
                            GroupBox{
                                HStack{
                                    DailyStatsView(goalList: self.goals)
                                    Spacer()
                                    ProgressRings(dateProvided: Date(), maxWidth: 120, maxLineWidth: 15, maxRingLimit: 3).frame(width: 150, height: 150).aspectRatio(contentMode: .fit)
                                }

                            }.cornerRadius(15).padding()
                        }

                    }
                    VStack(alignment: .center){
                        if(goals.isEmpty){
                            Text("Tap '+' to create a new minute goal!")
                        }
                        else {
                            Picker("", selection: self.$goalFilterCriteria){
                                Text("Today").font(.system(.subheadline, design: .rounded)).tag("Today")
                                        Text("All").font(.system(.subheadline, design: .rounded)).tag("All")
                            }.pickerStyle(SegmentedPickerStyle()).padding()
                        }

                                //DropDownMenu(selection: self.$goalFilterCriteria)
                        ScrollView{
                            if(self.goalFilterCriteria == "Today"){
                                ForEach(filteredGoals, id: \.self) { goal in
                                    NavigationLink(destination: GoalDetailView(goal: goal)){
                                        GroupBox{
                                            HStack{
                                                Text(goal.name!).font(.system(.title2, design: .rounded)).foregroundColor(Color.white)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                            }.font(.system(size: 24, design: .rounded)).padding(4).cornerRadius(15)

                                        }
                                            
                                       
                                        
                                    }
                                }
                            }
                            else {
                                ForEach(goals, id: \.self) { goal in
                                    NavigationLink(destination: GoalDetailView(goal: goal)){
                                        GroupBox{
                                            HStack{
                                                Text(goal.name!).font(.system(.title2, design: .rounded)).foregroundColor(Color.white)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                            }.font(.system(size: 24, design: .rounded)).padding(4).cornerRadius(8)

                                        }.cornerRadius(15)
                                            
                                       
                                        
                                    }
                                }
                            }
                        }
                       

                    }.padding()
                        
                    //}.padding()
                }
                self.createNavigationBar(geometry.size)
            }

        }
        
    }
    
    func createNavigationBar(_ geometrySize: CGSize) -> some View {
        ZStack(alignment: .top) {
            //BlurView(style: .dark).edgesIgnoringSafeArea(.top)
            
                    HStack(alignment: .firstTextBaseline) {
                        
                        VStack(alignment: .leading) {
                            Text(getCurrentDate().uppercased())
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
                            
                            GoalForm(editing: false, goal: Goal(), isPresented: self.$showNewGoalForm, success: self.$goalAddSuccess).environment(\.managedObjectContext, self.managedObjectContext)
                            
                        }.padding()

                    }
        }
        .frame(width: geometrySize.width, height: Constants.navigationBarHeight, alignment: .top).navigationBarHidden(true)

    }
    
    
   
    func getCurrentDate(with format: String = "EEEE, MMM d") -> String { let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
    }
}

#if DEBUG
struct MainProgressView_Previews: PreviewProvider {
    static var previews: some View {
        MainProgressView()
    }
}
#endif
