//
//  GoalRow.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI

struct GoalRow: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var goal: Goal
    @State private var showPopover: Bool = false
    
    
    var body: some View {
        VStack(alignment: .leading) {
            
            
                NavigationLink(destination: GoalDetailView(goal: goal)){
                    Text(goal.name!)
                }
            

            //add priority label
//            Button(goal.name!) {
//                self.showPopover = true
//            }.popover(
//                isPresented: self.$showPopover,
//                arrowEdge: .bottom
//            ) {
//                NavigationView{
//                    GoalDetailView(goal: goal).environment(\.managedObjectContext, self.managedObjectContext)
//                }
//
//
//
//            }
            
            
        }
    }
}

//struct GoalRow_Previews: PreviewProvider {
//    static var previews: some View {
//        GoalRow()
//    }
//}
