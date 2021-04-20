//
//  GoalDetailView.swift
//  Minutes
//
//  Created by Jonathan Bown on 9/15/20.
//

import SwiftUI
import WidgetKit

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
    @State private var showCustomMinuteSheet: Bool = false
    @State private var newSessionText: String = ""
    @State private var isSessionsEditable: Bool = false
    @State private var sessionsToRemove: [Date] = [Date]()
    @State private var remindersOnText: String = "Off"
    @State private var reminderTimeText: String = ""
    
    //Just check the list view model if the goal record exists
    var goalRecordsArray: [GoalRecord] {
        return goalRecords.sorted(by: {$0.date! > $1.date!})
    }
    
    
    var filteredCurrentGoalRecordsToday: [GoalRecord] {
        return AppUtil.filterGoalRecordsTodayByName(goalRecords: self.goalRecordsArray, goalName: self.goal.name!)
    }
    
    var filteredGoalRecordsCurrentGoal: [GoalRecord] {
        return AppUtil.filterGoalRecordsByGoal(goalRecords: self.goalRecordsArray, goalName: self.goal.name!)
    }
    
    //Extract dictionary used to display todays sessions
    var filteredGoalRecordsSavesToday: [Date: Double] {
        return AppUtil.filterGoalRecordSavesTodayByName(goalRecords: self.goalRecordsArray, goalName: self.goal.name!)
        
    }
    

    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            
            self.createProgressBox()
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 90).padding()
                .foregroundColor(Color(UIColor.black.lighter(by: 20.0)!)).animatableStopWatchText(watchTime: self.stopWatch.stopWatchTime)
            
            
            HStack{
                Spacer()
                StopWatchButton(actions: [self.stopWatch.reset, self.stopWatch.reset, self.resetTimer],
                                labels: ["Reset", "Reset"],
                                color: Color.red,
                                isPaused: self.stopWatch.isPaused(), playPause: false)
                Spacer()
                Button(action: {
                    if(!self.stopWatch.isRunning){
                        self.resetTimer()
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
                StopWatchButton(actions: [self.stopWatch.start, self.stopWatch.stop, self.startLoading],
                                labels: ["Start", "Pause"],
                                color: Color.blue,
                                isPaused: self.stopWatch.isPaused(), playPause: true)
                Spacer()
                
            }.padding()
            
            VStack{
                
                

                GroupBox(label: GroupBoxLabelButton(label: "Sessions", isEditable: self.$isSessionsEditable, action: self.makeListEditable)){
                    
                    //list of all goal updates today
                    
                        
                        ForEach(self.filteredGoalRecordsSavesToday.sorted(by: >), id: \.key){
                            key, value in

                                //Divider()
                            GroupBox{
                                HStack{
                                    if(self.isSessionsEditable){
                                        CheckListButton(dateKey: key, listOfSessions: self.$sessionsToRemove)
                                    }
                                    Text(key.shortTime)
                                    Spacer()
                                    Text(AppUtil.getTotalTimeString(seconds: value))
                                }
                            }

                            

                        }
                        
                    Divider().frame(height: 2).background(Color.white)
                        
                        HStack{
                            Spacer()
                            Button(action: {
                                if self.isSessionsEditable {
                                    //delete the sessions
                                    
                                    if(!self.sessionsToRemove.isEmpty){
                                        self.deleteGoalRecordSessions()
                                    }
                                    
                                    self.isSessionsEditable = false
                                }
                                else {
                                    self.addCustomMinutes()
                                }
                                
                            }){
                                if(!self.isSessionsEditable){
                                    Image(systemName: "plus").font(.system(size: 25, weight: .bold))
                                        //.frame(width: 100, height: 40).background(Color.gray).cornerRadius(15)
                                }
                                else {
                                    Image(systemName: "trash").font(.system(size: 20)).foregroundColor(.red)
                                }
                                
                            }.buttonStyle(CircleStopWatchSaveStyle())
                            Spacer()
                            
                        }.padding()


                }.padding()
                .background(Color.blue)
//                if $showCustomMinuteSheet.wrappedValue {
//                          ZStack() {
//                            Color.blue
//                              VStack {
//                                TextField("Test", text: self.$newSessionText)
//                                HStack{
//                                    //save and cancel button
//                                    Button(action: {
//                                        //Save and add to list
//                                        self.showCustomMinuteSheet = false
//
//                                    }){
//                                        Text("Save")
//                                    }
//
//                                    Button(action: {
//                                        self.showCustomMinuteSheet = false
//                                    }){
//                                        Text("Cancel")
//                                    }
//                                }
//
//                              }.padding()
//                          }
//                          .frame(width: 300, height: 80,alignment: .center)
//                          .cornerRadius(20).shadow(radius: 20)
//                      }
                
//                .popover(isPresented: self.$showCustomMinuteSheet) {
//                    GroupBox{
//                        Text("Testing")
//                    }
//                }
//                .padding()
 //               .background(Color.blue)
                
                
                //TODO: Add ability to just log minutes directly and display it as a list
                //List laps completed in the goal today
                
                
                //For each goal record display time completed and timestamp
                
                //option to delete
                
                
            }
            self.createStreakInfoTile().padding([.leading, .trailing], 15)
            self.createTotalTimeInfoTile().padding([.leading, .trailing], 15)
            self.createFrequencyInfoTile().padding([.leading, .trailing], 15)
            //if(checkNotificationsExist(id: self.goal.id!)){
            self.createReminderInfoTile().padding([.leading, .trailing], 15)
            //}
            self.createDateInfoTile().padding([.leading], 15).navigationBarTitle(Text(goal.name!), displayMode: .automatic).navigationBarItems(
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
                    
                    GoalForm(editing: true, passedGoal: self.goal, isPresented: self.$showGoalEditForm, success: self.$goalUpdatedSuccess).environment(\.managedObjectContext, managedObjectContext)
                    //NewGoalForm(isPresented: self.$showNewGoalForm)
                    
                })
            
        }.onChange(of: self.showGoalEditForm) { newValue in
            if(!newValue) {
                print("changing")
                print(self.remindersOnText)
                    self.checkNotificationsExist(id: self.goal.id!)
                
                print(self.remindersOnText)
                
            }
 
            
            
        }.onAppear { self.updateProgress()
            self.checkNotificationsExist(id: self.goal.id!)
        }.toast(isShowing: self.$goalUpdatedSuccess, text: Text("Saved")).textFieldAlert(isShowing: self.$showCustomMinuteSheet, text: self.$newSessionText, title: "Add Minutes", saveAction: self.saveCustomMinuteSession)
        
        
    }
    
    //MARK: - SUB VIEWS
    private func createDateInfoTile() -> some View {
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
            
            Divider().background(Color.white).padding(.horizontal, 2)
            
        }
    }
    
    //MARK: - SUB VIEWS
    private func createFrequencyInfoTile() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Frequency").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                    (
                        Text(String(self.goal.frequency!))
                            .font(Font.system(size: 25, weight: .regular, design: .rounded))
                            .kerning(0.25)
                            .foregroundColor(Color(goal.color!)).lineLimit(1)
                        
                    )
                    .padding([.top], -3)
                }.padding(.leading, 3)
                Spacer()
                
                
                if(self.goal.frequency! == "Weekly"){
                    VStack(alignment: .leading, spacing: 0) {
                        Text("On Days:").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                        (
                            Text(AppUtil.createWeekDaysString(days: self.goal.weekDay!))
                                .font(Font.system(size: 20, weight: .regular, design: .rounded))
                                .kerning(0.25)
                                .foregroundColor(Color(goal.color!)).lineLimit(2)
                            
                        )
                        .padding([.top], -3)
                    }.padding(.trailing,8)
                }
                else if(self.goal.frequency! == "Monthly"){
                    VStack(alignment: .leading, spacing: 0) {
                        Text("On Day:").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                        (
                            Text(String(self.goal.monthDay))
                                .font(Font.system(size: 25, weight: .regular, design: .rounded))
                                .kerning(0.25)
                                .foregroundColor(Color(goal.color!)).lineLimit(1)
                            
                        )
                        .padding([.top], -3)
                    }
                }
                
                
            }.padding(.vertical, 10)
            
            Divider().background(Color.white).padding(.horizontal, 2)
            
        }
    }
    
    
    
    //MARK: - SUB VIEWS
    private func createStreakInfoTile() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Current Streak").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                    (
                        Text(String(self.calculateCurrentStreak()))
                            .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                            .kerning(0.25).foregroundColor(Color(goal.color!))
                        
                    )
                    .padding([.top], -3)
                }.padding(.leading, 3)
//                Spacer()
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Best Streak").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                    (
                        Text(String(self.calculateBestStreak()))
                            .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                            .kerning(0.25)
                            .foregroundColor(Color(goal.color!)).lineLimit(1)
                        
                    )
                    .padding([.top], -3)
                }
                
                
            }.padding(.vertical, 10)
            
            Divider().background(Color.white).padding(.horizontal, 2)
            
        }
    }
    
    private func createTotalTimeInfoTile() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Total Time").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                    (
                        Text(AppUtil.getTotalTimeString(seconds: self.goal.totalTime))
                            .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                            .kerning(0.25)
                            .foregroundColor(Color(goal.color!))
                        
                    )
                    .padding([.top], -3)
                }.padding(.leading, 3)
                //Spacer()
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("This Week").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                    (
                        Text(AppUtil.calculateTimeThisWeek(goalRecords: self.filteredGoalRecordsCurrentGoal))
                            .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                            .kerning(0.25)
                            .foregroundColor(Color(goal.color!)).lineLimit(1)
                        
                    )
                    .padding([.top], -3)
                }.padding(.leading, 3)
                
                
            }.padding(.vertical, 10)
            
            Divider().background(Color.white).padding(.horizontal, 2)
            
        }
    }
    
    private func createReminderInfoTile() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Reminders").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                    (
                        Text(self.remindersOnText)
                            .font(Font.system(size: 25, weight: .regular, design: .rounded))
                            .kerning(0.25)
                            .foregroundColor(Color(goal.color!))
                        
                    )
                    .padding([.top], -3)
                }.padding(.leading, 3)
                //Spacer()
                
                if(self.remindersOnText == "On"){
                    VStack(alignment: .leading, spacing: 0) {
                        Text("At").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                        (
                            Text(self.reminderTimeText)
                                .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                                .kerning(0.25)
                                .foregroundColor(Color(goal.color!)).lineLimit(1)
                            
                        )
                        .padding([.top], -3)
                    }
                }
   
                
                
            }.padding(.vertical, 10)
            
            Divider().background(Color.white).padding(.horizontal, 2)
            
        }
    }
    

    
    private func createProgressBox() -> some View {
        VStack{
            GroupBox{
                HStack{
                    VStack(alignment: .leading, spacing: 2) {
                        
                        Text("Today").font(Font.system(size: 20, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                        (
                            Text(self.filteredCurrentGoalRecordsToday.isEmpty ? "0/\(Int(self.goal.goalTime))":"\(Int(self.filteredCurrentGoalRecordsToday[0].dayTime/60))/\(Int(self.goal.goalTime))")
                                .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                                .kerning(0.25)
                                //TODO: Must fix this
                                .foregroundColor(Color(goal.color!))
                                + Text("MIN")
                                .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                                .kerning(0.3).foregroundColor(Color(goal.color!))
                        )
                        .padding([.top], -3).padding(.bottom, 3)
                        
                    }.padding(.leading, 10)
                    Spacer()
                    
                    ZStack(alignment: .center){
                        ProgressRingView(progress: self.progress, thickness: 20, startColor: Color(self.goal.color!.darker(by: 10.0)!), endColor: Color(self.goal.color!.lighter(by: 15)!), backgroundColor: self.goal.color!).frame(width: 175, height: 175).aspectRatio(contentMode: .fit).animatableProgressText(progress: progress)
                    }
                    
                    
                }.padding(2)
            }.cornerRadius(15).padding()
            

        }
    }
    
    //create tile for total time
    
    //create tile for both streaks

    
    //MARK: - HELPER METHODS
    
    func checkNotificationsExist(id: UUID) {
        
         var finalString = ""
            self.getPendingRequests(id: id) { (hour, minute) in

                if let hr = hour {
                    if let min = minute {
                        var fullHour = ""
                        var fullMinute = ""
                        if(hr < 10) {
                            fullHour = "0\(String(describing: hr))"
                        }
                        else {
                            fullHour = "\(String(describing: hr))"
                        }
                        if(min < 10){
                            fullMinute = "0\(String(describing: min))"
                        }
                        else {
                            fullMinute = "\(String(describing: min))"
                        }
                        finalString = "\(fullHour):\(fullMinute)"
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm"

                        let date = dateFormatter.date(from: finalString)
                        dateFormatter.dateFormat = "h:mm a"
                        finalString = dateFormatter.string(from: date!)
                        
                        if(finalString == ""){
                            self.remindersOnText = "Off"
                        }
                        else {
                            self.remindersOnText = "On"
                            self.reminderTimeText = finalString
                        }
                    }
                }
                else {
                    if(finalString == ""){
                        self.remindersOnText = "Off"
                    }
                    else {
                        self.remindersOnText = "On"
                        self.reminderTimeText = finalString
                    }
                }
                

            }

     }
    
    func getPendingRequests(id: UUID, completion:@escaping (Int?, Int?)->Void){
        
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        
        queue.async(group: group) {
            group.enter()
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
            for notification:UNNotificationRequest in notificationRequests {
                if notification.identifier == id.uuidString {
                    guard let trigger = notification.trigger as? UNCalendarNotificationTrigger else {
                        completion(nil, nil)
                        return
                    }
                    let nextTriggerDate = trigger.nextTriggerDate()!
                    //get date components
                    let components = Calendar.current.dateComponents([.hour, .minute], from: nextTriggerDate)
                    if let hour = components.hour {
                        if let minute = components.minute {
                            completion(hour, minute)
                            return
                        }
                    }

                }
            }
            completion(nil, nil)
        }
            group.leave()
        }
        
        
        }
//
//    private func checkNotificationsExist(id: UUID) -> Bool {
//        var exist = false
//        //Check if any notifications exist, if they do set reminders to true
//        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
//            for notification:UNNotificationRequest in notificationRequests {
//                if notification.identifier == id.uuidString {
//
//                    exist = true
//                    return
//                }
//            }
//        }
//        return exist
//        //self.reminders = checkNotificationsExist(id: id)
//
//    }
    
    private func addCustomMinutes() {
        self.showCustomMinuteSheet = true
    }
    
    private func makeListEditable() -> Bool {
        self.isSessionsEditable.toggle()
        return self.isSessionsEditable
    }
    
    private func deleteGoalRecordSessions() {
        // remove the goalrecord from goal saves
        
        //remove the goalrecord from goal updates
        let record = self.goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs: $0.date!) && $0.name == goal.name}).first
        for key in self.sessionsToRemove {
            // the date
            let timeToRemove = self.filteredGoalRecordsSavesToday[key]

            
            record!.dayTime -= timeToRemove!
            self.goal.totalTime -= timeToRemove!
            record!.goalSaves!.removeValue(forKey: key)
            record!.goalUpdates!.removeValue(forKey: key.minuteQuadrant)

        }
        self.sessionsToRemove.removeAll()
        self.recalculateDayTime()
        self.recalculateProgress()
        record!.progress = self.progress
        
        self.saveContext()
    }
    
    private func saveCustomMinuteSession(){
        let records = self.goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs: $0.date!) && $0.name == goal.name})
        guard let customMinutes = Int(self.newSessionText)
        else {
            return
            //error
        }
        let customSeconds = Double(customMinutes) * 60.0
        //Add date to array of records for the goal record
        
        if(records.isEmpty){
            
            let newGoalRecord = GoalRecord(context: managedObjectContext)
            newGoalRecord.name = self.goal.name!
            newGoalRecord.date = Date()
            self.progress = customSeconds/(self.goal.goalTime*60)
            newGoalRecord.progress = self.progress
            newGoalRecord.id = self.goal.id!
            
            newGoalRecord.dayTime = customSeconds
            self.goal.totalTime += customSeconds
            //divide hours into four quadrants
            var hour = Calendar.current.component(.hour, from: Date())*4
            let minutes = (newGoalRecord.progress * 60).truncatingRemainder(dividingBy: 60)
            var entry = [Int:Double]()
            hour = hour + Date().minuteQuadrant
            entry[hour] = Double(minutes)
            newGoalRecord.goalUpdates = entry
            
            //SAVES
            var save = [Date:Double]()
            save[Date()] = customSeconds
            newGoalRecord.goalSaves = save
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
            records[0].dayTime += customSeconds
            self.progress = records[0].dayTime/(self.goal.goalTime*60)
            records[0].progress = self.progress
            
            
            
            var hour = Calendar.current.component(.hour, from: Date())*4
            let minutes = (records[0].progress * 60).truncatingRemainder(dividingBy: 60)
            hour = hour + Date().minuteQuadrant
            
            let keyExists = records[0].goalUpdates![hour] != nil
            if(keyExists){
                records[0].goalUpdates![hour] = (records[0].goalUpdates![hour]! + Double(minutes)).truncatingRemainder(dividingBy: 60)
            }
            else{
                records[0].goalUpdates![hour] = Double(minutes)
            }
            //Goal Saves
            let dateKey = Date()
            let saveKeyExists = records[0].goalSaves![dateKey] != nil
            if(saveKeyExists){
                records[0].goalSaves![dateKey] = (records[0].goalSaves![dateKey]! + customSeconds)
            }
            else{
                records[0].goalSaves![dateKey] = customSeconds
            }
            
            
        
            
            self.goal.totalTime += customSeconds
            saveContext()
            
            
        }
        
    }
    //Calculates the current streak the user is on
    private func calculateCurrentStreak() -> Int {
        return AppUtil.calculateGoalCurrentStreak(records: filteredGoalRecordsCurrentGoal, goalName: self.goal.name!)
    }
    
    private func calculateBestStreak() -> Int {
        return AppUtil.calculateGoalBestStreak(goalName: self.goal.name!)
    }
    
    //Save the current time into the proper goal entity
    private func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                #if DEBUG
                print("Error saving managed object context: \(error)")
                #endif
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
            
            newGoalRecord.dayTime = Double(self.stopWatch.totalAccumulatedTime.seconds())
            self.goal.totalTime += Double(self.stopWatch.totalAccumulatedTime.seconds())
            //divide hours into four quadrants
            var hour = Calendar.current.component(.hour, from: Date())*4
            let minutes = (newGoalRecord.progress * 60.0).truncatingRemainder(dividingBy: 60)
            var entry = [Int:Double]()
            hour = hour + Date().minuteQuadrant
            entry[hour] = Double(minutes)
            newGoalRecord.goalUpdates = entry
            print("Progress: \(newGoalRecord.progress)")
            print("Minutes:\(minutes)")
            //SAVES
            var save = [Date:Double]()
            save[Date()] = Double(self.stopWatch.totalAccumulatedTime.seconds())
            newGoalRecord.goalSaves = save
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
            records[0].dayTime += Double(self.stopWatch.totalAccumulatedTime.seconds())
            
            
            var hour = Calendar.current.component(.hour, from: Date())*4
            let minutes = (records[0].progress * 59.0).truncatingRemainder(dividingBy: 60)
            hour = hour + Date().minuteQuadrant
            print("Progress: \(records[0].progress)")
            print("Minutes:\(minutes)")
            let keyExists = records[0].goalUpdates![hour] != nil
            if(keyExists){
                records[0].goalUpdates![hour] = (records[0].goalUpdates![hour]! + Double(minutes)).truncatingRemainder(dividingBy: 60)
            }
            else{
                records[0].goalUpdates![hour] = Double(minutes)
            }
            //Goal Saves
            let dateKey = Date()
            let saveKeyExists = records[0].goalSaves![dateKey] != nil
            if(saveKeyExists){
                records[0].goalSaves![dateKey] = (records[0].goalSaves![dateKey]! + Double(self.stopWatch.totalAccumulatedTime.seconds()))
            }
            else{
                records[0].goalSaves![dateKey] = Double(self.stopWatch.totalAccumulatedTime.seconds())
            }
            
            
        
            
            self.goal.totalTime += Double(self.stopWatch.totalAccumulatedTime.seconds())
            saveContext()
            
            
        }
        //TODO Update this to check if active widget
        WidgetCenter.shared.reloadTimelines(ofKind: AppGroup.facts.rawValue)
        
        
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
    
    func recalculateDayTime() {
        let records = self.goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs: $0.date!) && $0.name == goal.name})
        if(!records.isEmpty){
            self.dayTime = records[0].dayTime
        }
        else{
            self.dayTime = 0.0
        }
        
    }
    
    func recalculateProgress() {
        self.progress = (Double(self.stopWatch.totalAccumulatedTime.seconds()) + self.dayTime)/(self.goal.goalTime*60)
    }
    

    
    func startLoading() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation() {
                
                recalculateProgress()
                //                if self.stopWatch.seconds >= Float(self.goal.goalTime*60) {
                //                    timer.invalidate()
                //                }
            }
        }
    }
    
    func resetTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
            withAnimation() {
                recalculateDayTime()
                self.timer?.invalidate()
            }
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

