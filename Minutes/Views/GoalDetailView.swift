//
//  GoalDetailView.swift
//  Minutes
//
//  Created by Jonathan Bown on 9/15/20.
//

import SwiftUI
import WidgetKit
import CoreHaptics

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
    @Binding var isDetailActive: Bool
    var goal: GoalViewModel
    
    @StateObject private var addGoalRecordVM = AddGoalRecordViewModel()
    @EnvironmentObject var goalListVM: GoalListViewModel
    @EnvironmentObject var goalRecordListVM: GoalRecordListViewModel
    
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
    @State private var goalCompleted: Bool = false
    @State private var showCustomMinuteSheet: Bool = false
    @State private var newSessionText: String = ""
    @State private var isSessionsEditable: Bool = false
    @State private var sessionsToRemove: [Date] = [Date]()
    @State private var remindersOnText: String = "Off"
    @State private var reminderTimeText: String = ""
    @State private var engine: CHHapticEngine?
    @State private var showError: Bool = false
    @State private var showedCompleted: Bool = false
    
    
    var body: some View {
        
        if(self.goalListVM.goals.isEmpty){
            EmptyView()
        }
        else{
           self.goalDetailView()
        }
        
        
    }
    
    //MARK: - SUB VIEWS
    
    private func goalDetailView() -> some View {
        
       return ScrollView(.vertical, showsIndicators: false){
            
            self.createProgressBox()
            
            RoundedRectangle(cornerRadius: Constants.globalCornerRadius)
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
                        self.saveStopwatchMinutesSession()
                        self.resetTimer()
                        self.complexSuccess()
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
                
                
                
                GroupBox(label: GroupBoxLabelButton(label: "Sessions", isEditable: self.$isSessionsEditable, action: self.makeListEditable)) {

                    //list of all goal updates today
                    ForEach(self.goalRecordListVM.filterGoalRecordSavesTodayForGoal(goal: goal).sorted(by: > ), id: \.key){
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
                            self.complexSuccess()
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
                
            }
            self.createStreakInfoTile().padding([.leading, .trailing], 15)
            self.createTotalTimeInfoTile().padding([.leading, .trailing], 15)
            self.createFrequencyInfoTile().padding([.leading, .trailing], 15)
            self.createReminderInfoTile().padding([.leading, .trailing], 15)
        self.createDateInfoTile().padding([.leading], 15).navigationBarTitle(Text(goal.name), displayMode: .automatic).navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                                    Button(action: {
                                        self.simpleSuccess()
                                        DispatchQueue.main.async {
                                            self.isDetailActive = false
                                        }
                                        
                                        
                                    }){
                                        Image(systemName: "xmark.circle.fill").font(Font.system(size: 30, weight: .light))
                                            .foregroundColor(Color.white)
                                            //.font(Font.system(size: 50, weight: .bold))
                                    },
                                trailing:
                                    Button(action: {
                                        DispatchQueue.main.async {
                                            self.showGoalEditForm.toggle()
                                        }
                                        
                                        
                                    }){
                                        Text("Edit").font(Font.system(size: 20, weight: .regular)).foregroundColor(Color.white)
                                            //.font(Font.system(size: 50, weight: .bold))
                                    }
            )
            .sheet(
                isPresented: self.$showGoalEditForm
            ) {
                
                GoalForm(editing: true, passedGoal: self.goal, isPresented: self.$showGoalEditForm, success: self.$goalUpdatedSuccess)
                
            }
            
       }.background(Color.black)
        //        .alert(isPresented: self.$showError) {
        //            return Alert(title: Text("Error Saving Goal"), message: Text("Try again!"), dismissButton: .default(Text("Ok")))
        //
        //        }
        .onChange(of: self.showGoalEditForm) { newValue in
            if(!newValue) {
                self.checkNotificationsExist(id: self.goal.uuid)
                self.recalculateProgressFromTimer()
                
            }
            
            
            
        }.onChange(of: self.stopWatch.isRunning){ newValue in
            //Removes pending notifications for goal
            if(newValue == false){
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [AppUtil.getGoalNotificationSpecificIdString(id: self.goal.uuid)])
            }
            
        }.onChange(of: self.goalRecordListVM.goalRecords){ newValue in
            if(self.stopWatch.isRunning){
                self.recalculateProgressFromTimer()
            }
            else{
                self.updateProgress()
            }
        }
        .onAppear {
            self.updateProgress()
            self.checkNotificationsExist(id: self.goal.uuid)
            self.prepareHaptics()
        }.toast(isShowing: self.$goalUpdatedSuccess, text: Text("Saved"))
       .toast(isShowing: self.$goalCompleted, text: Text("Goal Completed"))
       .textFieldAlert(isShowing: self.$showCustomMinuteSheet, text: self.$newSessionText, title: "Add Minutes", saveAction: self.saveCustomMinuteSession)
    }
    
    
    private func createDateInfoTile() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Started").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                    (
                        Text(String(self.goal.startDate.mediumDate))
                            .font(Font.system(size: 25, weight: .regular, design: .rounded))
                            .kerning(0.25)
                            .foregroundColor(goal.color).lineLimit(1)
                        
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
                                .foregroundColor(goal.color).lineLimit(1)
                            
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
                            .foregroundColor(goal.color).lineLimit(1)
                        
                    )
                    .padding([.top], -3)
                }.padding(.leading, 3)
                
                
                
                if(self.goal.frequency! == "Weekly"){
                    VStack(alignment: .leading, spacing: 0) {
                        Text("On Days:").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                        (
                            Text(AppUtil.createWeekDaysString(days: self.goal.weekDay!))
                                .font(Font.system(size: 25, weight: .regular, design: .rounded))
                                .kerning(0.25)
                                .foregroundColor(goal.color).lineLimit(2)
                            
                        )
                        .padding([.top], -3)
                    }
                    //.padding(.leading, 5)
                }
                else if(self.goal.frequency! == "Monthly"){
                    VStack(alignment: .leading, spacing: 0) {
                        Text("On Day:").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                        (
                            Text(String(self.goal.monthDay))
                                .font(Font.system(size: 25, weight: .regular, design: .rounded))
                                .kerning(0.25)
                                .foregroundColor(goal.color).lineLimit(1)
                            
                        )
                        .padding([.top], -3)
                    }
                    //.padding(.leading, 5)
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
                        Text(String(self.goalRecordListVM.calculateCurrentStreak(goalID: goal.id)))
                            .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                            .kerning(0.25).foregroundColor(goal.color)
                        
                    )
                    .padding([.top], -3)
                }.padding(.leading, 3)
                //                Spacer()
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Best Streak").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                    (
                        Text(String(self.goalRecordListVM.calculateBestStreak(goalID: goal.id)))
                            .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                            .kerning(0.25)
                            .foregroundColor(goal.color).lineLimit(1)
                        
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
                            .foregroundColor(goal.color)
                        
                    )
                    .padding([.top], -3)
                }.padding(.leading, 3)
                //Spacer()
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("This Week").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                    (
                        Text(self.goalRecordListVM.calculateTimeThisWeekForGoal(goalID: goal.uuid))
                            .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                            .kerning(0.25)
                            .foregroundColor(goal.color).lineLimit(1)
                        
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
                            .foregroundColor(goal.color)
                        
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
                                .foregroundColor(goal.color).lineLimit(1)
                            
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
                        
                        Text("Today").font(Font.system(size: 20, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white).padding(.bottom, 5)
                        (
                            Text(self.goalRecordListVM.getRecordTodayForGoal(goal: self.goal) == nil ? "0/\(Int(self.goal.goalTime))":"\(Int(self.self.goalRecordListVM.getRecordTodayForGoal(goal: self.goal)!.dayTime/60))/\(Int(self.goal.goalTime))")
                                .font(Font.system(size: 25, weight: .semibold, design: .rounded))
                                .kerning(0.25)
                                //TODO: Must fix this
                                .foregroundColor(goal.color)
                                + Text("MIN")
                                .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                                .kerning(0.3).foregroundColor(goal.color)
                        )
                        .padding([.top], -3).padding(.bottom, 3)
                        
                    }.padding(.leading, 10)
                    Spacer()
                    
                    ZStack(alignment: .center){
                        ProgressRingView(progress: self.progress, thickness: Constants.progressRingViewThicknessStandard, startColor: self.goal.color, endColor: self.goal.color, backgroundColor: self.goal.color).frame(width: 175, height: 175).aspectRatio(contentMode: .fit).animatableProgressText(progress: progress)
                    }
                }.padding(2)
            }.cornerRadius(15).padding()
            
            
        }
    }
    
    //create tile for total time
    
    //create tile for both streaks
    
    
    //MARK: - HELPER METHODS
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
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
        if let record = self.goalRecordListVM.getRecordTodayForGoal(goal: self.goal) {
            self.goalRecordListVM.removeTimeFromGoalRecord(id: record.id, datesToRemove: self.sessionsToRemove)
            
            self.sessionsToRemove.removeAll()
            self.progress = record.progress
            self.recalculateDayTime()
            self.updateProgress()
        }

    }
    
    private func saveCustomMinuteSession(){
        guard let customMinutes = Int(self.newSessionText)
        else {
            return
        }
        let customSeconds = Double(customMinutes) * 60.0
        self.updateGoalRecord(addedSeconds: customSeconds)
        self.updateProgress()
        
//        var newRecord = true
//        let record = self.goalRecordListVM.getRecordTodayForGoal(goal: self.goal)
//
//        if(record != nil){
//            newRecord = false
//        }
//
//
//
//
//        //Add date to array of records for the goal record
//        if(newRecord){
//
//            self.progress = customSeconds/(self.goal.goalTime*60)
//
//
//            //TODO: Add method to add goalrecord
//            addGoalRecordVM.goal = self.goal
//            addGoalRecordVM.dayTime = customSeconds
//            addGoalRecordVM.progress = self.progress
//
//            addGoalRecordVM.save()
//
//            self.goal.updateTotalTime(time: Double(customSeconds), add: true)
//
//
//
//        }
//
//        else {
//            let record = goalRecordListVM.getRecordTodayForGoal(goal: self.goal)
//            let updatedDayTime = record!.dayTime + customSeconds
//            self.progress = updatedDayTime/(self.goal.goalTime*60)
//            addGoalRecordVM.goal = self.goal
//            addGoalRecordVM.dayTime = customSeconds
//            addGoalRecordVM.progress = self.progress
//            addGoalRecordVM.update(goalRecord: record!)
//            self.goal.updateTotalTime(time: Double(customSeconds), add: true)
//
//        }
    }
    
    private func saveStopwatchMinutesSession() {
        let addedSeconds = Double(self.stopWatch.totalAccumulatedTime.seconds())
        self.updateGoalRecord(addedSeconds: addedSeconds)
    }
    
    //Save the current time into the proper goal entity
    
    //MARK: HAPTICS
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            
        }
    }
    
    func complexSuccess() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 5)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            
        }
    }
    
    func buttonTap() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            
        }
    }
    
    //MARK: UPDATES
    
    func updateGoalRecord(addedSeconds: Double) {
        var newRecord = true
        if(self.goalRecordListVM.getRecordTodayForGoal(goal: self.goal) != nil) {
            newRecord = false
        }
        
        
        addGoalRecordVM.goal = self.goal
        
        if(newRecord){
            

            addGoalRecordVM.dayTime = addedSeconds
            addGoalRecordVM.progress = addedSeconds/(self.goal.goalTime*60)
            addGoalRecordVM.save()
            self.goal.updateTotalTime(time: addedSeconds, add: true)

        }
        
        else {
            
            let record = goalRecordListVM.getRecordTodayForGoal(goal: self.goal)
            let newDayTime = addedSeconds + record!.dayTime
            addGoalRecordVM.dayTime = addedSeconds
            if let updatedRecord = addGoalRecordVM.update(goalRecord: record!) {
                self.goalRecordListVM.update(updatedRecord)
            }
            
            self.goal.updateTotalTime(time: addedSeconds, add: true)

        }
    }
    
    func updateProgress() {
        if let record = self.goalRecordListVM.getRecordTodayForGoal(goal: self.goal) {
            self.dayTime = record.dayTime
            self.progress = record.progress
        }
            else {
            self.dayTime = 0.0
            self.progress = 0.0
        }
    }
    
    func recalculateDayTime() {
        
        guard let record = goalRecordListVM.getRecordTodayForGoal(goal: self.goal) else {
            self.dayTime = 0.0
            return
        }
        self.dayTime = record.dayTime
        
    }
    
    func recalculateProgressFromTimer() {
        self.progress = (Double(self.stopWatch.totalAccumulatedTime.seconds()) + self.dayTime)/(self.goal.goalTime*60)
        
        //Schedule a notification when the user reaches a multiple of 100%
        

        if(self.progress >= 1.0 && !self.showedCompleted){
            self.alertUserCompletedAfterFirst()
            self.complexSuccess()
        }

    }
    
    func recalculateProgress() {
        self.progress = (Double(self.dayTime)/(self.goal.goalTime*60))
        
        //Schedule a notification when the user reaches a multiple of 100%
        

        
        if(self.progress >= 1.0 && !self.showedCompleted){
            self.alertUserCompletedAfterFirst()
            self.complexSuccess()
        }

    }
    
    func scheduleCompletionNotification() {
        
        //TODO: Check if app is in foreground and display aleart instead
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        center.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                //print("Not Authorized")
                return
            }
        }
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                //print("Notifications not allowed")
                return
            }
        }
        //print("Creating completed notification")
        
        let content = UNMutableNotificationContent()
        content.title = self.goal.name
        content.body = "You completed your Minute goal for \(self.goal.name)! Take a second to save your progress!"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        //MARK: FIND OUT HOW TO DISMISS BADGE
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        //Calculate Interval
        
        
        var secondsTillComplete = goal.goalTime*60.0
        
        if let goalRecord = self.goalRecordListVM.getRecordTodayForGoal(goal: self.goal) {
            secondsTillComplete -= goalRecord.dayTime
        }
        
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsTillComplete, repeats: false)
        let request = UNNotificationRequest(identifier: AppUtil.getGoalNotificationSpecificIdString(id: goal.uuid), content: content, trigger: trigger)
        center.add(request)
        self.showedCompleted = true
    }
    
    
    func alertUserCompletedAfterFirst() {
        //TODO: Check if app is in foreground and display alert instead
        self.goalCompleted = true
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        center.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                //print("Something went wrong")
            }
        }
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                //print("Notifications not allowed")
                return
            }
        }
        //print("Creating completed notification")
        
        let content = UNMutableNotificationContent()
        content.title = self.goal.name
        content.body = "You completed your Minute goal for \(self.goal.name)! Take a second to save your progress!"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        //Calculate Interval
        
        
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: AppUtil.getGoalNotificationSpecificIdString(id: goal.uuid), content: content, trigger: trigger)
        center.add(request)
        self.showedCompleted = true
    }
    
    
    
    func startLoading() {
        if(self.progress < 1.0){
            if(UserDefaults.standard.bool(forKey: Constants.generalCompletionReminder) == true){
                self.scheduleCompletionNotification()
            }
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation() {
                
                recalculateProgressFromTimer()
            }
        }
    }
    
    func resetTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
            withAnimation() {
                self.updateProgress()
                self.stopWatch.reset()
                //remove pending completion notifications
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [AppUtil.getGoalNotificationSpecificIdString(id: goal.uuid)])
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


//Modifier for the stopwatch text to look smooth in the goal detail view
struct StopWatchTextModifier: AnimatableModifier {
    var watchTime: String = ""
    var textColor: Color = .primary
    var font: CGFloat
    var animatableData: String {
        get { watchTime }
        set { watchTime = newValue }
    }
    func body(content: Content) -> some View {
        content
            .overlay(
                HStack(alignment: .center){
                    Text(watchTime.components(separatedBy: ":")[0]).font(.system(size: Constants.stopWatchTimerFontSize, design: .rounded)).fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 60, height: 50, alignment: .center)
                    Text(":").font(.system(size: Constants.stopWatchTimerFontSize, design: .rounded))
                        //.fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 10, height: 50, alignment: .center)
                    Text(watchTime.components(separatedBy: ":")[1]).font(.system(size: Constants.stopWatchTimerFontSize, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 60, height: 50, alignment: .center)
                    Text(":").font(.system(size: Constants.stopWatchTimerFontSize, design: .rounded))
                        //.fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 10, height: 50, alignment: .center)
                    Text(watchTime.components(separatedBy: ":")[2]).font(.system(size: Constants.stopWatchTimerFontSize, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 60, height: 50, alignment: .center)
                }.frame(width: 500, height: 120, alignment: .center)
                
            ) }
}

extension View {
    func animatableProgressText(progress: Double, textColor: Color = Color.primary)
    -> some View {
        self.modifier(ProgressTextModifier(progress: progress, textColor: textColor)) }
    
    func animatableStopWatchText(watchTime: String, textColor: Color = Color.primary)
    -> some View {
        self.modifier(StopWatchTextModifier(watchTime: watchTime, textColor: textColor, font: 30)) }
}



//struct GoalDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        var goal = 
//        return GoalDetailView()
//    }
//}

