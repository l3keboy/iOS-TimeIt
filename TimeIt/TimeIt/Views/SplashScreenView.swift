//
//  SplashScreenView.swift
//  TimeIt
//
//  Created by Luke Hendriks on 04/07/2022.
//

import SwiftUI

struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSplash = true
    
    var body: some View {
        ZStack {
            ZStack {
                Color("Primary").ignoresSafeArea()
                
                if colorScheme == .dark {
                    Image("LogoDarkmode")
                } else {
                    Image("LogoLightmode")
                }
            }
            .task {
                await splashScreenDelay()
            }
            if showingSplash != true {
                ZStack {
                    TimeItView()
                }
            }
        }
    }
    
    private func splashScreenDelay() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        withAnimation {
            showingSplash = false
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
            .preferredColorScheme(.dark)
    }
}
