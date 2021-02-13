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
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var dateProvided: Date
  
    var body: some View {
//        GeometryReader { proxy in
//        ZStack{
//            ProgressRingView(progress: .constant(0.5), thickness: CGFloat(10), startColor: Color(UIColor.red.darker(by: 10.0)!), endColor: Color(UIColor.red.lighter(by: 15)!), backgroundColor: UIColor.red).frame(width: proxy.size.width, height: proxy.size.height, alignment: .center).aspectRatio(contentMode: .fit)
//            ProgressRingView(progress: .constant(0.9), thickness: CGFloat(10), startColor: Color(UIColor.red.darker(by: 10.0)!), endColor: Color(UIColor.red.lighter(by: 15)!), backgroundColor: UIColor.red).frame(width: proxy.size.width - 30, height: proxy.size.height).aspectRatio(contentMode: .fit)
//            ProgressRingView(progress: .constant(0.7), thickness: CGFloat(10), startColor: Color(UIColor.red.darker(by: 10.0)!), endColor: Color(UIColor.red.lighter(by: 15)!), backgroundColor: UIColor.red).frame(width: 40, height: 40).aspectRatio(contentMode: .fill)
//
//        }
//        }
        
        ProgressRings(dateProvided: dateProvided, maxWidth: Int(30.0), maxLineWidth: 5, maxRingLimit: 3).frame(width: 120, height: 120)
            .aspectRatio(contentMode: .fill).environment(\.managedObjectContext, managedObjectContext)
        
    }
}

struct ProgressComplicationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressComplicationView(dateProvided: Date()).previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            
            CLKComplicationTemplateGraphicCircularView(ProgressComplicationView(dateProvided: Date())).previewContext()

            CLKComplicationTemplateGraphicCornerCircularView(ProgressComplicationView(dateProvided: Date())).previewContext().previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm"))
            
     
        }
 
    }
}
