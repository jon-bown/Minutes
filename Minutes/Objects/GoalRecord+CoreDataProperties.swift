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
            do {
                return try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSDate.self, NSNumber.self], from: goalSavesData) as? [Date:Double]
            } catch {
                // handle or print error
                return nil
            }
        }
        set {
            do {
                goalSavesData = try NSKeyedArchiver.archivedData(withRootObject: newValue ?? [:], requiringSecureCoding: false)
            } catch {
                // handle or print error
            }
        }
    }

    public var goalUpdates: [Int:Double]? {
        get {
            do {
                return try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSNumber.self], from: goalUpdatesData) as? [Int:Double]
            } catch {
                // handle or print error
                return nil
            }
        }
        set {
            do {
                goalUpdatesData = try NSKeyedArchiver.archivedData(withRootObject: newValue ?? [:], requiringSecureCoding: false)
            } catch {
                // handle or print error
            }
        }
    }

}

extension GoalRecord : Identifiable {

}
