//
//  DesignSystem.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI

// MARK: - Color Theme
extension Color {
    // Primary Colors
    static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 0.99)
    static let primaryPurple = Color(red: 0.58, green: 0.40, blue: 0.99)
    
    // Mood Colors
    static let moodExcellent = Color(red: 0.30, green: 0.85, blue: 0.39)
    static let moodGood = Color(red: 0.20, green: 0.78, blue: 0.95)
    static let moodFair = Color(red: 0.99, green: 0.73, blue: 0.22)
    static let moodPoor = Color(red: 0.99, green: 0.45, blue: 0.38)
    
    // Metric Colors
    static let energyYellow = Color(red: 0.99, green: 0.80, blue: 0.20)
    static let sleepPurple = Color(red: 0.69, green: 0.51, blue: 0.99)
    static let waterCyan = Color(red: 0.20, green: 0.78, blue: 0.88)
    static let exerciseOrange = Color(red: 0.99, green: 0.58, blue: 0.20)
    
    // UI Colors
    static let cardBackground = Color(.systemBackground)
    static let secondaryCardBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
}

// MARK: - Typography
struct WellnessFont {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Spacing
struct Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

// MARK: - Shadows
struct ShadowStyle {
    static func light() -> some View {
        Color.black.opacity(0.05)
    }
    
    static func medium() -> some View {
        Color.black.opacity(0.1)
    }
    
    static func heavy() -> some View {
        Color.black.opacity(0.15)
    }
}

// MARK: - Custom View Modifiers
struct CardStyle: ViewModifier {
    var padding: CGFloat = Spacing.md
    var cornerRadius: CGFloat = CornerRadius.lg
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct GlassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = .primaryBlue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WellnessFont.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WellnessFont.callout)
            .foregroundStyle(.primary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(Color.secondaryCardBackground)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Custom Components

struct GradientCard<Content: View>: View {
    let gradient: LinearGradient
    let content: Content
    
    init(colors: [Color], @ViewBuilder content: () -> Content) {
        self.gradient = LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Spacing.md)
            .background(gradient)
            .cornerRadius(CornerRadius.lg)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct AnimatedCheckmark: View {
    @State private var animate = false
    
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 60))
            .foregroundStyle(.green)
            .scaleEffect(animate ? 1.0 : 0.5)
            .opacity(animate ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    animate = true
                }
            }
    }
}

struct PulsingCircle: View {
    @State private var animate = false
    var color: Color = .blue
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .frame(width: 20, height: 20)
            .scaleEffect(animate ? 1.5 : 1.0)
            .opacity(animate ? 0.0 : 1.0)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
    }
}

struct BouncingIcon: View {
    let systemName: String
    let color: Color
    @State private var bounce = false
    
    var body: some View {
        Image(systemName: systemName)
            .foregroundStyle(color)
            .offset(y: bounce ? -5 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    bounce = true
                }
            }
    }
}

// MARK: - Haptic Feedback
struct HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(padding: CGFloat = Spacing.md, cornerRadius: CGFloat = CornerRadius.lg) -> some View {
        modifier(CardStyle(padding: padding, cornerRadius: cornerRadius))
    }
    
    func glassCard() -> some View {
        modifier(GlassCardStyle())
    }
    
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

// MARK: - Loading States
struct LoadingView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .font(WellnessFont.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(WellnessFont.title2)
                .fontWeight(.bold)
            
            Text(description)
                .font(WellnessFont.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
        }
        .padding(Spacing.xl)
    }
}
