//
//  AddMovieViewModel.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/7/21.
//

import Foundation
import SwiftUI
import CoreData


class AddGoalViewModel: ObservableObject {
    
    var name: String = ""
    var color: Color = Color.yellow
    var endDate: Date = Date()
    var frequency: String = ""
    var goalTime: Double = 0.0
    var startDate: Date = Date()
    var totalTime: Double = 0.0
    var weekDay: [String] = []
    var id: UUID = UUID()

    
    func save(dotw: WeekDays) {
        print("Save")
        CoreDataManager.shared.addGoal(name: name, color: color, goalTime: goalTime, frequency: frequency, startDate: startDate, dotw: dotw, endDate: endDate, id: id)
        
    }
    
    func update(id: NSManagedObjectID, dotw: WeekDays){
        CoreDataManager.shared.updateGoal(name: name, color: color, goalTime: goalTime, frequency: frequency, startDate: startDate, dotw: dotw, endDate: endDate, id: id)
    }
    
}
