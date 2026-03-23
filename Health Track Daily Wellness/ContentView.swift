//
//  ContentView.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    @State private var showWelcome = false
    
    var body: some View {
        ZStack {
            // Main app
            TabView {
                DailyLogView()
                    .tabItem {
                        Label("Daily Log", systemImage: "square.and.pencil")
                    }
                
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                
                TrendsView()
                    .tabItem {
                        Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                    }
                
                DashboardView()
                    .tabItem {
                        Label("History", systemImage: "list.bullet")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .preferredColorScheme(.light)
            .opacity((showOnboarding || showWelcome) ? 0 : 1)
            
            // Welcome screen overlay (shows every launch)
            if showWelcome && !showOnboarding {
                WelcomeView(showWelcome: $showWelcome)
                    .transition(.opacity)
                    .zIndex(1)
            }
            
            // Onboarding screen (shows only first time)
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .transition(.opacity)
                    .zIndex(2)
                    .onChange(of: showOnboarding) { _, newValue in
                        if !newValue {
                            hasCompletedOnboarding = true
                            // Show welcome after onboarding
                            withAnimation(.easeInOut.delay(0.3)) {
                                showWelcome = true
                            }
                        }
                    }
            }
        }
        .onAppear {
            if !hasCompletedOnboarding {
                // First time user - show onboarding
                showOnboarding = true
            } else {
                // Returning user - show welcome screen
                showWelcome = true
            }
        }
    }
}

#Preview {
    ContentView()
}
