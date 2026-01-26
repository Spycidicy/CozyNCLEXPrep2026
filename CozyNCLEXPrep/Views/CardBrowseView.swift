//
//  CardBrowseView.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import SwiftUI

// MARK: - Browse Filter Mode

enum BrowseFilterMode: String {
    case all = "All Cards"
    case weak = "Weak Cards"
    case mastered = "Mastered"
}

// MARK: - Browse Cards Home View (Smart Sections)

struct BrowseCardsHomeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @ObservedObject var authManager = AuthManager.shared

    @State private var selectedFilter: BrowseFilterMode?

    var isPremium: Bool {
        subscriptionManager.hasPremiumAccess ||
        (authManager.userProfile?.isPremium ?? false)
    }

    var allCards: [Flashcard] {
        cardManager.getAvailableCards(isSubscribed: isPremium)
    }

    var weakCards: [Flashcard] {
        allCards.filter { card in
            !cardManager.masteredCardIDs.contains(card.id) &&
            (cardManager.consecutiveCorrect[card.id] ?? 0) == 0
        }
    }

    var masteredCards: [Flashcard] {
        allCards.filter { cardManager.masteredCardIDs.contains($0.id) }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 4) {
                        Text("What would you like to study?")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Choose a card set to start learning")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    // Smart Sections
                    VStack(spacing: 12) {
                        // Weak Cards Section
                        BrowseSectionCard(
                            icon: "exclamationmark.triangle.fill",
                            iconColor: .orange,
                            title: "Weak Cards",
                            subtitle: "Cards you need to review",
                            count: weakCards.count,
                            accentColor: .orange
                        ) {
                            selectedFilter = .weak
                        }

                        // Mastered Cards Section
                        BrowseSectionCard(
                            icon: "checkmark.seal.fill",
                            iconColor: .green,
                            title: "Mastered",
                            subtitle: "Cards you've learned",
                            count: masteredCards.count,
                            accentColor: .green
                        ) {
                            selectedFilter = .mastered
                        }

                        // All Cards Section
                        BrowseSectionCard(
                            icon: "rectangle.stack.fill",
                            iconColor: .blue,
                            title: "All Cards",
                            subtitle: "Browse the full deck",
                            count: allCards.count,
                            accentColor: .blue
                        ) {
                            selectedFilter = .all
                        }
                    }
                    .padding(.horizontal)

                    // Tip
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16))
                        Text("Focus on weak cards first to improve faster. Cards become mastered after 3 correct answers in a row.")
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
            .background(Color.creamyBackground)
            .navigationTitle("Study Flashcards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(item: $selectedFilter) { filter in
                CardBrowseView(filterMode: filter)
                    .environmentObject(cardManager)
                    .environmentObject(subscriptionManager)
            }
        }
    }
}

// MARK: - Browse Section Card

struct BrowseSectionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let count: Int
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(iconColor)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Count Badge
                Text("\(count)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(accentColor.opacity(0.15))
                    .cornerRadius(12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.adaptiveWhite)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Make BrowseFilterMode Identifiable for fullScreenCover

extension BrowseFilterMode: Identifiable {
    var id: String { rawValue }
}

// MARK: - Card Browse View (Quizlet-style)

struct CardBrowseView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @ObservedObject var authManager = AuthManager.shared

    let filterMode: BrowseFilterMode

    @State private var selectedCategory: ContentCategory?
    @State private var searchText = ""
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    @State private var viewMode: ViewMode = .carousel

    init(filterMode: BrowseFilterMode = .all) {
        self.filterMode = filterMode
    }

    enum ViewMode: String, CaseIterable {
        case carousel = "Cards"
        case list = "List"
    }

    // Check premium from both StoreKit AND Supabase
    var isPremium: Bool {
        subscriptionManager.hasPremiumAccess ||
        (authManager.userProfile?.isPremium ?? false)
    }

    var baseCards: [Flashcard] {
        let available = cardManager.getAvailableCards(isSubscribed: isPremium)

        switch filterMode {
        case .all:
            return available
        case .weak:
            return available.filter { card in
                !cardManager.masteredCardIDs.contains(card.id) &&
                (cardManager.consecutiveCorrect[card.id] ?? 0) == 0
            }
        case .mastered:
            return available.filter { cardManager.masteredCardIDs.contains($0.id) }
        }
    }

    var filteredCards: [Flashcard] {
        var cards = baseCards

        if let category = selectedCategory {
            cards = cards.filter { $0.contentCategory == category }
        }

        if !searchText.isEmpty {
            cards = cards.filter {
                $0.question.localizedCaseInsensitiveContains(searchText) ||
                $0.answer.localizedCaseInsensitiveContains(searchText)
            }
        }

        return cards
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryChip(
                            title: "All",
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
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)

                // View Mode Picker
                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 10)

                if filteredCards.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No cards found")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    switch viewMode {
                    case .carousel:
                        CarouselView(
                            cards: filteredCards,
                            currentIndex: $currentCardIndex,
                            isFlipped: $isFlipped
                        )
                    case .list:
                        CardListView(cards: filteredCards)
                    }
                }
            }
            .background(Color.creamyBackground)
            .navigationTitle(filterMode.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search cards...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(filteredCards.count) cards")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.adaptiveWhite)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Carousel View

struct CarouselView: View {
    let cards: [Flashcard]
    @Binding var currentIndex: Int
    @Binding var isFlipped: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Progress indicator
            Text("\(currentIndex + 1) of \(cards.count)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)

            // Card
            if currentIndex < cards.count {
                FlippableCardView(card: cards[currentIndex], isFlipped: $isFlipped)
                    .frame(height: 350)
                    .padding(.horizontal, 20)
                    .id(currentIndex) // Force refresh when index changes
            }

            // Navigation controls
            HStack(spacing: 40) {
                Button(action: previousCard) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(currentIndex > 0 ? .mintGreen : .gray.opacity(0.3))
                }
                .disabled(currentIndex == 0)

                Button(action: { isFlipped.toggle() }) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 24))
                        Text("Flip")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.blue)
                }

                Button(action: nextCard) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(currentIndex < cards.count - 1 ? .mintGreen : .gray.opacity(0.3))
                }
                .disabled(currentIndex >= cards.count - 1)
            }
            .padding(.top, 10)

            // Keyboard hint
            Text("Tap card to flip")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.top, 20)
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 {
                        nextCard()
                    } else if value.translation.width > 50 {
                        previousCard()
                    }
                }
        )
    }

    private func previousCard() {
        guard currentIndex > 0 else { return }
        HapticManager.shared.light()
        withAnimation {
            currentIndex -= 1
            isFlipped = false
        }
    }

    private func nextCard() {
        guard currentIndex < cards.count - 1 else { return }
        HapticManager.shared.light()
        withAnimation {
            currentIndex += 1
            isFlipped = false
        }
    }
}

// MARK: - Flippable Card View

struct FlippableCardView: View {
    let card: Flashcard
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            // Front (Question)
            CardFaceView(
                content: card.question,
                label: "Question",
                category: card.contentCategory,
                showCategory: true
            )
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            // Back (Answer)
            CardFaceView(
                content: card.answer,
                label: "Answer",
                category: card.contentCategory,
                showCategory: false,
                rationale: card.rationale
            )
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .onTapGesture {
            HapticManager.shared.light()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }
}

// MARK: - Card Face View

struct CardFaceView: View {
    let content: String
    let label: String
    let category: ContentCategory
    let showCategory: Bool
    var rationale: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                if showCategory {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.system(size: 12))
                        Text(category.rawValue)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(category.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(category.color.opacity(0.15))
                    .cornerRadius(12)
                }

                Spacer()

                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            // Content
            ScrollView {
                VStack(spacing: 16) {
                    Text(content)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding()

                    if let rationale = rationale, !rationale.isEmpty, label == "Answer" {
                        Divider()
                            .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Rationale")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }

                            Text(rationale)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }

            Spacer()
        }
        .background(Color.adaptiveWhite)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

// MARK: - Card List View

struct CardListView: View {
    let cards: [Flashcard]
    @State private var expandedCardId: UUID?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(cards) { card in
                    BrowseCardListItem(
                        card: card,
                        isExpanded: expandedCardId == card.id,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                if expandedCardId == card.id {
                                    expandedCardId = nil
                                } else {
                                    expandedCardId = card.id
                                }
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Browse Card List Item

struct BrowseCardListItem: View {
    let card: Flashcard
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: card.contentCategory.icon)
                        .font(.system(size: 11))
                    Text(card.contentCategory.rawValue)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                .foregroundColor(card.contentCategory.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(card.contentCategory.color.opacity(0.15))
                .cornerRadius(8)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            // Question
            Text(card.question)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(isExpanded ? nil : 2)

            // Answer (when expanded)
            if isExpanded {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Answer")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.mintGreen)

                    Text(card.answer)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.primary)

                    if !card.rationale.isEmpty {
                        Text("Rationale")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                            .padding(.top, 8)

                        Text(card.rationale)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.adaptiveWhite)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .onTapGesture {
            HapticManager.shared.light()
            onTap()
        }
    }
}

// MARK: - Preview

#Preview("Study Flashcards Home") {
    BrowseCardsHomeView()
        .environmentObject(CardManager.shared)
        .environmentObject(SubscriptionManager())
}

#Preview("Card Browse - All") {
    CardBrowseView(filterMode: .all)
        .environmentObject(CardManager.shared)
        .environmentObject(SubscriptionManager())
}
