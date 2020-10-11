//
//  ProgressRing.swift
//  Minutes
//
//  Created by Jonathan Bown on 9/16/20.
//

import SwiftUI

struct ProgressRing: View {
    
    //Passed Parameters
    var width: CGFloat
    var color: Color
    var offset: Int
    var lineWidth: CGFloat = 20
    
    @Binding var progress: Double
    
    var body: some View {
        ZStack {
            
            
            Circle()
                .stroke(Color.gray, lineWidth: self.lineWidth)


            //Progress Bar
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color,
//                    AngularGradient(
//                        gradient: Gradient(colors: colors),
//                        center: .center,
//                        startAngle: .degrees(0),
//                        endAngle: .degrees(360)
//                    ),
                    style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .round)
                ).rotationEffect(.degrees(-90))
            Circle()
                .frame(width: self.lineWidth, height: self.lineWidth)
                .foregroundColor(color.opacity(1))
                .offset(y: CGFloat(offset))
            //Circle rounding top of progress bar
            Circle()
                .frame(width: self.lineWidth, height: self.lineWidth)
                .foregroundColor(progress > 0.95 ? color: color.opacity(0.001))
                .offset(y: -150)
                .rotationEffect(Angle.degrees(360 * Double(progress)))
                .shadow(color: progress > 0.96 ? Color.black.opacity(0.1): Color.clear, radius: 3, x: 4, y: 0)

           

           
        
        }.frame(width: self.width, height: self.width/2, alignment: .center)
    }
}

struct ProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        ProgressRing(width: 600, color: Color.green, offset: -150, lineWidth: 50, progress: .constant(0.8))
    }
}
