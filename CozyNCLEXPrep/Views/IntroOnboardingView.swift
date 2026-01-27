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

    enum PageType {
        case standard
        case sources
        case categories
    }

    private let pages: [(title: String, subtitle: String, icon: String, color: Color, pageType: PageType)] = [
        ("Welcome to CozyNCLEX!", "Your cozy companion for NCLEX success", "heart.fill", .pastelPink, .standard),
        ("Master the NCLEX", "Master all 4 Client Needs categories to pass", "target", .mintGreen, .categories),
        ("Trusted Sources", "Content compiled from leading NCLEX prep resources", "checkmark.seal.fill", .skyBlue, .sources),
        ("Track Progress", "Watch yourself grow with detailed stats", "chart.line.uptrend.xyaxis", .softLavender, .standard),
        ("Let's Get Started!", "Create your account to begin your nursing journey", "star.fill", .mintGreen, .standard)
    ]

    var body: some View {
        ZStack {
            // Animated gradient background
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
                // Dynamic top spacing based on screen height
                Spacer().frame(height: geo.size.height * 0.05)

                // Mascot - proportional to screen
                Image("NurseBear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geo.size.width * 0.38, 160), height: min(geo.size.width * 0.38, 160))
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .offset(y: mascotOffset)
                    .opacity(mascotOpacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                            mascotOffset = 0
                            mascotOpacity = 1
                        }
                    }

                Spacer().frame(height: geo.size.height * 0.02)

                // Page content - fixed height container for consistency
                VStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(pages[currentPage].color.opacity(0.2))
                            .frame(width: min(geo.size.width * 0.17, 70), height: min(geo.size.width * 0.17, 70))

                        Image(systemName: pages[currentPage].icon)
                            .font(.system(size: min(geo.size.width * 0.08, 32)))
                            .foregroundColor(pages[currentPage].color)
                    }
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                    // Title
                    Text(pages[currentPage].title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .offset(y: showContent ? 0 : 20)
                        .opacity(showContent ? 1 : 0)

                    // Subtitle
                    Text(pages[currentPage].subtitle)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .offset(y: showContent ? 0 : 20)
                        .opacity(showContent ? 1 : 0)

                    // Categories page - NCLEX mastery explanation
                    if pages[currentPage].pageType == .categories {
                        VStack(spacing: 16) {
                            // Category cards
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

                            // Bottom message
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

                    // Sources list for credentials page - scrollable if needed
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
                }
                .frame(maxHeight: .infinity)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showContent)
                .onChange(of: currentPage) { _, _ in
                    showContent = false
                    categoryAnimationProgress = [false, false, false, false]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation { showContent = true }
                        if pages[currentPage].pageType == .categories {
                            animateCategoriesSequentially()
                        }
                    }
                }

                Spacer(minLength: 20)

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? pages[currentPage].color : Color.gray.opacity(0.3))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, geo.size.height * 0.02)

                // Buttons
                VStack(spacing: 12) {
                    if currentPage < pages.count - 1 {
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

                        Button(action: { onComplete() }) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
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
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, geo.size.height * 0.04)
            }
            } // GeometryReader
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showContent = true }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 && currentPage < pages.count - 1 {
                        nextPage()
                    } else if value.translation.width > 50 && currentPage > 0 {
                        previousPage()
                    }
                }
        )
    }

    private func nextPage() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentPage += 1
        }
    }

    private func previousPage() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentPage -= 1
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

    // NCLEX Categories data
    private var nclexCategories: [(icon: String, name: String, description: String, color: Color)] {
        [
            ("shield.checkered", "Safe & Effective Care", "Infection control, safety, legal & ethical", .skyBlue),
            ("heart.circle", "Health Promotion", "Wellness, prevention & screening", .mintGreen),
            ("brain.head.profile", "Psychosocial Integrity", "Mental health & coping", .softLavender),
            ("waveform.path.ecg", "Physiological Integrity", "Body systems & pharmacology", .pastelPink)
        ]
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
            // Icon circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            // Text
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

            // Checkmark
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
