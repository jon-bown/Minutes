//
//  GoalCompletedNotificationView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 4/11/21.
//

import SwiftUI

struct GoalCompletedNotificationView: View {
    @Environment(\.presentationMode) var presentationMode
    var goal: GoalViewModel
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                Text(goal.name).font(.system(size: 20)).foregroundColor(goal.color).bold()
                Text("Goal").font(.system(size: 20))
                Text("Complete").font(.system(size: 20))
            }
            VStack{
//                ProgressRingView(progress: 1.0, startColor: Color(goal.color!), endColor: Color(goal.color!))
                
                Spacer()
                ProgressRingViewStatic(progress: 1.0, thickness: 4, startColor: goal.color, endColor: goal.color, backgroundColor: goal.color).frame(width: 50, height: 50).aspectRatio(contentMode: .fit)
//                ProgressRings(dateProvided: Date(), maxWidth: 30, maxLineWidth: Constants.weekdayRingThickness, maxRingLimit: 3).padding(2).clipShape(Circle()).padding(.vertical, 4)
                Spacer()
            }
        }.onAppear{
            WKInterfaceDevice.current().play(.success)
            self.dismissNotificationView()
        }
    }
    
    private func dismissNotificationView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // your code here
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

//struct GoalCompletedNotificationView_Previews: PreviewProvider {
//    static var previews: some View {
//        GoalCompletedNotificationView()
//    }
//}
