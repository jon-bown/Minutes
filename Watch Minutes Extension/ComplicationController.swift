//
//  ComplicationController.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 1/14/21.
//

import ClockKit
import SwiftUI
import UIKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let moc = PersistenceController.shared.container.viewContext
    
    
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "minuteProgress",
                                      displayName: "Minutes", supportedFamilies:
                                        [.graphicCorner, .graphicCircular])
            // Multiple complication support can be added here with more descriptors
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }
    
    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
       //handler(Date().addingTimeInterval(75.0 * 60.0 * 60.0))
        handler(Date().addingTimeInterval(86400))
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
//        let predictionDate = Date()
//        let predictionTemplate = template(for:
//                                            complication.family, date: predictionDate)
//
//        let entry = CLKComplicationTimelineEntry(date:
//                                                    predictionDate, complicationTemplate: predictionTemplate)
//
//
        //self.scheduleBAR(first: false)
        //self.requestUpdate()
        //handler(entry)
        print("getCurrent")
//        getTimelineEntries(for: complication, after: Date(), limit:
//                            1) {
//            handler($0?.last)
//        }
        
        
        let predictionDate = Date().addingTimeInterval(Double(60))
        let predictionTemplate = template(for: complication.family, date: predictionDate)
        let entry = CLKComplicationTimelineEntry(date: predictionDate, complicationTemplate: predictionTemplate)
        
        handler(entry)
        
    }
    
    
    
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date
        let fifteenMinutes = 15.0 * 60.0
        let twentyFourHours = 24.0 * 60.0 * 60.0
//        var current = date.addingTimeInterval(fifteenMinutes)
//        let endDate = date.addingTimeInterval(twentyFourHours)
//
        var entries = [CLKComplicationTimelineEntry]()
        print("getTimelineEntries")
        print(limit)
        for i in 0 ..< 1{
            let predictionDate = date.addingTimeInterval(Double(60 * 5 * i))
            let predictionTemplate = template(for: complication.family, date: predictionDate)
            let entry = CLKComplicationTimelineEntry(date: predictionDate, complicationTemplate: predictionTemplate)
            
            entries.append(entry)

        }
//        while (current.compare(endDate) == .orderedAscending) && (entries.count < limit) {
//            // 3: Calculate the date for this result
//            //let predictionDate = date.addingTimeInterval(Double(60 *5 * i))
//            print("getting timeline entries")
//            let predictionDate = date
//            let predictionTemplate = template(for:
//                                                complication.family, date: predictionDate)
//
//            let entry = CLKComplicationTimelineEntry(date:
//                                                        predictionDate, complicationTemplate: predictionTemplate)
//
//            entries.append(entry)
//
//            current = current.addingTimeInterval(fifteenMinutes)
//        }
        
        handler(entries)
    }
    
    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family {
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerCircularView(ProgressComplicationView(dateProvided: Date(), compFamily: complication.family).environment(\.managedObjectContext, moc))
            handler(template)
            break
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularView(ProgressComplicationView(dateProvided: Date(), compFamily: complication.family).environment(\.managedObjectContext, moc))
            handler(template)
            break
        default:
            let template = CLKComplicationTemplateGraphicCircularView(ProgressComplicationView(dateProvided: Date(), compFamily: complication.family).environment(\.managedObjectContext, moc))
            handler(template)
        }
        
    }
    
//    func requestedUpdateDidBegin() {
//        print("Complication update is starting")
//
//        //createData()
//
//        let server=CLKComplicationServer.sharedInstance()
//
//        for comp in (server.activeComplications!) {
//            server.reloadTimeline(for: comp)
//            print("Timeline has been reloaded!")
//        }
//
//    }
//
//    func requestedUpdateBudgetExhausted() {
//        print("Budget exhausted")
//    }
    
//        func requestUpdate() {
//            print("Complication update is starting")
//
//            //createData()
//
//            let server=CLKComplicationServer.sharedInstance()
//
//            for comp in (server.activeComplications!) {
//                //check if complication is the one we need
//
//                server.reloadTimeline(for: comp)
//                print("Timeline has been reloaded!")
//            }
//
//        }
    
    
    func template(for family: CLKComplicationFamily, date: Date) ->
    CLKComplicationTemplate {
        switch family {
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerCircularView(ProgressComplicationView(dateProvided: date, compFamily: family).environment(\.managedObjectContext, moc))
            return template
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularView(ProgressComplicationView(dateProvided: date, compFamily: family).environment(\.managedObjectContext, moc))
            return template
        default:
            let template = CLKComplicationTemplateGraphicCircularView(ProgressComplicationView(dateProvided: date, compFamily: family).environment(\.managedObjectContext, moc))
            
//            preconditionFailure("Complication family not supported")
            return template
        }
    }
    
    
    
}



class ExtensionDelegate: NSObject, ObservableObject, WKExtensionDelegate {
    
    private var activeState: Bool = false
    
    func applicationDidFinishLaunching() {
        //self.updateActiveComplications()
        //print("updating")
        //self.scheduleBAR(first: true)
        activeState = true
    }
//
    func applicationDidEnterBackground() {
        //self.updateActiveComplications()
        //self.scheduleBAR(first: false)
        //print("updating in background")
        activeState = false
    }
    
    func applicationWillEnterForeground() {
        activeState = true
    }
//
//    func applicationWillResignActive() {
//        self.updateActiveComplications()
//    }
    
    
    
    
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            
            task.setTaskCompletedWithSnapshot(false)
            print("reload complications")
            if(activeState){
                self.updateActiveComplications()
            }
            else {
                self.updateActiveComplications()
                self.scheduleBAR(first: false)
            }
//            switch task {
//            case let backgroundTask as WKApplicationRefreshBackgroundTask:
//                if let userInfo:NSDictionary = backgroundTask.userInfo as? NSDictionary {
//                    if let then:Date = userInfo["submissionDate"] as? Date {
//
//
//                        let interval = Date.init().timeIntervalSince(then)
//                        print("interval since request was made \(interval)")
//                    }
//                }
//
//                backgroundTask.setTaskCompletedWithSnapshot(false)
//                print("reload complications")
//                if(activeState){
//                    self.updateActiveComplications()
//                }
//                else {
//                    self.scheduleBAR(first: false)
//                }
//
//                break;
//            default:
//                print("breaking")
//                break
//            }
        }
    }
    
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {

        completionHandler(.newData)
    }
    
    
    func updateActiveComplications() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        if let activeComplications = complicationServer.activeComplications {
            for complication in activeComplications {
                if(complication.identifier == "minuteProgress"){
                    //complicationServer.extendTimeline(for: complication)
                    complicationServer.reloadTimeline(for: complication)
                }
                //complicationServer.reloadTimeline(for: complication)
            }
        }
    }
    
    
    func scheduleBAR(first: Bool){
        let now = Date()
        let scheduleDate = now.addingTimeInterval(first ? 60:15*60)
        let info:NSDictionary = ["submissionDate":now]
        let wkExt = WKExtension.shared()
        
        wkExt.scheduleBackgroundRefresh(withPreferredDate: scheduleDate, userInfo: info) {(error: Error?) in
            if (error != nil){
                print("background could not be refreshed: \(error.debugDescription)")
            }
        }
    }
}



