//
//  StopWatchButton.swift
//  Minutes
//
//  Created by Jonathan Bown on 10/9/20.
//

import SwiftUI


struct StopWatchButton : View {
    var actions: [() -> Void]
    var labels: [String]
    var color: Color
    var isPaused: Bool
    var playPause: Bool
    
    
    
    var body: some View {
        
        return Button(action: {
            if self.isPaused {
                self.actions[0]()
                if(self.actions.count > 2){
                    self.actions[2]()
                }
            } else {
                self.actions[1]()
            }
        }) {
            if isPaused {
                Text(self.labels[0])
                    .foregroundColor(self.playPause ? .green:.white).frame(width: 100, height: 100)
            } else {
                Text(self.labels[1])
                    .foregroundColor(self.playPause ? .red:.white).clipped().frame(width: 100, height: 100)
            }
        }.background(Circle()
                        .fill(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray).clipped().opacity(0.3)        .overlay(
                            Circle()
                                .stroke(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray, lineWidth: 2).frame(width: 80, height: 80)
                        )
                        .frame(width: 75, height: 75))
        
    }
    
    
}


struct WatchStopWatchButton : View {
    var actions: [() -> Void]
    var labels: [String]
    var color: Color
    var isPaused: Bool
    var playPause: Bool
    var degreeRotation: Double
    
    var body: some View {
        
        return Button(action: {
            
            
            if self.isPaused {
                self.actions[0]()
                if(self.actions.count > 2){
                    self.actions[2]()
                }
            } else {
                self.actions[1]()
            }
        }) {
            if isPaused {
                Text(self.labels[0])
                    .foregroundColor(self.playPause ? .green:.white)
            } else {
                Text(self.labels[1])
                    .foregroundColor(self.playPause ? .red:.white).clipped()
            }
        }.background(Capsule().foregroundColor(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray).opacity(0.3).frame(width: 80, height: 50))
        
        
        //        .background(HalfCapsuleShape().foregroundColor(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray).frame(width: 50, height: 80).rotationEffect(.degrees(degreeRotation)))
        
    }
    
}


struct StopWatchStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding().background(Circle().fill(Color .blue).clipped().opacity(0.3)        .overlay(Circle().stroke(Color.blue, lineWidth: 2).frame(width: 80, height: 80)
            )
            .frame(width: 75, height: 75))
        //.background(Circle()
        //              .fill(configuration.isPressed ? Color.clear:.black)
        //             .frame(width: 75, height: 75)).clipped()
        
        
        //frame
    }
    
}


struct WatchStopWatchStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding().background(Capsule().foregroundColor(Color.blue)).frame(width: 80, height: 50)
        //.background(Circle()
        //              .fill(configuration.isPressed ? Color.clear:.black)
        //             .frame(width: 75, height: 75)).clipped()
        
        
        //frame
    }
    
}


//struct StopWatchButton_Previews: PreviewProvider {
//    static var previews: some View {
//        StopWatchButton()
//    }
//}
