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
        }.buttonStyle(CircleStopWatchStyle(isPaused: self.isPaused, playPause: self.playPause))
        
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
        }.background(Capsule().foregroundColor(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray).opacity(0.3))
        
        
        //        .background(HalfCapsuleShape().foregroundColor(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray).frame(width: 50, height: 80).rotationEffect(.degrees(degreeRotation)))
        
    }
    
}


struct CircleStopWatchSaveStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding().background(Circle().fill(Color .blue).clipped().opacity(0.3)        .overlay(Circle().stroke(Color.blue, lineWidth: 2).frame(width: 80, height: 80)
            ).frame(width: 75, height: 75)).scaleEffect(configuration.isPressed ? 0.8 : 1.0)

    }
}


struct CircleStopWatchStyle: ButtonStyle {
    
    var isPaused: Bool
    var playPause: Bool
    
    init(isPaused: Bool, playPause: Bool) {
        self.isPaused = isPaused
        self.playPause = playPause
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.background(Circle()
                                        .fill(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray).clipped().opacity(0.3)        .overlay(
                                            Circle()
                                                .stroke(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray, lineWidth: 2).frame(width: 80, height: 80)
                                        )
                                        .frame(width: 75, height: 75))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
    
}


struct WatchStopWatchStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding().frame(width: 60, height: 40)            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
    }
    
}

struct WatchStopWatchSaveStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding().frame(width: 80, height: 50).scaleEffect(configuration.isPressed ? 0.8 : 1.0)
    }
    
}


struct WatchStopWatchButtonTest : View {
    var labels: [String]
    var isPaused: Bool
    var playPause: Bool
    
    var body: some View {
        
        return Button(action: {
            
//
//            if self.isPaused {
//                //self.actions[0]()
//                if(self.actions.count > 2){
//                    //self.actions[2]()
//                }
//            } else {
//                //self.actions[1]()
//            }
        }) {
            if isPaused {
                Text(self.labels[0])
                    .foregroundColor(self.playPause ? .green:.white)
            } else {
                Text(self.labels[1])
                    .foregroundColor(self.playPause ? .red:.white).clipped()
            }
        }.buttonStyle(WatchStopWatchStyle()).background(Capsule().foregroundColor(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray).opacity(0.3))
        
        
        //        .background(HalfCapsuleShape().foregroundColor(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray).frame(width: 50, height: 80).rotationEffect(.degrees(degreeRotation)))
        
    }
    
}


#if DEBUG
struct StopWatchButton_Previews: PreviewProvider {

    
    static var previews: some View {
        VStack{
            WatchStopWatchButtonTest(labels: ["Pause", "Pause"], isPaused: false, playPause: true)
           WatchStopWatchButtonTest(labels: ["Play", "Pause"], isPaused: false, playPause: false)
        }

    }
}
#endif
