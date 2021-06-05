//
//  StopWatchButton.swift
//  Minutes
//
//  Created by Jonathan Bown on 10/9/20.
//

import SwiftUI
#if !os(watchOS)
import CoreHaptics
#endif


struct StopWatchButton : View {
    var actions: [() -> Void]
    var labels: [String]
    var color: Color
    var isPaused: Bool
    var playPause: Bool
    #if !os(watchOS)
    @State private var engine: CHHapticEngine?
    #endif
    
    var body: some View {
        
        return Button(action: {
            #if !os(watchOS)
            self.complexSuccess()
            #endif
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
        }.buttonStyle(CircleStopWatchStyle(isPaused: self.isPaused, playPause: self.playPause)).onAppear {
            #if !os(watchOS)
            self.prepareHaptics()
            #endif
        }
        
    }

    #if !os(watchOS)
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            
        }
    }
    
    func complexSuccess() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 4)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 4)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            
        }
    }
    
    func buttonTap() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {

        }
    }
    #endif
    
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
        }.background(Capsule().foregroundColor(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray).opacity(0.3)).buttonStyle(WatchStopWatchSaveStyle())
        
        
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

        }) {
            if isPaused {
                Text(self.labels[0])
                    .foregroundColor(self.playPause ? .green:.white)
            } else {
                Text(self.labels[1])
                    .foregroundColor(self.playPause ? .red:.white).clipped()
            }
        }.buttonStyle(WatchStopWatchStyle()).background(Capsule().foregroundColor(self.playPause ? (self.isPaused ? Color.green: Color.red) : .gray).opacity(0.3))
        
        
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
