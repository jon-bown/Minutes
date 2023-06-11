//
//  WCoreDataManager.swift
//  MinutesWidgetExtension
//
//  Created by Jonathan Bown on 6/11/23.
//

import Foundation
import CoreData

class WCoreDataManager {
    
    static let shared = WCoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Minutes")
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.appfactorial.tempus.anulum")!.appendingPathComponent("YourModel.sqlite")
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                // Handle error
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchGoals() -> [Goal] {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()

        do {
            let result = try container.viewContext.fetch(request)
            return result
        } catch {
            // Handle error
            print("Fetch failed")
            return []
        }
    }
    
    func fetchGoalRecords() -> [GoalRecord] {
        let request: NSFetchRequest<GoalRecord> = GoalRecord.fetchRequest()

        do {
            let result = try container.viewContext.fetch(request)
            return result
        } catch {
            // Handle error
            print("Fetch failed")
            return []
        }
    }
    
}
