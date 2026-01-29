//
//  EngagementViews.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import SwiftUI
import UIKit

// MARK: - Daily Motivation View

struct DailyMotivationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var animateIn = false
    @State private var showQuote = false

    private let quote: MotivationalQuote
    var onDismiss: (() -> Void)?

    init(onDismiss: (() -> Void)? = nil) {
        self.quote = MotivationalQuote.randomForToday()
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [quote.color.opacity(0.9), quote.color.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Bear mascot
                Image("NurseBear")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)

                // Quote
                VStack(spacing: 16) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(showQuote ? 1 : 0)

                    Text(quote.text)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .opacity(showQuote ? 1 : 0)
                        .offset(y: showQuote ? 0 : 20)

                    if let author = quote.author {
                        Text("— \(author)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(showQuote ? 1 : 0)
                    }
                }

                Spacer()

                // Start Button
                Button(action: {
                    HapticManager.shared.success()
                    onDismiss?()
                    dismiss()
                }) {
                    HStack(spacing: 10) {
                        Text("Let's Study!")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(quote.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                }
                .padding(.horizontal, 40)
                .opacity(showQuote ? 1 : 0)
                .offset(y: showQuote ? 0 : 30)

                // Skip text
                Button("Skip") {
                    onDismiss?()
                    dismiss()
                }
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 30)
                .opacity(showQuote ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateIn = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showQuote = true
            }
        }
    }
}

// MARK: - Motivational Quote Model

struct MotivationalQuote {
    let text: String
    let author: String?
    let color: Color

    static let quotes: [MotivationalQuote] = [
        MotivationalQuote(text: "You are going to pass the NCLEX. Believe it.", author: "CozyBear", color: .mintGreen),
        MotivationalQuote(text: "Every card you study brings you closer to your RN.", author: "CozyBear", color: .blue),
        MotivationalQuote(text: "You didn't come this far to only come this far.", author: "CozyBear", color: .purple),
        MotivationalQuote(text: "Future nurses don't quit. Neither will you.", author: "CozyBear", color: .green),
        MotivationalQuote(text: "Your patients are waiting for you. Keep going.", author: "CozyBear", color: .orange),
        MotivationalQuote(text: "Difficult roads lead to beautiful destinations \u{2014} like your nursing career.", author: "CozyBear", color: .pink),
        MotivationalQuote(text: "You are more prepared than you think.", author: "CozyBear", color: .teal),
        MotivationalQuote(text: "One question at a time. One day at a time. You've got this.", author: "CozyBear", color: .indigo),
        MotivationalQuote(text: "The NCLEX is just one test. You are a whole nurse.", author: "CozyBear", color: .mint),
        MotivationalQuote(text: "Your dedication today is tomorrow's confidence.", author: "CozyBear", color: .cyan),
        MotivationalQuote(text: "Nursing school didn't break you. The NCLEX won't either.", author: "CozyBear", color: .red),
        MotivationalQuote(text: "You're not just studying \u{2014} you're building a career that saves lives.", author: "CozyBear", color: .purple),
        MotivationalQuote(text: "Every expert was once a beginner. You're almost there.", author: "CozyBear", color: .blue),
        MotivationalQuote(text: "Trust your preparation. Trust yourself.", author: "CozyBear", color: .green),
        MotivationalQuote(text: "You are capable of hard things \u{2014} and passing the NCLEX is one of them.", author: "CozyBear", color: .orange),
        MotivationalQuote(text: "The world needs more nurses like you.", author: "CozyBear", color: .pink),
        MotivationalQuote(text: "Progress, not perfection. You're doing great.", author: "CozyBear", color: .teal),
        MotivationalQuote(text: "This time next year, you'll be glad you didn't give up today.", author: "CozyBear", color: .indigo),
        MotivationalQuote(text: "You have the knowledge. You have the heart. You will pass.", author: "CozyBear", color: .mint),
        MotivationalQuote(text: "CozyBear believes in you. Now believe in yourself.", author: "CozyBear", color: .mintGreen),
    ]

    static func randomForToday() -> MotivationalQuote {
        // Use day of year as seed for consistent daily quote
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % quotes.count
        return quotes[index]
    }
}

// MARK: - Milestone Celebration View

struct MilestoneCelebrationView: View {
    let milestone: Int
    let onDismiss: () -> Void

    @State private var animateIn = false
    @State private var showConfetti = false
    @State private var starRotation: Double = 0

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // Confetti - uses existing ConfettiView from ContentView
            if showConfetti {
                MilestoneConfettiView()
            }

            // Content
            VStack(spacing: 24) {
                // Animated Star Badge
                ZStack {
                    GeometryReader { badgeGeo in
                    let badgeSize = min(badgeGeo.size.width * 0.3, 120)
                    let glowSize = badgeSize * 1.33
                    ZStack {
                    // Glow effect
                    Circle()
                        .fill(milestoneColor.opacity(0.3))
                        .frame(width: glowSize, height: glowSize)
                        .blur(radius: 20)

                    // Rotating rays
                    ForEach(0..<12, id: \.self) { i in
                        Rectangle()
                            .fill(milestoneColor.opacity(0.6))
                            .frame(width: 4, height: badgeSize * 0.67)
                            .offset(y: -badgeSize * 0.5)
                            .rotationEffect(.degrees(Double(i) * 30 + starRotation))
                    }

                    // Main badge
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [milestoneColor, milestoneColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: badgeSize, height: badgeSize)
                        .shadow(color: milestoneColor.opacity(0.5), radius: 15, y: 5)

                    // Number
                    Text("\(milestone)")
                        .font(.system(size: badgeSize * 0.33, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } // GeometryReader
                    .frame(height: 180)
                }
                .scaleEffect(animateIn ? 1 : 0.3)
                .opacity(animateIn ? 1 : 0)

                // Title
                VStack(spacing: 8) {
                    Text("INCREDIBLE!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(milestoneColor)
                        .tracking(4)

                    Text("\(milestone) Cards Mastered!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(milestoneMessage)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .offset(y: animateIn ? 0 : 30)
                .opacity(animateIn ? 1 : 0)

                // Reward
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("+\(milestoneXP) Bonus XP")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(25)
                .offset(y: animateIn ? 0 : 20)
                .opacity(animateIn ? 1 : 0)

                // Share & Continue Buttons
                VStack(spacing: 12) {
                    ShareMilestoneButton(milestone: milestone)

                    Button(action: {
                        HapticManager.shared.light()
                        onDismiss()
                    }) {
                        Text("Continue Studying")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
                .offset(y: animateIn ? 0 : 30)
                .opacity(animateIn ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateIn = true
            }

            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                starRotation = 360
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
                HapticManager.shared.achievement()
                SoundManager.shared.levelUp()
            }
        }
    }

    private var milestoneColor: Color {
        switch milestone {
        case 100: return .mintGreen
        case 500: return .blue
        case 1000: return .purple
        default: return .orange
        }
    }

    private var milestoneMessage: String {
        switch milestone {
        case 100: return "You're building a solid foundation!"
        case 500: return "Halfway to becoming an expert!"
        case 1000: return "You're NCLEX ready! Legendary status!"
        default: return "Keep up the amazing work!"
        }
    }

    private var milestoneXP: Int {
        switch milestone {
        case 100: return 200
        case 500: return 500
        case 1000: return 1000
        default: return 100
        }
    }
}

// MARK: - Share Milestone Button

struct ShareMilestoneButton: View {
    let milestone: Int
    @State private var renderedImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        Button(action: {
            generateAndShare()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                Text("Share Achievement")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.adaptiveWhite)
            .cornerRadius(14)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ShareSheet(items: [image])
            }
        }
    }

    private func generateAndShare() {
        let cardView = MilestoneShareCard(milestone: milestone)
            .frame(width: min(UIScreen.main.bounds.width - 20, 380))

        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0

        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
            showShareSheet = true
        }
    }
}

// MARK: - Milestone Share Card (Image Export)

struct MilestoneShareCard: View {
    let milestone: Int

    var body: some View {
        VStack(spacing: 0) {
            // Gradient Header with Trophy
            ZStack {
                LinearGradient(
                    colors: [milestoneColor, milestoneColor.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 12) {
                    // Trophy Icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 100, height: 100)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }

                    Text("MILESTONE ACHIEVED!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(2)

                    Text("\(milestone)")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("Cards Mastered")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.vertical, 30)
            }

            // Bottom Section
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image("NurseBear")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("CozyNCLEX Prep")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text("Preparing for my nursing career!")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                Divider()

                Text("One card at a time, one step closer to my dream.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.15), radius: 15, y: 8)
    }

    private var milestoneColor: Color {
        switch milestone {
        case 0..<50: return .blue
        case 50..<100: return .green
        case 100..<250: return .purple
        case 250..<500: return .orange
        default: return .yellow
        }
    }
}

// MARK: - Share Sheet (UIKit wrapper)

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Milestone Confetti View

struct MilestoneConfettiView: View {
    @State private var particles: [MilestoneParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    MilestoneConfettiPieceView(particle: particle)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .mint]
        for i in 0..<60 {
            let particle = MilestoneParticle(
                id: i,
                x: CGFloat.random(in: 0...size.width),
                color: colors.randomElement() ?? .red,
                size: CGFloat.random(in: 8...16),
                delay: Double.random(in: 0...0.8)
            )
            particles.append(particle)
        }
    }
}

struct MilestoneParticle: Identifiable {
    let id: Int
    let x: CGFloat
    let color: Color
    let size: CGFloat
    let delay: Double
}

struct MilestoneConfettiPieceView: View {
    let particle: MilestoneParticle
    @State private var animate = false

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 0.6)
            .rotationEffect(.degrees(animate ? Double.random(in: 360...720) : 0))
            .position(x: particle.x + (animate ? CGFloat.random(in: -50...50) : 0),
                      y: animate ? 1000 : -20)
            .animation(
                .easeIn(duration: Double.random(in: 2.5...4))
                .delay(particle.delay),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}

// MARK: - NCLEX Readiness View

struct NCLEXReadinessView: View {
    let masteredCount: Int
    let totalCards: Int
    let categoryProgress: [ContentCategory: Double]
    let averageAccuracy: Double
    var isPremium: Bool = true
    var onUpgradeTapped: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("NCLEX Readiness")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            if !isPremium {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.yellow)
                            }
                        }
                        Text(isPremium ? currentStage.subtitle : "Premium Feature")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()

                    // Circular Progress
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                            .frame(width: 70, height: 70)

                        Circle()
                            .trim(from: 0, to: isPremium ? overallReadiness : 0.42)
                            .stroke(isPremium ? readinessColor : Color.orange.opacity(0.4), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 70, height: 70)
                            .rotationEffect(.degrees(-90))

                        if isPremium {
                            Text("\(Int(overallReadiness * 100))%")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(readinessColor)
                        } else {
                            Text("42%")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(.orange)
                                .blur(radius: 8)
                        }

                        if !isPremium {
                            Button(action: { onUpgradeTapped?() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 10))
                                    Text("View Score")
                                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(8)
                            }
                            .offset(y: 44)
                        }
                    }
                }
                .padding()
                .background(Color.adaptiveWhite)
                .cornerRadius(16)

                // Progress Path
                VStack(spacing: 0) {
                    ForEach(ReadinessStage.allCases, id: \.self) { stage in
                        ReadinessStageRow(
                            stage: stage,
                            isCompleted: isPremium ? currentStage.rawValue > stage.rawValue : false,
                            isCurrent: isPremium ? currentStage == stage : (stage == .beginner),
                            progress: isPremium ? stageProgress(for: stage) : (stage == .beginner ? 0.65 : 0.0),
                            isLocked: !isPremium
                        )
                    }
                }
                .padding()
                .background(Color.adaptiveWhite)
                .cornerRadius(16)

                // Requirements for next stage (or upgrade prompt)
                if !isPremium {
                    // Upgrade prompt for non-premium users
                    VStack(spacing: 12) {
                        Text("Track Your NCLEX Readiness")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Get personalized readiness scores, track progress across all categories, and know when you're ready for the exam.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button(action: { onUpgradeTapped?() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 14))
                                Text("Unlock with Premium")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.adaptiveWhite)
                    .cornerRadius(12)
                } else if currentStage != .ready {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("To reach \(nextStage.title):")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        ForEach(requirementsForNextStage, id: \.self) { requirement in
                            HStack(spacing: 8) {
                                Image(systemName: "circle")
                                    .font(.system(size: 6))
                                    .foregroundColor(.secondary)
                                Text(requirement)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.adaptiveWhite)
                    .cornerRadius(12)
                }

                // Stats Summary — always visible, shows real data (capped for free)
                HStack(spacing: 12) {
                    ReadinessStatBox(
                        title: "Mastered",
                        value: isPremium ? "\(masteredCount)/\(requiredMasteryForReady)" : "\(masteredCount)/50",
                        icon: "star.fill",
                        color: isPremium ? .yellow : .orange
                    )

                    ReadinessStatBox(
                        title: "Accuracy",
                        value: "\(Int(averageAccuracy * 100))%",
                        icon: "target",
                        color: averageAccuracy >= 0.75 ? .mintGreen : .orange
                    )

                    ReadinessStatBox(
                        title: "Categories",
                        value: isPremium ? "\(completedCategories)/\(ContentCategory.allCases.count)" : "1/9",
                        icon: "folder.fill",
                        color: isPremium ? .blue : .orange
                    )
                }
            }
            .padding()
            .background(Color.creamyBackground)

            // Blur overlay for non-premium (only on the progress path section)
            if !isPremium {
                Color.clear // Keep content visible but show locked state
            }
        }
    }

    // MARK: - Improved Algorithm

    // Required mastery for 100% readiness
    private var requiredMasteryForReady: Int { 400 }

    private var overallReadiness: Double {
        // Weighted scoring system - much harder to reach high percentages

        // 1. Mastery Score (50% weight) - Need 400+ cards mastered for full score
        let masteryScore: Double
        if masteredCount < 50 {
            masteryScore = Double(masteredCount) / 50.0 * 0.15 // 0-15% for first 50 cards
        } else if masteredCount < 150 {
            masteryScore = 0.15 + (Double(masteredCount - 50) / 100.0 * 0.15) // 15-30%
        } else if masteredCount < 300 {
            masteryScore = 0.30 + (Double(masteredCount - 150) / 150.0 * 0.20) // 30-50%
        } else {
            masteryScore = 0.50 + min(Double(masteredCount - 300) / 100.0 * 0.10, 0.10) // 50-60%
        }

        // 2. Category Coverage (25% weight) - Need 70%+ mastery in each category
        let categoryScore = Double(completedCategories) / Double(ContentCategory.allCases.count) * 0.25

        // 3. Accuracy Score (15% weight) - Need 75%+ accuracy
        let accuracyScore: Double
        if averageAccuracy < 0.5 {
            accuracyScore = averageAccuracy * 0.05
        } else if averageAccuracy < 0.75 {
            accuracyScore = 0.025 + (averageAccuracy - 0.5) * 0.2
        } else {
            accuracyScore = 0.075 + (averageAccuracy - 0.75) * 0.3
        }

        // 4. Minimum cards studied requirement (10% weight)
        let studyBreadth = min(Double(masteredCount) / Double(max(totalCards, 1)) * 0.10, 0.10)

        return min(masteryScore + categoryScore + accuracyScore + studyBreadth, 1.0)
    }

    private var currentStage: ReadinessStage {
        switch overallReadiness {
        case 0..<0.10: return .beginner
        case 0.10..<0.30: return .learning
        case 0.30..<0.55: return .progressing
        case 0.55..<0.80: return .almostReady
        default: return .ready
        }
    }

    private var nextStage: ReadinessStage {
        switch currentStage {
        case .beginner: return .learning
        case .learning: return .progressing
        case .progressing: return .almostReady
        case .almostReady: return .ready
        case .ready: return .ready
        }
    }

    private var requirementsForNextStage: [String] {
        switch currentStage {
        case .beginner:
            return ["Master at least 50 cards", "Study cards from 3+ categories"]
        case .learning:
            return ["Master at least 150 cards", "Achieve 60%+ accuracy", "Study all 9 categories"]
        case .progressing:
            return ["Master at least 300 cards", "Achieve 70%+ accuracy", "Master 50%+ in 5 categories"]
        case .almostReady:
            return ["Master 400+ cards", "Achieve 75%+ accuracy", "Master 70%+ in all categories"]
        case .ready:
            return ["You're ready! Trust your preparation."]
        }
    }

    private var readinessColor: Color {
        currentStage.color
    }

    private var completedCategories: Int {
        categoryProgress.filter { $0.value >= 0.5 }.count
    }

    private func stageProgress(for stage: ReadinessStage) -> Double {
        let thresholds: [Double] = [0, 0.10, 0.30, 0.55, 0.80]
        let stageIndex = stage.rawValue

        if currentStage.rawValue > stageIndex { return 1.0 }
        if currentStage.rawValue < stageIndex { return 0.0 }

        let stageStart = thresholds[stageIndex]
        let stageEnd = stageIndex < 4 ? thresholds[stageIndex + 1] : 1.0

        return (overallReadiness - stageStart) / (stageEnd - stageStart)
    }
}

// MARK: - Readiness Stage

enum ReadinessStage: Int, CaseIterable {
    case beginner = 0
    case learning = 1
    case progressing = 2
    case almostReady = 3
    case ready = 4

    var title: String {
        switch self {
        case .beginner: return "Getting Started"
        case .learning: return "Building Foundation"
        case .progressing: return "Making Progress"
        case .almostReady: return "Almost Ready"
        case .ready: return "NCLEX Ready!"
        }
    }

    var subtitle: String {
        switch self {
        case .beginner: return "Start mastering cards to build your foundation"
        case .learning: return "You're building knowledge - keep going!"
        case .progressing: return "Great progress! Focus on weak areas"
        case .almostReady: return "Almost there! Polish your skills"
        case .ready: return "You're prepared for the NCLEX exam!"
        }
    }

    var icon: String {
        switch self {
        case .beginner: return "leaf.fill"
        case .learning: return "book.fill"
        case .progressing: return "chart.line.uptrend.xyaxis"
        case .almostReady: return "star.leadinghalf.filled"
        case .ready: return "checkmark.seal.fill"
        }
    }

    var color: Color {
        switch self {
        case .beginner: return .gray
        case .learning: return .blue
        case .progressing: return .orange
        case .almostReady: return .purple
        case .ready: return .green
        }
    }
}

// MARK: - Readiness Stage Row

struct ReadinessStageRow: View {
    let stage: ReadinessStage
    let isCompleted: Bool
    let isCurrent: Bool
    let progress: Double
    var isLocked: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            // Progress line and circle
            VStack(spacing: 0) {
                if stage != .beginner {
                    Rectangle()
                        .fill(isLocked ? Color.gray.opacity(0.2) : (isCompleted || isCurrent ? stage.color : Color.gray.opacity(0.3)))
                        .frame(width: 3, height: 20)
                }

                ZStack {
                    Circle()
                        .fill(isLocked ? Color.gray.opacity(0.15) : (isCompleted ? stage.color : (isCurrent ? stage.color.opacity(0.3) : Color.gray.opacity(0.2))))
                        .frame(width: 36, height: 36)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.gray.opacity(0.5))
                    } else if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: stage.icon)
                            .font(.system(size: 14))
                            .foregroundColor(isCurrent ? stage.color : .gray)
                    }
                }

                if stage != .ready {
                    Rectangle()
                        .fill(isLocked ? Color.gray.opacity(0.2) : (isCompleted ? stage.color : Color.gray.opacity(0.3)))
                        .frame(width: 3, height: 20)
                }
            }

            // Stage info — always readable
            VStack(alignment: .leading, spacing: 4) {
                Text(stage.title)
                    .font(.system(size: 16, weight: isCurrent && !isLocked ? .bold : .medium, design: .rounded))
                    .foregroundColor(isLocked ? .primary : (isCurrent ? stage.color : (isCompleted ? .primary : .secondary)))

                if isCurrent && !isLocked {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)

                            Capsule()
                                .fill(stage.color)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                } else if isLocked {
                    // Show greyed-out progress bar placeholder
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Readiness Stat Box

struct ReadinessStatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))

            Text(title)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.adaptiveWhite)
        .cornerRadius(12)
    }
}

// MARK: - Share Progress View

struct ShareProgressView: View {
    @Environment(\.dismiss) var dismiss
    let stats: ShareableStats
    @State private var renderedImage: UIImage?
    @State private var isGeneratingImage = true
    @State private var useCozyTheme = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Tap hint
                Text("Tap card to change style")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)

                // Preview Card
                if let image = renderedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.15), radius: 15, y: 8)
                        .padding(.horizontal)
                        .onTapGesture { toggleTheme() }
                } else {
                    ShareableImageCard(stats: stats, useCozyTheme: useCozyTheme)
                        .padding(.horizontal)
                        .onTapGesture { toggleTheme() }
                }

                // Share Options
                VStack(spacing: 12) {
                    if let image = renderedImage {
                        ShareLink(item: Image(uiImage: image), preview: SharePreview("My CozyNCLEX Progress", image: Image(uiImage: image))) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Image")
                            }
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.mintGreen)
                            .cornerRadius(14)
                        }
                    } else {
                        ProgressView()
                            .frame(height: 50)
                    }

                    Button(action: saveToPhotos) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save to Photos")
                        }
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.mintGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.mintGreen.opacity(0.1))
                        .cornerRadius(14)
                    }
                    .disabled(renderedImage == nil)
                }
                .padding(.horizontal)

                Spacer()
            }
            .frame(maxWidth: 700).frame(maxWidth: .infinity)
            .padding(.top, 20)
            .navigationTitle("Share Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                generateImage()
            }
        }
    }

    private func toggleTheme() {
        HapticManager.shared.light()
        useCozyTheme.toggle()
        generateImage()
    }

    private func generateImage() {
        let cardView = ShareableImageCard(stats: stats, useCozyTheme: useCozyTheme)
            .frame(width: min(UIScreen.main.bounds.width - 20, 380))

        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0

        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
        }
        isGeneratingImage = false
    }

    private func saveToPhotos() {
        guard let image = renderedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        HapticManager.shared.success()
    }
}

// MARK: - Shareable Image Card (Designed for Export)

struct ShareableImageCard: View {
    let stats: ShareableStats
    var useCozyTheme: Bool = false

    private var headerGradient: LinearGradient {
        if useCozyTheme {
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.95, blue: 0.88), Color.pastelPink.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.mintGreen, Color.mintGreen.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var headerTextColor: Color {
        useCozyTheme ? .primary : .white
    }

    private var headerSubtextColor: Color {
        useCozyTheme ? .secondary : .white.opacity(0.9)
    }

    /// Smart stat: swap streak for study time when streak is 0
    private var middleStat: (icon: String, value: String, label: String, color: Color) {
        if stats.currentStreak > 0 {
            return ("flame.fill", "\(stats.currentStreak)", "Day Streak", .orange)
        } else {
            return ("clock.fill", stats.formattedStudyTime, "Study Time", .purple)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gradient Header
            ZStack {
                headerGradient

                VStack(spacing: 8) {
                    // App Logo & Name
                    HStack(spacing: 12) {
                        Image("NurseBear")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 5)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("CozyNCLEX Prep")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(headerTextColor)
                            Text("NCLEX Study Progress")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(headerSubtextColor)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // Level Badge
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("LEVEL")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(headerSubtextColor)
                            Text("\(stats.level)")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundColor(headerTextColor)
                            Text(stats.levelTitle)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(headerSubtextColor)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                .padding(.vertical, 20)
            }

            // Stats Section
            VStack(spacing: 16) {
                // XP Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(stats.totalXP) XP")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Spacer()
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.yellow.opacity(0.2))
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * min(CGFloat(stats.totalXP % 1000) / 1000.0 + 0.1, 1.0))
                        }
                    }
                    .frame(height: 12)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: 700).frame(maxWidth: .infinity)
                .padding(.top, 20)

                // Stats Grid — smart stat swap
                HStack(spacing: 12) {
                    ShareImageStatBox(
                        icon: "checkmark.seal.fill",
                        value: "\(stats.masteredCards)",
                        label: "Cards Mastered",
                        color: .mintGreen
                    )

                    ShareImageStatBox(
                        icon: middleStat.icon,
                        value: middleStat.value,
                        label: middleStat.label,
                        color: middleStat.color
                    )

                    ShareImageStatBox(
                        icon: "target",
                        value: "\(Int(stats.accuracy * 100))%",
                        label: "Accuracy",
                        color: .blue
                    )
                }
                .padding(.horizontal, 20)

                // Footer with download watermark
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal, 20)

                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                        Text("Join me on the path to becoming a nurse!")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    // Acquisition watermark
                    Text("Download CozyNCLEX Prep on the App Store")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.primary.opacity(0.5))
                        .padding(.bottom, 16)
                }
                .padding(.top, 8)
            }
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.15), radius: 15, y: 8)
    }
}

struct ShareImageStatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Legacy Shareable Progress Card (for in-app display)

struct ShareableProgressCard: View {
    let stats: ShareableStats

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image("NurseBear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 2) {
                    Text("CozyNCLEX Prep")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("My Study Progress")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Lv.\(stats.level)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.mintGreen)
                    Text(stats.levelTitle)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Stats Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: horizontalSizeClass == .regular ? 4 : 2), spacing: 12) {
                ShareStatItem(icon: "star.fill", value: "\(stats.totalXP)", label: "Total XP", color: .yellow)
                ShareStatItem(icon: "checkmark.seal.fill", value: "\(stats.masteredCards)", label: "Mastered", color: .mintGreen)
                ShareStatItem(icon: "flame.fill", value: "\(stats.currentStreak)", label: "Day Streak", color: .orange)
                ShareStatItem(icon: "target", value: "\(Int(stats.accuracy * 100))%", label: "Accuracy", color: .blue)
            }

            // Footer
            Text("Join me on the path to becoming a nurse!")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color.adaptiveWhite)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

struct ShareStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text(label)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Shareable Stats Model

struct ShareableStats {
    let level: Int
    let levelTitle: String
    let totalXP: Int
    let masteredCards: Int
    let currentStreak: Int
    let accuracy: Double
    var totalStudyTimeSeconds: Int = 0

    var formattedStudyTime: String {
        let hours = Double(totalStudyTimeSeconds) / 3600.0
        if hours >= 1 {
            return String(format: "%.1f Hours", hours)
        } else {
            let minutes = totalStudyTimeSeconds / 60
            return "\(max(minutes, 1)) Min"
        }
    }
}

// MARK: - Preview

#Preview {
    DailyMotivationView()
}
