//
//  MinutesWidget.swift
//  MinutesWidget
//
//  Created by Jonathan Bown on 4/11/21.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    
    var managedObjectContext : NSManagedObjectContext
    
    init(context : NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), isDemo: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        var entry: SimpleEntry
        if(context.isPreview){
            entry = SimpleEntry(date: Date(), isDemo: "Y")
        }
        else {
            entry = SimpleEntry(date: Date(), isDemo: "")
        }
        
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, isDemo: "")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let isDemo: String
}

struct MinutesWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    @StateObject private var goalListVM = GoalListViewModel()
    @StateObject private var goalRecordListVM = GoalRecordListViewModel()
    
    var entry: Provider.Entry
    

    var body: some View {
        if(entry.isDemo != ""){
            ZStack{
                Color.black.opacity(1)
                if(widgetFamily == .systemSmall){
                    self.createSystemSmallDemo()
                }
                else if(widgetFamily == .systemMedium){
                    self.createSystemMediumDemo()
                }
                else {
                    self.createSystemLargeDemo()
                }

            }
        }
        else {
            ZStack{
                Color.black.opacity(1)
                if(widgetFamily == .systemSmall){
                    self.createSystemSmall()
                }
                else if(widgetFamily == .systemMedium){
                    self.createSystemMedium()
                }
                else {
                    self.createSystemLarge()
                }

            }
        }
    }
    
    func createSystemSmall() -> some View {
        ProgressRingsStatic(dateProvided: entry.date, maxWidth:120, maxLineWidth: 15, maxRingLimit: 3, animate: false).frame(width: 150, height: 150)
        .aspectRatio(contentMode: .fit)
    }
    
    
    //MARK: DEMO
    func createSystemSmallDemo() -> some View {
        Image("WidgetDemo").resizable().padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
    
    func createSystemMediumDemo() -> some View {
        HStack{
            Spacer()
            DailyStatsViewDemo(type: "Horizontal").padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
            Spacer()
            Image("WidgetDemo").resizable().aspectRatio(contentMode: .fit).padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
            Spacer()
        }
        
    }
    
    func createSystemLargeDemo() -> some View {
        VStack(alignment: .center){
            SmallCalendarViewDemo().padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
            Spacer()
            MiniBarChartWidgetView()
            Spacer()
            DailyStatsViewDemo(type: "V")
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        
        //Image("WidgetDemo").resizable().scaledToFit()
    }
    
    
    
    func createSystemMedium() -> some View {
  
        self.createHStackInfo()

    }
    
    func createSystemLarge() -> some View {
        
        VStack(alignment: .center){
  
            HStack{
                SmallCalendarView().padding(EdgeInsets(top: 8, leading: 0, bottom: 5, trailing: 0))
            }
            Spacer()
            MiniBarChartWidgetView()
            Spacer()
            HStack{
                DailyStatsView(goalList: goalListVM.goals, type: "V").padding(.leading, 5).padding(.bottom, 20)
            }
        }

    }
    
    func createHStackInfo() -> some View {
        HStack{
            DailyStatsView(goalList: goalListVM.goals).padding().padding(.leading, 10)
            Spacer()
            ProgressRingsStatic(dateProvided: entry.date, maxWidth:120, maxLineWidth: 15, maxRingLimit: 3, animate: false).frame(width: 150, height: 150)
                .aspectRatio(contentMode: .fit).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
        }.padding(.vertical, 5)
    }
}

@main
struct MinutesWidget: Widget {
    
    let kind: String = "MinutesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(context: persistentContainer.viewContext)) { entry in
            MinutesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Minute Progress")
        .description("Show overviews of progress throughout the day")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
    
    var persistentContainer: NSPersistentContainer = {
//        let storeURL = AppGroup.facts.containerURL.appendingPathComponent("Minutes.sqlite")
//        let description = NSPersistentStoreDescription(url: storeURL)
//
//        let container = NSPersistentContainer(name: "Minutes")
//        container.persistentStoreDescriptions = [description]
//        container.loadPersistentStores {
//            handle,error  in
//        }
        return CoreDataManager.shared.persistentContainer
    }()
}

//struct MinutesWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        MinutesWidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
