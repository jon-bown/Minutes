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
    @State var progress: Double = 0.0
    @State var dayTime: Double = 0.0
    
    var body: some View {
    
            TabView() {
                StopwatchButtonSubView(stopWatch: self.stopWatch, goal: self.goal, progress: self.$progress, dayTime: self.$dayTime).environment(\.managedObjectContext, managedObjectContext)
                StopwatchTimeSubview(stopWatch: self.stopWatch, goal: self.goal, progress: self.$progress, dayTime: self.$dayTime).environment(\.managedObjectContext, managedObjectContext)
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
    
}

//struct WKGoalDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        WKGoalDetailView()
//    }
//}
