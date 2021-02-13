//
//  StopwatchTimeSubview.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 2/5/21.
//

import SwiftUI

struct StopwatchTimeSubview: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goalRecords: FetchedResults<GoalRecord>
    
    var filteredGoalRecords: [GoalRecord] {
        return self.goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!) && goal.name == $0.name})
    }
    @ObservedObject var stopWatch: StopWatch
    @ObservedObject var goal: Goal
    @Binding var progress: Double
    @Binding var dayTime: Double
    
    var body: some View {
        VStack{
            if(filteredGoalRecords.isEmpty){
                ProgressView(value: 0.0)

                    .accentColor(Color(self.goal.color!)).padding()
            }
            else{
                ProgressView(value: filteredGoalRecords[0].progress).accentColor(Color(self.goal.color!)).foregroundColor(Color(self.goal.color!)).padding()
            }
            //Timer UI
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 90).padding()
                .foregroundColor(Color(UIColor.black.lighter(by: 20.0)!)).animatableStopWatchText(watchTime: self.stopWatch.stopWatchTime)

            
            Spacer()
//            WatchStopWatchButton(actions: [self.stopWatch.reset, self.stopWatch.lap],
//                            labels: ["Reset", "Reset"],
//                            color: Color.red,
//                            isPaused: self.stopWatch.isPaused(), playPause: false, degreeRotation: -90).padding(.trailing, 10).padding(.leading, 1)
//
//            WatchStopWatchButton(actions: [self.stopWatch.start, self.stopWatch.pause, self.startLoading],
//                            labels: ["Reset", "Save"],
//                            color: Color.red,
//                            isPaused: self.stopWatch.isPaused(), playPause: true, degreeRotation: 90).padding(.leading, 10).padding(.trailing,1)
//

            

        }.onAppear { self.updateProgress()}.navigationTitle("Goals")
        
        
    }
    
    
    private func startLoading() {
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
}


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
                    Text(watchTime.components(separatedBy: ":")[0]).font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 40, height: 50, alignment: .center)
                    Text(":").font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 10, height: 50, alignment: .center)
                    Text(watchTime.components(separatedBy: ":")[1]).font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 40, height: 50, alignment: .center)
                    Text(":").font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 10, height: 50, alignment: .center)
                    Text(watchTime.components(separatedBy: ":")[2]).font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .animation(nil).frame(width: 40, height: 50, alignment: .center)
                }.frame(width: 300, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .center)

            ) }
}

extension View {
//    func animatableProgressText(progress: Double, textColor: Color = Color.primary)
//    -> some View {
//        self.modifier(ProgressTextModifier(progress: progress, textColor: textColor)) }
//    
    func animatableStopWatchText(watchTime: String, textColor: Color = Color.primary)
    -> some View {
        self.modifier(StopWatchTextModifier(watchTime: watchTime, textColor: textColor)) }
}

//struct StopwatchTimeSubview_Previews: PreviewProvider {
//    static var previews: some View {
//        StopwatchTimeSubview()
//    }
//}
