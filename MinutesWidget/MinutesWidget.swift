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
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct MinutesWidgetEntryView : View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.widgetFamily) var widgetFamily
    
    @FetchRequest(
      entity: Goal.entity(),
      sortDescriptors: [
        NSSortDescriptor(keyPath: \Goal.priority, ascending: true)
      ]
    ) var goals: FetchedResults<Goal>
    
    var entry: Provider.Entry

    var body: some View {
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
    
    func createSystemSmall() -> some View {
        ProgressRingsStatic(dateProvided: entry.date, maxWidth:120, maxLineWidth: 15, maxRingLimit: 3, animate: false).frame(width: 150, height: 150)
        .aspectRatio(contentMode: .fit).environment(\.managedObjectContext, managedObjectContext)
    }
    
    func createSystemMedium() -> some View {
  
        self.createHStackInfo()

    }
    
    func createSystemLarge() -> some View {
        
        VStack{
            SmallCalendarView().padding(.top, 10).padding(.horizontal, 5)
            Spacer()
            MiniBarChartWidgetView().environment(\.managedObjectContext, managedObjectContext)
            Spacer()
            HStack{
                DailyStatsView(goalList: self.goals, type: "Vertical").padding(.leading, 5).padding(.bottom, 20)
            }
        }

    }
    
    func createHStackInfo() -> some View {
        HStack{
            DailyStatsView(goalList: self.goals).padding().padding(.leading, 5)
            Spacer()
            ProgressRingsStatic(dateProvided: entry.date, maxWidth:120, maxLineWidth: 15, maxRingLimit: 3, animate: false).frame(width: 150, height: 150)
                .aspectRatio(contentMode: .fit).environment(\.managedObjectContext, managedObjectContext).padding(.trailing, 5)
        }.padding(.vertical, 5)
    }
}

@main
struct MinutesWidget: Widget {
    
    let kind: String = "MinutesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(context: persistentContainer.viewContext)) { entry in
            MinutesWidgetEntryView(entry: entry).environment(\.managedObjectContext, persistentContainer.viewContext)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
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
        return PersistenceController.shared.container
    }()
}

//struct MinutesWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        MinutesWidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
