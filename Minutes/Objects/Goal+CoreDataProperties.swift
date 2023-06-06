//
//  Goal+CoreDataProperties.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/18/21.
//
//

import Foundation
import CoreData
import UIKit.UIColor


extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var color: UIColor?
    @NSManaged public var endDate: Date?
    @NSManaged public var frequency: String
    @NSManaged public var goalTime: Double
    @NSManaged public var monthDay: Int16
    @NSManaged public var name: String
    @NSManaged public var priority: Int16
    @NSManaged public var startDate: Date
    @NSManaged public var totalTime: Double
    @NSManaged public var weekDay: [String]?
    @NSManaged public var records: [GoalRecord]?

}

// MARK: Generated accessors for records
extension Goal {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: GoalRecord)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: GoalRecord)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}

extension Goal : Identifiable {

}
