//
//  GoalDetailView.swift
//  Minutes
//
//  Created by Jonathan Bown on 9/15/20.
//

import SwiftUI

struct ProgressBar: View {
    var color: UIColor
    @Binding var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(color))
                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}

struct GoalDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goalRecords: FetchedResults<GoalRecord>
    
    @ObservedObject var goal: Goal
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State var timer: Timer? = nil
    @State var progress: Double = 0.0
    @State var dayTime: Double = 0.0
    @ObservedObject var stopWatch = StopWatch()
    @State private var showGoalEditForm: Bool = false
    @State private var showSaveButton: Bool = false
    @State private var goalUpdatedSuccess: Bool = false
    //Just check the list view model if the goal record exists
    
    var filteredGoalRecordsToday: [GoalRecord] {
        return self.goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!) && goal.name == $0.name})
    }
    
    var filteredGoalRecordsCurrentGoal: [GoalRecord] {
        return self.goalRecords.filter({goal.name == $0.name})
    }
    
    var body: some View {
        ScrollView{
            VStack{
                GroupBox{
                    HStack{
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text("Today").font(Font.system(size: 20, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                            (
                                Text(self.filteredGoalRecordsToday.isEmpty ? "0/\(Int(self.goal.goalTime))":"\(Int(self.filteredGoalRecordsToday[0].dayTime/60))/\(Int(self.goal.goalTime))")
                                    .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                                    .kerning(0.25)
                                    .foregroundColor(Color(goal.color!))
                                    + Text("MIN")
                                    .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                                    .kerning(0.3).foregroundColor(Color(goal.color!))
                            )
                            .padding([.top], -3).padding(.bottom, 2)
                            
                            Text("Streak").font(Font.system(size: 20, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                            (
                                Text(String(self.calculateCurrentStreak()))
                                    .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                                    .kerning(0.3).foregroundColor(Color(goal.color!))
                                
                            )
                            Text("Total Time")
                                .font(Font.system(size: 18, weight: .regular, design: .default))
                                .kerning(0.05)
                                .foregroundColor(Color.white)
                            (
                                Text("\(self.getHoursFromSeconds(seconds: self.goal.totalTime)):\(self.getMinutesFromSeconds(seconds: self.goal.totalTime)):\(self.getSecondsFromSeconds(seconds: self.goal.totalTime))")
                                    .font(Font.system(size: 20, weight: .regular, design: .rounded))
                                    .kerning(0.25)
                                    .foregroundColor(Color(goal.color!))
                            )
                            .padding([.top], -3)
                            
                            
                        }
                        Spacer()
                        
                        ZStack(alignment: .center){
                            ProgressRingView(progress: self.progress, thickness: 20, startColor: Color(self.goal.color!.darker(by: 10.0)!), endColor: Color(self.goal.color!.lighter(by: 15)!), backgroundColor: self.goal.color!).frame(width: 175, height: 175).aspectRatio(contentMode: .fit).animatableProgressText(progress: progress)
                        }
                        
                        
                    }.padding(2)
                }.cornerRadius(15).padding()
                
                
                
                Divider().background(Color.white).padding(.leading, 10)
                //Align text properly
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 30) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Started").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                            (
                                Text(String(self.goal.startDate!.mediumDate))
                                    .font(Font.system(size: 25, weight: .regular, design: .rounded))
                                    .kerning(0.25)
                                    .foregroundColor(Color(goal.color!)).lineLimit(1)
                                
                            )
                            .padding([.top], -3)
                        }.padding(.leading, 3)
                        Spacer()
                        
                        
                        if(self.goal.endDate != nil){
                            VStack(alignment: .leading, spacing: 0) {
                                Text("End Date").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                                (
                                    Text(String(self.goal.endDate!.mediumDate))
                                        .font(Font.system(size: 25, weight: .regular, design: .rounded))
                                        .kerning(0.25)
                                        .foregroundColor(Color(goal.color!)).lineLimit(1)
                                    
                                )
                                .padding([.top], -3)
                            }
                        }
                        
                        
                    }.padding(.vertical, 10)
                    
                    Divider().background(Color.white)
                    
                    
                }.padding([.leading], 15)
            }
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 90).padding()
                .foregroundColor(Color(UIColor.black.lighter(by: 20.0)!)).animatableStopWatchText(watchTime: self.stopWatch.stopWatchTime)
            
            
            HStack{
                Spacer()
                StopWatchButton(actions: [self.stopWatch.reset, self.stopWatch.reset, self.resetProgress],
                                labels: ["Reset", "Reset"],
                                color: Color.red,
                                isPaused: self.stopWatch.isPaused(), playPause: false)
                Spacer()
                Button(action: {
                    if(!self.stopWatch.isRunning){
                        self.updateGoalRecord()
                    }
                }){
                    if(!self.stopWatch.isRunning){
                        Text("Save")
                    }
                    else {
                        Text("Save").opacity(0.5)
                    }
                    
                }.buttonStyle(CircleStopWatchSaveStyle()).disabled(self.stopWatch.isRunning)
                Spacer()
                StopWatchButton(actions: [self.stopWatch.start, self.stopWatch.pause, self.startLoading],
                                labels: ["Start", "Pause"],
                                color: Color.blue,
                                isPaused: self.stopWatch.isPaused(), playPause: true)
                Spacer()
                
            }.padding()
            
            VStack{
                
                
                
                //TODO: Add ability to just log minutes directly and display it as a list
                //List laps completed in the goal today
                
                
                //For each goal record display time completed and timestamp
                
                //option to delete
                
                
            }.navigationBarTitle(Text(goal.name!), displayMode: .automatic).navigationBarItems(
                //                    leading: Button(action: {
                //                    self.presentationMode.wrappedValue.dismiss()
                //                }){
                //                    Image(systemName: "x.circle").font(Font.system(size: 30, weight: .regular)).foregroundColor(.white)
                //                },
                trailing: Button(action: {
                    self.showGoalEditForm.toggle()
                }){
                    Text("Edit").font(Font.system(size: 15, weight: .regular))
                }.popover(
                    isPresented: self.$showGoalEditForm,
                    arrowEdge: .bottom
                ) {
                    
                    GoalForm(editing: true, goal: self.goal, isPresented: self.$showGoalEditForm, success: self.$goalUpdatedSuccess).environment(\.managedObjectContext, managedObjectContext)
                    //NewGoalForm(isPresented: self.$showNewGoalForm)
                    
                })
            
        }.onAppear { self.updateProgress()}.toast(isShowing: self.$goalUpdatedSuccess, text: Text("Saved"))
        
        
    }
    
    //MARK: - HELPER METHODS
    
    //Calculates the current streak the user is on
    private func calculateCurrentStreak() -> Int {
        if(filteredGoalRecordsCurrentGoal.count == 0){
            return 0
        }
        else {
            var count = 0
            //most recent goal record where progress of greater than 1 was achieved
            guard let first = filteredGoalRecordsCurrentGoal.sorted(by: {$0.date! > $1.date!}).first(where: {$0.progress >= 1}) else {
                //no streaks possible
                return 0
            }
            if(Calendar.current.isDate(Date(), inSameDayAs:first.date!)){
                return 1
            }
            else if(Calendar.current.isDateInYesterday(first.date!)){
                let completedGoals = goalRecords.sorted(by: {$0.date! > $1.date! && $0.name == self.goal.name!}).filter({$0.progress >= 1})
                var tempDate = first.date!
                for record in completedGoals {
                    let diffComponents = Calendar.current.dateComponents([.hour], from: record.date!, to: tempDate)
                    if let hours = diffComponents.hour {
                        if(hours <= 24){
                            count+=1
                        }
                        else {
                            return count
                        }
                        tempDate = record.date!
                    }
                    else{
                        print("Error with counting hours between dates")
                    }
                }
                return count
            }
            else {
                //you are not on a streak
                return 0
            }
            
        }
    }
    
    private func calculateBestStreak() -> Int {
        
        return 0
    }
    
    //Save the current time into the proper goal entity
    private func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Error saving managed object context: \(error)")
            }
        }
    }
    
    
    func updateGoalRecord() {
        let records = self.goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs: $0.date!) && $0.name == goal.name})
        
        //Add date to array of records for the goal record
        
        if(records.isEmpty){
            
            let newGoalRecord = GoalRecord(context: managedObjectContext)
            newGoalRecord.name = self.goal.name!
            newGoalRecord.date = Date()
            newGoalRecord.progress = self.progress
            newGoalRecord.id = self.goal.id!
            
            newGoalRecord.dayTime = Double(self.stopWatch.seconds)
            self.goal.totalTime += Double(self.stopWatch.seconds)
            //divide hours into four quadrants
            var hour = Calendar.current.component(.hour, from: Date())*4
            let minute = Calendar.current.component(.minute, from: Date())
            var quadrant = 0
            if(minute == 0){
                quadrant = 0
            }
            else if(minute > 0 && minute < 15) {
                quadrant = 1
            }
            else if(minute >= 15 && minute < 30){
                quadrant = 2
            }
            else if(minute >= 30 && minute < 45){
                quadrant = 3
            }
            else {
                quadrant = 4
            }
            let minutes = (newGoalRecord.progress * 60).truncatingRemainder(dividingBy: 60)
            var entry = [Int:Double]()
            hour = hour + quadrant
            entry[hour] = Double(minutes)
            newGoalRecord.goalUpdates = entry
            //add entry with hour: minutes
            //newGoal.color = UIColor(goalCol)
            //newGoal.cumTime = 0.0
            //newGoal.dayTime = 0.0
            //newGoal.goalTime = Double(self.goalDailyTime)
            //newGoal.frequency = ""
            //newGoal.id = UUID()
            saveContext()
        }
        
        else {
            //add entry with hour: minutes
            records[0].progress = self.progress
            records[0].dayTime += Double(self.stopWatch.seconds)
            
            
            var hour = Calendar.current.component(.hour, from: Date())*4
            let minute = Calendar.current.component(.minute, from: Date())
            var quadrant = 0
            if(minute == 0){
                quadrant = 0
            }
            else if(minute > 0 && minute < 15) {
                quadrant = 1
            }
            else if(minute >= 15 && minute < 30){
                quadrant = 2
            }
            else if(minute >= 30 && minute < 45){
                quadrant = 3
            }
            else {
                quadrant = 4
            }
            let minutes = (records[0].progress * 60).truncatingRemainder(dividingBy: 60)
            hour = hour + quadrant
            
            let keyExists = records[0].goalUpdates![hour] != nil
            if(keyExists){
                records[0].goalUpdates![hour] = records[0].goalUpdates![hour]! + Double(minutes)
            }
            else{
                records[0].goalUpdates![hour] = Double(minutes)
            }
            
        
            
            self.goal.totalTime += Double(self.stopWatch.seconds)
            saveContext()
            
            
        }
        
        
    }
    
    func updateProgress() {
        let records = self.goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs: $0.date!) && $0.name == goal.name})
        if(!records.isEmpty){
            self.dayTime = records[0].dayTime
            self.progress = records[0].progress
        }
        else{
            self.dayTime = 0.0
            self.progress = 0.0
        }
        
    }
    
    func startLoading() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation() {
                self.progress = (Double(self.stopWatch.seconds) + self.dayTime)/(self.goal.goalTime*60)
                //                if self.stopWatch.seconds >= Float(self.goal.goalTime*60) {
                //                    timer.invalidate()
                //                }
            }
        }
    }
    
    func resetProgress() {
        _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
            withAnimation() {
                self.timer?.invalidate()
            }
        }
        
    }
    
    private func getHoursFromSeconds(seconds: Double) -> String {
        let hours = Int(seconds/3600)
        if(String(hours).count == 1){
            return "0\(hours)"
        }
        else {
            return "\(hours)"
        }
    }
    
    private func getMinutesFromSeconds(seconds: Double) -> String {
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600))/60)
        if(String(minutes).count == 1){
            return "0\(minutes)"
        }
        else {
            return "\(minutes)"
        }
    }
    
    private func getSecondsFromSeconds(seconds: Double) -> String {
        let sec = seconds.truncatingRemainder(dividingBy: 3600)
        let remSec = Int(sec.truncatingRemainder(dividingBy: 60))
        if(String(remSec).count == 1){
            return "0\(remSec)"
        }
        else {
            return "\(remSec)"
        }
        
    }
}


//Modifier for the progress text to look smooth in the goal detail view
struct ProgressTextModifier: AnimatableModifier {
    var progress: Double = 0.0
    var textColor: Color = .primary
    private var progressText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.percentSymbol = "%"
        return formatter.string(from: NSNumber(value: progress)) ?? "" }
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    func body(content: Content) -> some View {
        content
            .overlay(
                Text(progressText).font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                    .animation(nil)
            ) }
}


//Modifier for the progress text to look smooth in the goal detail view
struct StopWatchTextModifier: AnimatableModifier {
    var watchTime: String = ""
    var textColor: Color = .primary
    var animatableData: String {
        get { watchTime }
        set { watchTime = newValue }
    }
    func body(content: Content) -> some View {
        content
            .overlay(
                HStack{
                    Text(watchTime.components(separatedBy: ":")[0]).font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 50, height: 50, alignment: .center)
                    Text(":").font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 10, height: 50, alignment: .center)
                    Text(watchTime.components(separatedBy: ":")[1]).font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 50, height: 50, alignment: .center)
                    Text(":").font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 10, height: 50, alignment: .center)
                    Text(watchTime.components(separatedBy: ":")[2]).font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 50, height: 50, alignment: .center)
                }.frame(width: 400, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .center)
                
            ) }
}

extension View {
    func animatableProgressText(progress: Double, textColor: Color = Color.primary)
    -> some View {
        self.modifier(ProgressTextModifier(progress: progress, textColor: textColor)) }
    
    func animatableStopWatchText(watchTime: String, textColor: Color = Color.primary)
    -> some View {
        self.modifier(StopWatchTextModifier(watchTime: watchTime, textColor: textColor)) }
}



//struct GoalDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        var goal = 
//        return GoalDetailView()
//    }
//}

