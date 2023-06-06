//
//  GoalRecord+CoreDataProperties.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/6/21.
//
//

import Foundation
import CoreData


extension GoalRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalRecord> {
        return NSFetchRequest<GoalRecord>(entityName: "GoalRecord")
    }

    @NSManaged public var date: Date
    @NSManaged public var dayTime: Double
    @NSManaged public var name: String
    @NSManaged public var progress: Double
    @NSManaged public var goal: Goal
    @NSManaged private var goalSavesData: Data
    @NSManaged private var goalUpdatesData: Data

    public var goalSaves: [Date:Double]? {
        get {
            return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(goalSavesData) as? [Date:Double]
        }
        set {
            goalSavesData = try! NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
        }
    }

    public var goalUpdates: [Int:Double]? {
        get {
            return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(goalUpdatesData) as? [Int:Double]
        }
        set {
            goalUpdatesData = try! NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
        }
    }


}

extension GoalRecord : Identifiable {

}
