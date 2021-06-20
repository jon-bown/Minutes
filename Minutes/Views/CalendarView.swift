//
//  CalendarView.swift
//  Minutes
//
//  Created by Jonathan Bown on 10/11/20.
//

import SwiftUI

fileprivate extension DateFormatter {
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }
    
    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}


struct WeekView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    
    let week: Date
    let content: (Date) -> DateView
    
    init(week: Date, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.week = week
        self.content = content
    }
    
    private var days: [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
        else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    var body: some View {
        HStack {
            ForEach(days, id: \.self) { date in
                HStack {
                    if self.calendar.isDate(self.week, equalTo: date, toGranularity: .month) {
                        self.content(date)
                    } else {
                        self.content(date).hidden()
                    }
                }
            }
        }
    }
}

struct MonthView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    
    let month: Date
    let showHeader: Bool
    let content: (Date) -> DateView
    
    init(
        month: Date,
        showHeader: Bool = true,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.month = month
        self.content = content
        self.showHeader = showHeader
    }
    
    private var weeks: [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month)
        else { return [] }
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: calendar.firstWeekday)
        )
    }
    
    private var header: some View {
        let formatter = DateFormatter.monthAndYear
        return
            Text(formatter.string(from: month)).font(
                Font.system(size: 30, weight: .semibold, design: .rounded)).background(Rectangle().frame(width: 180, height: 50).cornerRadius(15).foregroundColor(.lightBlack))
            //.font(.title)
            .padding()
        
    }
    
    var body: some View {
        VStack {
            if showHeader {
                header
            }
            
            ForEach(weeks, id: \.self) { week in
                WeekView(week: week, content: self.content)
            }
        }
    }
}

struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    
    let interval: DateInterval
    let content: (Date) -> DateView
    
    init(interval: DateInterval, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.interval = interval
        self.content = content
    }
    
    private var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(months, id: \.self) { month in
                    MonthView(month: month, content: self.content)
                }
            }
        }
    }
}

struct RootView: View {
    @Environment(\.calendar) var calendar
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Goal.priority, ascending: true)
        ]
    ) var goals: FetchedResults<Goal>
    
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goalRecords: FetchedResults<GoalRecord>
    
    private var year: DateInterval {
        if let minDate = goalRecords.min(by: { $0.date < $1.date })?.date {
            let maxDate = goalRecords.max(by: { $0.date < $1.date })?.date
            let thirtyDays = 24.0 * 3600.0 * 7
            return DateInterval(start: minDate, end: maxDate!.addingTimeInterval(thirtyDays))
        }
        else {
            return calendar.dateInterval(of: .weekOfMonth, for: Date())!
        }
        
        
        ///create custom intervals
    }
    
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        NavigationView{
            CalendarView(interval: year) { date in

                
                NavigationLink(destination: OverallProgressView(dateProvided: date)){
                    VStack {
                        Text(String(self.calendar.component(.day, from: date))).font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(.white)
                        //Text(date.dayOfTheWeek)
                        ProgressRings(dateProvided: date, maxWidth: 30, maxLineWidth: Constants.weekdayRingThickness, maxRingLimit: 3).padding(2).clipShape(Circle()).padding(.vertical, 4)
                        
                    }
                }
                
            }.frame(width: screenSize.width-80)
            
        }.navigationBarHidden(true).navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SmallCalendarView: View {
    @Environment(\.calendar) var calendar
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Goal.priority, ascending: true)
        ]
    ) var goals: FetchedResults<Goal>
    
    @FetchRequest(
        entity: GoalRecord.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalRecord.name, ascending: true)
        ]
    ) var goalRecords: FetchedResults<GoalRecord>
    
    private var year: DateInterval {
        
        return calendar.dateInterval(of: .weekOfMonth, for: Date())!
        
        ///create custom intervals
    }
    
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        NavigationView{
            CalendarView(interval: year) { date in
                
                VStack(alignment: .center) {
                    Text(String(self.calendar.component(.day, from: date))).foregroundColor(.white)
                    //Text(date.dayOfTheWeek)
                    ProgressRings(dateProvided: date, maxWidth: Constants.progressRingViewCalendarMaxWidth, maxLineWidth: Constants.weekdayRingThickness, maxRingLimit: 3).padding(2).clipShape(Circle()).padding(.vertical, 4)
                    
                }
                //.frame(width: 100, height: 200)
//                .background(Color.black.lighter(by: 50)).clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                
                //.background(Rectangle().frame(width: Constants.progressRingViewCalendarMaxWidth, height: 200).cornerRadius(15).foregroundColor(Color.black.lighter(by: 15)))
            }.frame(width: screenSize.width-80)
            
        }
    }
}
