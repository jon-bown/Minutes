//
//  ChangeGoalsView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 4/11/21.
//

import SwiftUI

struct ChangeGoalsView: View {
    @Environment(\.presentationMode) var presentationMode
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
    
    
    var goal: Goal
    @Binding var isPresented: Bool
    @State private var newMinutes: Double = 0.0
    var body: some View {
        NavigationView {
            VStack{
                Text(goal.name!).font(Font.system(size: 25, weight: .semibold, design: .rounded))
                    .kerning(0.25).foregroundColor(Color(goal.color!))
                Spacer()
                HStack{
                    Button(action: {
                        newMinutes -= 1.0
                        WKInterfaceDevice.current().play(.click)
                    }
                    
                    ){
                        Image(systemName: "minus")
                        
                    }
                    Text(String(Int(newMinutes))).font(Font.system(size: 25, weight: .semibold, design: .rounded))
                        .kerning(0.25).foregroundColor(Color(goal.color!))
                    Button(action: {
                        newMinutes += 1.0
                        WKInterfaceDevice.current().play(.click)
                    }){
                        Image(systemName: "plus")
                    }
                    
                }
                Spacer()
                Button(action: {
                    goal.goalTime = newMinutes
                    //UPDATE PROGRESS IN GOAL RECORD
                    if let record = AppUtil.getRecordTodayForGoal(goalRecords: self.goalRecordsArray, goalId: goal.id!) {
                        record.progress = record.dayTime/(self.goal.goalTime*60.0)
                    }
                    saveContext()
                    WKInterfaceDevice.current().play(.success)
                    isPresented = false
                }
                ){
                    Text("Save").font(Font.system(size: 25, weight: .semibold, design: .rounded))
                        .kerning(0.25)
                    //play around with foreground color
                }.background(Capsule().foregroundColor(Color(goal.color!)))
                //Button
            }
        }.onAppear{
            self.newMinutes = goal.goalTime
        }
        
    }
    
    private func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("Error saving managed object context")
            }
        }
    }
}

//struct ChangeGoalsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeGoalsView()
//    }
//}
