//
//  GoalRow.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import SwiftUI

struct GoalRow: View {
    @ObservedObject var goal: Goal
    var body: some View {
        if let name = goal.name {
            HStack{
                Text(name).font(.system(.title2, design: .rounded)).foregroundColor(Color.white)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(Color.gray)
            }.font(.system(size: 24, design: .rounded)).padding(4).cornerRadius(8)
        }
        

    }
}
