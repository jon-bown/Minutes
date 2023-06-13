//
//  OverallProgressView.swift
//  Minutes
//
//  Created by Jonathan Bown on 1/23/21.
//

import SwiftUI

struct OverallProgressView: View {
    
    @EnvironmentObject var goalListVM: GoalListViewModel
    @EnvironmentObject var goalRecordListVM: GoalRecordListViewModel
    
    var dateProvided: Date
    @State private var selectedDate: Date
    private var cal = Calendar.current
    

    //goalRecords created today
    private var days: [Date] {
        guard
            let weekInterval = cal.dateInterval(of: .weekOfYear, for: self.selectedDate)
            else { return [] }
        return cal.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }

    init(dateProvided: Date){
        self.dateProvided = dateProvided
        _selectedDate = State(initialValue: dateProvided)
    }
    
    
    var body: some View {
        GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        Color.black.edgesIgnoringSafeArea(.all)
                        ScrollView {
                            VStack {
                                Spacer(minLength: Constants.navigationBarHeight).frame(width: geometry.size.width, height: Constants.navigationBarHeight+20, alignment: .top)
                                //self.createRings()
                                ProgressRings(goalList: self.goalListVM.goals, goalRecordList: self.goalRecordListVM.goalRecords, dateProvided: self.selectedDate, maxWidth: 150,
                                              maxLineWidth: Constants.progressRingViewThicknessStandard, maxRingLimit: Constants.progressRingViewMaxRingLimitStandard, showClear: false).frame(width: Constants.progressRingViewFrameWidthStandard, height: Constants.progressRingViewFrameHeightStandard).aspectRatio(contentMode: .fit).padding(10)
                                self.createCharts()
                                //self.createFooter()
                            }
                        }
                        self.createNavigationBar(geometry.size)
                    }
        }
       
    }
    
    
    func createCharts() -> some View {
            Group {
                // Move Chart
                ForEach(goalListVM.filterCurrentGoalsByDate(date: self.selectedDate), id: \.id){ goal in
                    BarChartView(
                        title: goal.name, 
                        progress: "\(round(Double(goalRecordListVM.filterGoalRecordsByDate(date: self.selectedDate).first(where: {$0.goal.id == goal.id}) == nil ? 0: goalRecordListVM.filterGoalRecordsByDate(date: self.selectedDate).first(where: {$0.goal.id == goal.id})!.dayTime/Double(60.0))*100)/100)", //goalRecord.progress
                        goal: "\(Int(goal.goalTime))",
                        total: "",
                        average: "",
                        unit: "MIN",
                        data: goalRecordListVM.filterGoalRecordsByDate(date: self.selectedDate).first(where: {$0.goal.id == goal.id}) == nil ? ActivityData.timeReduced:goalRecordListVM.filterGoalRecordsByDate(date: self.dateProvided).first(where: {$0.goal.id == goal.id})!.goalUpdates!,
                        textColor: goal.color,
                        barStartColor: goal.color,
                        barEndColor: goal.color
                    )
                        .padding([.bottom], 25)
                }
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
                            VStack(spacing: 2) {
                                if(item.dayOfTheWeek == self.selectedDate.dayOfTheWeek){
                                    ZStack{
                                        Circle().fill(Color.pink).clipped().opacity(0.9).frame(width: 12, height: 12)
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
                                    ProgressRingsStatic(dateProvided: item, maxWidth: 30, maxLineWidth: Constants.weekdayRingThickness, maxRingLimit: 3).clipShape(Circle())
                                        .frame(width: 45, height: 40)
                                        .aspectRatio(contentMode: .fit)
                                }
                            }.contentShape(Rectangle()).onTapGesture {
                                print("Date tapped: \(item)")
                                self.selectedDate = item
                            
                            }
                        }
                    }
                }
            }
            .frame(width: geometrySize.width, height: Constants.navigationBarHeight, alignment: .top).navigationTitle(self.selectedDate.mediumDate).navigationBarTitleDisplayMode(.inline)
        }
}

