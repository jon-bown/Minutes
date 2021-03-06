//
//  ProgressRingViewStatic.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/2/21.
//


import SwiftUI

struct ProgressRingViewStatic: View {
    
    @State private var currentPercentage: Double = 0.001
    @State private var shadowOffset: CGPoint = CGPoint(x: 0, y: 0)
    
    var progress: Double
    
    var thickness: CGFloat = 30.0
    //var width: CGFloat = 250.0
    //var gradient = Gradient(colors: [.red, .red])
    var startColor: Color
    var endColor: Color
    var startAngle = -90.0
    var backgroundColor = UIColor.red
    var animate: Bool = true
    
    

    
    
    var body: some View {
        let gradient = AngularGradient(gradient: Gradient(colors: [startColor, endColor]), center: .center, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: self.currentPercentage > 0.1 ? 360 * currentPercentage: 0))
        
        return GeometryReader{ geometry in
            ZStack {
                RingBackgroundShape(thickness: thickness)
                    .fill(Color(backgroundColor).opacity(0.3))
                //            Circle()
                //                .stroke(Color(backgroundColor).opacity(0.2), lineWidth: thickness)
                if(self.progress == 0.0){
                    RingShape(currentPercentage: 0.005, thickness: thickness)
                        .fill(Color(backgroundColor)).rotationEffect(Angle(degrees: -90))
                }
                //            else{
                ////                RingShape(progress: progress, thickness: thickness)
                ////                    .fill(gradient).rotationEffect(.init(degrees: -90))
                ////                    .shadow(radius: 2)
                ////                    .drawingGroup()
                ////                    .onAppear() {
                ////                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                ////                            withAnimation(self.animation) {
                ////                                self.currentPercentage = self.progress
                ////                            }
                ////                        }
                ////                    }
                //
                //                RingBackgroundShape(thickness: thickness)
                //                    .fill(Color(backgroundColor))
                //            }
                RingShape(currentPercentage: progress, thickness: thickness)
                    .fill(gradient)
                    .rotationEffect(.init(degrees: -90))
                    .shadow(radius: 2)
                    .drawingGroup()

                RingTipShape(currentPercentage: progress+0.01, thickness: thickness)
                    .fill(progress > 0.96 ? Color.black.opacity(0.7) : Color.clear).blur(radius: 1).rotationEffect(.init(degrees: -90))
                RingTipShape(currentPercentage: progress, thickness: thickness)
                    .foregroundColor(progress > 0.96 ? endColor : .clear)
                    
                    .rotationEffect(.init(degrees: -90))
                    
                
                
                
                
            }
        }
        
        
    }
    
    func ringTipPosition(progress: Double, radius: Double, thickness: CGFloat) -> CGPoint {
        let angle = 360 * progress + startAngle
        let angleInRadian = angle * .pi / 180
        let xPos = (radius / 2 - Double(thickness)) * cos(angleInRadian)
        let yPos = (radius / 2 - Double(thickness)) * sin(angleInRadian)
        
        return CGPoint(x: xPos, y: yPos)
    }
//
//    private func ringTipShadowOffset(progress: Double, radius: Double, thickness: CGFloat) -> CGPoint {
//        let shadowPosition = ringTipPosition(progress: progress + 0.02, radius: radius, thickness: thickness)
//        let circlePosition = ringTipPosition(progress: progress, radius: radius, thickness: thickness)
//        let angle = (progress + startAngle)/360
//        //print("(\(shadowPosition.x),\(shadowPosition.y)")
//        //print(self.currentPercentage)
//        //if(angle < 180){
//        //            return CGPoint(x: -(circlePosition.y - shadowPosition.y), y: (circlePosition.x - shadowPosition.x))
//
//        //ORIGINAL
//        //        return CGPoint(x: shadowPosition.x - circlePosition.x, y: shadowPosition.y - circlePosition.y)
//        return CGPoint(x: shadowPosition.x, y: shadowPosition.y)
//        //            return CGPoint(x: -(circlePosition.x - shadowPosition.x), y: -(shadowPosition.y - circlePosition.y))
//        //}
//        //        else {
//        //            return CGPoint(x: (shadowPosition.y - circlePosition.y), y: (circlePosition.y - shadowPosition.y))
//        //        }
//
//        //        return CGPoint(x: (shadowPosition.y - circlePosition.y), y: (shadowPosition.x - circlePosition.x))
//    }
}






//struct ProgressRingView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ProgressRingView(progress: .constant(0.96)).previewLayout(.fixed(width: 300, height: 300))
//            ProgressRingView(progress: .constant(1.25)).previewLayout(.fixed(width: 300, height: 300))
//            ProgressRingView(progress: .constant(1.0)).previewLayout(.fixed(width: 300, height: 300))
//        }
//    }
//}
