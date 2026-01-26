//
//  CoachMarkSystem.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import SwiftUI
import Combine

// MARK: - Coach Mark Manager

@MainActor
class CoachMarkManager: ObservableObject {
    static let shared = CoachMarkManager()

    @Published var currentCoachMark: CoachMarkType?
    @Published var isShowingCoachMark = false
    @Published var highlightFrames: [CoachMarkType: CGRect] = [:]

    private let shownMarksKey = "shownCoachMarks"

    private init() {}

    /// Register a frame for a coach mark highlight
    func registerFrame(_ frame: CGRect, for mark: CoachMarkType) {
        highlightFrames[mark] = frame
    }

    // All coach marks in order
    private let coachMarkSequence: [CoachMarkType] = [
        .studyTab,
        .flashcards,
        .quickQuiz,
        .testYourself,
        .progressTab,
        .xpAndLevel,
        .streaks,
        .settingsTab
    ]

    // Check if a specific coach mark has been shown
    func hasShown(_ mark: CoachMarkType) -> Bool {
        let shown = UserDefaults.standard.stringArray(forKey: shownMarksKey) ?? []
        return shown.contains(mark.rawValue)
    }

    // Mark a coach mark as shown
    func markAsShown(_ mark: CoachMarkType) {
        var shown = UserDefaults.standard.stringArray(forKey: shownMarksKey) ?? []
        if !shown.contains(mark.rawValue) {
            shown.append(mark.rawValue)
            UserDefaults.standard.set(shown, forKey: shownMarksKey)
        }
    }

    // Show a coach mark if not already shown
    func showIfNeeded(_ mark: CoachMarkType) {
        guard !hasShown(mark) else { return }

        // Small delay for smooth transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.currentCoachMark = mark
                self.isShowingCoachMark = true
            }
        }
    }

    // Dismiss current coach mark and optionally show next
    func dismiss(showNext: Bool = true) {
        guard let current = currentCoachMark else { return }

        markAsShown(current)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isShowingCoachMark = false
            currentCoachMark = nil
        }

        // Show next coach mark in sequence if applicable
        if showNext, let nextMark = getNextCoachMark(after: current) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showIfNeeded(nextMark)
            }
        }
    }

    private func getNextCoachMark(after mark: CoachMarkType) -> CoachMarkType? {
        guard let currentIndex = coachMarkSequence.firstIndex(of: mark),
              currentIndex + 1 < coachMarkSequence.count else {
            return nil
        }

        let nextMark = coachMarkSequence[currentIndex + 1]

        // Only return if it's contextually appropriate
        // (e.g., don't show progressTab marks while on studyTab)
        switch nextMark {
        case .flashcards, .quickQuiz, .testYourself:
            return nextMark // These follow studyTab
        case .xpAndLevel, .streaks:
            return nil // These should be triggered when viewing progress tab
        case .settingsTab:
            return nil // Triggered when user taps settings
        default:
            return nil
        }
    }

    // Reset all coach marks (for testing)
    func resetAll() {
        UserDefaults.standard.removeObject(forKey: shownMarksKey)
        currentCoachMark = nil
        isShowingCoachMark = false
    }

    // Check if this is the user's first time (no marks shown yet)
    var isFirstTime: Bool {
        let shown = UserDefaults.standard.stringArray(forKey: shownMarksKey) ?? []
        return shown.isEmpty
    }
}

// MARK: - Coach Mark Types

enum CoachMarkType: String, CaseIterable {
    case studyTab
    case flashcards
    case quickQuiz
    case testYourself
    case browseCards
    case progressTab
    case xpAndLevel
    case streaks
    case masteryProgress
    case settingsTab

    var title: String {
        switch self {
        case .studyTab: return "Welcome to Study!"
        case .flashcards: return "Flashcards"
        case .quickQuiz: return "Quick Quiz"
        case .testYourself: return "Practice Tests"
        case .browseCards: return "Browse Cards"
        case .progressTab: return "Your Progress"
        case .xpAndLevel: return "XP & Levels"
        case .streaks: return "Daily Streaks"
        case .masteryProgress: return "Mastery Progress"
        case .settingsTab: return "Settings"
        }
    }

    var message: String {
        switch self {
        case .studyTab:
            return "This is your study hub! Choose a study mode below to start mastering NCLEX content."
        case .flashcards:
            return "Swipe through flashcards to learn. Get 3 correct in a row to master each card."
        case .quickQuiz:
            return "Test your knowledge with quick 10-question quizzes. Great for daily practice!"
        case .testYourself:
            return "Take full-length NCLEX practice tests to simulate the real exam experience. Upgrade to Premium to unlock this feature!"
        case .browseCards:
            return "Browse all cards by category. Great for targeted studying."
        case .progressTab:
            return "Track your study progress, stats, and achievements here."
        case .xpAndLevel:
            return "Earn XP by studying! Level up as you master more content."
        case .streaks:
            return "Study daily to build your streak. Consistency is key to NCLEX success!"
        case .masteryProgress:
            return "See how many cards you've mastered in each category."
        case .settingsTab:
            return "Customize your experience, manage your account, and sync settings."
        }
    }

    var icon: String {
        switch self {
        case .studyTab: return "book.fill"
        case .flashcards: return "rectangle.stack.fill"
        case .quickQuiz: return "bolt.fill"
        case .testYourself: return "checkmark.seal.fill"
        case .browseCards: return "square.grid.2x2.fill"
        case .progressTab: return "chart.bar.fill"
        case .xpAndLevel: return "star.fill"
        case .streaks: return "flame.fill"
        case .masteryProgress: return "trophy.fill"
        case .settingsTab: return "gearshape.fill"
        }
    }

    var color: Color {
        switch self {
        case .studyTab: return .mintGreen
        case .flashcards: return .skyBlue
        case .quickQuiz: return .orange
        case .testYourself: return .purple
        case .browseCards: return .pink
        case .progressTab: return .blue
        case .xpAndLevel: return .yellow
        case .streaks: return .orange
        case .masteryProgress: return .green
        case .settingsTab: return .gray
        }
    }

    var arrowDirection: ArrowDirection {
        switch self {
        case .studyTab:
            return .none // No arrow for welcome
        case .flashcards:
            return .up // Points up to flashcards card
        case .quickQuiz:
            return .up // Points up to quick quiz card
        case .testYourself:
            return .up // Points up to test yourself card
        case .browseCards:
            return .up
        case .progressTab:
            return .none // No arrow for tab switch
        case .xpAndLevel, .streaks, .masteryProgress:
            return .up
        case .settingsTab:
            return .none
        }
    }

    /// Vertical offset to position tooltip near the relevant feature
    var verticalOffset: CGFloat {
        switch self {
        case .studyTab:
            return -50 // Center-ish, slightly up
        case .flashcards:
            return -180 // Above the flashcards card
        case .quickQuiz:
            return -80 // Above quick quiz card
        case .testYourself:
            return 20 // Near test yourself card
        case .browseCards:
            return 100
        case .progressTab:
            return -50
        case .xpAndLevel:
            return -150
        case .streaks:
            return -50
        case .masteryProgress:
            return 50
        case .settingsTab:
            return 0
        }
    }

    /// Whether this is a premium feature
    var isPremiumFeature: Bool {
        switch self {
        case .testYourself:
            return true
        default:
            return false
        }
    }
}

enum ArrowDirection {
    case up, down, left, right, none
}

// MARK: - Coach Mark Overlay View

struct CoachMarkOverlay: View {
    @ObservedObject var manager = CoachMarkManager.shared

    var body: some View {
        if manager.isShowingCoachMark, let mark = manager.currentCoachMark {
            GeometryReader { geometry in
                ZStack {
                    // Dimmed background with spotlight cutout
                    SpotlightBackground(
                        highlightFrame: manager.highlightFrames[mark] ?? .zero,
                        hasHighlight: manager.highlightFrames[mark] != nil
                    )
                    .ignoresSafeArea()
                    .onTapGesture {
                        manager.dismiss()
                    }

                    // Tooltip positioned based on highlight
                    VStack {
                        if let frame = manager.highlightFrames[mark] {
                            // Position tooltip below or above the highlighted area
                            let tooltipAbove = frame.midY > geometry.size.height / 2

                            if tooltipAbove {
                                CoachMarkTooltip(mark: mark)
                                    .padding(.top, max(60, frame.minY - 220))
                                Spacer()
                            } else {
                                Spacer()
                                    .frame(height: frame.maxY + 20)
                                CoachMarkTooltip(mark: mark)
                                Spacer()
                            }
                        } else {
                            // Center the tooltip if no highlight frame
                            Spacer()
                            CoachMarkTooltip(mark: mark)
                            Spacer()
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .zIndex(1000)
        }
    }
}

// MARK: - Spotlight Background

struct SpotlightBackground: View {
    let highlightFrame: CGRect
    let hasHighlight: Bool

    var body: some View {
        Canvas { context, size in
            // Fill entire area with dim color
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(.black.opacity(0.6))
            )

            // Cut out the highlighted area if we have one
            if hasHighlight && highlightFrame != .zero {
                let expandedFrame = highlightFrame.insetBy(dx: -8, dy: -8)
                let roundedRect = Path(roundedRect: expandedFrame, cornerRadius: 16)

                context.blendMode = .destinationOut
                context.fill(roundedRect, with: .color(.white))
            }
        }
        .compositingGroup()
    }
}

// MARK: - Coach Mark Tooltip

struct CoachMarkTooltip: View {
    let mark: CoachMarkType
    @ObservedObject var manager = CoachMarkManager.shared

    var body: some View {
        VStack(spacing: 12) {
            // Icon and title row
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(mark.color.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: mark.icon)
                        .font(.system(size: 20))
                        .foregroundColor(mark.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(mark.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))

                    // Premium badge
                    if mark.isPremiumFeature {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10))
                            Text("Premium Feature")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.orange)
                    }
                }

                Spacer()
            }

            // Message
            Text(mark.message)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Got it button
            Button(action: {
                HapticManager.shared.light()
                manager.dismiss()
            }) {
                Text("Got it!")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(mark.color)
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.adaptiveWhite)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        .padding(.horizontal, 30)
    }
}

// MARK: - Highlight Frame Preference Key

struct HighlightFramePreferenceKey: PreferenceKey {
    static var defaultValue: [CoachMarkType: CGRect] = [:]

    static func reduce(value: inout [CoachMarkType: CGRect], nextValue: () -> [CoachMarkType: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - Highlightable Modifier

struct HighlightableModifier: ViewModifier {
    let mark: CoachMarkType
    @ObservedObject var manager = CoachMarkManager.shared

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: HighlightFramePreferenceKey.self,
                            value: [mark: geometry.frame(in: .global)]
                        )
                        .onAppear {
                            manager.registerFrame(geometry.frame(in: .global), for: mark)
                        }
                        .onChange(of: geometry.frame(in: .global)) { _, newFrame in
                            manager.registerFrame(newFrame, for: mark)
                        }
                }
            )
            // Add subtle glow when this item is being highlighted
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(mark.color, lineWidth: manager.currentCoachMark == mark ? 3 : 0)
                    .shadow(color: mark.color.opacity(0.5), radius: manager.currentCoachMark == mark ? 8 : 0)
                    .animation(.easeInOut(duration: 0.3), value: manager.currentCoachMark == mark)
            )
    }
}

extension View {
    /// Mark this view as highlightable for a specific coach mark
    func highlightable(for mark: CoachMarkType) -> some View {
        modifier(HighlightableModifier(mark: mark))
    }
}

// MARK: - Coach Mark Trigger Modifier

struct CoachMarkTrigger: ViewModifier {
    let mark: CoachMarkType
    let delay: Double

    func body(content: Content) -> some View {
        content
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    CoachMarkManager.shared.showIfNeeded(mark)
                }
            }
    }
}

extension View {
    func showCoachMark(_ mark: CoachMarkType, delay: Double = 0.5) -> some View {
        modifier(CoachMarkTrigger(mark: mark, delay: delay))
    }
}
