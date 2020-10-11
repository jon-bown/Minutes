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
        VStack(alignment: .leading) {
          // 1
            goal.name.map(Text.init)
            .font(.title)

    }
    }
}

//struct GoalRow_Previews: PreviewProvider {
//    static var previews: some View {
//        GoalRow()
//    }
//}
