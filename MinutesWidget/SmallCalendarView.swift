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
        return Text(formatter.string(from: month))
            .font(.title)
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

struct SmallCalendarView: View {
    @Environment(\.calendar) var calendar
    
    var goalList: [Goal]
    var goalRecordList: [GoalRecord]

//    private var week: DateInterval {
//
//        return calendar.dateInterval(of: .weekOfYear, for: Date())!
//
//      ///create custom intervals
//    }
    
    
    //let screenSize = UIScreen.main.bounds.size

    var body: some View {

        WeekView(week: Date()) { date in
            
            VStack(alignment: .center) {
                if(calendar.isDate(date, inSameDayAs: Date())){
                    ZStack{
                        Circle().fill(Color.pink).clipped().opacity(0.9).frame(width: 18, height: 18)
                        Text(String(self.calendar.component(.day, from: date))).foregroundColor(.white).font(.system(size: 15))
                    }.aspectRatio(contentMode: .fit)

                }
                else {
                    Text(String(self.calendar.component(.day, from: date))).foregroundColor(.white).font(.system(size: 15))
                }
                ProgressRingsStatic(goals: goalList, goalRecords: goalRecordList, dateProvided: date, maxWidth: 30, maxLineWidth: Constants.weekdayRingThickness, maxRingLimit: 3).clipShape(Circle()).padding(.top, 1)
                
            }.frame(width: 45.0, height: 70.0)
        }
    }
}


struct SmallCalendarViewDemo: View {
    @Environment(\.calendar) var calendar

    var body: some View {

        WeekView(week: Date()) { date in
            
            VStack {
                if(calendar.isDate(date, inSameDayAs: Date())){
                    ZStack{
                        Circle().fill(Color.pink).clipped().opacity(0.9).frame(width: 18, height: 18)
                        Text(String(self.calendar.component(.day, from: date))).foregroundColor(.white).font(.system(size: 15))
                    }.aspectRatio(contentMode: .fit)

                }
                else {
                    Text(String(self.calendar.component(.day, from: date))).foregroundColor(.white).font(.system(size: 15))
                }

                //Text(date.dayOfTheWeek)
                Image("WidgetDemo").resizable().frame(width: 32.0, height: 32.0)
            }
        }.padding()
    }
}


//create week view similar to root view
