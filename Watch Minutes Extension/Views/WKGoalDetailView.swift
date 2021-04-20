//
//  WKGoalDetailView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 1/21/21.
//

import SwiftUI

struct WKGoalDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var goal: Goal
    @ObservedObject var stopWatch = StopWatch()
    @State private var progress: Double = 0.0
    @State private var dayTime: Double = 0.0
    @State private var selectedTab = 0
    @State private var showModal: Bool = false
    @State private var showedCompleted: Bool = false
    
    var body: some View {

        TabView(selection: $selectedTab) {
            StopwatchButtonSubView(stopWatch: self.stopWatch, goal: self.goal, progress: self.$progress, dayTime: self.$dayTime, selectedTab: self.$selectedTab).environment(\.managedObjectContext, managedObjectContext).tag(0)
            StopwatchTimeSubview(stopWatch: self.stopWatch, goal: self.goal, progress: self.$progress, dayTime: self.$dayTime, selectedTab: self.$selectedTab).environment(\.managedObjectContext, managedObjectContext).tag(1)
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)).sheet(isPresented: self.$showModal) {
                GoalCompletedNotificationView()
            }.onChange(of: progress, perform: { value in
                if(value >= 1.0 && !self.showedCompleted){
                    self.showModal = true
                    self.showedCompleted = true
                    
                }
            })
    }
    

    
}

//struct WKGoalDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        WKGoalDetailView()
//    }
//}
