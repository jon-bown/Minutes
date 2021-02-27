//
//  NewGoalForm.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI
import UserNotifications

struct GoalForm: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Goal.priority, ascending: true)
        ]
    ) var goals: FetchedResults<Goal>
    
    var editing: Bool
    @ObservedObject var goal: Goal
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
    
    
    //End date
    
    
    let freq = ["Daily", "Weekly", "Monthly"] //add custom
    //time interval dictionary
    let dOTW = ["Mon":2, "Tue":3, "Wed":4, "Thu":5, "Fri":6, "Sat":7, "Sun":1]
    
    var disableSave: Bool {
        if(editing){
            return false
        }
        else{
            return self.goalName == "" || self.goalDailyTime == 0 || self.goalFrequency == ""
        }
        
    }

    //MARK: - BODY
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section{
                    TextField("Name", text: self.$goalName)
                    ColorPicker("Color Theme", selection: self.$goalCol, supportsOpacity: true)
                    HStack{
                        Text("Minutes").bold()
                        NumberTextField(value: self.$goalDailyTime, formatter: NumberFormatter(), keyType: UIKeyboardType.numberPad)

                    }
                    
                    Picker("Frequency", selection: self.$goalFrequency) {
                        ForEach(self.freq, id: \.self) { freq in
                            Text(freq)
                        }
                    }
                    if(self.goalFrequency == "Weekly"){
                        Picker("Day", selection: self.$goalDay) {
                            ForEach(self.dOTW.sorted(by: >), id: \.key) { key,value in
                                Text(key)
                            }
                        }
                        
                    }
                    
                    DatePicker("Start on:", selection: self.$startDate, displayedComponents: .date)
                    
                    Toggle(isOn: self.$setEndDate){
                        Text("End Date")
                    }
                    if(self.setEndDate){
                        DatePicker("End On:", selection: self.$endDate, displayedComponents: .date)
                        
                    }
                    
                    Toggle(isOn: self.$reminders){
                        Text("Reminders")
                    }.onTapGesture {
                        self.checkNotificationPermission()
                    }.alert(isPresented: self.$showPermissionAlert) {
                        Alert(title: Text("Error"), message: Text("You must enable notifications"), dismissButton: .default(Text("Go to Settings")))
                    }
                    
                    if(self.reminders && self.notificationPermission){
                        
                        DatePicker("Alert at:", selection: self.$startTime, displayedComponents: .hourAndMinute)
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
                            Text("Save")
                                .font(.headline)
                                .foregroundColor(Color.white)
                            Spacer()
                        }
                    }.disabled(disableSave)
                    .padding(.vertical, 10.0)
                    .background(disableSave ? Color.gray: Color.red)
                    .cornerRadius(15)
                    .padding(.horizontal, 50)
                }

                    //Spacer()
                
                
            }.navigationBarTitle(editing ? self.goalName:"New Goal", displayMode: .inline).navigationBarItems(leading: Button(action: {
                self.isPresented = false
            }){
                Image(systemName: "x.circle").font(Font.system(size: 30, weight: .regular)).foregroundColor(.white)
            })
        }.onAppear(){
            if(editing){
                //assign goal properties
                self.goalName = goal.name!
                self.goalCol = Color(goal.color!)
                self.goalDailyTime = Int(goal.goalTime)
                self.startDate = goal.startDate!
                self.priority = goal.priority
                self.goalFrequency = goal.frequency!
                
                self.checkNotificationPermission()
                self.checkNotificationsExist(id: goal.id!)
                if(self.reminders){
                    self.updateNotificationFields(id: goal.id!)
                }
                //check individual notifications
                
            }
            else{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat =  "HH:mm"
                dateFormatter.defaultDate = Date()
                if let date = dateFormatter.date(from: "12:00") {
                    self.startTime = date
                }
            }

        }
    }
    
    //MARK: - FUNCTIONS
    private func updateNotificationFields(id: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           for notification:UNNotificationRequest in notificationRequests {
            if notification.identifier == id.uuidString {
                guard let trigger = notification.trigger as? UNCalendarNotificationTrigger else {
                    return
                }
                self.startTime = trigger.nextTriggerDate()!
                  
               }
           }

        }
    }
    
    private func checkNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                self.notificationPermission = true
            } else {
                self.showPermissionAlert = true
                self.reminders = false
            }
        }
    }
    
    private func checkNotificationsExist(id: UUID) {
            //Check if any notifications exist, if they do set reminders to true
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
               for notification:UNNotificationRequest in notificationRequests {
                if notification.identifier == id.uuidString {
                    self.reminders = true
                   }
               }
            }
        }
    
    private func removeNotificationsForGoal(id: UUID){
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification:UNNotificationRequest in notificationRequests {
            if notification.identifier == id.uuidString {
                  identifiers.append(notification.identifier)
               }
           }
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    private func submitUserNotificationTrigger(id: UUID) {
        
        let center = UNUserNotificationCenter.current()
        
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
            break
        case "Weekly":
            dateComponents.weekday = self.dOTW[self.goalDay]
            break
        case "Monthly":
            dateComponents.day = componentsDay.day
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
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
            center.add(request)
            
        //}

        
    }
    
    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    
    private func addGoal(){
        let newGoal = Goal(context: managedObjectContext)
        
        // 2
        newGoal.name = goalName
        newGoal.color = UIColor(goalCol)
        newGoal.totalTime = 0.0
        
        newGoal.goalTime = Double(self.goalDailyTime)
        newGoal.frequency = self.goalFrequency
        newGoal.id = UUID()
        newGoal.startDate = self.startDate
        newGoal.frequency = self.goalFrequency
        switch self.goalFrequency {
        case "Daily":
            newGoal.monthDay = 0
            newGoal.weekDay = ""
            break
        case "Weekly":
            newGoal.weekDay = self.goalDay
            newGoal.monthDay = 0
            break
        case "Monthly":
            newGoal.weekDay = ""
            newGoal.monthDay = self.startDate.dayOfTheMonth
            break
        default:
            break
        }
        
        if goals.isEmpty {
            newGoal.priority = 1
        }
        else {
            newGoal.priority = goals.map { $0.priority }.max()! + 1
        }
        if(self.setEndDate){
            newGoal.endDate = self.endDate
        }
        //save notifications
        if(self.reminders){
            self.submitUserNotificationTrigger(id: newGoal.id!)
        }

        self.saveContext()
        
        self.success = true
        self.isPresented = false
    }
    
    func updateGoal() {
                goal.color = UIColor(self.goalCol)
                goal.name = self.goalName
                goal.goalTime = Double(self.goalDailyTime)
                goal.startDate = self.startDate
                goal.frequency = self.goalFrequency
                switch self.goalFrequency {
                case "Daily":
                    goal.monthDay = 0
                    goal.weekDay = ""
                    break
                case "Weekly":
                    goal.weekDay = self.goalDay
                    goal.monthDay = 0
                    break
                case "Monthly":
                    goal.weekDay = ""
                    goal.monthDay = self.startDate.dayOfTheMonth
                    break
                default:
                    break
                }
                if managedObjectContext.hasChanges {
                    try? self.managedObjectContext.save()
        }
        
        if(self.reminders){
            print("submit")
            self.submitUserNotificationTrigger(id: goal.id!)
        }
        else {
            self.removeNotificationsForGoal(id: goal.id!)
        }
        self.success = true
        self.isPresented = false
        }
}




//struct NewGoalForm_Previews: PreviewProvider {
//    static var previews: some View {
//        NewGoalForm(isPresented: .constant(true))
//    }
//}
