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
    
    var goal: Goal
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State var timerIsPaused: Bool = true
    @State var timer: Timer? = nil
    @State var progress: Double = 0.0
    @ObservedObject var stopWatch = StopWatch()
    @State private var showGoalEditForm: Bool = false
    
    
//    var goalProgress = Float() {
//        didSet {
//            self.progress = Double(self.stopWatch.getMinutes())/self.goal.goalTime
//        }
//    }
//
    

    
    var body: some View {

            VStack{
                
                VStack {
                    ProgressBar(color: self.goal.color!, value: self.$progress).frame(height: 20).padding()
                       }
 
                //TODO: Improve timer UI
                Text(self.stopWatch.stopWatchTime)
                    .font(.custom("courier", size: 70))
                    .frame(width: UIScreen.main.bounds.size.width,
                           height: 300,
                           alignment: .center)
                
                
                HStack{
                    StopWatchButton(actions: [self.stopWatch.reset, self.stopWatch.lap],
                                    labels: ["Reset", "Save"],
                                    color: Color.red,
                                    isPaused: self.stopWatch.isPaused())

                    StopWatchButton(actions: [self.stopWatch.start, self.stopWatch.pause, self.startLoading],
                                    labels: ["Start", "Pause"],
                                    color: Color.blue,
                                    isPaused: self.stopWatch.isPaused())
                }
//                if timerIsPaused {
//                  HStack {
//                    Button(action:{
//                        self.restartTimer()
//                    }){
//                      Image(systemName: "backward.end.alt")
//                        .padding(.all)
//                    }
//                    .padding(.all)
//                    Button(action:{
//                        self.startTimer()
//                    }){
//                      Image(systemName: "play.fill")
//                        .padding(.all)
//                    }
//                    .padding(.all)
//                  }
//                } else {
//                    Button(action:{
//                              print("STOP")
//                              self.stopTimer()
//                            }){
//                              Image(systemName: "stop.fill")
//                                .padding(.all)
//                            }
//                            .padding(.all)
//                }
                
                Form{
                    //Align text properly
                    HStack{
                        Spacer()
                        Text("Minute Goal")
                        Spacer()
                        Text(String(self.goal.dayTime))
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        Text("Total Time Spent")
                        Spacer()
                        Text(String(self.goal.cumTime))
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        Text("Current Goal")
                        Spacer()
                        Text(String(self.goal.goalTime))
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        Text("Frequency")
                        Spacer()
                        Text(String(self.goal.goalTime))
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        Text("Started On")
                        Spacer()
                        Text(String(self.goal.goalTime))
                        Spacer()
                    }
                    
                
                }

            }.navigationBarTitle(Text(goal.name!), displayMode: .inline).navigationBarItems(trailing: Button(action: {
                self.showGoalEditForm.toggle()
            }){
                Text("Edit").font(Font.system(size: 15, weight: .regular))
            }.popover(
                isPresented: self.$showGoalEditForm,
                arrowEdge: .bottom
            ) {
                
                GoalEditForm(isPresented: self.$showGoalEditForm, goal: self.goal)
                //NewGoalForm(isPresented: self.$showNewGoalForm)
                
            })
        
    }
    
    
    func startTimer(){
      timerIsPaused = false
      // 1. Make a new timer
      timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
        // 2. Check time to add to H:M:S
        if self.seconds == 59 {
          self.seconds = 0
          if self.minutes == 59 {
            self.minutes = 0
            self.hours = self.hours + 1
          } else {
            self.minutes = self.minutes + 1
          }
        } else {
          self.seconds = self.seconds + 1
        }
      }
    }
    
    
    func stopTimer(){
      timerIsPaused = true
      timer?.invalidate()
      timer = nil
    }
    
    
    func restartTimer(){
      hours = 0
      minutes = 0
      seconds = 0
    }
    
    func startLoading() {
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation() {
                self.progress = Double(self.stopWatch.seconds)/(self.goal.goalTime*60)
                if self.stopWatch.seconds >= Float(self.goal.goalTime*60) {
                    timer.invalidate()
                }
            }
        }
    }
}

//struct GoalDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        var goal = 
//        return GoalDetailView()
//    }
//}
