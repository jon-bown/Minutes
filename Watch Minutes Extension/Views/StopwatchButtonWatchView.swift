//
//  StopwatchButtonWatchView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 4/21/21.
//

import SwiftUI

struct StopwatchButtonWatchView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goalRecords: FetchedResults<GoalRecord>
    
    
    var goalRecordsArray: [GoalRecord] {
        return goalRecords.sorted(by: {$0.date! > $1.date!})
    }
    
    
    @Binding var watchRunning: Bool
    @Binding var watchTotalTime: Double
    @ObservedObject var goal: Goal
    @State var timer: Timer?
    @Binding var progress: Double
    @Binding var selectedTab: Int
    @Binding var showedNotification: Bool
    @State private var showEditView: Bool = false
    var actions: [() -> Void]
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    self.actions[0]()
                    WKInterfaceDevice.current().play(.stop)
                    self.showedNotification = false
                }){
                    
                    Text("Reset").foregroundColor(.white)
                    
                    
                }.background(Capsule().foregroundColor(Color.gray).opacity(0.7)).buttonStyle(WatchStopWatchSaveStyle())
                
                
                Button(action: {
                    if(!self.watchRunning){
                        self.actions[1]()
                        WKInterfaceDevice.current().play(.start)
                        //self.delegate?.scheduleBAR(first: false)
                    }
                    else {
                        self.actions[2]()
                        WKInterfaceDevice.current().play(.stop)
                    }
                }){
                    if(!self.watchRunning){
                        
                        Text(self.watchTotalTime == 0.0 ? "Start": "Resume").foregroundColor(.white)
                        
                    }
                    else {
                        Text("Pause").foregroundColor(.white)
                    }
                    
                }.background(Capsule().foregroundColor(self.watchRunning ? Color.red:Color.green).opacity(0.7)).buttonStyle(WatchStopWatchSaveStyle())
            }.padding(.top, 20)
            
            
            HStack{
                Button(action: {
                    if(!self.watchRunning){
                        self.updateGoalRecord()
                        WKInterfaceDevice.current().play(.success)
                        //self.delegate?.scheduleBAR(first: false)
                    }
                }){
                    if(!self.watchRunning){
                        Text("Save").foregroundColor(.white)
                    }
                    else {
                        Text("Save").foregroundColor(.gray)
                    }
                    
                }.background(Capsule().foregroundColor(Color.blue).opacity(0.7)).buttonStyle(WatchStopWatchSaveStyle()).disabled(self.watchRunning)
                
                //TODO: ADD EDIT BUTTON
                
                Button(action: {
                    if(!self.watchRunning){
                        self.showEditView = true
                        WKInterfaceDevice.current().play(.click)
                        //self.delegate?.scheduleBAR(first: false)
                    }
                }){
                    if(!self.watchRunning){
                        Text("Edit").foregroundColor(.white)
                    }
                    else {
                        Text("Edit").foregroundColor(.black)
                    }
                    
                }.background(Capsule().foregroundColor(Color.yellow).opacity(0.7)).buttonStyle(WatchStopWatchSaveStyle()).disabled(self.watchRunning).sheet(isPresented: self.$showEditView) {
                    //Show edit view
                    ChangeGoalsView(goal: goal, isPresented: self.$showEditView)
                }
            }.padding(.top, 20)
            
        }.navigationTitle("Goals")
        
    }
    
    
    func updateGoalRecord() {
        var newRecord = false
        let record = AppUtil.getRecordTodayForGoal(goalRecords: self.goalRecordsArray, goalID: self.goal.id!)
        if(record == nil){
            newRecord = true
        }
        
        //Add date to array of records for the goal record
        
        if(newRecord){
            
            let newGoalRecord = GoalRecord(context: managedObjectContext)
            newGoalRecord.name = self.goal.name!
            newGoalRecord.date = Date()
            newGoalRecord.progress = self.progress
            newGoalRecord.id = self.goal.id!
            
            newGoalRecord.dayTime = Double(self.watchTotalTime)
            self.goal.totalTime += Double(self.watchTotalTime)
            //divide hours into four quadrants
            var hour = Calendar.current.component(.hour, from: Date())*4
            let minutes = (newGoalRecord.progress * 60.0).truncatingRemainder(dividingBy: 60)
            var entry = [Int:Double]()
            hour = hour + Date().minuteQuadrant
            entry[hour] = Double(minutes)
            newGoalRecord.goalUpdates = entry
            //SAVES
            var save = [Date:Double]()
            save[Date()] = Double(self.watchTotalTime)
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
            if let record = AppUtil.getRecordTodayForGoal(goalRecords: self.goalRecordsArray, goalID: self.goal.id!) {
                record.progress = self.progress
                record.dayTime += Double(self.watchTotalTime)
                
                
                var hour = Calendar.current.component(.hour, from: Date())*4
                let minutes = (record.progress * 59.0).truncatingRemainder(dividingBy: 60)
                hour = hour + Date().minuteQuadrant
                let keyExists = record.goalUpdates![hour] != nil
                if(keyExists){
                    record.goalUpdates![hour] = (record.goalUpdates![hour]! + Double(minutes)).truncatingRemainder(dividingBy: 60)
                }
                else{
                    record.goalUpdates![hour] = Double(minutes)
                }
                //Goal Saves
                let dateKey = Date()
                let saveKeyExists = record.goalSaves![dateKey] != nil
                if(saveKeyExists){
                    record.goalSaves![dateKey] = (record.goalSaves![dateKey]! + Double(self.watchTotalTime))
                }
                else{
                    record.goalSaves![dateKey] = Double(self.watchTotalTime)
                }
                
                self.goal.totalTime += Double(self.watchTotalTime)
                saveContext()
                
            }
            
            
        }
        self.watchTotalTime = 0.0
        
    }
    
    private func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                
            }
        }
    }
}
