//
//  Goal+CoreDataProperties.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/24/21.
//
//

import Foundation
import CoreData
import UIKit.UIColor


extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var color: UIColor?
    @NSManaged public var endDate: Date?
    @NSManaged public var frequency: String?
    //Goal time is the number of minutes
    @NSManaged public var goalTime: Double
    @NSManaged public var id: UUID?
    @NSManaged public var monthDay: Int
    @NSManaged public var name: String?
    @NSManaged public var priority: Int64
    @NSManaged public var startDate: Date?
    @NSManaged public var totalTime: Double
    @NSManaged public var weekDay: [String]?

}

extension Goal : Identifiable {

}
