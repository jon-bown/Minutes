//
//  NewGoalForm.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI
import UserNotifications
import CoreHaptics

/*
 Form for adding or editing a goal
 */
struct GoalForm: View {
            
    var editing: Bool
    var passedGoal: GoalViewModel?
    @Binding var isPresented: Bool
    @Binding var success: Bool
    
    @State private var goalName: String = ""
    @State private var goalColor: String = ""
    @State private var goalDailyTime: Int = 1
    @State private var goalFrequency: String = ""
    @State private var goalDay: String = ""
    @State private var goalCol: Color = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    @State private var startDate: Date = Date()
    @State private var priority: Int = 0
    @State private var reminders: Bool = false
    @State private var setEndDate: Bool = false
    @State private var startTime: Date = Date()
    @State private var notificationPermission: Bool = false
    @State private var showPermissionAlert: Bool = false
    @State private var endDate: Date = Date()
    @State private var engine: CHHapticEngine?
    @State private var showError: Bool = false
    
    
    let freq = ["Daily", "Weekly", "Monthly"] //add custom
    //time interval dictionary
    @StateObject var dayOTW = WeekDays()
    
    var disableSave: Bool {
        if(editing){
            return false
        }
        else{
            return self.goalName == "" || self.goalDailyTime == 0 || self.goalFrequency == ""
        }
        
    }
    
    let screenSize = UIScreen.main.bounds.size
    

    
    //MARK: - BODY
    var body: some View {
        NavigationView{
            VStack{
                //Text(editing ? self.goalName:"New Goal").bold().font(.system(.largeTitle)).padding(.top, 5)
                Form{
                    Section{
                        TextField("Name", text: self.$goalName)
                        ColorPicker(selection: self.$goalCol, supportsOpacity: true){
                            Text("Color Theme").font(Constants.globalBodyTextFont).bold()
                        }
                        HStack{
                            let goalDailyTimeBinding = Binding<String>(
                                get: {
                                    if self.goalDailyTime > 0 {
                                        return String(self.goalDailyTime)
                                    } else {
                                        return ""
                                    }
                                },
                                set: {
                                    if let value = Int($0) {
                                        self.goalDailyTime = value
                                    } else {
                                        self.goalDailyTime = 0
                                    }
                                }
                            )
                            Text("Minutes:").font(Constants.globalBodyTextFont)
                            TextField("Minutes:", text: goalDailyTimeBinding)
                                .keyboardType(.numberPad)
                            
                        }
                        
                        Picker(selection: self.$goalFrequency, label: Text("Frequency").font(Constants.globalBodyTextFont).bold()) {
                            Text("") // Empty string option
                            ForEach(self.freq, id: \.self) { freq in
                                Text(freq).font(Constants.globalBodyTextFont)
                            }
                        }
                        if(self.goalFrequency == "Weekly"){
                            
                            ForEach(0..<self.dayOTW.weekDays.count, id: \.self) { index in
                                
                                HStack {
                                    Button(action: {
                                        self.dayOTW.selectDay(index: index)
                                    }) {
                                        HStack{
                                            if self.dayOTW.weekDays[index].isSelected {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Constants.checkMarkColor)
                                                    .animation(.easeIn)
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(.primary)
                                                    .animation(.easeOut)
                                            }
                                            Text(self.dayOTW.weekDays[index].weekDayString).foregroundColor(.white).font(Constants.globalBodyTextFont)
                                            
                                        }.accentColor(.red)
                                    }.buttonStyle(BorderlessButtonStyle())
                                    
                                }
                                
                                
                                
                            }
                        }
                        
                        
                        DatePicker(selection: self.$startDate, displayedComponents: .date) {
                            Text("Start On:").font(Constants.globalBodyTextFont)
                        }
                        
                        Toggle(isOn: self.$setEndDate){
                            Text("End Date").font(Constants.globalBodyTextFont)
                        }
                        if(self.setEndDate){
                            DatePicker(selection: self.$endDate, displayedComponents: .date) {
                                Text("End On:").font(Constants.globalBodyTextFont)
                            }
                            
                        }
                        
                        Toggle(isOn: self.$reminders){
                            Text("Reminders").font(Constants.globalBodyTextFont)
                        }.onTapGesture {
                            if(!self.notificationPermission){
                                self.checkNotificationPermission()
                            }
                            
                        }.alert(isPresented: self.$showPermissionAlert) {
                            Alert(title: Text("Error"), message: Text("You must enable notifications in Settings"), dismissButton: .default(Text("Go to Settings")))
                        }.alert(isPresented: self.$showError) {
                            self.isPresented = false
                            return Alert(title: Text("Error Saving Goal"), message: Text("Try again!"), dismissButton: .default(Text("Ok")))
                            
                        }
                        
                        if(self.reminders){
                            
                            DatePicker(selection: self.$startTime, displayedComponents: .hourAndMinute){
                                Text("Alert At:").font(Constants.globalBodyTextFont)
                            }
                        }
                    }.padding(5)
                }
                Section{
                    Button(action: {
                        if(editing){
                            self.updateGoal()
                        }
                        else {
                            self.addGoal()
                        }
                        
                    }) {
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Save").font(Constants.globalBodyTextFont).bold()
                                //.font(.headline)
                                .foregroundColor(Color.white)
                            Spacer()
                        }
                    }.disabled(disableSave)
                    .padding(.vertical, 10.0)
                    .background(disableSave ? Color.gray: Color.red)
                    .cornerRadius(15)
                    .padding(.horizontal, 50)
                    
                    Button(action: {
                        self.dismissView()
                        
                    }) {
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Cancel").font(Constants.globalBodyTextFont).bold()
                                //.font(.headline)
                                .foregroundColor(Color.white)
                            Spacer()
                        }
                    }.disabled(false)
                    .padding(.vertical, 10.0)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .padding(.horizontal, 50)
                    
                }
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    Spacer()
                }
                //Spacer()
                
                
            }
            
            .navigationTitle(editing ? self.goalName:"New Goal")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(leading:
                                    Button(action: {
                                        self.simpleSuccess()
                                        DispatchQueue.main.async {
                                            self.isPresented = false
                                        }
                                    }){
                                        Image(systemName: "xmark.circle.fill").font(Font.system(size: 30, weight: .semibold))
                                            .foregroundColor(Color.white)
                                            //.font(Font.system(size: 50, weight: .bold))
                                    }
            )
        }
        //.frame(width: screenSize.width-20, height: screenSize.height-150)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(){
            self.prepareHaptics()
            if(editing){
                //assign goal properties
                guard let goal = self.passedGoal else {
                    return
                }
                self.goalName = goal.name
                self.goalCol = goal.color
                self.goalDailyTime = Int(goal.goalTime)
                self.startDate = goal.startDate
                self.priority = goal.priority
                self.goalFrequency = goal.frequency!
                if(self.goalFrequency == "Weekly"){
                    self.dayOTW.populateSelections(currentDays: goal.weekDay!)
                }
                self.checkNotificationsExist(id: goal.uuid)
                
                

                //check individual notifications
                
            }
            else{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat =  "HH:mm"
                dateFormatter.defaultDate = Date()
                if let date = dateFormatter.date(from: "12:00") {
                    self.startTime = date
                }
                self.dayOTW.populateSelections(currentDays: [])
            }
            
        }
    }
    
    //MARK: - FUNCTIONS

    
    private func requestNotificationAuthorization() {
        
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        
        group.enter()
        
        queue.async {
        
            self.isNotificationAuthorizationRequesting { permission in
                
                self.reminders = permission
                self.notificationPermission = permission
                self.showPermissionAlert = !permission
                
            }
            group.leave()
        }
        
        
    }
    
    func isNotificationAuthorizationRequesting(completion:@escaping (Bool)->Void) {
        let center = UNUserNotificationCenter.current()
        //var grant = false
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                  completion(true)

            } else {
                completion(false)
            }
        }
    }
    
    private func checkNotificationPermission() {
        var permissionResult: UNAuthorizationStatus = .notDetermined
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        
        group.enter()
        
        queue.async {
            AppUtil.isNotificationsEnabled { result in
                permissionResult = result
                //print("Permission result Async: \(permissionResult.rawValue)")
                switch permissionResult  {
                case .authorized:
                    //print(permissionResult.rawValue)
                    self.notificationPermission = true
                case .denied:
                    self.reminders = false
                    self.notificationPermission = false
                    self.showPermissionAlert = true
                case .notDetermined:
                    self.requestNotificationAuthorization()
                case .provisional:
                    // @available(iOS 12.0, *)
                    //print("The application is authorized to post non-interruptive user notifications.")
                    self.notificationPermission = true
                case .ephemeral:
                    // @available(iOS 14.0, *)
                    //print("The application is temporarily authorized to post notifications. Only available to app clips.")
                    self.notificationPermission = true
                @unknown default:
                    //print("Unknow Status")
                    self.notificationPermission = false
                }
                //print(result.rawValue)
            }
            //group.wait()
            group.leave()
        }
        


    }
    
    
    private func checkNotificationsExist(id: UUID) {
        
        var remind = false
        var hour: Int = 0
        var minute: Int = 0
        
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        
       
        
        queue.async(group: group) {
            group.enter()
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                for notification:UNNotificationRequest in notificationRequests {
                    if notification.identifier == id.uuidString {
                        remind = true
                        guard let trigger = notification.trigger as? UNCalendarNotificationTrigger else {
                            return
                        }
                        let nextTriggerDate = trigger.nextTriggerDate()!
                        //get date components
                        let components = Calendar.current.dateComponents([.hour, .minute], from: nextTriggerDate)
                        hour = components.hour!
                        minute = components.minute!
                        return
                    }
                }
            }
             group.leave()
         }
        

        group.notify(queue: queue) {
            self.reminders = remind
            if(remind){
                self.checkNotificationPermission()
                self.startTime = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self.startTime)!
            }

           }
    }
    
    
    
    private func removeNotificationsForGoal(id: UUID){
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id.uuidString])
    }
    
    private func submitUserNotificationTrigger(id: UUID) {
        
        
        let content = UNMutableNotificationContent()
        content.title = self.goalName
        content.body = "Add some time to your \(self.goalName) goal today!"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        let componentsTime = Calendar.current.dateComponents([.month, .day, .hour, .minute, .weekday, .year], from: self.startTime)
        let componentsDay = Calendar.current.dateComponents([.day], from: self.startDate)
        var dateComponents = DateComponents()
        
        dateComponents.hour = componentsTime.hour
        dateComponents.minute = componentsTime.minute
        switch self.goalFrequency {
        case "Daily":
            submitNotificationTrigger(components: dateComponents, repeats: true, identifier: id.uuidString, content: content)
            break
        case "Weekly":
            //loop through and create one for each
            for weekday in self.dayOTW.weekDays {
                if(weekday.isSelected) {
                    dateComponents.weekday = weekday.id
                    submitNotificationTrigger(components: dateComponents, repeats: true, identifier: id.uuidString, content: content)
                }
            }
            
            
            break
        case "Monthly":
            dateComponents.day = componentsDay.day
            
            submitNotificationTrigger(components: dateComponents, repeats: true, identifier: id.uuidString, content: content)
            //dateComponents.weekday
            break
        //        case "Biweekly":
        //            //interval trigger
        //            break
        //        case "Monthly":
        //            dateComponents.day = components.day
        //            break
        //        case "Every 3 months":
        //            //interval trigger
        //            let duration = DateComponents(calendar: Calendar.current, month: 3)
        //            let later = Calendar.current.date(byAdding: duration, to: self.startTime)
        //            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: later.date, repeats: false)
        //            break
        //        case "Every 6 Months":
        //            //interval trigger
        //            break
        //        case "Yearly":
        //            dateComponents.month = components.month
        //            dateComponents.day = components.day
        //            break
        default:
            break
        }
        
        //if(dateComponents.isValidDate){
        //}
        
        
    }
    
    private func submitNotificationTrigger(components: DateComponents, repeats: Bool, identifier: String, content: UNNotificationContent) {
        let center = UNUserNotificationCenter.current()
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
        
    }
    
    private func dismissView() {
        DispatchQueue.main.async {
        self.isPresented = false
        }
    }
    

    //MARK: HAPTICS
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            self.showError = true
        }
    }
    
    func complexSuccess() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 6)
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
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    
    
    //MARK: EDITING
    private func addGoal(){
        
        let addGoalVM = AddGoalViewModel()
        addGoalVM.name = self.goalName
        addGoalVM.color = self.goalCol
        addGoalVM.startDate = self.startDate
        addGoalVM.endDate = self.endDate
        addGoalVM.frequency = self.goalFrequency
        addGoalVM.goalTime = Double(self.goalDailyTime)
        addGoalVM.save(dotw: self.dayOTW)

        //save notifications
        if(self.reminders){
            self.removeNotificationsForGoal(id: self.passedGoal!.uuid)
            self.submitUserNotificationTrigger(id: self.passedGoal!.uuid)
        }
        
        
        self.simpleSuccess()
        
        self.success = true
        self.dismissView()
    }
    
    func updateGoal() {
        
        
        let addGoalVM = AddGoalViewModel()
        addGoalVM.name = self.goalName
        addGoalVM.color = self.goalCol
        addGoalVM.startDate = self.startDate
        addGoalVM.endDate = self.endDate
        addGoalVM.frequency = self.goalFrequency
        addGoalVM.goalTime = Double(self.goalDailyTime)
        addGoalVM.update(id: self.passedGoal!.id, dotw: self.dayOTW)
        
        if(self.reminders){
            self.removeNotificationsForGoal(id: self.passedGoal!.uuid)
            self.submitUserNotificationTrigger(id: self.passedGoal!.uuid)
        }
        else {
            self.removeNotificationsForGoal(id: self.passedGoal!.uuid)
        }
        
        self.simpleSuccess()
        
        self.success = true
        self.dismissView()
        
        //MARK: TODO: UPDATE PROGRESS
        
    }
}




//struct NewGoalForm_Previews: PreviewProvider {
//    static var previews: some View {
//        NewGoalForm(isPresented: .constant(true))
//    }
//}
