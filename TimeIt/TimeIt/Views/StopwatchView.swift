//
//  StopwatchView.swift
//  TimeIt
//
//  Created by Luke Hendriks on 04/07/2022.
//

import SwiftUI

struct StopwatchView: View {
    @Environment(\.scenePhase) var phase
    
    @ObservedObject private var stopwatchClass = StopwatchClass()
    @State private var secondsToSubtract: Double = 0
    
    var body: some View {
        ZStack {
            Color("Primary").ignoresSafeArea()
            
            VStack {
                let (hours, minutes, seconds) = stopwatchClass.secondsConverter(timeInSeconds: Int(floor(stopwatchClass.secondsElapsed)))
                let formattedSeconds = stopwatchClass.formatSeconds(timeInSeconds: stopwatchClass.secondsElapsed - floor(stopwatchClass.secondsElapsed) + Double(seconds))
                
                Text(String(format: "%02i:%02i:\(formattedSeconds)",  hours, minutes))
                    .bold()
                    .font(.system(size: 40).monospacedDigit())
                    .padding(.vertical, 144)
                
                HStack {
                    if stopwatchClass.stopwatchRunning == .running {
                        Button("TimeIt") {
                            secondsToSubtract = 0
                            for lap in stopwatchClass.laps {
                                secondsToSubtract += lap.time
                            }
                            
                            stopwatchClass.laps.append(LapModel(id: stopwatchClass.lapId, time: stopwatchClass.secondsElapsed - secondsToSubtract))
                            stopwatchClass.lapId += 1
                        }
                        .frame(width: 100, height: 50, alignment: .center)
                        .background(Colors.shared.accentColorBlue)
                        .cornerRadius(15)
                    } else {
                        Button("Reset") {
                            stopwatchClass.reset_timer()
                            stopwatchClass.lapId = 1
                            stopwatchClass.laps = []
                        }
                        .frame(width: 100, height: 50, alignment: .center)
                        .background(Colors.shared.accentColorBlue)
                        .cornerRadius(15)
                    }
                    
                    Spacer()
                    
                    if stopwatchClass.stopwatchRunning == .running {
                        Button("Stop") {
                            stopwatchClass.stop_timer()
                        }
                        .frame(width: 100, height: 50, alignment: .center)
                        .background(Colors.shared.accentColorRed)
                        .cornerRadius(15)
                    } else {
                        Button("Start") {
                            stopwatchClass.start_timer()
                        }
                        .frame(width: 100, height: 50, alignment: .center)
                        .background(Colors.shared.accentColorGreen)
                        .cornerRadius(15)
                    }
                    
                }
                .padding(.horizontal, 50)
                
                List(stopwatchClass.laps.reversed()) { lap in
                    HStack {
                        Text("Lap \(lap.id)")
                        
                        Spacer()
                        
                        let (hours, minutes, seconds) = stopwatchClass.secondsConverter(timeInSeconds: Int(floor(lap.time)))
                        let formattedSeconds = stopwatchClass.formatSeconds(timeInSeconds: lap.time - floor(lap.time) + Double(seconds))
                        Text(String(format: "%02i:%02i:\(formattedSeconds)",  hours, minutes))
                    }
                }
            }.foregroundColor(.primary).ignoresSafeArea()
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                AppManagerViewModel.shared.isActive = true
                stopwatchClass.stopwatchInForeground()
            case .background:
                AppManagerViewModel.shared.isActive = false
            case .inactive:
                if AppManagerViewModel.shared.isActive == true {
                    stopwatchClass.stopwatchInBackground()
                }
            @unknown default:
                return
            }
        }
        .onDisappear() {
            stopwatchClass.stopwatchInBackground()
        }
        .onAppear() {
            stopwatchClass.stopwatchInForeground()
        }
    }
}

struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        StopwatchView()
            .preferredColorScheme(.dark)
    }
}
