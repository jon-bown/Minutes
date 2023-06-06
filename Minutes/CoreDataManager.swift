//
//  CoreDataManager.swift
//  Minutes
//
//  Created by Jonathan Bown on 6/5/21.
//

import Foundation
import CoreData
import SwiftUI


class CoreDataManager {
    let persistentContainer: NSPersistentCloudKitContainer
    
    static let shared = CoreDataManager()
    
    private init() {
        //persistentContainer = PersistenceController.persistentContainer
        persistentContainer = NSPersistentCloudKitContainer(name: "Minutes")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to initialize Core Data \(error)")
            }
        }

        let storeURL = URL.storeURL(for: "group.com.appfactorial.tempus.anulum", databaseName: "Minutes")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.minutes.icloud")
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    //TODO: Add Fetch Requests
    func saveContext () {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
    }
    
    
    //Retrieval
    
    func getAllGoals() -> [Goal] {
        
//        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        
        do {
            let items = try persistentContainer.viewContext.fetch(fetchRequest)
            print(items)
           return items
        }
        catch {
            return []
        }
    }
    
    func getGoalByID(id: NSManagedObjectID) -> Goal? {
        
        do {
            return try persistentContainer.viewContext.existingObject(with: id) as? Goal
        } catch {
            print(error)
            return nil
        }
        
    }
    
    func getGoalRecordByID(id: NSManagedObjectID) -> GoalRecord? {
        
        do {
            return try persistentContainer.viewContext.existingObject(with: id) as? GoalRecord
        } catch {
            print(error)
            return nil
        }
        
    }
    
    func getAllGoalRecords() -> [GoalRecord] {
        let fetchRequest: NSFetchRequest<GoalRecord> = GoalRecord.fetchRequest()
        
        do {
           return try persistentContainer.viewContext.fetch(fetchRequest)
        }
        catch {
            return []
        }
    }
    
    func getRecordTodayForGoal(id: UUID) -> GoalRecord? {
        
        let goalRecords = self.getAllGoalRecords()
            
        if(goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs: $0.date) && id == $0.goal.id}).isEmpty){
                    return nil
                }
        else {
            return goalRecords.first(where: {Calendar.current.isDate(Date(), inSameDayAs: $0.date) && id == $0.goal.id})!
        }
                
    }
    
    //MARK: - SAVING
    func saveGoal() {
        //create goal
        
        self.saveContext()
    }
    
    func saveGoalRecord() {
        //create goal record
        
        do {
            try persistentContainer.viewContext.save()
        }
        catch {
            print("Failed to save movie \(error)")
        }
    }
    
    //MARK: - DELETING
    
    func deleteGoal(goal: Goal){
        persistentContainer.viewContext.delete(goal)

        
        saveContext()
    }
    
    func deleteGoalRecord(goalRecord: GoalRecord){
        persistentContainer.viewContext.delete(goalRecord)
        
        saveContext()
    }
    
    
    func deleteAllGoals() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
        
        fetchRequest.includesPropertyValues = false
        do {
            let items = try persistentContainer.viewContext.fetch(fetchRequest) as! [Goal]
            
            for item in items {
                persistentContainer.viewContext.delete(item)
            }
            
            saveContext()
            //persistentContainer.viewContext.reset() // < reset context
            
        } catch {
            // Error Handling
            // ...
        }
    }
    
    func deleteAllGoalRecords() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GoalRecord")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try persistentContainer.viewContext.fetch(fetchRequest) as! [GoalRecord]
            
            for item in items {
                persistentContainer.viewContext.delete(item)
            }
            saveContext()
            
        } catch {
            // Error Handling
            // ...
        }
    }
    
    
    func addGoal(name: String, color: Color, goalTime: Double, frequency: String, startDate: Date, dotw: WeekDays, endDate: Date?, id: UUID) {
        
        let newGoal = Goal(context: persistentContainer.viewContext)

        newGoal.name = name
        newGoal.color = UIColor(color)
        newGoal.totalTime = 0.0
        newGoal.id = id
        newGoal.goalTime = Double(goalTime)
        newGoal.frequency = frequency
        newGoal.startDate = startDate
        newGoal.endDate = nil
        switch frequency {
        case "Daily":
            newGoal.monthDay = 0
            newGoal.weekDay = [String]()
            break
        case "Weekly":
            newGoal.weekDay = [String]()
            for index in 0...6 {
                if(dotw.weekDays[index].isSelected) {
                    
                    newGoal.weekDay!.append(dotw.weekDays[index].weekDayString)
                }
            }
            newGoal.monthDay = 0
            break
        case "Monthly":
            newGoal.weekDay = [String]()
            newGoal.monthDay = Int16(startDate.dayOfTheMonth)
            break
        default:
            break
        }
        
        
        var priority = 1
        if !self.getAllGoals().isEmpty {
            priority = self.getAllGoals().map { Int($0.priority) }.max()! + 1
        }
        
        newGoal.priority = Int16(priority)
        
        saveContext()

    }
    
    func updateGoal(name: String, color: Color, goalTime: Double, frequency: String, startDate: Date, dotw: WeekDays, endDate: Date?, id: NSManagedObjectID) {
        
        let goal = getGoalByID(id: id)!
        
        goal.name = name
        goal.color = UIColor(color)
        goal.totalTime = 0.0
        //newGoal.id = id
        goal.goalTime = Double(goalTime)
        goal.frequency = frequency
        goal.startDate = startDate
        goal.endDate = nil
        switch frequency {
        case "Daily":
            goal.monthDay = 0
            goal.weekDay = [String]()
            break
        case "Weekly":
            goal.weekDay = [String]()
            for index in 0...6 {
                if(dotw.weekDays[index].isSelected) {
                    
                    goal.weekDay!.append(dotw.weekDays[index].weekDayString)
                    //print(self.dayOTW.weekDays[index].weekDayString)
                }
            }
            goal.monthDay = 0
            break
        case "Monthly":
            goal.weekDay = [String]()
            goal.monthDay = Int16(startDate.dayOfTheMonth)
            break
        default:
            break
        }
        
        if(goal.records != nil){
            if(!goal.records!.isEmpty) {
                let record = getRecordTodayForGoal(id: goal.id!)!
                record.progress = record.dayTime/(goal.goalTime*60.0)
            }
        }
        saveContext()
    }
    
    func addGoalRecord(goal: GoalViewModel, date: Date, progress: Double, seconds: Double) {
        
        let newGoalRecord = GoalRecord(context: persistentContainer.viewContext)
        newGoalRecord.name = goal.name
        newGoalRecord.date = date
        newGoalRecord.progress = progress
        newGoalRecord.dayTime = seconds
        newGoalRecord.goal = goal.goal
        var hour = Calendar.current.component(.hour, from: Date())*4
        let minutes = (newGoalRecord.progress * 59).truncatingRemainder(dividingBy: 60)
        var entry = [Int:Double]()
        hour = hour + Date().minuteQuadrant
        entry[hour] = Double(minutes)
        newGoalRecord.goalUpdates = entry
        
        
        var save = [Date:Double]()
        save[Date()] = seconds
        newGoalRecord.goalSaves = save
        
        goal.goal.addToRecords(newGoalRecord)
        
        saveContext()
    }
    
    func updateGoalRecord(id: NSManagedObjectID, secondsToAdd: Double) {
        if let record = getGoalRecordByID(id: id) {
            record.dayTime += secondsToAdd
            record.progress = record.dayTime/(record.goal.goalTime*60.0)
            
            var hour = Calendar.current.component(.hour, from: Date())*4
            let minutes = (record.progress * 59.0).truncatingRemainder(dividingBy: 60)
            hour = hour + Date().minuteQuadrant
            
            let keyExists = record.goalUpdates![hour] != nil
            if(keyExists){
                record.goalUpdates![hour] = (record.goalUpdates![hour]! + Double(minutes)).truncatingRemainder(dividingBy: 60)
            }
            else{
                record.goalUpdates![hour] = Double(minutes)
            }
            //Goal Saves
            let dateKey = Date()
            let saveKeyExists = record.goalSaves![dateKey] != nil
            if(saveKeyExists){
                record.goalSaves![dateKey] = (record.goalSaves![dateKey]! + secondsToAdd)
            }
            else{
                record.goalSaves![dateKey] = secondsToAdd
            }
            let parentGoal = self.getGoalByID(id: record.goal.objectID)!
            parentGoal.totalTime = record.dayTime
        }

        
        saveContext()
    }
    
    func removeTimeFromGoalRecord(id: NSManagedObjectID, datesToRemove: [Date]) {
        if let record = getGoalRecordByID(id: id) {
            for key in datesToRemove {
                // the date
                let timeToRemove = record.goalSaves![key]!
                
                
                record.dayTime -= timeToRemove
                record.goalSaves!.removeValue(forKey: key)
                record.goalUpdates!.removeValue(forKey: key.minuteQuadrant)
                
                self.changeTotalTimeOfGoal(id: record.goal.objectID, time: timeToRemove, add: false)
            }
            
            record.progress = record.dayTime/(record.goal.goalTime*60.0)
            
            saveContext()
        }

    }
    
    
    func changeTotalTimeOfGoal(id: NSManagedObjectID, time: Double, add: Bool){
        do {
            let goal = try persistentContainer.viewContext.existingObject(with: id) as? Goal
            
            if(add){
                goal?.totalTime += time
            }
            else{
                goal?.totalTime -= time
            }
            
            saveContext()
            
        } catch {
            //TODO: Throw Error
            print(error)
        }
    }
    
    
    func changeTotalTimeOfGoalRecord(id: NSManagedObjectID, time: Double, add: Bool){
        do {
            let goalRecord = try persistentContainer.viewContext.existingObject(with: id) as? GoalRecord
            
            if(add){
                goalRecord?.dayTime += time
            }
            else{
                goalRecord?.dayTime -= time
            }
            
            saveContext()
            
        } catch {
            //TODO: Throw Error
            print(error)
        }
    }
    
    func changePriorityOfGoal(id: NSManagedObjectID, priority: Int){
        do {
            let goal = try persistentContainer.viewContext.existingObject(with: id) as? Goal
            
                goal?.priority = Int16(priority)

            
            saveContext()
            
        } catch {
            //TODO: Throw Error
            print("error")
            print(error)
        }
    }
    
    func changeGoalTimeOfGoal(id: NSManagedObjectID, time: Double){
        do {
            
            if let goal = try persistentContainer.viewContext.existingObject(with: id) as? Goal
            {
                goal.goalTime = time
                
                if let records = goal.records {
                    for record in records {
                        record.progress = record.dayTime/(goal.goalTime*60.0)
                    }
                }
                
            }
            
            saveContext()
            
        } catch {
            //TODO: Throw Error
            print(error)
        }
    }
    
}
