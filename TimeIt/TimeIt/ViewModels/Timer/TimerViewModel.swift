//
//  TimerViewModel.swift
//  TimeIt
//
//  Created by Luke Hendriks on 05/07/2022.
//

import Foundation

class TimerClass: ObservableObject {
    @Published var timerStatus: TimerModes = .stopped
    @Published var timeRemaining: Double = 0.0
    @Published var timerTimer = Timer()
    
    private let TIMER_RUNNING_FORKEY = "timerRunning"
    private let CLOSE_DATE_FORKEY = "closeDateTimer"
    private let TIMER_REMAINING_FORKEY = "timerRemaining"
    func updateTimeRemaining() {
        if self.timerStatus == .running {
            self.timeRemaining -= 1
            if self.timeRemaining == 0 {
                self.timerStatus = .stopped
                self.timerTimer.invalidate()
            }
        }
    }
    
    func createTimer() {
        timerTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateTimeRemaining()
        }
        
        NotificationsViewModel.shared.createTimerNotification(notificationDelay: Double(self.timeRemaining), notificationTitle: "Timer ended", notificationDescription: "Your timer has ended!")
        
        DispatchQueue.global(qos: .background).async {
            while self.timeRemaining > 0 {
                Thread.sleep(forTimeInterval: 1)
            }
            
            self.timerTimer.invalidate()
        }
    }
    
    func startTimer(timerDelaySeconds: Double) {
        timerStatus = .running
        timeRemaining = timerDelaySeconds
        createTimer()
    }
    
    func stopTimer() {
        timerStatus = .paused
        NotificationsViewModel.shared.removeNotificationRequest(notificationIdentifier: NotificationsViewModel.shared.TIMER_NOTIFICATION_IDENTIFIER)
    }
    
    func resumeTimer() {
        timerStatus = .running
        
        guard timerTimer == timerTimer else {
            createTimer()
            return
        }
        NotificationsViewModel.shared.createTimerNotification(notificationDelay: Double(self.timeRemaining), notificationTitle: "Timer ended", notificationDescription: "Your timer has ended!")
    }
    
    func resetTimer() {
        NotificationsViewModel.shared.removeNotificationRequest(notificationIdentifier: NotificationsViewModel.shared.TIMER_NOTIFICATION_IDENTIFIER)
        
        timerStatus = .stopped
        timeRemaining = 0
        self.timerTimer.invalidate()
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
        formatter.minimumFractionDigits = 0
        
        let formattedSeconds = formatter.string(from: NSNumber(value: timeInSeconds))
        return formattedSeconds!
    }
    
    func timerInBackground() {
        let closeNow = Date.now.timeIntervalSince1970
        var timerRunningValue: String
        
        timerTimer.invalidate()
        
        if (self.timerStatus == .running) {
            timerRunningValue = "on"
        } else if (self.timerStatus == .paused) {
            timerRunningValue = "paused"
        } else {
            timerRunningValue = "off"
        }
        
        UserDefaults.standard.set(self.timeRemaining, forKey: TIMER_REMAINING_FORKEY)
        UserDefaults.standard.set(timerRunningValue, forKey: TIMER_RUNNING_FORKEY)
        UserDefaults.standard.set(closeNow, forKey: CLOSE_DATE_FORKEY)
    }
    
    func timerInForeground() {
        let previousTimeRemaining = UserDefaults.standard.double(forKey: TIMER_REMAINING_FORKEY)
        let closedDate = UserDefaults.standard.double(forKey: CLOSE_DATE_FORKEY)
        let openNow = Date.now.timeIntervalSince1970
        
        let stopwatchRunningValue = UserDefaults.standard.string(forKey: TIMER_RUNNING_FORKEY)
        
        if stopwatchRunningValue == "on" {
            self.timeRemaining = previousTimeRemaining - (openNow - closedDate)
            if self.timeRemaining <= 0 {
                self.timeRemaining = 0
                resetTimer()
            } else {
                startTimer(timerDelaySeconds: self.timeRemaining)
            }
        } else if stopwatchRunningValue == "paused" {
            self.timeRemaining = previousTimeRemaining
            stopTimer()
        } else {
            self.timeRemaining = 0
            resetTimer()
        }
    }
}
