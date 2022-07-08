//
//  TimerView.swift
//  TimeIt
//
//  Created by Luke Hendriks on 04/07/2022.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.scenePhase) var phase
    
    @ObservedObject private var timerClass = TimerClass()
    
    @State private var hoursInput: String = ""
    @State private var minutesInput: String = ""
    @State private var secondsInput: String = ""
    @State private var seconds: Int = 0
    @State private var showingNotificationAlert = false
    
    var body: some View {
        ZStack {
            Color("Primary").ignoresSafeArea()
            VStack {
                HStack {
                    if timerClass.timerStatus == .stopped {
                        VStack {
                            TextField("00", text: $hoursInput)
                                .frame(width: 75, height: 50, alignment: .center)
                                .border(.primary)
                                .font(.system(size: 32)).monospacedDigit()
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                            
                            Text("Hours")
                                .foregroundColor(.primary)
                                .opacity(0.5)
                        }
                        
                        VStack {
                            TextField("00", text: $minutesInput)
                                .frame(width: 75, height: 50, alignment: .center)
                                .border(.primary)
                                .font(.system(size: 32)).monospacedDigit()
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                            
                            Text("Minutes")
                                .foregroundColor(.primary)
                                .opacity(0.5)
                        }
                        
                        VStack {
                            TextField("00", text: $secondsInput)
                                .frame(width: 75, height: 50, alignment: .center)
                                .border(.primary)
                                .font(.system(size: 32)).monospacedDigit()
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                            
                            Text("Seconds")
                                .foregroundColor(.primary)
                                .opacity(0.5)
                        }
                    } else {
                        let (hours, minutes, seconds) = timerClass.secondsConverter(timeInSeconds: Int(timerClass.timeRemaining))
                        let formattedSeconds = timerClass.formatSeconds(timeInSeconds: Double(seconds))
                        
                        Text(String(format: "%02i:%02i:\(formattedSeconds)",  hours, minutes))
                            .bold()
                            .font(.system(size: 40).monospacedDigit())
                            .padding(.vertical, 15)
                    }
                }
                .padding(.top, 256)
                .padding(.bottom, 106)
                
                HStack {
                    Button("Reset") {
                        timerClass.resetTimer()
                    }
                    .frame(width: 100, height: 50, alignment: .center)
                    .background(Colors.shared.accentColorYellow)
                    .cornerRadius(15)
                    
                    Spacer()
                    
                    if timerClass.timerStatus == .running {
                        Button("Pause") {
                            timerClass.stopTimer()
                        }
                        .frame(width: 100, height: 50, alignment: .center)
                        .background(Colors.shared.accentColorBlue)
                        .cornerRadius(15)
                    } else if timerClass.timerStatus == .paused {
                        Button("Resume") {
                            timerClass.resumeTimer()
                        }
                        .frame(width: 100, height: 50, alignment: .center)
                        .background(Colors.shared.accentColorBlue)
                        .cornerRadius(15)
                    } else {
                        Button("Start") {
                            seconds = ((Int(hoursInput) ?? 0) * 3600) + ((Int(minutesInput) ?? 0) * 60) + (Int(secondsInput) ?? 0)
                            
                            if seconds > 0 {
                                if NotificationsViewModel.shared.userAllowedNotifications == false {
                                    showingNotificationAlert = true
                                }
                                
                                timerClass.startTimer(timerDelaySeconds: Double(seconds))
                                
                                hoursInput = ""
                                minutesInput = ""
                                secondsInput = ""
                            }
                        }
                        .frame(width: 100, height: 50, alignment: .center)
                        .background(Colors.shared.accentColorGreen)
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 518)
            }.foregroundColor(.primary).ignoresSafeArea()
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                AppManagerViewModel.shared.isActive = true
                timerClass.timerInForeground()
                NotificationsViewModel.shared.checkNotificationSettings()
            case .background:
                AppManagerViewModel.shared.isActive = false
            case .inactive:
                if AppManagerViewModel.shared.isActive == true {
                    timerClass.timerInBackground()
                }
            @unknown default:
                return
            }
        }
        .onDisappear() {
            timerClass.timerInBackground()
        }
        .onAppear() {
            timerClass.timerInForeground()
            NotificationsViewModel.shared.checkNotificationSettings()
        }
        .alert("Notifications denied", isPresented: $showingNotificationAlert, actions: {
            Button("Turn on") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }.accentColor(Colors.shared.accentColorBlue)
            Button("Leave off") {
                self.showingNotificationAlert = false
            }.accentColor(Colors.shared.accentColorRed)
        }, message: {
            Text("If you want to get notified when your timer ends, please grant notification permissions in settings!")
        })
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .preferredColorScheme(.dark)
    }
}
