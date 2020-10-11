//
//  ProgressRings.swift
//  Minutes
//
//  Created by Jonathan Bown on 8/20/20.
//

import SwiftUI



struct ProgressRings: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // 1
    @FetchRequest(
      // 2
      entity: Goal.entity(),
      // 3
      sortDescriptors: [
        NSSortDescriptor(keyPath: \Goal.name, ascending: true)
      ]
    // 4
    ) var goals: FetchedResults<Goal>
    
    @State private var ringLimit: Int = 5
        
    var body: some View {
        ZStack {
            ForEach(goals, id: \.self){ goal in
                if let index = goals.firstIndex(of: goal){
                    if(index <= ringLimit){
                        ProgressRing(width: CGFloat(600-index*100), color: Color(goal.color!), offset: -150+index*25, lineWidth: 20, progress: .constant(0))
                    }
                }
                else {
                   
                }

               
            }

//            ProgressRing(width: 500, color: Color.lightRed, offset: -125, lineWidth: 20, progress: .constant(0.8))
//        ZStack {
//
//
//            Circle()
//                .stroke(Color.outlineRed, lineWidth: 20)
//            //Progress Bar
//            Circle()
//                .trim(from: 0, to: progress)
//                .stroke(
//                    AngularGradient(
//                        gradient: Gradient(colors: colors),
//                        center: .center,
//                        startAngle: .degrees(0),
//                        endAngle: .degrees(360)
//                    ),
//                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
//                ).rotationEffect(.degrees(-90))
//            Circle()
//                .frame(width: 20, height: 20)
//                .foregroundColor(progress > 0.95 ? Color.lightRed: Color.lightRed.opacity(0))
//                .offset(y: -150)
//                .rotationEffect(Angle.degrees(360 * Double(progress)))
//                .shadow(color: progress > 0.96 ? Color.black.opacity(0.1): Color.clear, radius: 3, x: 4, y: 0)
//            //Circle rounding top of progress bar
//            Circle()
//                .frame(width: 20, height: 20)
//                .foregroundColor(Color.darkRed)
//                .offset(y: -150)
//
//
//        }.frame(width: 600, height: 300, alignment: .center)
//
//        ZStack {
//
//
//            Circle()
//                .stroke(Color.outlineGreen, lineWidth: 20)
//            //Progress Bar
//            Circle()
//                .trim(from: 0, to: progress)
//                .stroke(
//                    AngularGradient(
//                        gradient: Gradient(colors: colorsG),
//                        center: .center,
//                        startAngle: .degrees(0),
//                        endAngle: .degrees(360)
//                    ),
//                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
//                ).rotationEffect(.degrees(-90))
//            Circle()
//                .frame(width: 20, height: 20)
//                .foregroundColor(progress > 0.95 ? Color.lightGreen: Color.lightGreen.opacity(0))
//                .offset(y: -150)
//                .rotationEffect(Angle.degrees(360 * Double(progress)))
//                .shadow(color: progress > 0.96 ? Color.black.opacity(0.1): Color.clear, radius: 3, x: 4, y: 0)
//            //Circle rounding top of progress bar
//            Circle()
//                .frame(width: 20, height: 20)
//                .foregroundColor(Color.darkGreen)
//                .offset(y: -125)
//
//
//        }.frame(width: 500, height: 250, alignment: .center)
        }
  //Use for debugging core data instance
//        Button(action:{
//                  print(goals)
//
//                }){
//                  Image(systemName: "stop.fill")
//                    .padding(.all)
//                }
//                .padding(.all)
    }
}

struct ProgressRings_Previews: PreviewProvider {
    static var previews: some View {
        ProgressRings()
    }
}
