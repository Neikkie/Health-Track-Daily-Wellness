//
//  WelcomeView.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @State private var animateLogo = false
    @State private var animateContent = false
    
    var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "☀️"
        case 12..<17:
            return "🌤️"
        case 17..<21:
            return "🌆"
        default:
            return "🌙"
        }
    }
    
    var currentDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.primaryBlue, Color.primaryPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // Logo with Dove
                VStack(spacing: Spacing.lg) {
                    ZStack {
                        // Outer glow circle
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 160, height: 160)
                        
                        // Inner glow circle
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 140, height: 140)
                        
                        // Dove logo
                        Image("DoveLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 2)
                            )
                    }
                    .scaleEffect(animateLogo ? 1.0 : 0.5)
                    .opacity(animateLogo ? 1.0 : 0.0)
                    
                    Text("Dova Health")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(animateContent ? 1.0 : 0.0)
                    
                    Text("& Wellness")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .opacity(animateContent ? 1.0 : 0.0)
                }
                
                Spacer()
                
                // Greeting section
                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.sm) {
                        Text(greetingEmoji)
                            .font(.system(size: 32))
                        Text(timeBasedGreeting)
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : 20)
                    
                    Text(currentDay)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    // Motivational text
                    Text("Track your wellness journey")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .padding(.top, Spacing.sm)
                }
                .padding(.horizontal, Spacing.xl)
                
                Spacer()
                
                // Get Started button
                Button(action: {
                    HapticManager.impact(style: .medium)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showWelcome = false
                    }
                }) {
                    HStack(spacing: Spacing.sm) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }
                    .foregroundStyle(Color.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(.white)
                    .cornerRadius(CornerRadius.lg)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, Spacing.xl)
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 30)
                .padding(.bottom, Spacing.xl)
            }
        }
        .onAppear {
            // Animate logo
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateLogo = true
            }
            
            // Animate content after logo
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                animateContent = true
            }
        }
    }
}

#Preview {
    WelcomeView(showWelcome: .constant(true))
}
