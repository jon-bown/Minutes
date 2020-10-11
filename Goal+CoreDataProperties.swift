//
//  Goal+CoreDataProperties.swift
//  Minutes
//
//  Created by Jonathan Bown on 8/13/20.
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
    @NSManaged public var cumTime: Double
    @NSManaged public var dayTime: Double
    @NSManaged public var frequency: String?
    @NSManaged public var goalTime: Double
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var startDate: Date?

}
