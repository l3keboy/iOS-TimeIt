//
//  ContentView.swift
//  TimeIt
//
//  Created by Luke Hendriks on 04/07/2022.
//

import SwiftUI

struct TimeItView: View {
    var body: some View {
        TabView {
            ClockView()
                .tabItem{
                    Label("Clock", systemImage: "clock")
                }
            TimerView()
                .tabItem{
                    Label("Timer", systemImage: "timer")
                }
            StopwatchView()
                .tabItem{
                    Label("Stopwatch", systemImage: "stopwatch")
                }
        }
    }
}

struct TimeItView_Previews: PreviewProvider {
    static var previews: some View {
        TimeItView()
            .preferredColorScheme(.dark)
    }
}
