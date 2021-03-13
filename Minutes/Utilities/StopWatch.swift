//
//  StopWatchTwo.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/11/21.
//

import UIKit


var kDisableTimerWhenAppIsNotActive = true

class StopWatch: ObservableObject {
    
    
    private enum TimerMode {
        case stopped
        case running
        case suspended
    }
    
    
    // the heart of a timer object is a timer, if one is active
    private weak var timer: Timer? = nil
    
    private var previouslyAccumulatedTime: TimeInterval = 0
    private var startDate: Date? = nil
    private var lastStopDate: Date? = nil
    private var state: TimerMode = .stopped
    
    @Published var totalAccumulatedTime: TimeInterval = 0
    
    // now we let people ask us questions or tell us to do things
    var isSuspended: Bool { return state == .suspended }
    var isRunning: Bool { return state == .running }
    var isStopped: Bool { return state == .stopped }
    
    private var sourceTimer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "stopwatch.timer")
    private var counter: Int = 0
    var cumCounter: Int = 0
    
    var stopWatchTime:String = "00:00:00"


    var minutes: Float = 0.0
    
    var seconds: Float = 0.0
    
    
    
    private func shutdownTimer() {
        // how long we've been in the .running state
        let accumulatedRunningTime = Date().timeIntervalSince(startDate!)
        // total running time: however long we had been running before entering the
        // current .running state, plus how long we've now been running now
        previouslyAccumulatedTime += accumulatedRunningTime
        totalAccumulatedTime = previouslyAccumulatedTime

        // remember when we shut down
        lastStopDate = Date()
        // throw out the time
        timer!.invalidate()
        timer = nil  // should happen anyway with a weak variable
    }
    
    func suspend() {
        // it only makes sense to suspend if you are running
        if state == .running {
            shutdownTimer()
            state = .suspended
        }
    }
    
    func start() {
        // we can only start if we are not running (either suspended or stopped)
        if state != .running {
            // set new start time beginning now
            startDate = Date()
            // except, if we are restarting the timer after the app was moved from inactive
            // to active, use whatever we had as the lastStopDate when we suspended to be
            // the new startDate (if so configured to do so)
            if state == .suspended && !kDisableTimerWhenAppIsNotActive {
                startDate = lastStopDate
            }
            // schedule a new timer
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector(update)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode:RunLoop.Mode.default)
            state = .running
        }
    }
    
    func stop() {
        // it only makes sense to stop if you are running
        if state == .running {
            shutdownTimer()
            state = .stopped
        }
    }
    
    @objc private func update() {
        // how long we've been running in the current .running state
        // and add in any previously accumulated time
        totalAccumulatedTime = previouslyAccumulatedTime + Date().timeIntervalSince(startDate!)
        
        DispatchQueue.main.async {
            self.seconds = self.totalAccumulatedTime.seconds()
            self.stopWatchTime = self.totalAccumulatedTime.stringFromTimeInterval()
        }
    }
    
    func reset() {
        guard state == .stopped else { return }
        previouslyAccumulatedTime = 0
        totalAccumulatedTime = 0
        
                self.stopWatchTime = "00:00:00"
                self.counter = 0
                self.seconds = 0
    }
    
    //MARK: - OLD

//    func start() {
//
//        self.paused = !self.paused
//        self.isRunning = true
//        guard let _ = self.sourceTimer else {
//            self.startTimer()
//            return
//        }
//
//        self.resumeTimer()
//    }
    
//    func pause() {
//
//        self.paused = !self.paused
//        self.isRunning = false
//        self.sourceTimer?.suspend()
//    }
    

//    func reset() {
//
//        self.stopWatchTime = "00:00:00"
//        self.counter = 0
//        self.isRunning = false
//        self.seconds = 0
//    }
//
//    func update() {
//        objectWillChange.send()
//    }
    
    func isPaused() -> Bool {
        return self.isStopped
    }
    
    private func startTimer() {
        self.sourceTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.strict,
                                                          queue: self.queue)
        
        self.resumeTimer()
    }
    
    private func resumeTimer() {
        self.sourceTimer?.setEventHandler {
            self.updateTimer()
        }
        
        self.sourceTimer?.schedule(deadline: .now(),
                                   repeating: 0.01)
        self.sourceTimer?.resume()
    }
    
    private func updateTimer() {
        self.counter += 1
        
        DispatchQueue.main.async {
            self.seconds = Float(self.counter / 100)
            self.stopWatchTime = StopWatch.convertCountToTimeString(counter: self.counter)
        }
    }
    
    func getCounter() -> Int {
        return self.counter
    }
    
    func getSeconds() -> Float {
        return self.totalAccumulatedTime.seconds()
    }
    
    func getMinutes() -> Float {
        return self.totalAccumulatedTime.minutes()
    }
    

}


extension TimeInterval{

        func stringFromTimeInterval() -> String {

            let time = NSInteger(self)

            let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
            let seconds = time % 60
            let minutes = (time / 60) % 60
            let hours = (time / 3600)

            return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds,ms)
            
            //return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)

        }
    
    
    func seconds() -> Float {
        let time = NSInteger(self)

        let seconds = time
        
        return Float(seconds)
    }
    
    
    func minutes() -> Float {
        let time = NSInteger(self)

        let minutes = (time / 60) % 60
        
        return Float(minutes)
    }
    
    
    }


extension StopWatch {
    static func convertCountToTimeString(counter: Int) -> String {
        let millseconds = counter % 100
        let seconds = counter / 100 % 60
        let totalSeconds = counter / 100
        let minutes = totalSeconds / 60
        let hours = minutes / 60
        
        var millsecondsString = "\(millseconds)"
        var secondsString = "\(seconds)"
        var minutesString = "\(minutes)"
        var hoursString = "\(hours)"
        
        if millseconds < 10 {
            millsecondsString = "0" + millsecondsString
        }
        
        if seconds < 10 {
            secondsString = "0" + secondsString
        }
        
        if minutes < 10 {
            minutesString = "0" + minutesString
        }
        
        if hours < 10 {
            hoursString = "0" + hoursString
        }
        
        
        return "\(minutesString):\(secondsString):\(millsecondsString)"
    }
}
