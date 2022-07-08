//
//  ClockViewModel.swift
//  TimeIt
//
//  Created by Luke Hendriks on 06/07/2022.
//

import Foundation

class ClockClass: ObservableObject {
    @Published var currentLocalTime: String = ""
    
    private var timer = Timer()
    
    func updateTime(timezone: TimeZone) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.currentLocalTime = self.formatTime(timezone: timezone)
        }
    }
    
    func stopTimeUpdates() {
        timer.invalidate()
    }
    
    func formatTime(timezone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = timezone
        
        return formatter.string(from: Date())
    }
}
