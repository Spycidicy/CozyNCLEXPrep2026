//
//  IntroOnboardingView.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import SwiftUI

struct IntroOnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0
    @State private var showContent = false
    @State private var mascotOffset: CGFloat = 50
    @State private var mascotOpacity: Double = 0
    @State private var categoryAnimationProgress: [Bool] = [false, false, false, false]
    @State private var typingText: String = ""
    @State private var bearWiggle: Double = 0
    @State private var promiseChecks: [Bool] = [false, false, false]
    @State private var showPromiseButton = false
    @State private var statsAnimated = false
    @State private var featureAnimationProgress: [Bool] = [false, false, false, false]
    @State private var pulseScale: CGFloat = 1.0

    enum PageType {
        case welcome
        case painPoint
        case categories
        case sources
        case features
        case promise
        case getStarted
    }

    private let pages: [(title: String, subtitle: String, icon: String, color: Color, pageType: PageType)] = [
        ("Hey future nurse!", "I'm CozyBear, and I'm here to help you crush the NCLEX", "hand.wave.fill", .pastelPink, .welcome),
        ("The NCLEX is tough.", "42% of repeat test-takers fail again. But not you.", "exclamationmark.triangle.fill", .softLavender, .painPoint),
        ("4 Categories to Master", "The NCLEX tests these areas — we cover all of them", "target", .mintGreen, .categories),
        ("Trusted Sources", "Content compiled from leading NCLEX prep resources", "checkmark.seal.fill", .skyBlue, .sources),
        ("Study Smarter", "Everything you need, nothing you don't", "sparkles", .skyBlue, .features),
        ("Make a Promise", "Students who commit to daily practice are 3x more likely to pass", "heart.fill", .pastelPink, .promise),
        ("You're Ready!", "Let's turn that anxiety into confidence", "star.fill", .mintGreen, .getStarted)
    ]

    private let fullWelcomeText = "I'm CozyBear, and I'm here to help you crush the NCLEX"

    // NCLEX Categories data
    private var nclexCategories: [(icon: String, name: String, description: String, color: Color)] {
        [
            ("shield.checkered", "Safe & Effective Care", "Infection control, safety, legal & ethical", .skyBlue),
            ("heart.circle", "Health Promotion", "Wellness, prevention & screening", .mintGreen),
            ("brain.head.profile", "Psychosocial Integrity", "Mental health & coping", .softLavender),
            ("waveform.path.ecg", "Physiological Integrity", "Body systems & pharmacology", .pastelPink)
        ]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    pages[currentPage].color.opacity(0.2),
                    Color.creamyBackground,
                    Color.creamyBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)

            GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer().frame(height: geo.size.height * 0.04)

                Image("NurseBear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geo.size.width * 0.35, 150), height: min(geo.size.width * 0.35, 150))
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .offset(y: mascotOffset)
                    .opacity(mascotOpacity)
                    .rotationEffect(.degrees(bearWiggle))
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                            mascotOffset = 0
                            mascotOpacity = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true)) {
                                bearWiggle = 3
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    bearWiggle = 0
                                }
                            }
                        }
                    }

                Spacer().frame(height: geo.size.height * 0.02)

                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(pages[currentPage].color.opacity(0.2))
                            .frame(width: min(geo.size.width * 0.17, 70), height: min(geo.size.width * 0.17, 70))
                            .scaleEffect(pulseScale)

                        Image(systemName: pages[currentPage].icon)
                            .font(.system(size: min(geo.size.width * 0.08, 32)))
                            .foregroundColor(pages[currentPage].color)
                    }
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                    Text(pages[currentPage].title)
                        .font(.system(size: min(geo.size.width * 0.065, 26), weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .offset(y: showContent ? 0 : 20)
                        .opacity(showContent ? 1 : 0)

                    if pages[currentPage].pageType == .welcome {
                        Text(typingText)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .frame(minHeight: 40)
                    } else {
                        Text(pages[currentPage].subtitle)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .offset(y: showContent ? 0 : 20)
                            .opacity(showContent ? 1 : 0)
                    }

                    // MARK: - Pain Point page
                    if pages[currentPage].pageType == .painPoint {
                        VStack(spacing: 16) {
                            HStack(spacing: 20) {
                                OnboardingStatBubble(value: "400+", label: "Questions", color: .skyBlue, isAnimated: statsAnimated)
                                OnboardingStatBubble(value: "9", label: "Categories", color: .mintGreen, isAnimated: statsAnimated)
                                OnboardingStatBubble(value: "24/7", label: "Access", color: .softLavender, isAnimated: statsAnimated)
                            }
                            .padding(.top, 8)

                            HStack(spacing: 10) {
                                Image(systemName: "shield.checkered")
                                    .font(.system(size: 18))
                                    .foregroundColor(.mintGreen)
                                Text("We've got you covered")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.mintGreen.opacity(0.12))
                            .cornerRadius(20)
                            .scaleEffect(statsAnimated ? 1 : 0.8)
                            .opacity(statsAnimated ? 1 : 0)
                        }
                        .offset(y: showContent ? 0 : 30)
                        .opacity(showContent ? 1 : 0)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    statsAnimated = true
                                }
                            }
                        }
                    }

                    // MARK: - Categories page
                    if pages[currentPage].pageType == .categories {
                        VStack(spacing: 16) {
                            VStack(spacing: 10) {
                                ForEach(Array(nclexCategories.enumerated()), id: \.offset) { index, category in
                                    OnboardingCategoryCard(
                                        icon: category.icon,
                                        name: category.name,
                                        description: category.description,
                                        color: category.color,
                                        isAnimated: categoryAnimationProgress[index]
                                    )
                                }
                            }
                            .padding(.horizontal)

                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.mintGreen)
                                Text("Master all 4 = Pass the NCLEX")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.mintGreen.opacity(0.15))
                            .cornerRadius(20)
                            .scaleEffect(categoryAnimationProgress[3] ? 1 : 0.8)
                            .opacity(categoryAnimationProgress[3] ? 1 : 0)
                        }
                        .offset(y: showContent ? 0 : 30)
                        .opacity(showContent ? 1 : 0)
                        .onAppear {
                            animateCategoriesSequentially()
                        }
                    }

                    // MARK: - Sources page
                    if pages[currentPage].pageType == .sources {
                        ScrollView {
                            VStack(spacing: 10) {
                                SourceBadgeView(name: "Kaplan", color: .blue)
                                SourceBadgeView(name: "Archer Review", color: .green)
                                SourceBadgeView(name: "UWorld", color: .orange)
                                SourceBadgeView(name: "NCSBN", color: .purple)
                                SourceBadgeView(name: "CAT Methodology", color: .pink)
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                        .offset(y: showContent ? 0 : 30)
                        .opacity(showContent ? 1 : 0)
                    }

                    // MARK: - Features page
                    if pages[currentPage].pageType == .features {
                        VStack(spacing: 12) {
                            OnboardingFeatureRow(icon: "bolt.fill", title: "Quick Study Mode", description: "5-minute sessions that fit your schedule", color: .orange, isAnimated: featureAnimationProgress[0])
                            OnboardingFeatureRow(icon: "brain.head.profile", title: "Spaced Repetition", description: "Focus on what you get wrong", color: .softLavender, isAnimated: featureAnimationProgress[1])
                            OnboardingFeatureRow(icon: "checkmark.seal.fill", title: "NCLEX Readiness", description: "Know exactly when you're ready to test", color: .mintGreen, isAnimated: featureAnimationProgress[2])
                            OnboardingFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Tracking", description: "Watch your confidence grow daily", color: .skyBlue, isAnimated: featureAnimationProgress[3])
                        }
                        .padding(.horizontal)
                        .offset(y: showContent ? 0 : 30)
                        .opacity(showContent ? 1 : 0)
                        .onAppear {
                            animateFeaturesSequentially()
                        }
                    }

                    // MARK: - Promise page
                    if pages[currentPage].pageType == .promise {
                        VStack(spacing: 14) {
                            OnboardingPromiseRow(text: "I'll study a little every day", isChecked: promiseChecks[0], delay: 0) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { promiseChecks[0].toggle() }
                                checkAllPromises()
                            }
                            OnboardingPromiseRow(text: "I won't give up when it gets hard", isChecked: promiseChecks[1], delay: 1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { promiseChecks[1].toggle() }
                                checkAllPromises()
                            }
                            OnboardingPromiseRow(text: "I believe I can pass the NCLEX", isChecked: promiseChecks[2], delay: 2) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { promiseChecks[2].toggle() }
                                checkAllPromises()
                            }
                        }
                        .padding(.horizontal, 20)
                        .offset(y: showContent ? 0 : 30)
                        .opacity(showContent ? 1 : 0)
                    }

                    // MARK: - Get Started page
                    if pages[currentPage].pageType == .getStarted {
                        VStack(spacing: 12) {
                            HStack(spacing: 6) {
                                ForEach(0..<5) { _ in
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 16))
                                }
                            }
                            .opacity(showContent ? 1 : 0)

                            Text("\"This app made studying actually fun.\nI passed on my first try!\"")
                                .font(.system(size: 14, design: .rounded))
                                .italic()
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .opacity(showContent ? 1 : 0)

                            Text("— CozyNCLEX Student")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.primary.opacity(0.6))
                                .opacity(showContent ? 1 : 0)
                        }
                        .padding(.top, 8)
                    }
                }
                .frame(maxHeight: .infinity)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showContent)
                .onChange(of: currentPage) { _, _ in
                    showContent = false
                    categoryAnimationProgress = [false, false, false, false]
                    featureAnimationProgress = [false, false, false, false]
                    statsAnimated = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation { showContent = true }
                        if pages[currentPage].pageType == .categories {
                            animateCategoriesSequentially()
                        }
                        if pages[currentPage].pageType == .features {
                            animateFeaturesSequentially()
                        }
                        if pages[currentPage].pageType == .welcome {
                            startTypingAnimation()
                        }
                        if pages[currentPage].pageType == .painPoint {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    statsAnimated = true
                                }
                            }
                        }
                    }
                }

                Spacer(minLength: 20)

                // Page indicators — progress bar style
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentPage ? pages[currentPage].color : Color.gray.opacity(0.25))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, geo.size.height * 0.02)

                // Buttons
                VStack(spacing: 12) {
                    if pages[currentPage].pageType == .promise {
                        Button(action: nextPage) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                Text("I Promise")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [.pastelPink, .pastelPink.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        .opacity(showPromiseButton ? 1 : 0.4)
                        .scaleEffect(showPromiseButton ? 1 : 0.95)
                        .disabled(!showPromiseButton)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showPromiseButton)
                    } else if currentPage < pages.count - 1 {
                        Button(action: nextPage) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [pages[currentPage].color, pages[currentPage].color.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                    } else {
                        Button(action: { onComplete() }) {
                            HStack {
                                Text("Create Account")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [.mintGreen, .green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .scaleEffect(pulseScale)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                                    pulseScale = 1.03
                                }
                            }
                        }

                        Button(action: { onComplete() }) {
                            Text("Already have an account? **Log In**")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }

                    if currentPage < pages.count - 1 && pages[currentPage].pageType != .promise {
                        Button(action: { onComplete() }) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, geo.size.height * 0.04)
            }
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
            } // GeometryReader
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showContent = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                startTypingAnimation()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 && currentPage < pages.count - 1 {
                        if pages[currentPage].pageType == .promise && !showPromiseButton { return }
                        nextPage()
                    } else if value.translation.width > 50 && currentPage > 0 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage -= 1
                        }
                    }
                }
        )
    }

    private func nextPage() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentPage += 1
        }
    }

    private func startTypingAnimation() {
        typingText = ""
        let characters = Array(fullWelcomeText)
        for (index, character) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                typingText += String(character)
            }
        }
    }

    private func animateCategoriesSequentially() {
        for index in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15 + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    categoryAnimationProgress[index] = true
                }
            }
        }
    }

    private func animateFeaturesSequentially() {
        for index in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.18 + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    featureAnimationProgress[index] = true
                }
            }
        }
    }

    private func checkAllPromises() {
        if promiseChecks.allSatisfy({ $0 }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showPromiseButton = true
                }
                withAnimation(.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true)) {
                    bearWiggle = 3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        bearWiggle = 0
                    }
                }
            }
        }
    }
}

// MARK: - Onboarding Category Card

struct OnboardingCategoryCard: View {
    let icon: String
    let name: String
    let description: String
    let color: Color
    let isAnimated: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(color)
                .scaleEffect(isAnimated ? 1 : 0)
                .opacity(isAnimated ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.adaptiveWhite)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .scaleEffect(isAnimated ? 1 : 0.9)
        .opacity(isAnimated ? 1 : 0.3)
    }
}

// MARK: - Source Badge View

struct SourceBadgeView: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(name)
                .font(.system(size: 14, weight: .medium, design: .rounded))
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.adaptiveWhite)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

#Preview {
    IntroOnboardingView(onComplete: {})
}
