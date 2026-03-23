//
//  OnboardingView.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    @State private var animateContent = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "heart.text.square.fill",
            title: "Welcome to Dova",
            subtitle: "Your Personal Wellness Companion",
            description: "Track your daily health, mood, and wellness journey all in one beautiful app.",
            color: .primaryBlue
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Everything",
            subtitle: "Comprehensive Health Logging",
            description: "Monitor symptoms, mood, energy, sleep, water intake, exercise, medications, and more.",
            color: .primaryPurple
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Discover Patterns",
            subtitle: "Intelligent Insights",
            description: "Visualize trends, spot correlations, and understand what affects your wellness.",
            color: .moodExcellent
        ),
        OnboardingPage(
            icon: "calendar.badge.clock",
            title: "Stay Consistent",
            subtitle: "Build Healthy Habits",
            description: "Set reminders, track streaks, and make wellness tracking a natural part of your routine.",
            color: .exerciseOrange
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient based on current page
            LinearGradient(
                colors: [pages[currentPage].color, pages[currentPage].color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.selection()
                        withAnimation(.spring()) {
                            showOnboarding = false
                        }
                    }) {
                        Text("Skip")
                            .font(WellnessFont.callout)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.lg)
                
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Page indicator and buttons
                VStack(spacing: Spacing.xl) {
                    // Custom page indicator
                    HStack(spacing: Spacing.sm) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? .white : .white.opacity(0.4))
                                .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    
                    // Action button
                    Button(action: {
                        HapticManager.impact(style: .medium)
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(.spring()) {
                                showOnboarding = false
                            }
                        }
                    }) {
                        HStack(spacing: Spacing.sm) {
                            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                                .font(WellnessFont.headline)
                            Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(pages[currentPage].color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(.white)
                        .cornerRadius(CornerRadius.lg)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .padding(.bottom, Spacing.xxl)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Icon
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 160, height: 160)
                
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.icon)
                    .font(.system(size: 70))
                    .foregroundStyle(.white)
            }
            .scaleEffect(animate ? 1.0 : 0.8)
            .opacity(animate ? 1.0 : 0.0)
            
            VStack(spacing: Spacing.md) {
                // Title
                Text(page.title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 20)
                
                // Subtitle
                Text(page.subtitle)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 20)
                
                // Description
                Text(page.description)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.sm)
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 20)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animate = true
            }
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
