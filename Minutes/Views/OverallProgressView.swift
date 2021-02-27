//
//  OverallProgressView.swift
//  Minutes
//
//  Created by Jonathan Bown on 1/23/21.
//

import SwiftUI

struct OverallProgressView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.calendar) var calendar
    
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
    
    var filteredGoals: [Goal] {
        return goals.filter({(Date() > $0.startDate! ||  calendar.isDate(Date(), inSameDayAs:$0.startDate!)) && ((Date().dayOfTheWeek == $0.weekDay && $0.frequency == "Weekly") || ($0.frequency == "Monthly" && $0.monthDay == Date().dayOfTheMonth) || $0.frequency == "Daily")}).sorted(by: {$0.priority < $1.priority})
    }
    
    //goalRecords created today
    var filteredGoalRecords: [GoalRecord] {
        return self.goalRecords.filter({Calendar.current.isDate(Date(), inSameDayAs:$0.date!)})
    }
    
    private var days: [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: dateProvided)
            else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    var dateProvided: Date
    
    
    var body: some View {
        GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        Color.black.edgesIgnoringSafeArea(.all)
                        ScrollView {
                            VStack {
                                Spacer(minLength: Constants.navigationBarHeight).frame(width: geometry.size.width, height: Constants.navigationBarHeight+20, alignment: .top)
                                //self.createRings()
                                ProgressRings(dateProvided: dateProvided, maxWidth: 200, maxLineWidth: Int(Constants.mainRingThickness), maxRingLimit: 3).padding(10)
                                self.createCharts()
                                //self.createFooter()
                            }
                        }
                        self.createNavigationBar(geometry.size)
                    }
                }
//        ScrollView{
//            VStack{
//                //Weekly view of goals
//                ProgressRings(dateProvided: Date(), maxWidth: 200, maxRingLimit: 3).padding(10)
//                
//                //scroll down and see charts for each goal today
//            }
//        }

       
    }
    
    
    func createCharts() -> some View {
            Group {
                // Move Chart
                ForEach(filteredGoals, id: \.self){ goal in
                    BarChartView(
                        title: goal.name!, //goalRecord.name
                        progress: "\(Double(filteredGoalRecords.first(where: {$0.name == goal.name}) == nil ? 0:filteredGoalRecords.first(where: {$0.name == goal.name})!.dayTime)/Double(60.0))", //goalRecord.progress
                        goal: "\(Int(goal.goalTime))",
                        total: "",
                        average: "",
                        unit: "MIN",
                        data: filteredGoalRecords.first(where: {$0.name == goal.name}) == nil ? ActivityData.timeReduced:filteredGoalRecords.first(where: {$0.name == goal.name})!.goalUpdates!,
                        textColor: Color(goal.color!),
                        barStartColor: Color(goal.color!.lighter(by: 30)!),
                        barEndColor: Color(goal.color!.darker(by: 30)!)
                    )
                        .padding([.bottom], 25)
                }
//                BarChartView(
//                    title: "Move", //goalRecord.name
//                    progress: "330", //goalRecord.progress
//                    goal: "300",
//                    total: "2 175 CAL",
//                    average: "56",
//                    unit: "CAL",
//                    data: ActivityData.moveChartData,
//                    textColor: Color.moveTextColor,
//                    barStartColor: Color.moveBarStartColor,
//                    barEndColor: Color.moveBarEndColor
//                )
//                    .padding([.bottom], 25)
                
//                // Exercise Chart
//                BarChartView(
//                    title: "Exercise",
//                    progress: "22",
//                    goal: "30",
//                    total: "8H 42M",
//                    average: "11",
//                    unit: "MIN",
//                    data: ActivityData.exerciseChartData,
//                    textColor: Color.exerciseTextColor,
//                    barStartColor: Color.exerciseBarStartColor,
//                    barEndColor: Color.exerciseBarEndColor
//                )
//                    .padding([.bottom], 25)
                
                // Stand Chart
//                StandChartView(
//                    title: "Stand",
//                    progress: "10",
//                    goal: "12",
//                    idle: "0",
//                    unit: "HRS",
//                    data: ActivityData.standChartData,
//                    textColor: Color.standTextColor,
//                    barStartColor: Color.standBarStartColor,
//                    barEndColor: Color.standBarEndColor
//                )
//                    .padding([.bottom], 25)
            }
        }
        
        func createFooter() -> some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 60) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Steps")
                            .font(Font.system(size: 18, weight: .regular, design: .default))
                            .kerning(0.05)
                            .foregroundColor(Color.white)
                        Text("5 588")
                            .font(Font.system(size: 28, weight: .semibold, design: .rounded))
                            .kerning(0.25)
                            .foregroundColor(Color.activityValueText)
                            .padding([.top], -3)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Distance").font(Font.system(size: 18, weight: .regular, design: .default)).kerning(0.05).foregroundColor(Color.white)
                        (
                            Text("4,5")
                                .font(Font.system(size: 28, weight: .semibold, design: .rounded))
                                .kerning(0.25)
                                .foregroundColor(Color.activityValueText)
                            + Text("KM")
                                .font(Font.system(size: 24, weight: .semibold, design: .rounded))
                                .kerning(0.3).foregroundColor(Color.activityValueText)
                        )
                            .padding([.top], -3)
                    }
                    Spacer()
                }
                Divider()
                    .background(Color.dividerBackground)
                    .frame(height: 2)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 15, trailing: 0))
                Text("Flights Climbed")
                    .font(Font.system(size: 18, weight: .regular, design: .default))
                    .kerning(0.05)
                    .foregroundColor(Color.white)
                Text("4")
                    .font(Font.system(size: 28, weight: .semibold, design: .rounded))
                    .kerning(0.25)
                    .foregroundColor(Color.activityValueText)
                    .padding([.top], -3)
                }
                .padding([.leading], 15)
        }
        
        func createNavigationBar(_ geometrySize: CGSize) -> some View {
            ZStack(alignment: .top) {
                BlurView(style: .dark).edgesIgnoringSafeArea(.top)
                VStack {
                    HStack {
                        
                        //Use weekdays here
                        ForEach(days, id:\.self) { item in
                            VStack(spacing: 1) {
                                if(item.dayOfTheWeek == self.dateProvided.dayOfTheWeek){
                                    ZStack{
                                        Circle().fill(Color.pink).clipped().opacity(0.9).frame(width: 15, height: 15)
                                        Text(String(item.dayOfTheWeek[item.dayOfTheWeek.startIndex]))
                                            .font(Font.system(size: 10, weight: .regular, design: .default))
                                            .foregroundColor(Color.white)
                                    }.aspectRatio(contentMode: .fit)

                                }
                                else {
                                    Text(String(item.dayOfTheWeek[item.dayOfTheWeek.startIndex]))
                                        .font(Font.system(size: 10, weight: .regular, design: .default))
                                        .foregroundColor(Color.white)
                                }
                                ZStack {
                                    ProgressRings(dateProvided: item, maxWidth: 30, maxLineWidth: Int(Constants.weekdayRingThickness), maxRingLimit: 3).clipShape(Circle())
                                        .frame(width: 45, height: 45)
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: geometrySize.width, height: Constants.navigationBarHeight, alignment: .top).navigationTitle(self.dateProvided.mediumDate).navigationBarTitleDisplayMode(.inline)
        }
}

//struct OverallProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        OverallProgressView()
//    }
//}
