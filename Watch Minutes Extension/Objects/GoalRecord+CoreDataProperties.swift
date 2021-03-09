//
//  GoalRecord+CoreDataProperties.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 3/8/21.
//
//

import Foundation
import CoreData


extension GoalRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalRecord> {
        return NSFetchRequest<GoalRecord>(entityName: "GoalRecord")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dayTime: Double
    @NSManaged public var goalUpdates: [Int:Double]?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var progress: Double
    @NSManaged public var goalSaves: [Date:Double]?

}

extension GoalRecord : Identifiable {

}
