//
//  GoalCompletedNotificationView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 4/11/21.
//

import SwiftUI

struct GoalCompletedNotificationView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        HStack {
            VStack{
                Text("Goal")
                Text("Complete")
            }
            VStack{
                //Progress rings
                Text("ProgressRings")
                Spacer()
            }
        }.onAppear{
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

struct GoalCompletedNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        GoalCompletedNotificationView()
    }
}
