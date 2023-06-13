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
    
    let dataManager = WCoreDataManager.shared
    
    func placeholder(in context: Context) -> SimpleEntry {
        let placeholderGoalList: [Goal] = []
        let placeholderGoalRecordList: [GoalRecord] = []
        return SimpleEntry(date: Date(), isDemo: "", goalList: placeholderGoalList, goalRecordList: placeholderGoalRecordList)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        var entry: SimpleEntry
        if(context.isPreview){
            let demoGoalList: [Goal] = []
            let demoGoalRecordList: [GoalRecord] = []
            entry = SimpleEntry(date: Date(), isDemo: "Y", goalList: demoGoalList, goalRecordList: demoGoalRecordList)
        }
        else {
            let fetchedGoalList = dataManager.fetchGoals()
            let fetchedGoalRecordList = dataManager.fetchGoalRecords()
            entry = SimpleEntry(date: Date(), isDemo: "", goalList: fetchedGoalList, goalRecordList: fetchedGoalRecordList)
        }
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let fetchedGoalList = dataManager.fetchGoals()
        let fetchedGoalRecordList = dataManager.fetchGoalRecords()
        for minuteOffset in 0 ..< 10 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, isDemo: "", goalList: fetchedGoalList, goalRecordList: fetchedGoalRecordList)
            entries.append(entry)
        }
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let isDemo: String
    let goalList: [Goal]
    let goalRecordList: [GoalRecord]
}


struct MinutesWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
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
        ProgressRingsStatic(goals: entry.goalList, goalRecords: entry.goalRecordList, dateProvided: entry.date, maxWidth:120, maxLineWidth: 15, maxRingLimit: 3, animate: false).frame(width: 150, height: 150)
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
            MiniBarChartWidgetView(goalRecordList: entry.goalRecordList)
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
                SmallCalendarView(goalList: entry.goalList, goalRecordList: entry.goalRecordList).padding(EdgeInsets(top: 8, leading: 0, bottom: 5, trailing: 0))
            }
            Spacer()
            MiniBarChartWidgetView(goalRecordList: entry.goalRecordList)
            Spacer()
            HStack{
                DailyStatsView(goalList: entry.goalList, goalRecordList: entry.goalRecordList, type: "V").padding(.leading, 5).padding(.bottom, 20)
            }
        }
        
    }
    
    func createHStackInfo() -> some View {
        HStack{
            DailyStatsView(goalList: entry.goalList, goalRecordList: entry.goalRecordList).padding().padding(Edge.Set.leading, 10)
            Spacer()
            ProgressRingsStatic(goals: entry.goalList, goalRecords: entry.goalRecordList, dateProvided: entry.date, maxWidth:120, maxLineWidth: 15, maxRingLimit: 3, animate: false).frame(width: 150, height: 150)
                .aspectRatio(contentMode: .fit).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
        }.padding(.vertical, 5)
    }
}

@main
struct MinutesWidget: Widget {
    
    let kind: String = "MinutesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MinutesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Minute Progress")
        .description("Show overviews of progress throughout the day")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


//struct MinutesWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        MinutesWidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
