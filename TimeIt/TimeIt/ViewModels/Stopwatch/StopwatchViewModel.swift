//
//  StopwatchViewModel.swift
//  TimeIt
//
//  Created by Luke Hendriks on 04/07/2022.
//

import Foundation

class StopwatchClass: ObservableObject {
    @Published var secondsElapsed: Double = 0.000
    @Published var stopwatchRunning: StopwatchModes = .stopped
    @Published var lapId: Int = 1
    @Published var laps: [LapModel] = []
    
    private var stopwatchTimer = Timer()
    
    let STOPWATCH_RUNNING_FORKEY = "stopwatchRunning"
    let SECONDS_ELAPSED_FORKEY = "secondsElapsed"
    let CLOSED_DATE_FORKEY = "closedDateStopwatch"
    let LAPS_DATA_FORKEY = "lapsData"
    let LAPS_ID_FORKEY = "lapId"
    
    func start_timer() {
        stopwatchRunning = .running
        stopwatchTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { timer in
            if self.stopwatchRunning == .running {
                self.secondsElapsed += 0.001
            }
        })
        RunLoop.main.add(stopwatchTimer, forMode: .tracking)
    }
    
    func stop_timer() {
        stopwatchRunning = .paused
    }
    
    func reset_timer() {
        stopwatchRunning = .stopped
        secondsElapsed = 0.000
    }
    
    func secondsConverter(timeInSeconds: Int) -> (Int, Int, Int) {
        let hours = timeInSeconds / 3600
        let minutes = (timeInSeconds % 3600 ) / 60
        let seconds = (timeInSeconds % 3600 ) % 60
        
        return (hours, minutes, seconds)
    }
    
    func formatSeconds(timeInSeconds: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        formatter.minimumFractionDigits = 3
        formatter.numberStyle = .decimal
        
        let formattedSeconds = formatter.string(from: NSNumber(value: timeInSeconds))
        return formattedSeconds!
    }
    
    func stopwatchInBackground() {
        let closeNow = Date.now.timeIntervalSince1970
        var stopwatchRunningValue: String
        
        stopwatchTimer.invalidate()
        
        if (self.stopwatchRunning == .running) {
            stopwatchRunningValue = "on"
        } else if (self.stopwatchRunning == .paused) {
            stopwatchRunningValue = "paused"
        } else {
            stopwatchRunningValue = "off"
        }
        
        UserDefaults.standard.set(self.secondsElapsed, forKey: SECONDS_ELAPSED_FORKEY)
        UserDefaults.standard.set(stopwatchRunningValue, forKey: STOPWATCH_RUNNING_FORKEY)
        UserDefaults.standard.set(closeNow, forKey: CLOSED_DATE_FORKEY)
        
        let lapsData = try? JSONEncoder().encode(laps)
        UserDefaults.standard.set(lapsData, forKey: LAPS_DATA_FORKEY)
        UserDefaults.standard.set(lapId, forKey: LAPS_ID_FORKEY)
    }
    
    func stopwatchInForeground() {
        let previousSecondsElapsed = UserDefaults.standard.double(forKey: SECONDS_ELAPSED_FORKEY)
        let closedDate = UserDefaults.standard.double(forKey: CLOSED_DATE_FORKEY)
        let openNow = Date.now.timeIntervalSince1970
        
        if let lapsData = UserDefaults.standard.data(forKey: LAPS_DATA_FORKEY) {
            self.laps = try! JSONDecoder().decode([LapModel].self, from: lapsData)
        }
        self.lapId = UserDefaults.standard.integer(forKey: LAPS_ID_FORKEY)
        
        let stopwatchRunningValue = UserDefaults.standard.string(forKey: STOPWATCH_RUNNING_FORKEY)
        
        if stopwatchRunningValue == "on" {
            self.secondsElapsed = openNow - closedDate + previousSecondsElapsed
            start_timer()
        } else if stopwatchRunningValue == "paused" {
            self.secondsElapsed = previousSecondsElapsed
            stop_timer()
        } else {
            self.secondsElapsed = 0.000
            reset_timer()
        }
    }
}
