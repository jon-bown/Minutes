//
//  GoalRow.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI

struct GoalRow: View {
    @ObservedObject var goal: Goal
    @State private var showPopover: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: GoalDetailView(goal: goal)){
                Text(goal.name!)
            }
            
        }
    }
}
