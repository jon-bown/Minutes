//
//  ChangeGoalsView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 4/11/21.
//

import SwiftUI

struct ChangeGoalsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var goalRecordListVM = GoalRecordListViewModel.sharedInstance
    
    var goal: GoalViewModel
    @Binding var isPresented: Bool
    @State private var newMinutes: Double = 0.0
    var body: some View {
        NavigationView {
            VStack{
                Text(goal.name).font(Font.system(size: 25, weight: .semibold, design: .rounded))
                    .kerning(0.25).foregroundColor(goal.color)
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
                        .kerning(0.25).foregroundColor(goal.color)
                    Button(action: {
                        newMinutes += 1.0
                        WKInterfaceDevice.current().play(.click)
                    }){
                        Image(systemName: "plus")
                    }
                    
                }
                Spacer()
                Button(action: {
                    goal.updateGoalTime(time: newMinutes)
                    //UPDATE PROGRESS IN GOAL RECORD
                    WKInterfaceDevice.current().play(.success)
                    isPresented = false
                }
                ){
                    Text("Save").font(Font.system(size: 25, weight: .semibold, design: .rounded))
                        .kerning(0.25)
                    //play around with foreground color
                }.background(Capsule().foregroundColor(goal.color))
                //Button
            }
        }.onAppear{
            self.newMinutes = goal.goalTime
        }
        
    }
    
}

//struct ChangeGoalsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeGoalsView()
//    }
//}
