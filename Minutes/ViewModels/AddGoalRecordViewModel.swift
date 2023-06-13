//
//  AddGoalRecordViewModel.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/22/21.
//

import Foundation
import SwiftUI
import CoreData


class AddGoalRecordViewModel: ObservableObject {
    
    var goal: GoalViewModel?
    var date: Date = Date()
    var dayTime: Double = 0.0
    var progress: Double = 0.0

    func save() {
        CoreDataManager.shared.addGoalRecord(goal: self.goal!, date: date, progress: progress, seconds: dayTime)
        
    }
    
    func update(goalRecord: GoalRecordViewModel) -> GoalRecordViewModel? {
        return CoreDataManager.shared.updateGoalRecord(goal: self.goal!, goalRecord: goalRecord, secondsToAdd: dayTime)
    }
    
}
