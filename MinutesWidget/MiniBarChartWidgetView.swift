//
//  MiniBarChartWidgetView.swift
//  MinutesWidgetExtension
//
//  Created by Jonathan Bown on 4/19/21.
//

import SwiftUI

struct MiniBarChartWidgetView: View {
    @Environment(\.calendar) var calendar
    
    @StateObject private var goalListVM = GoalListViewModel.sharedInstance
    @StateObject private var goalRecordListVM = GoalRecordListViewModel.sharedInstance
        
//    var title: String
//    var progress: String
//    var goal: String
//    var total: String
//    var average: String
//    var unit: String
//    var data: [Int: Double]
//    var textColor: Color
    private var barStartColor: Color = Color.red
//   var barEndColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Today")
                    .font(Font.system(size: 18, weight: .regular, design: .default))
                    .kerning(0.05)
                    .foregroundColor(Color.white)
//                    (
//                        Text("\(progress)/\(goal)")
//                            .font(Font.system(size: 28, weight: .semibold, design: .rounded))
//                            .kerning(0.25)
//                            .foregroundColor(textColor)
//                        + Text(unit)
//                            .font(Font.system(size: 24, weight: .semibold, design: .rounded))
//                            .kerning(0.3)
//                            .foregroundColor(textColor)
//                    )
                    .padding([.top], -3)
            }
                .padding([.bottom], 10)
            self.createChart()
                .padding([.bottom], 2)
            self.createLegend()
                .frame(width: Constants.miniBarChartColumnWidth * CGFloat(Constants.miniBarChartColumns) + (Constants.miniBarChartColumnSpacing * CGFloat(Constants.miniBarChartColumns - 1)), height: 14)
//            Text("TOTAL \(total)")
//                .font(Font.system(size: 12, weight: .regular, design: .default))
//                .kerning(0.3)
//                .foregroundColor(textColor)
        }
    }
    //MARK: - HELPERS
    private func getGoalName(id: UUID) -> String{
        if let goal = goalListVM.goals.first(where: {$0.uuid == id}) {
            return goal.name
        }
        else {
            return ""
        }
        
    }
    
    private func getGoalColor(id: UUID) -> Color{
        if let goal = goalListVM.goals.first(where: {$0.uuid == id}) {
            return goal.color
        }
        else {
            return Color.white
        }
        
    }
    
    
    
    func createChart() -> some View {
        let maxColumnIndex = Constants.barChartColumns - 1
        return ZStack(alignment: .bottomLeading) {
            VStack(alignment: .center, spacing: 20) {
                HStack(alignment: .center, spacing: Constants.barChartColumnWidth) {
                    ForEach(0..<maxColumnIndex, id: \.self) { i in
                        Rectangle()
                            .fill(Color(red: 129 / 255, green: 129 / 255, blue: 129 / 255))
                            .frame(width: 1, height: 1)
                    }
                }
                HStack(alignment: .center, spacing: Constants.barChartColumnWidth) {
                    ForEach(0..<maxColumnIndex, id: \.self) { i in
                        Rectangle()
                            .fill(Color(red: 71 / 255, green: 72 / 255, blue: 73 / 255))
                            .frame(width: 1, height: 1)
                    }
                }
                HStack(alignment: .center, spacing: Constants.barChartColumnWidth) {
                    ForEach(0..<maxColumnIndex, id: \.self) { i in
                        Rectangle()
                            .fill(Color(red: 71 / 255, green: 72 / 255, blue: 73 / 255))
                            .frame(width: 1, height: 1)
                    }
                }
                HStack(alignment: .top, spacing: Constants.barChartColumnSpacing) {
                    ForEach(0..<maxColumnIndex, id: \.self) { i in
                        Rectangle()
                            .fill(self.barStartColor)
                            .frame(width: Constants.barChartColumnWidth, height: Constants.barChartColumnWidth)
                            .cornerRadius(Constants.barChartColumnWidth / 2)
                    }
                }
            }
            //MARK: - DATA INPUT
            HStack(alignment: .bottom, spacing: Constants.barChartColumnSpacing) {
                ForEach(self.goalRecordListVM.filterGoalRecords()){ record in
                    ForEach(0..<maxColumnIndex, id: \.self) { i in
                        MiniBarChartBarView(height: record.goalUpdates![i] ?? Double(0), startColor: record.goal.color, endColor: record.goal.color)
                    }
                }

            }
            .drawingGroup()
        }
    }
    
    func createLegend() -> some View {
        HStack(alignment: .center) {
            self.createLegendItem("00:00")
            Spacer()
            self.createLegendItem("06:00")
            Spacer()
            self.createLegendItem("12:00")
            Spacer()
            self.createLegendItem("18:00")
//            Spacer()
//            self.createLegendItem("24:00")
        }
    }
    
    func createLegendItem(_ time: String) -> some View {
        Text(time)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .font(Font.system(size: 11, weight: .medium, design: .default))
            .foregroundColor(Color.chartLegendText)
    }
    


}

struct MiniBarChartBarShape: Shape {
    
    var height: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius = Constants.miniBarChartColumnWidth / 2
        path.addRoundedRect(in: CGRect(x: 0, y: CGFloat(-height+1), width: Constants.miniBarChartColumnWidth, height: CGFloat(height)), cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        return path
    }
    
    
}

struct MiniBarChartBarView: View {
    
    var height: Double
    var startColor: Color
    var endColor: Color
    
    
    var body: some View {
        MiniBarChartBarShape(height: height)
            .fill(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .bottom, endPoint: .top))
            .frame(width: Constants.miniBarChartColumnWidth, height: CGFloat(self.height))
            }
    }
    

