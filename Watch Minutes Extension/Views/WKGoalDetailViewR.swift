//
//  WKGoalDetailView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 1/21/21.
//

import SwiftUI

struct WKGoalDetailViewR: View {
    @Environment(\.scenePhase) private var scenePhase

    @EnvironmentObject var goalRecordListVM: GoalRecordListViewModel
    
    var goal: GoalViewModel
    @State private var progress: Double = 0.0
    @State private var selectedTab = 0
    @State private var showModal: Bool = false
    @State private var showedCompleted: Bool = false
    @State private var startDate: Date = Date()
    @State private var backgroundDate: Date = Date()
    @State var totalTimeText: String = "00:00:00"

    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    @State private var watchState: Bool = false
    //@SceneStorage("watchState") private var watchState: Bool = false
    @State var totalTime: Double = 0.0
    //@SceneStorage("totalTime") private var totalTime: Double = 0.0
    
    var body: some View {

        TabView(selection: $selectedTab) {
            StopwatchButtonWatchView(watchRunning: self.$watchState, watchTotalTime: self.$totalTime, goal: self.goal, progress: self.$progress, selectedTab: self.$selectedTab, showedNotification: self.$showedCompleted, actions: [self.reset, self.start, self.stop]).tag(0)
            StopwatchTimeWatchView(goal: self.goal, progress: self.$progress, selectedTab: self.$selectedTab, totalTime: self.$totalTime).onReceive(timer) { _ in
                    
                    if self.watchState {
                        if(self.goalRecordListVM.getRecordTodayForGoal(goal: self.goal) != nil){
                            self.progress = (Double(self.totalTime) + self.goalRecordListVM.getRecordTodayForGoal(goal: self.goal)!.dayTime)/(self.goal.goalTime*60)

                        }
                        else{
                            self.progress = (Double(self.totalTime))/(self.goal.goalTime*60)
                        }
                        if(self.progress >= 1.0 && !self.showedCompleted){
                            self.showModal = true
                            self.showedCompleted = true
                            
                        }
                        self.totalTime = Date().timeIntervalSince(startDate)
                    }
                totalTimeText = AppUtil.getTotalTimeString(seconds: self.totalTime)
                }.tag(1)
            

            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)).sheet(isPresented: self.$showModal) {
                GoalCompletedNotificationView(goal: self.goal)
            }
        .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillResignActiveNotification)) { _ in
            //print("Moving to the background")
            if(self.watchState){
                self.backgroundDate = Date()
            }
            
        }
//        .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationDidBecomeActiveNotification)) { _ in
//            //print("Moving to the foreground")
//            if(self.watchState){
//                //self.stopWatch.reset()
//                let deltaTime: Int = Int(Date().timeIntervalSince(backgroundDate))
//                //self.totalTime = Double(deltaTime) + totalTime
//                //self.totalTimeText = AppUtil.getTotalTimeString(seconds: self.totalTime)
//                //self.startDate = Date()
//                //self.stopWatch.start()
//            }
//        }
//        .onChange(of: scenePhase) { newScenePhase in
//                if newScenePhase == .background {
////                    // Make sure to save any unsaved changes to the products model.
////                    print("background")
////                    self.watchState = self.stopWatch.isRunning
////                    if(self.stopWatch.isRunning){
////                        print("Is Running")
////                        self.stopWatch.suspend()
////                    }
////
////                    print(self.watchState)
//                }
//                if newScenePhase == .inactive {
//                    // Make sure to save any unsaved changes to the products model.
//                    print("inactive")
//
//
//                    if(self.stopWatch.isRunning){
//                        self.watchState = self.stopWatch.isRunning
//                        print("Is Running")
//                        self.stopWatch.stop()
//                        self.totalTime = self.stopWatch.totalAccumulatedTime
//                        print("Total time:\(self.totalTime)")
//                        self.stopWatch.objectWillChange.send()
//                    }
//                    print(self.watchState)
//                }
//                if newScenePhase == .active {
//                    // Make sure to save any unsaved changes to the products model.
//                    print("active")
//                    if(self.watchState){
//                        print("restarting")
//                        //self.stopWatch.startRunning()
//                        print("Running:\(self.stopWatch.isRunning)")
//                        print("Stopped:\(self.stopWatch.isStopped)")
//                        print("Suspended:\(self.stopWatch.isSuspended)")
//                        print("Total time:\(self.totalTime)")
//                        print("Total Watch time:\(self.stopWatch.stopWatchTime)")
//                        self.stopWatch.reset()
//                        self.stopWatch.totalAccumulatedTime = self.totalTime
//
//                            self.stopWatch.start()
//
//                        //
//                        self.stopWatch.objectWillChange.send()
//                        print("Running:\(self.stopWatch.isRunning)")
//                        print("Stopped:\(self.stopWatch.isStopped)")
//                        print("Suspended:\(self.stopWatch.isSuspended)")
//                    }
//
//                }
//            }
    }
    
    
    func start() {
        // we can only start if we are not running (either suspended or stopped)
        if !self.watchState {
            // set new start time beginning now
            if(totalTime == 0.0){
                startDate = Date()
            }
            //startDate = Date()
            // except, if we are restarting the timer after the app was moved from inactive
            // to active, use whatever we had as the lastStopDate when we suspended to be
            // the new startDate (if so configured to do so)
            // schedule a new timer
            self.watchState = true
        }
        self.selectedTab = 1
    }
    
    func reset() {
        self.totalTime = 0.0
        self.startDate = Date()
        self.totalTimeText = AppUtil.getTotalTimeString(seconds: self.totalTime)
    }
    
    func stop() {
        // it only makes sense to stop if you are running
        if self.watchState {
            self.watchState = false
    }
    }
        
    
}


//struct WKGoalDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        WKGoalDetailView()
//    }
//}
