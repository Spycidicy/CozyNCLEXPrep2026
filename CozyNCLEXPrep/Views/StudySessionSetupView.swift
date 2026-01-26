//
//  StudySessionSetupView.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import SwiftUI

// MARK: - Study Session Setup View

struct StudySessionSetupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var appManager: AppManager

    let gameMode: GameMode
    let onStart: ([Flashcard]) -> Void

    @State private var selectedCardCount: CardCount = .ten
    @State private var selectedCategory: ContentCategory?
    @State private var shuffleCards = true

    enum CardCount: Int, CaseIterable {
        case ten = 10
        case twenty = 20
        case thirty = 30
        case fifty = 50
        case all = 0

        var title: String {
            switch self {
            case .ten: return "10 Cards"
            case .twenty: return "20 Cards"
            case .thirty: return "30 Cards"
            case .fifty: return "50 Cards"
            case .all: return "All Cards"
            }
        }

        var subtitle: String {
            switch self {
            case .ten: return "Quick session"
            case .twenty: return "Standard session"
            case .thirty: return "Extended session"
            case .fifty: return "Deep dive"
            case .all: return "Full deck"
            }
        }

        var icon: String {
            switch self {
            case .ten: return "bolt.fill"
            case .twenty: return "flame.fill"
            case .thirty: return "star.fill"
            case .fifty: return "sparkles"
            case .all: return "infinity"
            }
        }

        var color: Color {
            switch self {
            case .ten: return .mintGreen
            case .twenty: return .orange
            case .thirty: return .purple
            case .fifty: return .red
            case .all: return .blue
            }
        }
    }

    var availableCards: [Flashcard] {
        // Use getGameCards which filters out mastered cards and prioritizes weak cards
        var cards = cardManager.getGameCards(isSubscribed: subscriptionManager.isSubscribed)

        // Filter by category if selected
        if let category = selectedCategory {
            cards = cards.filter { $0.contentCategory == category }
        }

        return cards
    }

    var selectedCards: [Flashcard] {
        var cards = availableCards

        // Cards are already sorted by weakness from getGameCards
        // Only shuffle if user explicitly wants randomization
        if shuffleCards {
            cards = cards.shuffled()
        }

        if selectedCardCount != .all {
            cards = Array(cards.prefix(selectedCardCount.rawValue))
        }

        return cards
    }

    var cardCountText: String {
        let count = min(selectedCardCount == .all ? availableCards.count : selectedCardCount.rawValue, availableCards.count)
        return "\(count) cards"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Fixed Header with Start Button
                VStack(spacing: 16) {
                    // Game Mode Header
                    GameModeHeader(gameMode: gameMode)

                    // Summary & Start Button
                    HStack(spacing: 16) {
                        // Summary
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ready to study")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.secondary)
                            Text(cardCountText)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.mintGreen)
                            if let category = selectedCategory {
                                Text(category.rawValue)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        // Start Button
                        Button(action: startSession) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 16))
                                Text("Start")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [gameMode.color, gameMode.color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: gameMode.color.opacity(0.3), radius: 8, y: 4)
                        }
                        .disabled(selectedCards.isEmpty)
                        .opacity(selectedCards.isEmpty ? 0.5 : 1)
                    }
                    .padding()
                    .background(Color.adaptiveWhite)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    if availableCards.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.mintGreen)
                            Text("You've mastered all cards! Reset progress to study again.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
                .background(Color.creamyBackground)

                // Scrollable Options
                ScrollView {
                    VStack(spacing: 24) {
                        // Card Count Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How many cards?")
                                .font(.system(size: 18, weight: .bold, design: .rounded))

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(CardCount.allCases, id: \.self) { count in
                                    CardCountOption(
                                        count: count,
                                        isSelected: selectedCardCount == count,
                                        availableCount: availableCards.count
                                    ) {
                                        HapticManager.shared.light()
                                        selectedCardCount = count
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Category Filter
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category (optional)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    CategoryChip(
                                        title: "All Categories",
                                        isSelected: selectedCategory == nil,
                                        color: .gray
                                    ) {
                                        selectedCategory = nil
                                    }

                                    ForEach(ContentCategory.allCases, id: \.self) { category in
                                        CategoryChip(
                                            title: category.rawValue,
                                            isSelected: selectedCategory == category,
                                            color: category.color
                                        ) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Shuffle Toggle
                        Toggle(isOn: $shuffleCards) {
                            HStack {
                                Image(systemName: "shuffle")
                                    .foregroundColor(.purple)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Shuffle cards")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                    Text("Off = weakest cards first")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.adaptiveWhite)
                        .cornerRadius(14)
                        .padding(.horizontal)

                        // Info about card selection
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 16))
                            Text("Cards you haven't mastered are prioritized. Mastered cards won't appear in study sessions.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .background(Color.creamyBackground)
            .navigationTitle("Setup Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func startSession() {
        HapticManager.shared.success()
        let cards = selectedCards

        // Set session cards
        cardManager.sessionCards = cards

        // Call onStart which will navigate and dismiss the sheet
        onStart(cards)
    }
}

// MARK: - Game Mode Header

struct GameModeHeader: View {
    let gameMode: GameMode

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(gameMode.color.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: gameMode.icon)
                    .font(.system(size: 26))
                    .foregroundColor(gameMode.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(gameMode.rawValue)
                    .font(.system(size: 22, weight: .bold, design: .rounded))

                Text(gameMode.description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.adaptiveWhite)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Card Count Option

struct CardCountOption: View {
    let count: StudySessionSetupView.CardCount
    let isSelected: Bool
    let availableCount: Int
    let action: () -> Void

    var isDisabled: Bool {
        count != .all && count.rawValue > availableCount
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: count.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .white : count.color)

                Text(count.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .primary)

                Text(count.subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? count.color : Color.adaptiveWhite)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
}

// MARK: - GameMode Color Extension

extension GameMode {
    var color: Color {
        switch self {
        case .swipe: return .mintGreen
        case .quiz: return .pastelPink
        case .smartReview: return .softLavender
        case .match: return .peachOrange
        case .write: return .skyBlue
        case .test: return .coralPink
        }
    }

    var description: String {
        switch self {
        case .swipe: return "Swipe through flashcards"
        case .quiz: return "Multiple choice questions"
        case .smartReview: return "Spaced repetition learning"
        case .match: return "Match questions to answers"
        case .write: return "Type your answers"
        case .test: return "Simulated NCLEX test"
        }
    }
}

// MARK: - Preview

#Preview {
    StudySessionSetupView(gameMode: .swipe) { cards in
        print("Starting with \(cards.count) cards")
    }
    .environmentObject(CardManager.shared)
    .environmentObject(SubscriptionManager())
    .environmentObject(AppManager())
}
