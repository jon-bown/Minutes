//
//  StopwatchButtonSubView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 2/5/21.
//

import SwiftUI

struct StopwatchButtonSubView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goalRecords: FetchedResults<GoalRecord>
    @ObservedObject var stopWatch: StopWatch
    @ObservedObject var goal: Goal
    @Binding var progress: Double
    @Binding var dayTime: Double
    @Binding var selectedTab: Int
    
    
    var body: some View {
        VStack{
            HStack(alignment: .center){
                
                WatchStopWatchButton(actions: [self.stopWatch.reset, self.stopWatch.lap],
                                labels: ["Reset", "Reset"],
                                color: Color.red,
                                isPaused: self.stopWatch.isPaused(), playPause: false, degreeRotation: -90).padding(.trailing, 8).padding(.leading, 5)
                
                WatchStopWatchButton(actions: [self.stopWatch.start, self.stopWatch.pause, self.startLoading],
                                labels: ["Start", "Pause"],
                                color: Color.red,
                                isPaused: self.stopWatch.isPaused(), playPause: true, degreeRotation: 90).padding(.leading, 8).padding(.trailing,5)
                

            }
            HStack{
                Button(action: {
                    if(!self.stopWatch.isRunning){
                        self.updateGoalRecord()
                        //self.delegate?.scheduleBAR(first: false)
                    }
                }){
                    if(!self.stopWatch.isRunning){
                        Text("Save")
                    }
                    else {
                        Text("Save").opacity(0.5)
                    }
                    
                }.buttonStyle(WatchStopWatchSaveStyle()).disabled(self.stopWatch.isRunning)
            }
        }.navigationTitle("Goals")

    }
    
    
    private func startLoading() {
        self.selectedTab = 1
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation() {
                self.progress = (Double(self.stopWatch.seconds) + self.dayTime)/(self.goal.goalTime*60)
            }
        }
    }
    
    
    private func updateProgress() {
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
            let minutes = self.stopWatch.seconds / 60
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
            
            let hour = Calendar.current.component(.hour, from: Date())
            let minutes = self.stopWatch.seconds / 60
            
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
    
    private func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Error saving managed object context: \(error)")
            }
        }
    }
}

//struct StopwatchButtonSubView_Previews: PreviewProvider {
//    static var previews: some View {
//        StopwatchButtonSubView()
//    }
//}
