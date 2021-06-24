//
//  ProgressComplicationView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 1/17/21.
//

import SwiftUI
import ClockKit

struct ProgressComplicationView: View {
    //Grab goal records
    @Environment(\.complicationRenderingMode) var renderingMode
    var dateProvided: Date
    
    var compFamily: CLKComplicationFamily
  
    var body: some View {
//        GeometryReader { proxy in
//        ZStack{
//            ProgressRingView(progress: .constant(0.5), thickness: CGFloat(10), startColor: Color(UIColor.red.darker(by: 10.0)!), endColor: Color(UIColor.red.lighter(by: 15)!), backgroundColor: UIColor.red).frame(width: proxy.size.width, height: proxy.size.height, alignment: .center).aspectRatio(contentMode: .fit)
//            ProgressRingView(progress: .constant(0.9), thickness: CGFloat(10), startColor: Color(UIColor.red.darker(by: 10.0)!), endColor: Color(UIColor.red.lighter(by: 15)!), backgroundColor: UIColor.red).frame(width: proxy.size.width - 30, height: proxy.size.height).aspectRatio(contentMode: .fit)
//            ProgressRingView(progress: .constant(0.7), thickness: CGFloat(10), startColor: Color(UIColor.red.darker(by: 10.0)!), endColor: Color(UIColor.red.lighter(by: 15)!), backgroundColor: UIColor.red).frame(width: 40, height: 40).aspectRatio(contentMode: .fill)
//
//        }
//        }
        

//                ZStack{
//
//
//
//
//                    ProgressView(value: 0.7){
//                        ProgressView(value: 0.9){
//
//                        }.frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).progressViewStyle(CircularProgressViewStyle(tint: .red))
//                    }.progressViewStyle(CircularProgressViewStyle(tint: .green))
//
//
//
//                }

        if(compFamily == .graphicCircular){
            ProgressRingsStatic(dateProvided: dateProvided, maxWidth: 37.0, maxLineWidth: 5, maxRingLimit: 3, animate: false, tinted: self.renderingMode == .tinted).frame(width: 50, height: 50)
                .aspectRatio(contentMode: .fill)
        }
        else if(compFamily == .graphicCorner) {
            ProgressRingsStatic(dateProvided: dateProvided, maxWidth: 25.0, maxLineWidth: 3, maxRingLimit: 3, animate: false, tinted: self.renderingMode == .tinted).frame(width: 50, height: 50)
                .aspectRatio(contentMode: .fill)
        }
        else {
            ProgressRingsStatic(dateProvided: dateProvided, maxWidth: 25.0, maxLineWidth: 3, maxRingLimit: 3, animate: false, tinted: self.renderingMode == .tinted).frame(width: 50, height: 50)
                .aspectRatio(contentMode: .fill)
        }
        

        
    }
}
#if DEBUG
struct ProgressComplicationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressComplicationView(dateProvided: Date(), compFamily: .graphicCircular).previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            
            CLKComplicationTemplateGraphicCircularView(ProgressComplicationView(dateProvided: Date(), compFamily: .graphicCircular)).previewContext()

            CLKComplicationTemplateGraphicCornerCircularView(ProgressComplicationView(dateProvided: Date(), compFamily: .graphicCorner)).previewContext().previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            
     
        }
 
    }
}
#endif
