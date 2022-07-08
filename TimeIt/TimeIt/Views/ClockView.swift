//
//  ClockView.swift
//  TimeIt
//
//  Created by Luke Hendriks on 04/07/2022.
//

import SwiftUI

struct ClockView: View {
    @Environment(\.timeZone) var timeZone
    @Environment(\.scenePhase) var phase
    
    @ObservedObject private var clockClass = ClockClass()
    
    @State private var showingLocationSheet = false
    
    var body: some View {
        ZStack {
            Color("Primary").ignoresSafeArea()
            VStack {
                VStack {
                    Text("Local time")
                        .font(.system(size: 36))
                        .opacity(0.5)
                        .padding(.vertical, 32)
                    Text("\(clockClass.currentLocalTime)")
                        .font(.system(size: 48))
                        .monospacedDigit()
                    Text("\(timeZone.identifier)")
                        .font(.system(size: 16))
                        .opacity(0.5)
                        .padding(.vertical, 32)
                }
            }
        }
        .onAppear {
            self.clockClass.updateTime(timezone: timeZone)
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                AppManagerViewModel.shared.isActive = true
                clockClass.updateTime(timezone: timeZone)
            case .background:
                AppManagerViewModel.shared.isActive = false
            case .inactive:
                if AppManagerViewModel.shared.isActive == true {
                    clockClass.stopTimeUpdates()
                }
            @unknown default:
                return
            }
        }
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView()
            .preferredColorScheme(.dark)
    }
}
