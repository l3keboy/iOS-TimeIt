//
//  TimeItApp.swift
//  TimeIt
//
//  Created by Luke Hendriks on 04/07/2022.
//

import SwiftUI

@main
struct TimeItApp: App {
    
    init() {
        NotificationsViewModel.shared.requestPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
