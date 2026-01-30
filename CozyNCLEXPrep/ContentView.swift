//
//  ContentView.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/22/26.
//

import SwiftUI
import Combine
import AVFoundation
import StoreKit
import Charts
import UserNotifications
import UIKit
import AudioToolbox
import Supabase
import WidgetKit

// MARK: - Persistence Manager

class PersistenceManager {
    static let shared = PersistenceManager()

    private let defaults = UserDefaults.standard

    // Keys
    private let savedCardsKey = "savedCardIDs"
    private let masteredCardsKey = "masteredCardIDs"
    private let consecutiveCorrectKey = "consecutiveCorrect"
    private let userCardsKey = "userCreatedCards"
    private let studySetsKey = "studySets"
    private let userStatsKey = "userStats"
    private let spacedRepDataKey = "spacedRepetitionData"
    private let isSubscribedKey = "isSubscribed"
    private let selectedCategoriesKey = "selectedCategories"
    private let cardNotesKey = "cardNotes"
    private let flaggedCardsKey = "flaggedCardIDs"
    private let testHistoryKey = "testHistory"
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    private let darkModeKey = "darkModeEnabled"
    private let appearanceModeKey = "appearanceMode" // 0 = system, 1 = light, 2 = dark

    // MARK: - Appearance

    func getAppearanceMode() -> Int {
        return defaults.integer(forKey: appearanceModeKey)
    }

    func setAppearanceMode(_ mode: Int) {
        defaults.set(mode, forKey: appearanceModeKey)
    }

    // MARK: - Onboarding

    func hasSeenOnboarding() -> Bool {
        return defaults.bool(forKey: hasSeenOnboardingKey)
    }

    func setOnboardingComplete() {
        defaults.set(true, forKey: hasSeenOnboardingKey)
    }

    // MARK: - Save Methods

    func saveSavedCards(_ ids: Set<UUID>) {
        let array = ids.map { $0.uuidString }
        defaults.set(array, forKey: savedCardsKey)
    }

    func saveMasteredCards(_ ids: Set<UUID>) {
        let array = ids.map { $0.uuidString }
        defaults.set(array, forKey: masteredCardsKey)
    }

    func saveConsecutiveCorrect(_ dict: [UUID: Int]) {
        let stringDict = Dictionary(uniqueKeysWithValues: dict.map { ($0.key.uuidString, $0.value) })
        defaults.set(stringDict, forKey: consecutiveCorrectKey)
    }

    func saveUserCards(_ cards: [Flashcard]) {
        if let encoded = try? JSONEncoder().encode(cards) {
            defaults.set(encoded, forKey: userCardsKey)
        }
    }

    func saveStudySets(_ sets: [StudySet]) {
        if let encoded = try? JSONEncoder().encode(sets) {
            defaults.set(encoded, forKey: studySetsKey)
        }
    }

    func saveUserStats(_ stats: UserStats) {
        if let encoded = try? JSONEncoder().encode(stats) {
            defaults.set(encoded, forKey: userStatsKey)
        }
    }

    func saveSpacedRepData(_ data: [UUID: SpacedRepetitionData]) {
        let stringDict = Dictionary(uniqueKeysWithValues: data.map { ($0.key.uuidString, $0.value) })
        if let encoded = try? JSONEncoder().encode(stringDict) {
            defaults.set(encoded, forKey: spacedRepDataKey)
        }
    }

    func saveSubscriptionStatus(_ isSubscribed: Bool) {
        defaults.set(isSubscribed, forKey: isSubscribedKey)
    }

    func saveSelectedCategories(_ categories: Set<ContentCategory>) {
        let array = categories.map { $0.rawValue }
        defaults.set(array, forKey: selectedCategoriesKey)
    }

    func saveCardNotes(_ notes: [UUID: CardNote]) {
        let stringDict = Dictionary(uniqueKeysWithValues: notes.map { ($0.key.uuidString, $0.value) })
        if let encoded = try? JSONEncoder().encode(stringDict) {
            defaults.set(encoded, forKey: cardNotesKey)
        }
    }

    func saveFlaggedCards(_ ids: Set<UUID>) {
        let array = ids.map { $0.uuidString }
        defaults.set(array, forKey: flaggedCardsKey)
    }

    func saveTestHistory(_ history: [TestResult]) {
        if let encoded = try? JSONEncoder().encode(history) {
            defaults.set(encoded, forKey: testHistoryKey)
        }
    }

    // MARK: - Load Methods

    func loadSavedCards() -> Set<UUID> {
        guard let array = defaults.stringArray(forKey: savedCardsKey) else { return [] }
        return Set(array.compactMap { UUID(uuidString: $0) })
    }

    func loadMasteredCards() -> Set<UUID> {
        guard let array = defaults.stringArray(forKey: masteredCardsKey) else { return [] }
        return Set(array.compactMap { UUID(uuidString: $0) })
    }

    func loadConsecutiveCorrect() -> [UUID: Int] {
        guard let stringDict = defaults.dictionary(forKey: consecutiveCorrectKey) as? [String: Int] else { return [:] }
        return Dictionary(uniqueKeysWithValues: stringDict.compactMap { key, value in
            guard let uuid = UUID(uuidString: key) else { return nil }
            return (uuid, value)
        })
    }

    func loadUserCards() -> [Flashcard] {
        guard let data = defaults.data(forKey: userCardsKey),
              let cards = try? JSONDecoder().decode([Flashcard].self, from: data) else { return [] }
        return cards
    }

    func loadStudySets() -> [StudySet] {
        guard let data = defaults.data(forKey: studySetsKey),
              let sets = try? JSONDecoder().decode([StudySet].self, from: data) else { return [] }
        return sets
    }

    func loadUserStats() -> UserStats {
        guard let data = defaults.data(forKey: userStatsKey),
              let stats = try? JSONDecoder().decode(UserStats.self, from: data) else { return UserStats() }
        return stats
    }

    func loadSpacedRepData() -> [UUID: SpacedRepetitionData] {
        guard let data = defaults.data(forKey: spacedRepDataKey),
              let stringDict = try? JSONDecoder().decode([String: SpacedRepetitionData].self, from: data) else { return [:] }
        return Dictionary(uniqueKeysWithValues: stringDict.compactMap { key, value in
            guard let uuid = UUID(uuidString: key) else { return nil }
            return (uuid, value)
        })
    }

    func loadSubscriptionStatus() -> Bool {
        return defaults.bool(forKey: isSubscribedKey)
    }

    func loadSelectedCategories() -> Set<ContentCategory> {
        guard let array = defaults.stringArray(forKey: selectedCategoriesKey) else {
            return Set(ContentCategory.allCases)
        }
        let categories = array.compactMap { ContentCategory(rawValue: $0) }
        return categories.isEmpty ? Set(ContentCategory.allCases) : Set(categories)
    }

    func loadCardNotes() -> [UUID: CardNote] {
        guard let data = defaults.data(forKey: cardNotesKey),
              let stringDict = try? JSONDecoder().decode([String: CardNote].self, from: data) else { return [:] }
        return Dictionary(uniqueKeysWithValues: stringDict.compactMap { key, value in
            guard let uuid = UUID(uuidString: key) else { return nil }
            return (uuid, value)
        })
    }

    func loadFlaggedCards() -> Set<UUID> {
        guard let array = defaults.stringArray(forKey: flaggedCardsKey) else { return [] }
        return Set(array.compactMap { UUID(uuidString: $0) })
    }

    func loadTestHistory() -> [TestResult] {
        guard let data = defaults.data(forKey: testHistoryKey),
              let history = try? JSONDecoder().decode([TestResult].self, from: data) else { return [] }
        return history
    }

    // MARK: - Clear User Data (for logout)

    // MARK: - User Change Detection

    private let lastUserIdKey = "lastSignedInUserId"

    /// Checks if a different user has signed in and clears data if so
    /// Returns true if data was cleared (user changed), false otherwise
    func handleUserChange(newUserId: String) -> Bool {
        let lastUserId = defaults.string(forKey: lastUserIdKey)

        if lastUserId != newUserId {
            print("🔄 User changed from \(lastUserId ?? "none") to \(newUserId) - clearing local data")
            clearAllUserData()
            defaults.set(newUserId, forKey: lastUserIdKey)
            return true
        }
        return false
    }

    /// Clears all user-specific data when logging out
    /// This ensures the next user doesn't see previous user's data
    func clearAllUserData() {
        // User progress data
        defaults.removeObject(forKey: savedCardsKey)
        defaults.removeObject(forKey: masteredCardsKey)
        defaults.removeObject(forKey: consecutiveCorrectKey)
        defaults.removeObject(forKey: userCardsKey)
        defaults.removeObject(forKey: studySetsKey)
        defaults.removeObject(forKey: userStatsKey)
        defaults.removeObject(forKey: spacedRepDataKey)
        defaults.removeObject(forKey: cardNotesKey)
        defaults.removeObject(forKey: flaggedCardsKey)
        defaults.removeObject(forKey: testHistoryKey)

        // Subscription status - IMPORTANT: Clear cached premium to prevent leaking to other accounts
        defaults.removeObject(forKey: isSubscribedKey)

        // Daily goals and XP data
        defaults.removeObject(forKey: "totalXP")
        defaults.removeObject(forKey: "dailyGoals")
        defaults.removeObject(forKey: "lastGoalDate")
        defaults.removeObject(forKey: "cardOfTheDayID")
        defaults.removeObject(forKey: "cardOfTheDayDate")
        defaults.removeObject(forKey: "cardOfTheDayCompleted")
        defaults.removeObject(forKey: "currentStreak")
        defaults.removeObject(forKey: "longestStreak")
        defaults.removeObject(forKey: "lastStudyDate")
        defaults.removeObject(forKey: "dailyContractDate")
        defaults.removeObject(forKey: "dailyCommitment")
        defaults.removeObject(forKey: "celebratedMilestones")

        // Achievements
        defaults.removeObject(forKey: "achievements")

        // Session progress
        for mode in GameMode.allCases {
            defaults.removeObject(forKey: "sessionProgress_\(mode.rawValue)")
        }

        // Sync metadata
        defaults.removeObject(forKey: "lastSyncDate")
        defaults.removeObject(forKey: "pendingChanges")

        // Clear last user ID so next sign-in starts fresh
        defaults.removeObject(forKey: lastUserIdKey)

        defaults.synchronize()

        print("🗑️ All user data cleared from local storage")
    }
}

// MARK: - Session Progress Manager

struct SessionProgress: Codable {
    let gameMode: String
    let cardIDs: [String]
    let currentIndex: Int
    let score: Int
    let cardsReviewed: Int // For SmartReview
    let streakCount: Int // For BearQuiz
    let savedAt: Date

    var isValid: Bool {
        // Progress is valid for 24 hours
        Date().timeIntervalSince(savedAt) < 86400
    }
}

class SessionProgressManager {
    static let shared = SessionProgressManager()
    private let defaults = UserDefaults.standard
    private let progressKeyPrefix = "sessionProgress_"

    private init() {}

    func saveProgress(
        gameMode: GameMode,
        cardIDs: [UUID],
        currentIndex: Int,
        score: Int,
        cardsReviewed: Int = 0,
        streakCount: Int = 0
    ) {
        // Don't save if we've completed the session or barely started
        guard currentIndex > 0 && currentIndex < cardIDs.count else { return }

        let progress = SessionProgress(
            gameMode: gameMode.rawValue,
            cardIDs: cardIDs.map { $0.uuidString },
            currentIndex: currentIndex,
            score: score,
            cardsReviewed: cardsReviewed,
            streakCount: streakCount,
            savedAt: Date()
        )

        if let encoded = try? JSONEncoder().encode(progress) {
            defaults.set(encoded, forKey: progressKeyPrefix + gameMode.rawValue)
        }
    }

    func loadProgress(for gameMode: GameMode) -> SessionProgress? {
        guard let data = defaults.data(forKey: progressKeyPrefix + gameMode.rawValue),
              let progress = try? JSONDecoder().decode(SessionProgress.self, from: data),
              progress.isValid else {
            return nil
        }
        return progress
    }

    func clearProgress(for gameMode: GameMode) {
        defaults.removeObject(forKey: progressKeyPrefix + gameMode.rawValue)
    }

    func hasProgress(for gameMode: GameMode) -> Bool {
        return loadProgress(for: gameMode) != nil
    }
}

// MARK: - Test Result Model

struct TestResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let questionCount: Int
    let correctCount: Int
    let timeSpentSeconds: Int
    let categoryBreakdown: [String: CategoryTestResult]
    let answers: [TestAnswer]

    var accuracy: Double {
        guard questionCount > 0 else { return 0 }
        return Double(correctCount) / Double(questionCount) * 100
    }

    init(questionCount: Int, correctCount: Int, timeSpentSeconds: Int, categoryBreakdown: [String: CategoryTestResult], answers: [TestAnswer]) {
        self.id = UUID()
        self.date = Date()
        self.questionCount = questionCount
        self.correctCount = correctCount
        self.timeSpentSeconds = timeSpentSeconds
        self.categoryBreakdown = categoryBreakdown
        self.answers = answers
    }
}

struct CategoryTestResult: Codable {
    var correct: Int = 0
    var total: Int = 0

    var accuracy: Double {
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total) * 100
    }
}

struct TestAnswer: Codable, Identifiable {
    let id: UUID
    let cardID: UUID
    let question: String
    let correctAnswer: String
    let selectedAnswer: String
    let isCorrect: Bool
    let rationale: String
    let category: String

    init(card: Flashcard, selectedAnswer: String, isCorrect: Bool) {
        self.id = UUID()
        self.cardID = card.id
        self.question = card.question
        self.correctAnswer = card.answer
        self.selectedAnswer = selectedAnswer
        self.isCorrect = isCorrect
        self.rationale = card.rationale
        self.category = card.contentCategory.rawValue
    }
}

// MARK: - Spaced Repetition Data Model

struct SpacedRepetitionData: Codable {
    var easeFactor: Double = 2.5
    var interval: Int = 0
    var repetitions: Int = 0
    var nextReviewDate: Date = Date()

    // SM-2 Algorithm implementation
    mutating func processResponse(quality: Int) {
        // quality: 0-5 (0-2 = fail, 3-5 = pass)
        if quality >= 3 {
            // Correct response
            if repetitions == 0 {
                interval = 1
            } else if repetitions == 1 {
                interval = 6
            } else {
                interval = Int(Double(interval) * easeFactor)
            }
            repetitions += 1
        } else {
            // Incorrect response - reset
            repetitions = 0
            interval = 1
        }

        // Update ease factor
        let newEF = easeFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02))
        easeFactor = max(1.3, newEF)

        // Set next review date
        nextReviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()
    }

    var isDue: Bool {
        return Date() >= nextReviewDate
    }

    var daysUntilDue: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: nextReviewDate).day ?? 0
        return max(0, days)
    }
}

// MARK: - Card Notes Model

struct CardNote: Codable, Identifiable {
    let id: UUID
    let cardID: UUID
    var note: String
    let createdDate: Date
    var modifiedDate: Date

    init(id: UUID = UUID(), cardID: UUID, note: String) {
        self.id = id
        self.cardID = cardID
        self.note = note
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
}

// MARK: - Achievement System

enum AchievementType: String, Codable, CaseIterable {
    case firstCard = "First Steps"
    case tenCards = "Getting Started"
    case fiftyCards = "Dedicated Learner"
    case hundredCards = "Century Club"
    case fiveHundredCards = "Card Master"
    case firstMastered = "First Mastery"
    case tenMastered = "Growing Strong"
    case fiftyMastered = "Knowledge Builder"
    case hundredMastered = "Expert Level"
    case threeDayStreak = "On a Roll"
    case sevenDayStreak = "Week Warrior"
    case thirtyDayStreak = "Monthly Master"
    case firstTest = "Test Taker"
    case perfectTest = "Perfect Score"
    case allCategories = "Well Rounded"

    var icon: String {
        switch self {
        case .firstCard, .tenCards, .fiftyCards, .hundredCards, .fiveHundredCards:
            return "square.stack.fill"
        case .firstMastered, .tenMastered, .fiftyMastered, .hundredMastered:
            return "star.fill"
        case .threeDayStreak, .sevenDayStreak, .thirtyDayStreak:
            return "flame.fill"
        case .firstTest, .perfectTest:
            return "doc.text.fill"
        case .allCategories:
            return "chart.pie.fill"
        }
    }

    var description: String {
        switch self {
        case .firstCard: return "Study your first card"
        case .tenCards: return "Study 10 cards"
        case .fiftyCards: return "Study 50 cards"
        case .hundredCards: return "Study 100 cards"
        case .fiveHundredCards: return "Study 500 cards"
        case .firstMastered: return "Master your first card"
        case .tenMastered: return "Master 10 cards"
        case .fiftyMastered: return "Master 50 cards"
        case .hundredMastered: return "Master 100 cards"
        case .threeDayStreak: return "3 day study streak"
        case .sevenDayStreak: return "7 day study streak"
        case .thirtyDayStreak: return "30 day study streak"
        case .firstTest: return "Complete your first test"
        case .perfectTest: return "Get 100% on a test"
        case .allCategories: return "Study all categories"
        }
    }

    var color: Color {
        switch self {
        case .firstCard, .tenCards: return .mintGreen
        case .fiftyCards, .hundredCards, .fiveHundredCards: return .softLavender
        case .firstMastered, .tenMastered: return .pastelPink
        case .fiftyMastered, .hundredMastered: return .coralPink
        case .threeDayStreak: return .peachOrange
        case .sevenDayStreak, .thirtyDayStreak: return .orange
        case .firstTest, .perfectTest: return .skyBlue
        case .allCategories: return .lavenderGreen
        }
    }
}

struct Achievement: Codable, Identifiable {
    let id: UUID
    let type: AchievementType
    let unlockedDate: Date

    init(type: AchievementType) {
        self.id = UUID()
        self.type = type
        self.unlockedDate = Date()
    }
}

// MARK: - Notification Manager

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var isAuthorized = false
    @Published var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()

    private let reminderTimeKey = "studyReminderTime"
    private let remindersEnabledKey = "studyRemindersEnabled"

    static let nursingAffirmations: [String] = [
        "You know more than you think you do. Trust your gut.",
        "This exam tests your safety, not your worth. You are safe.",
        "Take a deep breath. Your future patients are waiting for you.",
        "You are going to be an incredible RN. Keep going.",
        "Don't panic. Read the question again. You got this.",
        "Visualizing you with that 'RN' behind your name. It's coming.",
        "Progress over perfection. You are doing great."
    ]

    init() {
        loadSettings()
        checkAuthorizationStatus()
    }

    func loadSettings() {
        if let timeInterval = UserDefaults.standard.object(forKey: reminderTimeKey) as? TimeInterval {
            reminderTime = Date(timeIntervalSince1970: timeInterval)
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(reminderTime.timeIntervalSince1970, forKey: reminderTimeKey)
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.scheduleStudyReminder()
                    self.scheduleDailyAffirmation()
                }
            }
        }
    }

    /// Called from the onboarding "Let Bear Help You" slide
    func requestPermissionAndSchedule(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.scheduleDailyAffirmation()
                    self.scheduleStudyReminder()
                }
                completion()
            }
        }
    }

    // MARK: - Daily Affirmation (9:00 AM)

    func scheduleDailyAffirmation() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyAffirmation"])

        let affirmation = Self.nursingAffirmations.randomElement() ?? Self.nursingAffirmations[0]

        let content = UNMutableNotificationContent()
        content.title = "Daily Cozy Reminder"
        content.body = affirmation
        content.sound = .default

        var components = DateComponents()
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyAffirmation", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Study Reminder (6:00 PM)

    func scheduleStudyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["studyReminder"])

        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak Alive!"
        content.body = "A quick 5-minute session is all it takes. Don't break the chain!"
        content.sound = .default
        content.badge = 1

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "studyReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
        saveSettings()
    }

    /// Schedule a streak warning notification if user hasn't studied
    func scheduleStreakWarning(currentStreak: Int) {
        guard currentStreak > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Streak at Risk! 🔥"
        content.body = "Your \(currentStreak)-day streak will end at midnight! Study now to keep it alive."
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        // Schedule for 9 PM if they haven't studied
        var components = DateComponents()
        components.hour = 21
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "streakWarning", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    /// Cancel streak warning (call when user studies)
    func cancelStreakWarning() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["streakWarning"])
    }

    /// Clear badge count
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    func cancelReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Achievement Manager

class AchievementManager: ObservableObject {
    @Published var unlockedAchievements: [Achievement] = []
    @Published var newAchievement: Achievement?

    private let achievementsKey = "unlockedAchievements"

    init() {
        loadAchievements()
    }

    func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let achievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            unlockedAchievements = achievements
        }
    }

    func saveAchievements() {
        if let data = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }

    func hasAchievement(_ type: AchievementType) -> Bool {
        unlockedAchievements.contains { $0.type == type }
    }

    func unlock(_ type: AchievementType) {
        guard !hasAchievement(type) else { return }
        let achievement = Achievement(type: type)
        unlockedAchievements.append(achievement)
        newAchievement = achievement
        saveAchievements()

        // Trigger app review prompt for achievements
        ReviewManager.shared.recordAchievementUnlocked()
    }

    func checkAchievements(stats: UserStats, masteredCount: Int, categoriesStudied: Set<String>) {
        // Cards studied achievements
        if stats.totalCardsStudied >= 1 { unlock(.firstCard) }
        if stats.totalCardsStudied >= 10 { unlock(.tenCards) }
        if stats.totalCardsStudied >= 50 { unlock(.fiftyCards) }
        if stats.totalCardsStudied >= 100 { unlock(.hundredCards) }
        if stats.totalCardsStudied >= 500 { unlock(.fiveHundredCards) }

        // Mastery achievements
        if masteredCount >= 1 { unlock(.firstMastered) }
        if masteredCount >= 10 { unlock(.tenMastered) }
        if masteredCount >= 50 { unlock(.fiftyMastered) }
        if masteredCount >= 100 { unlock(.hundredMastered) }

        // Streak achievements
        if stats.currentStreak >= 3 { unlock(.threeDayStreak) }
        if stats.currentStreak >= 7 { unlock(.sevenDayStreak) }
        if stats.currentStreak >= 30 { unlock(.thirtyDayStreak) }

        // Category achievement
        if categoriesStudied.count >= ContentCategory.allCases.count {
            unlock(.allCategories)
        }
    }

    func checkTestAchievements(isFirstTest: Bool, isPerfect: Bool) {
        if isFirstTest { unlock(.firstTest) }
        if isPerfect { unlock(.perfectTest) }
    }
}

// MARK: - Appearance Manager

class AppearanceManager: ObservableObject {
    static let shared = AppearanceManager()

    enum Mode: Int, CaseIterable {
        case system = 0
        case light = 1
        case dark = 2

        var name: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }

        var icon: String {
            switch self {
            case .system: return "iphone"
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            }
        }

        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    @Published var currentMode: Mode {
        didSet {
            PersistenceManager.shared.setAppearanceMode(currentMode.rawValue)
        }
    }

    init() {
        let savedMode = PersistenceManager.shared.getAppearanceMode()
        self.currentMode = Mode(rawValue: savedMode) ?? .system
    }
}

// MARK: - Haptic Feedback Manager

class HapticManager {
    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    private let selectionFeedback = UISelectionFeedbackGenerator()

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "hapticsEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "hapticsEnabled") }
    }

    init() {
        // Default to enabled if not set
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "hapticsEnabled")
        }
        prepareAll()
    }

    private func prepareAll() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationFeedback.prepare()
        selectionFeedback.prepare()
    }

    func light() {
        guard isEnabled else { return }
        lightImpact.impactOccurred()
    }

    func medium() {
        guard isEnabled else { return }
        mediumImpact.impactOccurred()
    }

    func heavy() {
        guard isEnabled else { return }
        heavyImpact.impactOccurred()
    }

    func soft() {
        guard isEnabled else { return }
        softImpact.impactOccurred()
    }

    func rigid() {
        guard isEnabled else { return }
        rigidImpact.impactOccurred()
    }

    func success() {
        guard isEnabled else { return }
        notificationFeedback.notificationOccurred(.success)
    }

    func warning() {
        guard isEnabled else { return }
        notificationFeedback.notificationOccurred(.warning)
    }

    func error() {
        guard isEnabled else { return }
        notificationFeedback.notificationOccurred(.error)
    }

    func selection() {
        guard isEnabled else { return }
        selectionFeedback.selectionChanged()
    }

    // Convenience methods for specific actions
    func cardFlip() { soft() }
    func correctAnswer() { success() }
    func wrongAnswer() { error() }
    func buttonTap() { light() }
    func swipe() { medium() }
    func achievement() {
        guard isEnabled else { return }
        // Double tap for achievements
        heavyImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            heavyImpact.impactOccurred()
        }
    }
    func levelUp() {
        guard isEnabled else { return }
        // Triple success for level up
        notificationFeedback.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [self] in
            notificationFeedback.notificationOccurred(.success)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            notificationFeedback.notificationOccurred(.success)
        }
    }
    func streak() { rigid() }
}

// MARK: - Sound Manager

class SoundManager: ObservableObject {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "soundsEnabled")
        }
    }

    init() {
        // Default to enabled if not set
        if UserDefaults.standard.object(forKey: "soundsEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "soundsEnabled")
        }
        isEnabled = UserDefaults.standard.bool(forKey: "soundsEnabled")

        // Configure audio session
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func playSystemSound(_ soundID: SystemSoundID) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(soundID)
    }

    func cardFlip() {
        playSystemSound(1104) // Tock sound
    }

    func correctAnswer() {
        playSystemSound(1057) // Positive sound
    }

    func wrongAnswer() {
        playSystemSound(1053) // Negative sound
    }

    func buttonTap() {
        playSystemSound(1104) // Light tap
    }

    func achievement() {
        playSystemSound(1025) // Fanfare-like
    }

    func levelUp() {
        playSystemSound(1026) // Level up sound
    }

    func streak() {
        playSystemSound(1016) // Tweet sound
    }

    func swipe() {
        playSystemSound(1306) // Swoosh
    }

    func celebration() {
        playSystemSound(1335) // Confetti/celebration
    }
}

// MARK: - Daily Goals & XP System

/// Random number generator with a seed for consistent daily goals
struct SeededRandomGenerator: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

struct DailyGoal: Codable, Identifiable {
    let id: UUID
    let type: DailyGoalType
    var target: Int
    var progress: Int
    let xpReward: Int
    var isCompleted: Bool

    init(type: DailyGoalType, target: Int, xpReward: Int) {
        self.id = UUID()
        self.type = type
        self.target = target
        self.progress = 0
        self.xpReward = xpReward
        self.isCompleted = false
    }

    var progressPercent: Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(progress) / Double(target))
    }
}

enum DailyGoalType: String, Codable, CaseIterable {
    case studyCards = "Study Cards"
    case correctAnswers = "Get Correct"
    case studyMinutes = "Study Time"
    case masterCards = "Master Cards"
    case perfectQuiz = "Perfect Quiz"
    case studyCategories = "Study Categories"
    case correctStreak = "Correct Streak"
    case reviewCards = "Review Cards"

    var icon: String {
        switch self {
        case .studyCards: return "square.stack.fill"
        case .correctAnswers: return "checkmark.circle.fill"
        case .studyMinutes: return "clock.fill"
        case .masterCards: return "star.fill"
        case .perfectQuiz: return "rosette"
        case .studyCategories: return "folder.fill"
        case .correctStreak: return "flame.fill"
        case .reviewCards: return "arrow.counterclockwise"
        }
    }

    var color: Color {
        switch self {
        case .studyCards: return .softLavender
        case .correctAnswers: return .mintGreen
        case .studyMinutes: return .skyBlue
        case .masterCards: return .pastelPink
        case .perfectQuiz: return .yellow
        case .studyCategories: return .blue
        case .correctStreak: return .orange
        case .reviewCards: return .purple
        }
    }

    var displayName: String {
        switch self {
        case .studyCards: return "Study Cards"
        case .correctAnswers: return "Get Correct"
        case .studyMinutes: return "Study Time"
        case .masterCards: return "Master Cards"
        case .perfectQuiz: return "Perfect Quiz"
        case .studyCategories: return "Categories"
        case .correctStreak: return "Streak"
        case .reviewCards: return "Review"
        }
    }
}

// MARK: - Daily Commitment (Legacy - kept for backward compatibility)

enum DailyCommitment: String, CaseIterable {
    case light = "Light Study"
    case moderate = "Moderate Study"
    case intense = "Intense Study"

    var bonusXP: Int {
        switch self {
        case .light: return 5
        case .moderate: return 10
        case .intense: return 20
        }
    }
}

// MARK: - Remote Daily Goals Model
struct RemoteDailyGoal: Codable {
    let type: String
    let target: Int
    let xpReward: Int

    enum CodingKeys: String, CodingKey {
        case type
        case target
        case xpReward
    }

    func toDailyGoal() -> DailyGoal? {
        guard let goalType = DailyGoalType(rawValue: type) else { return nil }
        return DailyGoal(type: goalType, target: target, xpReward: xpReward)
    }
}

struct DailyGoalsSchedule: Codable {
    let id: UUID
    let goalDate: String
    let goals: [RemoteDailyGoal]
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case goalDate = "goal_date"
        case goals
        case createdAt = "created_at"
    }
}

class DailyGoalsManager: ObservableObject {
    static let shared = DailyGoalsManager()

    @Published var dailyGoals: [DailyGoal] = []
    @Published var totalXP: Int = 0
    @Published var currentLevel: Int = 1
    @Published var xpForNextLevel: Int = 100
    @Published var showLevelUpCelebration = false
    @Published var lastGoalDate: Date?
    @Published var cardOfTheDay: Flashcard?
    @Published var hasCompletedCardOfTheDay = false
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var hasSignedDailyContract = false
    @Published var dailyCommitment: DailyCommitment?
    @Published var showMilestoneCelebration = false
    @Published var milestoneCelebrationValue: Int = 0
    @Published var isLoadingGoals = false

    private let dailyGoalsKey = "dailyGoals"
    private let totalXPKey = "totalXP"
    private let lastGoalDateKey = "lastGoalDate"
    private let cardOfTheDayIDKey = "cardOfTheDayID"
    private let cardOfTheDayDateKey = "cardOfTheDayDate"
    private let cardOfTheDayCompletedKey = "cardOfTheDayCompleted"
    private let currentStreakKey = "currentStreak"
    private let longestStreakKey = "longestStreak"
    private let lastStudyDateKey = "lastStudyDate"
    private let dailyContractDateKey = "dailyContractDate"
    private let dailyCommitmentKey = "dailyCommitment"
    private let celebratedMilestonesKey = "celebratedMilestones"
    private let lastFetchedGoalsDateKey = "lastFetchedGoalsDate"
    private let syncManager = SyncManager.shared
    private var isInitializing = true

    init() {
        loadData()
        checkAndResetDailyGoals()
        isInitializing = false
        print("🎯 DailyGoalsManager init: \(dailyGoals.count) goals loaded")
    }

    func loadData() {
        totalXP = UserDefaults.standard.integer(forKey: totalXPKey)
        calculateLevel()

        if let data = UserDefaults.standard.data(forKey: dailyGoalsKey),
           let goals = try? JSONDecoder().decode([DailyGoal].self, from: data) {
            dailyGoals = goals
        }

        if let date = UserDefaults.standard.object(forKey: lastGoalDateKey) as? Date {
            lastGoalDate = date
        }

        hasCompletedCardOfTheDay = UserDefaults.standard.bool(forKey: cardOfTheDayCompletedKey)
        currentStreak = UserDefaults.standard.integer(forKey: currentStreakKey)
        longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)

        // Check if daily contract was signed today
        checkDailyContract()
    }

    private func checkDailyContract() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let contractDate = UserDefaults.standard.object(forKey: dailyContractDateKey) as? Date {
            let contractDay = calendar.startOfDay(for: contractDate)
            hasSignedDailyContract = calendar.isDate(contractDay, inSameDayAs: today)
        } else {
            hasSignedDailyContract = false
        }

        if hasSignedDailyContract, let commitmentRaw = UserDefaults.standard.string(forKey: dailyCommitmentKey) {
            dailyCommitment = DailyCommitment(rawValue: commitmentRaw)
        } else {
            dailyCommitment = nil
        }
    }

    func saveData() {
        UserDefaults.standard.set(totalXP, forKey: totalXPKey)
        if let data = try? JSONEncoder().encode(dailyGoals) {
            UserDefaults.standard.set(data, forKey: dailyGoalsKey)
        }
        UserDefaults.standard.set(lastGoalDate, forKey: lastGoalDateKey)
        UserDefaults.standard.set(hasCompletedCardOfTheDay, forKey: cardOfTheDayCompletedKey)
        UserDefaults.standard.set(currentStreak, forKey: currentStreakKey)
        UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)

        // Mark XP data for sync
        syncManager.markChanged(CloudKitConfig.RecordType.userXP, id: "main")

        // Skip widget update during init to avoid circular dependency with StatsManager
        guard !isInitializing else { return }

        // Update widget data
        let stats = StatsManager.shared.stats
        let completedGoals = dailyGoals.filter { $0.isCompleted }.count
        WidgetDataManager.update(
            streak: currentStreak, level: currentLevel, levelTitle: levelTitle,
            totalXP: totalXP, xpProgress: xpProgressPercent,
            totalCardsStudied: stats.totalCardsStudied,
            accuracy: stats.overallAccuracy,
            dailyGoalsCompleted: completedGoals, dailyGoalsTotal: dailyGoals.count,
            cardOfTheDayQuestion: cardOfTheDay?.question ?? "Start studying to see your Card of the Day!",
            cardOfTheDayCategory: cardOfTheDay?.contentCategory.rawValue ?? "General"
        )
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Resets all in-memory state for a new user (called on logout)
    func resetForNewUser() {
        dailyGoals = []
        totalXP = 0
        currentLevel = 1
        xpForNextLevel = 100
        showLevelUpCelebration = false
        lastGoalDate = nil
        cardOfTheDay = nil
        hasCompletedCardOfTheDay = false
        currentStreak = 0
        longestStreak = 0
        hasSignedDailyContract = false
        dailyCommitment = nil
        showMilestoneCelebration = false
        milestoneCelebrationValue = 0
    }

    func signDailyContract(_ commitment: DailyCommitment) {
        hasSignedDailyContract = true
        dailyCommitment = commitment
        UserDefaults.standard.set(Date(), forKey: dailyContractDateKey)
        UserDefaults.standard.set(commitment.rawValue, forKey: dailyCommitmentKey)

        // Award bonus XP for signing contract
        addXP(commitment.bonusXP)
    }

    func recordStudyActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastStudy = UserDefaults.standard.object(forKey: lastStudyDateKey) as? Date {
            let lastStudyDay = calendar.startOfDay(for: lastStudy)
            let daysDiff = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0

            if daysDiff == 1 {
                // Consecutive day - increase streak
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
                // Trigger review prompt for streak milestones
                ReviewManager.shared.recordStreakMilestone()
            } else if daysDiff > 1 {
                // Missed days - reset streak
                currentStreak = 1
            }
            // daysDiff == 0 means same day, don't change streak
        } else {
            // First study ever
            currentStreak = 1
        }

        UserDefaults.standard.set(today, forKey: lastStudyDateKey)
        saveData()
    }

    func checkMilestone(masteredCount: Int) {
        let milestones = [100, 500, 1000]
        let celebrated = UserDefaults.standard.array(forKey: celebratedMilestonesKey) as? [Int] ?? []

        for milestone in milestones {
            if masteredCount >= milestone && !celebrated.contains(milestone) {
                // Celebrate this milestone
                milestoneCelebrationValue = milestone
                showMilestoneCelebration = true

                // Mark as celebrated
                var newCelebrated = celebrated
                newCelebrated.append(milestone)
                UserDefaults.standard.set(newCelebrated, forKey: celebratedMilestonesKey)

                // Award milestone XP
                let bonusXP: Int
                switch milestone {
                case 100: bonusXP = 200
                case 500: bonusXP = 500
                case 1000: bonusXP = 1000
                default: bonusXP = 100
                }
                addXP(bonusXP)

                break // Only celebrate one milestone at a time
            }
        }
    }

    func calculateLevel() {
        // XP needed: Level 1 = 100, Level 2 = 250, Level 3 = 450, etc.
        // Formula: 100 + (level - 1) * 150
        var level = 1
        var xpNeeded = 100
        var totalRequired = 0

        while totalXP >= totalRequired + xpNeeded {
            totalRequired += xpNeeded
            level += 1
            xpNeeded = 100 + (level - 1) * 150
        }

        currentLevel = level
        xpForNextLevel = xpNeeded
    }

    var xpProgressInCurrentLevel: Int {
        var level = 1
        var xpNeeded = 100
        var totalRequired = 0

        while totalXP >= totalRequired + xpNeeded && level < currentLevel {
            totalRequired += xpNeeded
            level += 1
            xpNeeded = 100 + (level - 1) * 150
        }

        return totalXP - totalRequired
    }

    var xpProgressPercent: Double {
        guard xpForNextLevel > 0 else { return 0 }
        return Double(xpProgressInCurrentLevel) / Double(xpForNextLevel)
    }

    func checkAndResetDailyGoals() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        print("🎯 checkAndResetDailyGoals: lastGoalDate = \(String(describing: lastGoalDate)), today = \(today)")

        if let lastDate = lastGoalDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            if today > lastDay {
                // New day - reset goals
                print("🎯 New day detected, fetching/generating new goals")
                fetchOrGenerateDailyGoals()
                hasCompletedCardOfTheDay = false
            } else {
                print("🎯 Same day, keeping existing \(dailyGoals.count) goals")
            }
        } else {
            // First time - generate goals
            print("🎯 First time, fetching/generating goals")
            fetchOrGenerateDailyGoals()
        }

        lastGoalDate = today
        saveData()
        print("🎯 After checkAndResetDailyGoals: \(dailyGoals.count) goals")
    }

    /// Fetch daily goals from Supabase, fall back to local generation
    func fetchOrGenerateDailyGoals() {
        // First, generate local goals immediately so UI isn't empty
        generateLocalDailyGoals()

        // Then try to fetch from server (will update if successful)
        Task {
            await fetchDailyGoalsFromServer()
        }
    }

    /// Fetch today's daily goals from Supabase
    @MainActor
    func fetchDailyGoalsFromServer() async {
        guard SupabaseConfig.isConfigured else {
            print("🎯 Supabase not configured, using local goals")
            return
        }

        isLoadingGoals = true
        defer { isLoadingGoals = false }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())

        print("🎯 Fetching daily goals for \(todayString) from Supabase...")

        do {
            let schedules: [DailyGoalsSchedule] = try await SupabaseConfig.client
                .from("daily_goals_schedule")
                .select()
                .eq("goal_date", value: todayString)
                .execute()
                .value

            if let schedule = schedules.first {
                let remoteGoals = schedule.goals.compactMap { $0.toDailyGoal() }
                if remoteGoals.count >= 3 {
                    // Keep current progress if goal types match
                    var updatedGoals: [DailyGoal] = []
                    for remoteGoal in remoteGoals {
                        if let existingGoal = dailyGoals.first(where: { $0.type == remoteGoal.type }) {
                            var goal = remoteGoal
                            goal.progress = existingGoal.progress
                            goal.isCompleted = existingGoal.isCompleted
                            updatedGoals.append(goal)
                        } else {
                            updatedGoals.append(remoteGoal)
                        }
                    }
                    dailyGoals = updatedGoals
                    saveData()
                    print("🎯 Loaded \(remoteGoals.count) goals from server: \(remoteGoals.map { $0.type.rawValue })")
                    return
                }
            }

            print("🎯 No goals found for today in database, using local goals")
        } catch {
            print("🎯 Error fetching daily goals: \(error.localizedDescription)")
        }
    }

    /// Generate goals locally (deterministic based on date - same for all users)
    func generateLocalDailyGoals() {
        // Pool of possible goals with varying difficulty
        let goalPool: [(type: DailyGoalType, target: Int, xpReward: Int)] = [
            // Easy goals
            (.studyCards, 15, 40),
            (.correctAnswers, 10, 35),
            (.studyMinutes, 5, 25),
            (.reviewCards, 10, 30),
            // Medium goals
            (.studyCards, 25, 55),
            (.correctAnswers, 20, 50),
            (.studyMinutes, 15, 45),
            (.masterCards, 3, 60),
            (.studyCategories, 3, 45),
            (.reviewCards, 20, 50),
            // Hard goals
            (.studyCards, 40, 75),
            (.correctAnswers, 30, 65),
            (.studyMinutes, 25, 60),
            (.masterCards, 5, 80),
            (.perfectQuiz, 1, 70),
            (.correctStreak, 10, 75),
        ]

        // Use today's date as seed for consistent daily goals (same for all users!)
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let year = calendar.component(.year, from: Date())
        let combinedSeed = UInt64(year * 1000 + dayOfYear) // Unique per day across years

        // Shuffle based on day to get different goals each day
        var seededRandom = SeededRandomGenerator(seed: combinedSeed)
        let shuffledPool = goalPool.shuffled(using: &seededRandom)

        // Select 3 unique goal types
        var selectedGoals: [DailyGoal] = []
        var selectedTypes: Set<DailyGoalType> = []

        for goal in shuffledPool {
            if !selectedTypes.contains(goal.type) {
                selectedGoals.append(DailyGoal(type: goal.type, target: goal.target, xpReward: goal.xpReward))
                selectedTypes.insert(goal.type)

                if selectedGoals.count == 3 {
                    break
                }
            }
        }

        // Fallback if something goes wrong
        if selectedGoals.count < 3 {
            selectedGoals = [
                DailyGoal(type: .studyCards, target: 20, xpReward: 50),
                DailyGoal(type: .correctAnswers, target: 15, xpReward: 40),
                DailyGoal(type: .studyMinutes, target: 10, xpReward: 30)
            ]
        }

        dailyGoals = selectedGoals
        print("🎯 generateLocalDailyGoals: Generated \(selectedGoals.count) goals: \(selectedGoals.map { $0.type.rawValue })")
        saveData()
    }

    /// Legacy function name for compatibility
    func generateDailyGoals() {
        fetchOrGenerateDailyGoals()
    }

    func updateGoal(_ type: DailyGoalType, progress: Int) {
        if let index = dailyGoals.firstIndex(where: { $0.type == type }) {
            dailyGoals[index].progress += progress

            if dailyGoals[index].progress >= dailyGoals[index].target && !dailyGoals[index].isCompleted {
                dailyGoals[index].isCompleted = true
                addXP(dailyGoals[index].xpReward)
                HapticManager.shared.achievement()
                SoundManager.shared.achievement()
            }
            saveData()
        }
    }

    func recordStudySession(cardsStudied: Int, correct: Int, timeSeconds: Int) {
        updateGoal(.studyCards, progress: cardsStudied)
        updateGoal(.correctAnswers, progress: correct)
        updateGoal(.studyMinutes, progress: timeSeconds / 60)

        // Bonus XP for studying
        addXP(cardsStudied * 2 + correct * 3)
    }

    func recordMastery() {
        updateGoal(.masterCards, progress: 1)
        addXP(25) // Bonus for mastering
    }

    /// Record cards reviewed (for Smart Review mode)
    func recordReviewCards(count: Int) {
        updateGoal(.reviewCards, progress: count)
    }

    /// Record a perfect quiz (100% correct)
    func recordPerfectQuiz() {
        updateGoal(.perfectQuiz, progress: 1)
        addXP(50) // Bonus XP for perfect quiz
    }

    /// Record correct answer streak
    func recordCorrectStreak(streakCount: Int) {
        // Only update if this streak is longer than current progress
        if let index = dailyGoals.firstIndex(where: { $0.type == .correctStreak }) {
            if streakCount > dailyGoals[index].progress {
                dailyGoals[index].progress = streakCount
                if streakCount >= dailyGoals[index].target && !dailyGoals[index].isCompleted {
                    dailyGoals[index].isCompleted = true
                    addXP(dailyGoals[index].xpReward)
                    HapticManager.shared.achievement()
                }
                saveData()
            }
        }
    }

    /// Record categories studied (tracks unique categories per day)
    func recordCategoryStudied(_ category: ContentCategory) {
        let key = "categoriesStudiedToday"
        let dateKey = "categoriesStudiedDate"
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Check if we need to reset for a new day
        var studiedCategories: Set<String>
        if let storedDate = UserDefaults.standard.object(forKey: dateKey) as? Date,
           calendar.isDate(storedDate, inSameDayAs: today),
           let stored = UserDefaults.standard.stringArray(forKey: key) {
            studiedCategories = Set(stored)
        } else {
            studiedCategories = []
            UserDefaults.standard.set(today, forKey: dateKey)
        }

        // Add this category if not already studied today
        let categoryName = category.rawValue
        if !studiedCategories.contains(categoryName) {
            studiedCategories.insert(categoryName)
            UserDefaults.standard.set(Array(studiedCategories), forKey: key)
            updateGoal(.studyCategories, progress: 1)
        }
    }

    func addXP(_ amount: Int) {
        let oldLevel = currentLevel
        totalXP += amount
        calculateLevel()

        if currentLevel > oldLevel {
            showLevelUpCelebration = true
            HapticManager.shared.levelUp()
            SoundManager.shared.levelUp()
        }
        saveData()

        // Sync XP to cloud
        Task {
            await CloudSyncManager.shared.syncXPToCloud(totalXP: totalXP)
        }
    }

    // MARK: - Cloud Sync Methods

    /// Set XP from cloud sync (doesn't trigger celebration)
    func setXPFromSync(_ xp: Int) {
        guard xp > totalXP else { return }
        totalXP = xp
        calculateLevel()
        UserDefaults.standard.set(totalXP, forKey: totalXPKey)
        print("☁️ Updated local XP from cloud: \(xp)")
    }

    /// Set streak from cloud sync
    func setStreakFromSync(current: Int, longest: Int) {
        if current > currentStreak {
            currentStreak = current
            UserDefaults.standard.set(currentStreak, forKey: currentStreakKey)
        }
        if longest > longestStreak {
            longestStreak = longest
            UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)
        }
    }

    func selectCardOfTheDay(from cards: [Flashcard]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Check if we already have a card for today
        if let savedDateInterval = UserDefaults.standard.object(forKey: cardOfTheDayDateKey) as? TimeInterval {
            let savedDate = Date(timeIntervalSince1970: savedDateInterval)
            if calendar.isDate(savedDate, inSameDayAs: today) {
                // Load existing card of the day
                if let savedID = UserDefaults.standard.string(forKey: cardOfTheDayIDKey),
                   let uuid = UUID(uuidString: savedID),
                   let card = cards.first(where: { $0.id == uuid }) {
                    cardOfTheDay = card
                    return
                }
            }
        }

        // Select new card of the day based on date seed for consistency
        guard !cards.isEmpty else { return }
        let daysSince1970 = Int(today.timeIntervalSince1970 / 86400)
        let index = daysSince1970 % cards.count
        cardOfTheDay = cards[index]

        // Save for today
        UserDefaults.standard.set(cardOfTheDay?.id.uuidString, forKey: cardOfTheDayIDKey)
        UserDefaults.standard.set(today.timeIntervalSince1970, forKey: cardOfTheDayDateKey)
        hasCompletedCardOfTheDay = false
        saveData()
    }

    func completeCardOfTheDay() {
        guard !hasCompletedCardOfTheDay else { return }
        hasCompletedCardOfTheDay = true
        addXP(20) // Bonus XP for card of the day
        HapticManager.shared.success()
        SoundManager.shared.correctAnswer()
        saveData()
    }

    func resetAllProgress() {
        totalXP = 0
        currentLevel = 1
        dailyGoals = []
        lastGoalDate = nil
        hasCompletedCardOfTheDay = false
        cardOfTheDay = nil

        UserDefaults.standard.removeObject(forKey: totalXPKey)
        UserDefaults.standard.removeObject(forKey: dailyGoalsKey)
        UserDefaults.standard.removeObject(forKey: lastGoalDateKey)
        UserDefaults.standard.removeObject(forKey: cardOfTheDayIDKey)
        UserDefaults.standard.removeObject(forKey: cardOfTheDayDateKey)
        UserDefaults.standard.removeObject(forKey: cardOfTheDayCompletedKey)

        generateDailyGoals()
        calculateLevel()
    }

    var levelTitle: String {
        switch currentLevel {
        case 1: return "Nursing Newbie"
        case 2: return "Student Nurse"
        case 3: return "Aspiring Nurse"
        case 4: return "Dedicated Learner"
        case 5: return "Knowledge Builder"
        case 6: return "Focused Scholar"
        case 7: return "Study Champion"
        case 8: return "Clinical Thinker"
        case 9: return "Expert in Training"
        case 10: return "NCLEX Warrior"
        case 11: return "Quiz Conqueror"
        case 12: return "Senior Scholar"
        case 13: return "Nearly There"
        case 14: return "NCLEX Candidate"
        case 15: return "Test Day Tough"
        case 16: return "Board Ready"
        case 17: return "Elite Learner"
        case 18: return "Future RN"
        case 19: return "Almost There"
        case 20: return "NCLEX Ready"
        case 21: return "NCLEX Master"
        default: return "NCLEX Legend"
        }
    }
}

// MARK: - Animated Button Style

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticManager.shared.buttonTap()
                }
            }
    }
}

struct SoftBounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticManager.shared.light()
                }
            }
    }
}

// MARK: - Shimmer Effect Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    if isActive {
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.4), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 2)
                        .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                    }
                }
                .mask(content)
            )
            .onAppear {
                if isActive {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
            }
    }
}

extension View {
    func shimmer(_ isActive: Bool = true) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }
}

// MARK: - Pulsing Glow Modifier

struct PulsingGlowModifier: ViewModifier {
    let color: Color
    let isActive: Bool
    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color.opacity(isGlowing ? 0.6 : 0.2) : .clear, radius: isGlowing ? 12 : 6)
            .onAppear {
                if isActive {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        isGlowing = true
                    }
                }
            }
    }
}

extension View {
    func pulsingGlow(_ color: Color, isActive: Bool = true) -> some View {
        modifier(PulsingGlowModifier(color: color, isActive: isActive))
    }
}

// MARK: - Color Theme (Dark Mode Adaptive)

extension Color {
    // Adaptive colors using UIColor for dark mode support
    static var creamyBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
                : UIColor(red: 255/255, green: 249/255, blue: 240/255, alpha: 1)
        })
    }

    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
                : UIColor.white
        })
    }

    // Adaptive white - uses dark gray in dark mode
    static var adaptiveWhite: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 1)
                : UIColor.white
        })
    }

    // Adaptive text colors
    static var primaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor.black
        })
    }

    static var secondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.lightGray
                : UIColor.darkGray
        })
    }

    // Accent colors (these work in both modes)
    static let pastelPink = Color(red: 255/255, green: 183/255, blue: 178/255)
    static let mintGreen = Color(red: 181/255, green: 234/255, blue: 215/255)
    static let lavenderGreen = Color(red: 226/255, green: 240/255, blue: 203/255)
    static let softLavender = Color(red: 200/255, green: 180/255, blue: 220/255)
    static let coralPink = Color(red: 255/255, green: 150/255, blue: 150/255)
    static let skyBlue = Color(red: 173/255, green: 216/255, blue: 230/255)
    static let peachOrange = Color(red: 255/255, green: 218/255, blue: 185/255)
}

// MARK: - Enums

enum Screen {
    case onboarding
    case auth
    case menu
    case flashcardsGame
    case learnGame
    case matchGame
    case cardBrowser
    case createCard
    case studySets
    case testMode
    case writeMode
    case stats
    case search
    case blocksGame
}

enum GameMode: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case flashcards = "Study Flashcards"
    case learn = "Bear Learn"
    case match = "Cozy Match"
    case blocks = "Cozy Blocks"
    case test = "Practice Test"
    case write = "Write Mode"

    var icon: String {
        switch self {
        case .flashcards: return "rectangle.on.rectangle.angled"
        case .learn: return "brain.head.profile"
        case .match: return "square.grid.2x2"
        case .write: return "pencil.line"
        case .test: return "doc.text"
        case .blocks: return "square.grid.3x3.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .flashcards: return "Swipe to learn"
        case .learn: return "Adaptive learning"
        case .match: return "Memory match"
        case .write: return "Type answers"
        case .test: return "Practice exam"
        case .blocks: return "Block puzzle study"
        }
    }

    var isPaid: Bool {
        switch self {
        case .flashcards, .match, .blocks: return false
        case .learn, .write, .test: return true
        }
    }
}

enum CardFilter: String, CaseIterable {
    case all = "All Cards"
    case mastered = "Mastered"
    case saved = "Saved"
    case userCreated = "My Cards"
}

enum QuestionType: String, Codable, CaseIterable {
    case standard = "Multiple Choice"
    case sata = "Select All That Apply"
    case priority = "Priority/Order"
    case written = "Written Response"
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var color: Color {
        switch self {
        case .easy: return .mintGreen
        case .medium: return .peachOrange
        case .hard: return .coralPink
        }
    }
}

enum NCLEXCategory: String, Codable, CaseIterable {
    case safeEffectiveCare = "Safe & Effective Care"
    case healthPromotion = "Health Promotion"
    case psychosocial = "Psychosocial Integrity"
    case physiological = "Physiological Integrity"

    var color: Color {
        switch self {
        case .safeEffectiveCare: return .skyBlue
        case .healthPromotion: return .mintGreen
        case .psychosocial: return .softLavender
        case .physiological: return .pastelPink
        }
    }

    var icon: String {
        switch self {
        case .safeEffectiveCare: return "shield.checkered"
        case .healthPromotion: return "heart.circle"
        case .psychosocial: return "brain.head.profile"
        case .physiological: return "waveform.path.ecg"
        }
    }
}

enum ContentCategory: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    case fundamentals = "Fundamentals"
    case medSurg = "Med-Surg"
    case pharmacology = "Pharmacology"
    case pediatrics = "Pediatrics"
    case maternity = "Maternity"
    case mentalHealth = "Mental Health"
    case leadership = "Leadership"
    case infectionControl = "Infection Control"
    case safety = "Safety"

    var color: Color {
        switch self {
        case .fundamentals: return .mintGreen
        case .medSurg: return .pastelPink
        case .pharmacology: return .softLavender
        case .pediatrics: return .skyBlue
        case .maternity: return .peachOrange
        case .mentalHealth: return .lavenderGreen
        case .leadership: return .coralPink
        case .infectionControl: return .mintGreen
        case .safety: return .skyBlue
        }
    }

    var icon: String {
        switch self {
        case .fundamentals: return "book.fill"
        case .medSurg: return "cross.case.fill"
        case .pharmacology: return "pill.fill"
        case .pediatrics: return "figure.and.child.holdinghands"
        case .maternity: return "figure.2.and.child.holdinghands"
        case .mentalHealth: return "brain.head.profile"
        case .leadership: return "person.3.fill"
        case .infectionControl: return "hand.raised.fill"
        case .safety: return "exclamationmark.shield.fill"
        }
    }
}

// MARK: - Flexible Database Value Conversion

extension ContentCategory {
    /// Convert database value to ContentCategory with flexible matching
    static func fromDatabaseValue(_ value: String) -> ContentCategory? {
        // Try exact match first
        if let category = ContentCategory(rawValue: value) {
            return category
        }

        // Normalize: lowercase, remove spaces/underscores/hyphens
        let normalized = value.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "-", with: "")

        // Map normalized values to categories
        switch normalized {
        case "fundamentals":
            return .fundamentals
        case "medsurg", "medsurgery", "medicalsurgical":
            return .medSurg
        case "pharmacology", "pharm":
            return .pharmacology
        case "pediatrics", "peds":
            return .pediatrics
        case "maternity", "maternal", "maternalnewborn", "ob":
            return .maternity
        case "mentalhealth", "mental", "psychiatric", "psych":
            return .mentalHealth
        case "leadership", "management", "leadershipmanagement":
            return .leadership
        case "infectioncontrol", "infection":
            return .infectionControl
        case "safety", "safetyinfectioncontrol":
            return .safety
        default:
            return nil
        }
    }
}

extension NCLEXCategory {
    /// Convert database value to NCLEXCategory with flexible matching
    static func fromDatabaseValue(_ value: String) -> NCLEXCategory? {
        // Try exact match first
        if let category = NCLEXCategory(rawValue: value) {
            return category
        }

        // Normalize: lowercase, remove spaces/underscores/hyphens
        let normalized = value.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "&", with: "")

        // Map normalized values to categories
        switch normalized {
        case "safeeffectivecareenvironment", "safeeffectivecare", "safecare", "safeeffective":
            return .safeEffectiveCare
        case "healthpromotionandmaintenance", "healthpromotion", "healthmaintenance":
            return .healthPromotion
        case "psychosocialintegrity", "psychosocial", "psych":
            return .psychosocial
        case "physiologicalintegrity", "physiological", "physio":
            return .physiological
        default:
            return nil
        }
    }
}

extension Difficulty {
    /// Convert database value to Difficulty with flexible matching
    static func fromDatabaseValue(_ value: String) -> Difficulty? {
        // Try exact match first
        if let difficulty = Difficulty(rawValue: value) {
            return difficulty
        }

        // Normalize: lowercase
        let normalized = value.lowercased()

        switch normalized {
        case "easy", "beginner", "simple":
            return .easy
        case "medium", "moderate", "intermediate":
            return .medium
        case "hard", "difficult", "advanced":
            return .hard
        default:
            return nil
        }
    }
}

extension QuestionType {
    /// Convert database value to QuestionType with flexible matching
    static func fromDatabaseValue(_ value: String) -> QuestionType? {
        // Try exact match first
        if let questionType = QuestionType(rawValue: value) {
            return questionType
        }

        // Normalize: lowercase, remove spaces/underscores/hyphens
        let normalized = value.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "-", with: "")

        switch normalized {
        case "standard", "multiplechoice", "mc", "regular":
            return .standard
        case "selectallthatapply", "sata", "selectall", "multiselect":
            return .sata
        case "priority", "priorityorder", "ordering", "ordered", "sequence", "dragdrop":
            return .priority
        case "written", "writtenresponse", "fillintheblank", "fillin", "blank", "fill":
            return .written
        default:
            return nil
        }
    }
}

// MARK: - Data Models

struct Flashcard: Identifiable, Equatable, Codable {
    let id: UUID
    let question: String
    let answer: String
    let wrongAnswers: [String]
    let rationale: String
    let contentCategory: ContentCategory
    let nclexCategory: NCLEXCategory
    let difficulty: Difficulty
    let questionType: QuestionType
    let isPremium: Bool
    let isUserCreated: Bool

    init(id: UUID = UUID(), question: String, answer: String, wrongAnswers: [String], rationale: String = "", contentCategory: ContentCategory, nclexCategory: NCLEXCategory = .physiological, difficulty: Difficulty = .medium, questionType: QuestionType = .standard, isPremium: Bool = false, isUserCreated: Bool = false) {
        self.id = id
        self.question = question
        self.answer = answer
        self.wrongAnswers = wrongAnswers
        self.rationale = rationale
        self.contentCategory = contentCategory
        self.nclexCategory = nclexCategory
        self.difficulty = difficulty
        self.questionType = questionType
        self.isPremium = isPremium
        self.isUserCreated = isUserCreated
    }

    var allAnswers: [String] {
        wrongAnswers + [answer]
    }

    func shuffledAnswers() -> [String] {
        var options = wrongAnswers

        // Ensure we have at least 3 wrong answers for 4 total options
        if options.count < 3 {
            // Get other answers from cards in the same category to use as distractors
            let sameCategory = Flashcard.allCards.filter { $0.contentCategory == self.contentCategory && $0.id != self.id }
            let otherAnswers = sameCategory.map { $0.answer }.filter { $0 != self.answer && !options.contains($0) }

            // Add random distractors until we have 3 wrong answers
            for distractor in otherAnswers.shuffled() {
                if options.count >= 3 { break }
                options.append(distractor)
            }

            // If still not enough, use answers from any category
            if options.count < 3 {
                let allOtherAnswers = Flashcard.allCards.map { $0.answer }.filter { $0 != self.answer && !options.contains($0) }
                for distractor in allOtherAnswers.shuffled() {
                    if options.count >= 3 { break }
                    options.append(distractor)
                }
            }
        }

        return (options + [answer]).shuffled()
    }

    static func == (lhs: Flashcard, rhs: Flashcard) -> Bool {
        lhs.id == rhs.id
    }
}

struct StudySet: Identifiable, Codable {
    let id: UUID
    var name: String
    var cardIDs: [UUID]
    var color: String
    let createdDate: Date

    init(id: UUID = UUID(), name: String, cardIDs: [UUID] = [], color: String = "pink", createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.cardIDs = cardIDs
        self.color = color
        self.createdDate = createdDate
    }
}

struct StudySession: Codable {
    let date: Date
    let cardsStudied: Int
    let correctAnswers: Int
    let timeSpentSeconds: Int
    let mode: String
}

struct CategoryStats: Codable {
    var correct: Int = 0
    var total: Int = 0

    var accuracy: Double {
        guard total > 0 else { return 0 }
        // Cap at 100% to handle any edge cases
        return min(Double(correct) / Double(total) * 100, 100.0)
    }
}

struct UserStats: Codable {
    var totalCardsStudied: Int = 0
    var totalCorrectAnswers: Int = 0
    var totalTimeSpentSeconds: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastStudyDate: Date?
    var sessions: [StudySession] = []
    var categoryAccuracy: [String: CategoryStats] = [:]

    var overallAccuracy: Double {
        guard totalCardsStudied > 0 else { return 0 }
        // Cap at 100% to handle any edge cases where data might be inconsistent
        return min(Double(totalCorrectAnswers) / Double(totalCardsStudied) * 100, 100.0)
    }
}

/// Tracks card mastery within a single Learn session
struct LearnSessionCard: Identifiable {
    let id: UUID
    let card: Flashcard
    var sessionLevel: Int = 0      // 0 = new, 1 = seen once correct, 2 = learned
    var attempts: Int = 0          // Total attempts this session
    var correctStreak: Int = 0     // Consecutive correct in session

    var isLearned: Bool { sessionLevel >= 2 }
}

struct MatchTile: Identifiable, Equatable {
    let id: UUID
    let cardId: UUID
    let content: String
    let isQuestion: Bool
    var isMatched: Bool = false
    var isSelected: Bool = false
    var showError: Bool = false

    init(id: UUID = UUID(), cardId: UUID, content: String, isQuestion: Bool) {
        self.id = id
        self.cardId = cardId
        self.content = content
        self.isQuestion = isQuestion
    }
}

// MARK: - NCLEX Question Bank

extension Flashcard {
    // FREE CARDS (50) - Available to all users
    static let freeCards: [Flashcard] = [
        Flashcard(
            question: "Which nursing intervention is MOST important for preventing hospital-acquired infections?",
            answer: "Performing hand hygiene before and after patient contact",
            wrongAnswers: ["Wearing gloves for all patient interactions", "Isolating all patients with infections", "Administering prophylactic antibiotics"],
            rationale: "CORRECT: Hand hygiene is THE #1 evidence-based intervention for preventing HAIs per CDC and WHO. Simple, cheap, effective.\n\nWHY OTHER ANSWERS ARE WRONG:\n• Gloves for ALL interactions = Overuse leads to false security; gloves don't replace hand hygiene, and can spread pathogens if not changed\n• Isolating ALL infected patients = Not practical or necessary; isolation is for specific conditions requiring precautions\n• Prophylactic antibiotics = Creates antibiotic resistance; used only for specific surgical situations, not general prevention\n\nTHE 5 MOMENTS FOR HAND HYGIENE (WHO):\n1. Before patient contact\n2. Before aseptic procedure\n3. After body fluid exposure\n4. After patient contact\n5. After touching patient surroundings\n\nNCLEX TIP: Hand hygiene is almost always the correct answer for infection prevention questions.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What does the acronym RACE stand for in fire safety?",
            answer: "Rescue, Alarm, Contain, Extinguish",
            wrongAnswers: ["Run, Alert, Call, Evacuate", "Rescue, Alert, Cover, Exit", "Remove, Alarm, Close, Escape"],
            rationale: "CORRECT: RACE is the standardized fire response protocol used in healthcare facilities.\n\nR - RESCUE patients in immediate danger (closest to fire)\nA - ALARM - pull fire alarm, call switchboard\nC - CONTAIN - close doors to limit fire/smoke spread\nE - EXTINGUISH - only if small, safe, and you're trained (use PASS technique)\n\nWHY OTHER ANSWERS ARE WRONG:\nAll alternatives have incorrect components:\n• \"Run\" - Never run; creates panic, spreads fire\n• \"Call\" - Alarm comes before calling for help\n• \"Exit/Escape\" - Evacuation is last resort, not first step\n• \"Cover\" - Not part of standard protocol\n\nALSO KNOW PASS (Fire Extinguisher):\nP - Pull the pin\nA - Aim at base of fire\nS - Squeeze the handle\nS - Sweep side to side",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What is the correct order for performing a physical assessment?",
            answer: "Inspection, palpation, percussion, auscultation",
            wrongAnswers: ["Palpation, inspection, percussion, auscultation", "Auscultation, inspection, palpation, percussion", "Percussion, palpation, auscultation, inspection"],
            rationale: "CORRECT: IPPA sequence (Inspection, Palpation, Percussion, Auscultation) - systematic head-to-toe approach.\n\nWHY OTHER ANSWERS ARE WRONG:\nAll other orders disrupt the logical sequence:\n• Inspection MUST be first - visual assessment is non-invasive and guides further exam\n• Palpation before inspection means you might miss visible abnormalities\n• Auscultation first can alter findings (especially abdomen)\n\nEXCEPTION: ABDOMINAL ASSESSMENT = Inspection, Auscultation, Percussion, Palpation\nWhy? Palpation and percussion stimulate bowel activity and alter auscultation findings.\n\nMEMORY AID: \"I Properly Perform Assessments\" = Inspection, Palpation, Percussion, Auscultation",
            contentCategory: .fundamentals,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What is the FIRST action a nurse should take when a patient falls?",
            answer: "Assess the patient for injuries",
            wrongAnswers: ["Call the physician", "Complete an incident report", "Help the patient back to bed"],
            rationale: "CORRECT: Assess first - patient safety is the priority. You need to determine injury severity before moving the patient (could have spinal injury).\n\nWHY OTHER ANSWERS ARE WRONG:\n• Call the physician - Assessment data needed first; calling without info wastes time\n• Complete incident report - Administrative task, never takes priority over patient care\n• Help patient back to bed - DANGEROUS - could worsen spinal injury; assess first\n\nNCLEX TIP: When you see \"FIRST action,\" think assessment before intervention. ABC (Airway, Breathing, Circulation) and safety always come first.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient is diagnosed with exocrine pancreatic insufficiency (EPI). Which of the following dietary modifications is MOST important for the nurse to teach the patient?",
            answer: "Consume a low-fat diet with pancreatic enzyme replacement therapy.",
            wrongAnswers: ["Prepare the patient for the prescribed diagnostic imaging procedure", "Initiate intravenous fluid therapy as ordered by the healthcare provider", "Apply a cold compress to the area for twenty minutes at a time"],
            rationale: "Patients with EPI have difficulty digesting fats due to a lack of pancreatic enzymes. A low-fat diet helps reduce symptoms such as steatorrhea (fatty stools), and pancreatic enzyme replacement therapy helps improve digestion and absorption of nutrients. The other options may be helpful in some situations, but the low-fat diet and enzyme replacement are the most crucial components of dietary management for EPI.",
            contentCategory: .fundamentals,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "The nurse is reviewing risk factors for coronary heart disease with a group of patients. Which of the following risk factors is NOT explicitly mentioned in the provided text?",
            answer: "Hyperlipidemia",
            wrongAnswers: ["Serum sodium level", "Arterial blood gas", "Troponin level"],
            rationale: "While the text discusses plaque buildup and narrowing of the arteries, it doesn't explicitly mention hyperlipidemia (high cholesterol) as a risk factor. The text refers to risk factors in general but does not provide a list. Therefore, hyperlipidemia is the answer as it is a risk factor for CHD but is not detailed in the provided content. The other options can be related to symptoms presented in the content (chest pain, shortness of breath, neck pain).",
            contentCategory: .fundamentals,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A nurse is preparing to administer medications. Which action demonstrates proper patient identification?",
            answer: "Check two patient identifiers and compare with the MAR",
            wrongAnswers: ["Ask the patient their name only", "Check the room number", "Verify with the patient's family member"],
            rationale: "CORRECT: Two patient identifiers (name + DOB or name + MRN) per The Joint Commission standards. Compare with MAR to ensure right patient.\n\nWHY OTHER ANSWERS ARE WRONG:\n• Ask name only = Only ONE identifier; patients may answer to wrong name if confused\n• Room number = NEVER an identifier; patients change rooms, wrong patient could be in bed\n• Family member = Family can misidentify; always verify with patient or wristband\n\nMEMORY AID: \"Two IDs before the meds\" - Always TWO identifiers.\n\nCLINICAL PEARL: Use open-ended questions: \"What is your name and date of birth?\" NOT \"Are you Mr. Smith?\" (leading question - confused patients may say yes to anything).",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which vital sign change indicates a patient may be developing shock?",
            answer: "Decreased blood pressure with increased heart rate",
            wrongAnswers: ["Increased blood pressure with decreased heart rate", "Normal blood pressure with normal heart rate", "Decreased blood pressure with decreased heart rate"],
            rationale: "CORRECT: This is COMPENSATORY SHOCK - the heart beats faster (tachycardia) trying to maintain cardiac output as BP drops.\n\nWHY OTHER ANSWERS ARE WRONG:\n• Increased BP + decreased HR = Cushing triad (increased ICP), not shock\n• Normal VS = No shock present\n• Decreased BP + decreased HR = Late/decompensated shock or other cause (beta-blocker effect)\n\nMEMORY AID: Think of shock like a failing pump - heart works harder (faster) but pressure still drops.\n\nCLINICAL PEARL: Early shock may show NORMAL BP because of compensation. Watch for: tachycardia, narrowing pulse pressure, delayed cap refill, anxiety/restlessness.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with tuberculosis is being discharged. Which instruction is MOST important for preventing transmission?",
            answer: "Take all medications exactly as prescribed for the full duration",
            wrongAnswers: ["Avoid all public places permanently", "Wear a mask at home at all times", "Sleep in a separate house from family"],
            rationale: "CORRECT: TB treatment requires 6-9 months of multiple drugs. COMPLETING treatment prevents drug resistance and ensures cure. Non-adherence = MDR-TB.\n\nTB TREATMENT (Standard regimen - RIPE):\n• Rifampin - 6 months\n• Isoniazid (INH) - 6 months\n• Pyrazinamide - 2 months\n• Ethambutol - 2 months\n\nWHY COMPLETION IS CRITICAL:\n• Incomplete treatment = surviving bacteria become resistant\n• Drug-resistant TB is extremely difficult to treat\n• Directly Observed Therapy (DOT) recommended\n\nWHY OTHER ANSWERS ARE WRONG:\n• Avoid all public places permanently = Not necessary; becomes non-infectious 2-3 weeks after starting treatment\n• Mask at home always = Only until non-infectious (2-3 weeks)\n• Separate house = Excessive; good ventilation and treatment sufficient\n\nTB TRANSMISSION PREVENTION:\n• Airborne precautions while hospitalized\n• Negative pressure room\n• N95 respirator for staff\n• Patient wears surgical mask during transport\n• After 2-3 weeks of effective treatment = generally non-infectious\n\nMEDICATION SIDE EFFECTS TO MONITOR:\n• Rifampin: Orange body fluids (normal), hepatotoxicity\n• INH: Peripheral neuropathy (give B6), hepatotoxicity\n• Pyrazinamide: Hepatotoxicity, hyperuricemia\n• Ethambutol: Optic neuritis (report vision changes)\n\nTEACHING: Report signs of hepatotoxicity - dark urine, jaundice, RUQ pain, fatigue",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What is the CORRECT order for donning PPE?",
            answer: "Gown, mask/respirator, goggles/face shield, gloves",
            wrongAnswers: ["Gloves, gown, mask, goggles", "Mask, gloves, gown, goggles", "Goggles, gloves, mask, gown"],
            rationale: "CORRECT: Sequence is designed to prevent contamination of clean equipment and ensure proper fit.\n\nDONNING PPE (putting ON):\n1. GOWN first - ties in back, provides base layer\n2. MASK/RESPIRATOR - requires both hands, fit to face\n3. GOGGLES/FACE SHIELD - over mask straps\n4. GLOVES last - over gown cuffs for complete coverage\n\nDOFFING PPE (taking OFF) - Most contaminated first:\n1. GLOVES first (most contaminated)\n2. Hand hygiene\n3. GOWN (contaminated outside)\n4. Hand hygiene\n5. GOGGLES/FACE SHIELD\n6. MASK/RESPIRATOR last (touch only straps)\n7. Hand hygiene\n\nWHY OTHER ANSWERS ARE WRONG:\n• All start with wrong item\n• Gloves should be last on (first off)\n• Mask needs to be on before eye protection\n\nMEMORY AIDS:\n• DONNING: \"Gown, Mask, Goggles, Gloves\" - GMG G\n• DOFFING: \"Gloves off first, Mask off last\"\n\nKEY POINTS:\n• Perform hand hygiene before donning and after doffing\n• Remove PPE at doorway or in anteroom\n• Discard in appropriate waste container\n• Don't touch face during removal\n• If PPE becomes visibly soiled or torn, change it\n\nN95 RESPIRATOR:\n• Must be fit-tested annually\n• Seal check before each use\n• Cannot wear if facial hair prevents seal",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient has C. difficile infection. Which precautions are required?",
            answer: "Contact precautions with hand washing (not alcohol-based sanitizer)",
            wrongAnswers: ["Droplet precautions only", "Airborne precautions", "Standard precautions only"],
            rationale: "CORRECT: C. diff spores are NOT killed by alcohol. Must use soap and water for hand hygiene. Contact precautions for gown/gloves.\n\nC. DIFF PRECAUTIONS:\n• CONTACT PRECAUTIONS: Gown and gloves\n• HAND WASHING with soap and water (NOT alcohol gel)\n• Private room or cohorting\n• Dedicated equipment\n• Enhanced environmental cleaning with sporicidal agents (bleach-based)\n\nWHY SOAP AND WATER:\n• C. diff forms SPORES\n• Spores are resistant to alcohol\n• Friction of hand washing physically removes spores\n• Bleach kills spores on surfaces\n\nWHY OTHER ANSWERS ARE WRONG:\n• Droplet = C. diff is spread fecal-oral, not respiratory\n• Airborne = Not an airborne pathogen\n• Standard only = Inadequate; increased transmission risk\n\nC. DIFF FACTS:\n• Usually caused by antibiotic use (disrupts normal gut flora)\n• Symptoms: Watery diarrhea, fever, abdominal pain\n• Diagnosis: Stool toxin test\n• Treatment: Stop offending antibiotic, start oral vancomycin or fidaxomicin\n• Complications: Toxic megacolon, perforation\n\nPREVENTION:\n• Antibiotic stewardship (appropriate use only)\n• Contact precautions for infected patients\n• Hand hygiene with soap and water\n• Environmental cleaning with bleach\n• Probiotics may help prevent",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which isolation precaution is required for a patient with tuberculosis?",
            answer: "Airborne precautions with N95 respirator",
            wrongAnswers: ["Contact precautions only", "Droplet precautions with surgical mask", "Standard precautions only"],
            rationale: "CORRECT: TB spreads via airborne droplet nuclei (<5 microns) that remain suspended in air for hours. Requires special precautions.\n\nAIRBORNE PRECAUTIONS:\n• N95 respirator (fit-tested annually)\n• Private room with negative pressure\n• Door must remain closed\n• 6-12 air changes per hour\n• HEPA filtration or exhaust to outside\n• Patient wears surgical mask during transport\n\nAIRBORNE DISEASES (memory aid - MTV):\n• Measles\n• Tuberculosis\n• Varicella (chickenpox) + Disseminated zoster\n\nWHY OTHER ANSWERS ARE WRONG:\n• Contact precautions = For infections spread by touch (MRSA, C. diff)\n• Droplet with surgical mask = For large droplets (flu, pertussis, meningococcal) - surgical mask sufficient\n• Standard precautions = Base level for all patients but inadequate for TB\n\nCOMPARISON OF PRECAUTIONS:\n| Type | Particle Size | Examples | Mask Type |\n|------|---------------|----------|-----------|\n| Airborne | <5 microns | TB, measles, varicella | N95 |\n| Droplet | >5 microns | Flu, pertussis, mumps | Surgical |\n| Contact | N/A (touch) | MRSA, C. diff, scabies | None specific |\n\nTB-SPECIFIC CARE:\n• Patient on airborne precautions until 3 negative sputum smears\n• TB skin test annually for healthcare workers\n• TB prophylaxis if positive PPD without active disease\n• Multi-drug regimen for active TB (6-9 months)",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What is the nurse's responsibility when receiving an unclear or potentially harmful order?",
            answer: "Clarify the order with the prescriber before acting",
            wrongAnswers: ["Carry out the order as written", "Ignore the order", "Have another nurse carry out the order"],
            rationale: "CORRECT: Nurses are legally and ethically obligated to QUESTION unclear, incomplete, or potentially harmful orders. You are accountable for your actions.\n\nWHEN TO CLARIFY ORDERS:\n• Order is illegible or unclear\n• Dose seems incorrect (too high or too low)\n• Medication is contraindicated for this patient\n• Order conflicts with other orders\n• Order doesn't match patient's condition\n• You're unfamiliar with the medication/procedure\n• Order seems to violate policy or standards\n\nWHY OTHER ANSWERS ARE WRONG:\n• Carry out as written = \"Following orders\" is not a defense; nurse is accountable\n• Ignore the order = Patient may be harmed by not receiving needed treatment\n• Have another nurse do it = Passing the problem doesn't resolve it; still your responsibility\n\nCHAIN OF COMMAND:\n1. Contact prescriber directly, clarify concerns\n2. If prescriber refuses to change, contact supervisor\n3. If still unresolved, escalate up chain of command\n4. Document all communication\n\nREFUSING AN ORDER:\n• You have the RIGHT to refuse an order you believe is harmful\n• Document your concerns and who you notified\n• Continue to advocate for patient safety\n\nDOCUMENTATION:\n\"Clarified order with Dr. X regarding [concern]. New order received: [details].\"\nOR\n\"Expressed concern to Dr. X about [order]. Dr. X stated [response]. Notified charge nurse.\"",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which task is appropriate to delegate to a UAP (unlicensed assistive personnel)?",
            answer: "Taking vital signs on a stable patient",
            wrongAnswers: ["Assessing a new patient's pain level", "Administering oral medications", "Teaching a patient about new medications"],
            rationale: "CORRECT: UAPs can perform tasks that are routine, standard, low-risk, and require no nursing judgment. Vital signs on STABLE patients fit this criteria.\n\nTHE 5 RIGHTS OF DELEGATION:\n1. Right TASK (routine, standard procedure)\n2. Right CIRCUMSTANCE (stable patient, predictable outcome)\n3. Right PERSON (competent UAP, within their training)\n4. Right DIRECTION (clear, specific instructions)\n5. Right SUPERVISION (RN monitors and evaluates)\n\nWHAT UAPs CAN DO:\n✓ Vital signs (stable patients)\n✓ ADLs (bathing, feeding, toileting)\n✓ Ambulation\n✓ I&O measurement\n✓ Specimen collection (not invasive)\n✓ Transport\n✓ CPR (if trained)\n\nWHAT UAPs CANNOT DO:\n✗ Assessment (any form)\n✗ Teaching\n✗ Medication administration\n✗ Care planning\n✗ Evaluation of outcomes\n✗ Unstable patients\n✗ Initial or comprehensive assessments\n\nWHY OTHER ANSWERS ARE WRONG:\n• Assessing pain = ASSESSMENT requires RN; UAP can ask and report, but not assess\n• Administering medications = ALWAYS requires licensed nurse (RN or LPN depending on state)\n• Teaching = Requires RN; UAP can reinforce but not teach new content\n\nNCLEX TIP: When \"stable\" appears with a task, it's often delegable. When assessment, teaching, or evaluation is involved, it requires an RN.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A nurse receives report on four patients. Which patient should be assessed FIRST?",
            answer: "Post-op patient with increasing restlessness and blood pressure dropping",
            wrongAnswers: ["Diabetic patient due for morning insulin", "Patient requesting pain medication", "Patient scheduled for discharge teaching"],
            rationale: "CORRECT: This patient shows signs of SHOCK (restlessness = early sign of hypoxia, dropping BP = inadequate perfusion). Post-op bleeding is likely. This is life-threatening.\n\nPRIORITIZATION FRAMEWORKS:\n1. ABCs: Airway, Breathing, Circulation\n2. Maslow's Hierarchy: Physiological needs first\n3. Acute vs Chronic: Acute/changing conditions first\n4. Actual vs Potential: Actual problems before risk for problems\n\nANALYZING THIS QUESTION:\n• Post-op + restlessness + dropping BP = ACTUAL airway/circulation problem (hemorrhagic shock)\n• Insulin due = Scheduled, can wait briefly, patient is stable\n• Pain medication = Important but not life-threatening\n• Discharge teaching = Can definitely wait\n\nWHY OTHER ANSWERS ARE WRONG:\n• Diabetic/insulin = Scheduled task, patient presumably stable; come back to this\n• Pain medication = Comfort need, not life-threatening; return after emergency\n• Discharge teaching = Lowest priority; psychosocial/educational need\n\nNCLEX PRIORITIZATION TIPS:\n• \"Unstable\" and \"changing\" are red flags = see first\n• New onset symptoms > chronic symptoms\n• Assessment findings suggesting shock, bleeding, airway compromise = EMERGENCY\n• Scheduled tasks can wait (briefly) for emergencies\n• Teaching and comfort needs are lower priority than survival needs",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A nurse makes a medication error. What is the FIRST action?",
            answer: "Assess the patient for adverse effects",
            wrongAnswers: ["Complete an incident report before telling anyone", "Notify the nurse manager", "Call the pharmacy"],
            rationale: "CORRECT: PATIENT SAFETY FIRST. Always assess for harm before any administrative actions. The patient may need immediate intervention.\n\nMEDICATION ERROR RESPONSE SEQUENCE:\n1. ASSESS the patient immediately (Are they okay? Signs of adverse reaction?)\n2. INTERVENE if needed (antidotes, supportive care, call rapid response)\n3. NOTIFY the provider (they need to know to manage patient care)\n4. DOCUMENT objectively in the medical record (what happened, patient assessment, interventions)\n5. COMPLETE incident report (for quality improvement, NOT in medical record)\n6. NOTIFY manager per facility policy\n\nWHY OTHER ANSWERS ARE WRONG:\n• Incident report first = Administrative task never before patient care\n• Notify manager = Important but after patient assessment and provider notification\n• Call pharmacy = May be needed later but patient comes first\n\nDOCUMENTATION OF ERRORS:\n• DO document: What happened, patient assessment, interventions, provider notification\n• DON'T document: \"Error made,\" \"Incident report filed,\" speculation, blame\n\nINCIDENT REPORTS:\n• Quality improvement tool, not punitive (in most systems)\n• NOT part of medical record\n• Don't reference in chart notes\n• Identifies system issues and patterns\n\nNCLEX TIP: Patient assessment and safety ALWAYS come first. Administrative tasks are important but never take priority over patient care.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A 68-year-old African American male is admitted with worsening symptoms of heart failure. The nurse understands that this population is at higher risk for heart failure. What intervention should the nurse prioritize when providing care?",
            answer: "Strict adherence to prescribed medication regimen and dietary restrictions.",
            wrongAnswers: ["Delegate the task to a licensed practical nurse under appropriate supervision", "Notify the charge nurse and document the situation in the patient's chart", "Assign the most experienced nurse to the patient requiring complex care"],
            rationale: "African Americans tend to develop heart failure earlier and have more severe cases, partly due to higher rates of hypertension and other contributing factors. Therefore, ensuring strict adherence to the medication regimen and dietary restrictions (such as low sodium) is crucial for managing the condition and preventing further complications. While the other options are important aspects of care, medication adherence is most critical for this patient population.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What is the normal fetal heart rate range?",
            answer: "110-160 beats per minute",
            wrongAnswers: ["60-100 beats per minute", "100-150 beats per minute", "160-200 beats per minute"],
            rationale: "CORRECT: Normal FHR baseline is 110-160 bpm, measured between contractions over a 10-minute period.\n\nFHR BASELINE CATEGORIES:\n• Bradycardia: <110 bpm for >10 minutes\n• Normal: 110-160 bpm\n• Tachycardia: >160 bpm for >10 minutes\n\nWHY OTHER ANSWERS ARE WRONG:\n• 60-100 = Adult heart rate; would be severe fetal bradycardia\n• 100-150 = Lower limit too low\n• 160-200 = Would be fetal tachycardia\n\nCAUSES OF FETAL BRADYCARDIA:\n• Fetal hypoxia (late sign)\n• Maternal hypotension\n• Cord compression\n• Maternal medication (beta-blockers)\n• Prolonged pushing\n\nCAUSES OF FETAL TACHYCARDIA:\n• Maternal fever/infection\n• Fetal anemia\n• Fetal hypoxia (early sign)\n• Medications (terbutaline)\n• Fetal arrhythmia\n\nREASSURING FHR CHARACTERISTICS:\n• Baseline 110-160 bpm\n• Moderate variability (6-25 bpm fluctuation)\n• Accelerations present (increase ≥15 bpm for ≥15 seconds)\n• No late or variable decelerations\n\nNON-REASSURING SIGNS:\n• Absent or minimal variability\n• Recurrent late decelerations\n• Recurrent severe variable decelerations\n• Prolonged decelerations\n• Sinusoidal pattern",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What is the expected fundal height at 20 weeks gestation?",
            answer: "At the level of the umbilicus",
            wrongAnswers: ["Just above the symphysis pubis", "Halfway between umbilicus and xiphoid", "At the xiphoid process"],
            rationale: "CORRECT: McDonald's rule: Fundal height in cm ≈ gestational age in weeks. At 20 weeks, fundus is at umbilicus.\n\nFUNDAL HEIGHT LANDMARKS:\n• 12 weeks: Just above symphysis pubis\n• 16 weeks: Halfway between symphysis and umbilicus\n• 20 weeks: At umbilicus\n• 36 weeks: At xiphoid process (highest point)\n• 38-40 weeks: May drop as baby engages (lightening)\n\nWHY OTHER ANSWERS ARE WRONG:\n• Above symphysis = 12 weeks (too early)\n• Between umbilicus and xiphoid = 28-32 weeks\n• At xiphoid = 36 weeks (too late)\n\nFUNDAL HEIGHT ASSESSMENT:\n• Measure from top of symphysis to top of fundus\n• Use non-elastic tape measure\n• Patient should empty bladder first\n• After 20 weeks: Discrepancy of >2-3 cm warrants investigation\n\nCAUSES OF FUNDAL HEIGHT DISCREPANCY:\nTOO LARGE:\n• Wrong dates\n• Multiple gestation\n• Polyhydramnios\n• Macrosomia\n• Fibroids\n\nTOO SMALL:\n• Wrong dates\n• IUGR\n• Oligohydramnios\n• Fetal demise\n\nMEMORY AID: \"At 20 weeks, fundus is at the belly button (umbilicus).\"",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A postpartum patient has a boggy uterus and heavy bleeding. What is the FIRST nursing action?",
            answer: "Massage the uterine fundus",
            wrongAnswers: ["Administer pain medication", "Call for emergency surgery", "Insert a Foley catheter"],
            rationale: "CORRECT: Boggy uterus = UTERINE ATONY, the #1 cause of postpartum hemorrhage. Fundal massage is the immediate first intervention - stimulates uterine contraction to control bleeding.\n\nPOSTPARTUM HEMORRHAGE (PPH) CAUSES - \"The 4 T's\":\n1. TONE (atony) - 70-80% of cases - boggy, soft uterus\n2. TRAUMA - lacerations, hematoma, uterine rupture\n3. TISSUE - retained placenta or clots\n4. THROMBIN - coagulation disorders\n\nWHY OTHER ANSWERS ARE WRONG:\n• Pain medication = Does not address the emergency bleeding\n• Emergency surgery = May be needed but try less invasive measures first\n• Foley catheter = A full bladder CAN prevent uterine contraction, but massage first while preparing to empty bladder\n\nPPH MANAGEMENT SEQUENCE:\n1. Fundal massage (FIRST - immediate, noninvasive)\n2. Empty bladder (Foley if needed)\n3. Uterotonics: Oxytocin, Methylergonovine, Carboprost, Misoprostol\n4. Bimanual compression if above fail\n5. Surgical intervention (B-Lynch suture, hysterectomy) as last resort\n\nPPH DEFINITION: >500 mL for vaginal birth, >1000 mL for cesarean\n\nFUNDAL MASSAGE TECHNIQUE: One hand on fundus, massage firmly in circular motion. Other hand supports lower uterus to prevent uterine inversion.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A pregnant patient at 28 weeks has Rh-negative blood. When should RhoGAM be administered?",
            answer: "At 28 weeks gestation and within 72 hours after delivery if baby is Rh-positive",
            wrongAnswers: ["Only after delivery", "Only if antibodies are present", "At every prenatal visit"],
            rationale: "CORRECT: RhoGAM (Rh immune globulin) prevents Rh sensitization in Rh-negative mothers carrying Rh-positive babies.\n\nRhoGAM TIMING:\n• 28 weeks gestation (routine antepartum dose)\n• Within 72 hours after delivery (if baby is Rh-positive)\n• After any event with risk of fetal-maternal hemorrhage\n\nADDITIONAL INDICATIONS FOR RhoGAM:\n• Miscarriage or elective abortion\n• Ectopic pregnancy\n• Amniocentesis, CVS\n• Abdominal trauma during pregnancy\n• Placental abruption or previa with bleeding\n• External cephalic version\n\nWHY OTHER ANSWERS ARE WRONG:\n• Only after delivery = Need prenatal dose at 28 weeks (fetal cells may cross in 3rd trimester)\n• Only if antibodies present = Once antibodies form, RhoGAM won't help; it PREVENTS sensitization\n• Every visit = Not necessary; specific timing is important\n\nRh SENSITIZATION EXPLAINED:\n• Rh-negative mother + Rh-positive baby = Risk of sensitization\n• Fetal RBCs enter maternal circulation → mother makes anti-Rh antibodies\n• FIRST pregnancy usually okay (sensitization occurs at delivery)\n• SUBSEQUENT pregnancies: Antibodies cross placenta → attack fetal RBCs → hemolytic disease\n\nRhoGAM contains anti-D antibodies that destroy any Rh-positive fetal cells before mother can make her own antibodies.\n\nDOSE: 300 mcg IM covers up to 30 mL of fetal blood exposure.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "When should a pregnant patient feel fetal movement (quickening)?",
            answer: "Primigravida: 18-20 weeks; Multigravida: 16-18 weeks",
            wrongAnswers: ["8-10 weeks in all pregnancies", "25-28 weeks in all pregnancies", "Only after 30 weeks"],
            rationale: "CORRECT: Multiparous women feel movement earlier because they recognize the sensation from previous pregnancies.\n\nQUICKENING EXPLAINED:\n• First maternal perception of fetal movement\n• Described as \"fluttering,\" \"butterflies,\" or \"gas bubbles\"\n• Multigravida feel it earlier (experienced, know what to expect)\n• Movement present earlier but not felt until quickening\n\nWHY OTHER ANSWERS ARE WRONG:\n• 8-10 weeks = Too early; fetus moves but too small to feel\n• 25-28 weeks = Too late; quickening occurs earlier\n• After 30 weeks = Much too late\n\nFETAL MOVEMENT COUNTING:\n• Third trimester: Count kicks (fetal kick counts)\n• Cardiff method: Count to 10 movements; should reach 10 within 2 hours\n• If <10 movements in 2 hours after eating and lying on side: Contact provider\n\nDECREASED FETAL MOVEMENT:\n• May indicate fetal compromise\n• Warrants evaluation (NST, BPP)\n• Assess for: maternal medications, fetal sleep cycle, anterior placenta (muffles movement)\n\nIMPORTANT MILESTONES:\n• Quickening: 16-20 weeks\n• Audible FHR with Doppler: 10-12 weeks\n• FHR audible with fetoscope: 18-20 weeks\n• Fetus viable: ~24 weeks\n\nPATIENT TEACHING: Report decreased fetal movement; it may indicate fetal distress.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with acute kidney injury has a urine output of 200 mL in 24 hours. What phase of AKI is the patient in?",
            answer: "Oliguric phase",
            wrongAnswers: ["Initiation phase", "Diuretic phase", "Recovery phase"],
            rationale: "CORRECT: OLIGURIA = urine output <400 mL/day. This patient with 200 mL/24hr is in oliguric phase - the most dangerous phase with highest mortality.\n\nAKI PHASES:\n\n1. INITIATION (Onset):\n• Begins with insult (ischemia, toxin, obstruction)\n• Hours to days\n• May be preventable if caught early\n\n2. OLIGURIC/ANURIC PHASE:\n• Urine output <400 mL/day (oliguria) or <100 mL/day (anuria)\n• Lasts 1-3 weeks\n• Highest mortality\n• Fluid overload, hyperkalemia, uremia\n\n3. DIURETIC PHASE:\n• Urine output increases (may be >3-5 L/day)\n• Kidneys recovering\n• Risk of dehydration and electrolyte loss\n• Lasts 1-3 weeks\n\n4. RECOVERY PHASE:\n• GFR and urine output normalize\n• May take up to 12 months\n• Some patients have permanent damage\n\nWHY OTHER ANSWERS ARE WRONG:\n• Initiation = Very early phase before oliguria develops\n• Diuretic = HIGH urine output (opposite of this patient)\n• Recovery = Normal or near-normal output\n\nOLIGURIA MANAGEMENT:\n• Fluid restriction\n• Monitor electrolytes (especially K+)\n• Dialysis if indicated\n• Avoid nephrotoxic drugs\n• Daily weights\n• Strict I&O",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with anemia has hemoglobin of 7.0 g/dL. Which assessment finding does the nurse expect?",
            answer: "Fatigue and pallor",
            wrongAnswers: ["Ruddy complexion", "Increased energy", "Bradycardia"],
            rationale: "CORRECT: Low Hgb = decreased oxygen-carrying capacity = tissue hypoxia = FATIGUE. Pallor from decreased red blood cells in circulation.\n\nNORMAL HEMOGLOBIN:\n• Males: 14-18 g/dL\n• Females: 12-16 g/dL\n• Hgb 7.0 = SEVERE anemia\n\nANEMIA SYMPTOMS:\n• Fatigue, weakness (most common)\n• Pallor (skin, mucous membranes, conjunctivae, nail beds)\n• Tachycardia (heart compensates for low O2)\n• Dyspnea on exertion\n• Dizziness\n• Headache\n• Cold intolerance\n\nCOMPENSATORY MECHANISMS:\n• Increased heart rate (deliver more blood)\n• Increased respiratory rate\n• Shift of oxyhemoglobin curve\n\nWHY OTHER ANSWERS ARE WRONG:\n• Ruddy complexion = Seen in polycythemia (too many RBCs)\n• Increased energy = Opposite - fatigue is hallmark\n• Bradycardia = Would expect TACHYCARDIA as compensation\n\nANEMIA TYPES:\nMICROCYTIC (small RBCs):\n• Iron deficiency (most common)\n• Thalassemia\n\nNORMOCYTIC (normal size):\n• Acute blood loss\n• Chronic disease\n\nMACROCYTIC (large RBCs):\n• B12 deficiency\n• Folate deficiency\n\nTREATMENT DEPENDS ON CAUSE:\n• Iron deficiency: iron supplements\n• B12 deficiency: B12 injections\n• Severe anemia: blood transfusion\n• Chronic kidney disease: erythropoietin",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with a urinary catheter develops cloudy, foul-smelling urine with sediment. What should the nurse suspect?",
            answer: "Urinary tract infection",
            wrongAnswers: ["Normal catheter drainage", "Dehydration", "Kidney stones"],
            rationale: "CORRECT: Cloudy, foul-smelling urine with sediment = classic UTI signs. Catheters are a major risk factor for UTI.\n\nUTI SIGNS AND SYMPTOMS:\n• Cloudy urine\n• Foul odor\n• Sediment\n• Hematuria (blood)\n• Fever\n• Suprapubic pain/tenderness\n• Confusion in elderly (may be only sign)\n\nCATHETER-ASSOCIATED UTI (CAUTI):\n• Most common healthcare-associated infection\n• Risk increases with duration of catheterization\n• Remove catheter ASAP when no longer needed\n\nWHY OTHER ANSWERS ARE WRONG:\n• Normal drainage = Normal urine is clear, amber, no strong odor\n• Dehydration = Would cause concentrated (darker) urine, not cloudy/foul\n• Kidney stones = Would cause hematuria, pain, but not typically foul smell\n\nCAUTI PREVENTION:\n• Insert only when necessary\n• Remove as soon as possible\n• Maintain closed drainage system\n• Keep bag below bladder level\n• Secure catheter to prevent pulling\n• Meatal care (soap and water)\n• Hand hygiene before/after handling\n• Empty bag when 2/3 full\n\nNURSING INTERVENTIONS:\n• Obtain urine culture before antibiotics\n• Administer antibiotics as ordered\n• Encourage fluids (if not contraindicated)\n• Monitor temperature\n• Assess for sepsis signs",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with suspected stroke arrives at the ED. What is the MOST critical information to obtain?",
            answer: "Time of symptom onset",
            wrongAnswers: ["Patients medical history", "List of current medications", "Patients age"],
            rationale: "CORRECT: TIME IS BRAIN! tPA (alteplase) can only be given within 4.5 hours of symptom onset. Need exact time to determine eligibility for treatment.\n\nWHY TIME IS CRITICAL:\n• tPA (tissue plasminogen activator) dissolves clots\n• Window: within 4.5 hours of symptom onset\n• Earlier treatment = better outcomes\n• \"Last known well\" time is used if onset unknown\n\nISCHEMIC STROKE TREATMENT TIMELINE:\n• Door-to-physician: 10 minutes\n• Door-to-CT: 25 minutes\n• Door-to-CT interpretation: 45 minutes\n• Door-to-needle (tPA): 60 minutes\n\nWHY OTHER ANSWERS ARE WRONG:\n• Medical history = Important but doesnt determine immediate treatment eligibility\n• Medications = Important for tPA contraindications but TIME is priority\n• Age = Not as critical as symptom onset time\n\ntPA CONTRAINDICATIONS:\n• >4.5 hours from symptom onset\n• Recent surgery or trauma\n• Active bleeding\n• Bleeding disorders\n• Recent stroke\n• Uncontrolled hypertension\n• INR >1.7\n\nSTROKE TYPES:\nISCHEMIC (87%):\n• Blocked blood vessel\n• Treatment: tPA, thrombectomy\n• Time-sensitive\n\nHEMORRHAGIC (13%):\n• Bleeding in brain\n• NO tPA (would worsen bleeding)\n• Treatment: control BP, surgery if needed",
            contentCategory: .medSurg,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient is scheduled for a colonoscopy. Which finding indicates the bowel prep was effective?",
            answer: "Clear, yellow liquid stool",
            wrongAnswers: ["Brown formed stool", "Small amount of solid stool", "No stool output in 6 hours"],
            rationale: "CORRECT: Clear yellow liquid = bowel is clean. Visualization requires empty colon. Any solid material or brown color means inadequate prep.\n\nCOLONOSCOPY BOWEL PREP:\n• Clear liquid diet 1-2 days before\n• Bowel prep solution (polyethylene glycol/GoLYTELY, etc.)\n• Large volume of fluid to flush colon\n• Expected: Multiple watery stools becoming clear\n\nADEQUATE PREP INDICATORS:\n• Watery stool\n• Clear to light yellow color\n• No solid particles\n• Able to see through fluid\n\nWHY OTHER ANSWERS ARE WRONG:\n• Brown formed stool = Inadequate prep; needs more prep solution\n• Small solid stool = Inadequate; procedure may be cancelled/rescheduled\n• No output = May indicate obstruction or non-compliance\n\nPATIENT TEACHING:\n• Begin clear liquid diet as instructed\n• Drink all of prep solution (even if difficult)\n• Stay near bathroom\n• Use barrier cream for skin protection\n• Stay hydrated\n• Stop certain medications as instructed (anticoagulants, iron)\n\nCOLONOSCOPY POST-PROCEDURE:\n• May have cramping and gas (air introduced during procedure)\n• Monitor for bleeding (small amount normal, large amount report)\n• Watch for signs of perforation (severe pain, fever, distention)\n• Can resume regular diet after recovery\n• Sedation - no driving for 24 hours",
            contentCategory: .medSurg,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient has a tracheostomy. What is the nurses priority intervention?",
            answer: "Maintain a patent airway",
            wrongAnswers: ["Document tube size", "Assess nutritional status", "Teach patient to write notes"],
            rationale: "CORRECT: Airway is ALWAYS the priority with tracheostomy. A blocked trach = no airway = death. Keep suction equipment at bedside.\n\nTRACHEOSTOMY PRIORITIES (ABCs):\n• Airway patency is #1\n• Keep suction equipment at bedside (always!)\n• Keep spare trach tube at bedside (same size AND one size smaller)\n• Keep obturator at bedside\n\nWHY OTHER ANSWERS ARE WRONG:\n• Document tube size = Important but not priority over airway\n• Nutritional status = Important long-term but not immediate priority\n• Writing notes = Communication is important but airway first\n\nTRACHEOSTOMY CARE:\n• Suction as needed (not routinely - irritates mucosa)\n• Clean inner cannula q8h or as needed\n• Change trach ties when soiled (two-person technique)\n• Keep stoma clean and dry\n• Humidified oxygen (trach bypasses natural humidification)\n\nTRACH SUCTIONING:\n• Preoxygenate with 100% O2\n• Sterile technique\n• Insert catheter WITHOUT suction (to carina, then pull back 1 cm)\n• Apply suction only while withdrawing\n• Maximum 10 seconds per pass\n• Allow recovery between passes\n\nEMERGENCY EQUIPMENT AT BEDSIDE:\n• Suction catheter and suction source\n• Spare tracheostomy tubes (same size + one smaller)\n• Obturator\n• Manual resuscitation bag\n• Oxygen source",
            contentCategory: .medSurg,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient post-lumbar puncture reports a severe headache. What position should the nurse place the patient in?",
            answer: "Flat supine position",
            wrongAnswers: ["Fowlers position", "Side-lying with HOB elevated", "Prone with head turned"],
            rationale: "CORRECT: Post-LP headache is from CSF leakage. Lying FLAT reduces pressure on puncture site and helps seal. Also increase fluids.\n\nPOST-LUMBAR PUNCTURE HEADACHE:\n• Occurs in 10-30% of patients\n• Due to CSF leakage through dural puncture site\n• Worse when upright (gravity pulls CSF down)\n• Better when lying flat\n\nSYMPTOMS:\n• Severe headache (positional)\n• Worsens sitting/standing\n• Improves lying down\n• May have nausea, dizziness, neck stiffness\n\nWHY OTHER ANSWERS ARE WRONG:\n• Fowlers = Head elevated increases CSF pressure at site\n• Side-lying with HOB elevated = Still elevated, still problematic\n• Prone with head turned = Not necessary; supine is sufficient\n\nNURSING INTERVENTIONS:\n• Flat position for 4-6 hours (or longer if headache)\n• Increase fluid intake (oral and IV)\n• Caffeine may help (causes vasoconstriction)\n• Pain medication as ordered\n• Avoid straining (increases CSF pressure)\n\nBLOOD PATCH:\n• For severe or persistent headaches\n• Anesthesiologist injects patients blood at puncture site\n• Blood clots and seals the leak\n• Usually provides relief within hours\n\nLUMBAR PUNCTURE NURSING CARE:\n• Pre: empty bladder, explain procedure\n• During: fetal position or sitting bent over\n• Post: flat position, monitor neuro status\n• Check puncture site for bleeding/hematoma\n• Monitor for signs of infection",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with GERD asks how to reduce symptoms. Which instruction should the nurse provide?",
            answer: "Avoid lying down for 2-3 hours after eating",
            wrongAnswers: ["Eat large meals to reduce frequency of eating", "Lie down after meals to aid digestion", "Drink plenty of fluids with meals"],
            rationale: "CORRECT: Staying upright allows gravity to keep stomach contents down. Lying down promotes reflux of acid into esophagus.\n\nGERD LIFESTYLE MODIFICATIONS:\n• Remain upright 2-3 hours after eating\n• Elevate head of bed 6-8 inches (blocks, not pillows)\n• Eat small, frequent meals\n• Avoid tight clothing\n• Lose weight if overweight\n• Avoid eating before bedtime\n\nWHY OTHER ANSWERS ARE WRONG:\n• Large meals = Increase gastric distention, worsen reflux\n• Lie down after meals = Promotes reflux; gravity works against you\n• Fluids with meals = Increases gastric volume; drink between meals instead\n\nFOODS TO AVOID:\n• Fatty/fried foods (slow emptying)\n• Citrus, tomatoes (acidic)\n• Chocolate, peppermint (relax LES)\n• Caffeine, alcohol\n• Carbonated beverages\n• Spicy foods\n\nMEDICATIONS FOR GERD:\n• Antacids (quick relief)\n• H2 blockers (famotidine) - reduce acid production\n• PPIs (omeprazole, pantoprazole) - most effective\n• Prokinetic agents (metoclopramide) - speed emptying\n\nWHEN TO SEEK MEDICAL ATTENTION:\n• Difficulty swallowing\n• Painful swallowing\n• Unintentional weight loss\n• GI bleeding\n• Symptoms not controlled with OTC medications\n\nCOMPLICATIONS OF UNTREATED GERD:\n• Esophagitis\n• Barretts esophagus (precancerous)\n• Strictures\n• Esophageal cancer",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with schizophrenia reports hearing voices telling them to hurt themselves. What type of hallucination is this?",
            answer: "Command auditory hallucination",
            wrongAnswers: ["Visual hallucination", "Tactile hallucination", "Olfactory hallucination"],
            rationale: "CORRECT: Command hallucinations are auditory hallucinations that direct the person to take specific action, often harmful. This is a PSYCHIATRIC EMERGENCY.\n\nTYPES OF HALLUCINATIONS:\n| Type | Sense | Examples | Common in |\n|------|-------|----------|-----------|\n| Auditory | Hearing | Voices, commands | Schizophrenia (#1 type) |\n| Visual | Seeing | People, objects | Delirium, substance use |\n| Tactile | Touch | Bugs crawling | Alcohol withdrawal, cocaine |\n| Olfactory | Smell | Burning, foul odors | Seizures, brain tumors |\n| Gustatory | Taste | Strange tastes | Seizures, brain lesions |\n\nWHY OTHER ANSWERS ARE WRONG:\n• Visual = Would be seeing things, not hearing\n• Tactile = Would involve feeling sensations on body\n• Olfactory = Would involve smelling something not there\n\nCOMMAND HALLUCINATION NURSING CARE:\n1. ASSESS content: What do the voices say? Do they tell you to hurt yourself or others?\n2. SAFETY: Implement precautions if commands are dangerous\n3. DON'T argue about reality but don't validate hallucination either\n4. DISTRACT with reality-based activities\n5. MEDICATION: Ensure antipsychotic compliance\n\nTHERAPEUTIC RESPONSE: \"I understand the voices feel real to you. I don't hear them, but I want to help you feel safe. What are the voices saying?\"",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which defense mechanism is demonstrated when a patient diagnosed with cancer says \"The lab must have made a mistake\"?",
            answer: "Denial",
            wrongAnswers: ["Projection", "Rationalization", "Displacement"],
            rationale: "CORRECT: Denial is refusing to acknowledge reality as a way to cope with overwhelming, threatening information.\n\nDENIAL:\n• Definition: Unconscious refusal to accept reality\n• Purpose: Protects ego from overwhelming threat\n• Example: \"There must be some mistake with my diagnosis.\"\n• Normal initially; becomes problematic if prevents treatment\n\nWHY OTHER ANSWERS ARE WRONG:\n• Projection = Attributing your unacceptable feelings to someone else\n  Example: \"The nurse is angry at me\" (when you're actually angry)\n• Rationalization = Making excuses to justify behavior\n  Example: \"I smoked because I was stressed, not because I'm addicted\"\n• Displacement = Redirecting feelings to a safer target\n  Example: Yelling at spouse after bad day at work\n\nCOMMON DEFENSE MECHANISMS:\n| Mechanism | Definition | Example |\n|-----------|------------|---------|\n| Denial | Refusing reality | \"This can't be happening\" |\n| Repression | Unconsciously forgetting | No memory of trauma |\n| Suppression | Consciously pushing away | \"I'll think about it later\" |\n| Projection | Blaming others for own feelings | \"She hates me\" |\n| Displacement | Shifting feelings to safer target | Kicking dog after bad day |\n| Rationalization | Making excuses | \"I deserved that drink\" |\n| Sublimation | Channeling into acceptable outlet | Exercising when angry |\n| Regression | Returning to earlier behavior | Adult throwing tantrum |\n\nNURSING RESPONSE TO DENIAL: Initially allow (protective), but gently reality-orient over time. Offer support and information when ready.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which therapeutic communication technique involves restating the patient's message?",
            answer: "Reflection",
            wrongAnswers: ["Clarification", "Confrontation", "Summarizing"],
            rationale: "CORRECT: Reflection mirrors back the patient's feelings or content, showing understanding and encouraging further expression.\n\nREFLECTION:\n• Mirrors content or feelings back to patient\n• Shows you're listening and understanding\n• Encourages elaboration\n• Example: Patient: \"I'm so frustrated with my treatment.\"\n  Nurse: \"You're feeling frustrated with your treatment.\"\n\nWHY OTHER ANSWERS ARE WRONG:\n• Clarification = Asking for more information to understand better\n  Example: \"What do you mean when you say frustrated?\"\n• Confrontation = Pointing out discrepancies (use carefully, therapeutically)\n  Example: \"You say you're fine, but you look upset.\"\n• Summarizing = Condensing main points at end of interaction\n  Example: \"So today we discussed your medication concerns and family visit.\"\n\nTHERAPEUTIC COMMUNICATION TECHNIQUES:\n| Technique | Definition | Example |\n|-----------|------------|---------|\n| Open-ended questions | Encourage elaboration | \"How are you feeling?\" |\n| Reflection | Mirror feelings | \"You seem sad.\" |\n| Clarification | Seek understanding | \"Can you explain more?\" |\n| Silence | Allow processing | Simply being present |\n| Validation | Acknowledge feelings | \"It's understandable to feel that way.\" |\n| Focusing | Direct to important topic | \"Let's talk more about...\" |\n| Summarizing | Review main points | \"To summarize...\" |\n\nNON-THERAPEUTIC TECHNIQUES (AVOID):\n• Giving advice\n• False reassurance\n• Asking \"why\"\n• Changing the subject\n• Judging/moralizing\n• Disagreeing/arguing",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with alcohol use disorder is admitted. When should the nurse expect withdrawal symptoms to begin?",
            answer: "6-24 hours after last drink",
            wrongAnswers: ["Immediately upon admission", "3-5 days after last drink", "1-2 weeks after last drink"],
            rationale: "CORRECT: Alcohol withdrawal follows a predictable timeline. Symptoms begin 6-24 hours after last drink.\n\nALCOHOL WITHDRAWAL TIMELINE:\n| Time | Symptoms |\n|------|----------|\n| 6-24 hrs | Tremors, anxiety, insomnia, tachycardia, diaphoresis, N/V |\n| 24-48 hrs | Hallucinations (usually visual - \"seeing bugs\") |\n| 48-72 hrs | SEIZURES (grand mal) - highest risk period |\n| 3-5 days | DELIRIUM TREMENS (DTs) - confused, agitated, fever, severe autonomic instability |\n\nWHY OTHER ANSWERS ARE WRONG:\n• Immediately = Too early; need time for blood alcohol to drop\n• 3-5 days = This is when DTs occur, not initial symptoms\n• 1-2 weeks = Withdrawal is acute; would be resolved or fatal by then\n\nDELIRIUM TREMENS (DTs):\n• Most serious complication\n• 5-15% mortality if untreated\n• Symptoms: Severe confusion, hallucinations, fever, hypertension, tachycardia, diaphoresis, tremors\n\nCIWA-Ar SCALE: Clinical Institute Withdrawal Assessment - used to monitor severity and guide benzodiazepine dosing (score >8-10 typically requires treatment)\n\nTREATMENT:\n• Benzodiazepines (lorazepam, chlordiazepoxide) - prevent seizures and DTs\n• Thiamine (B1) - prevent Wernicke encephalopathy\n• Fluids, electrolytes, nutrition\n• Multivitamins, folate",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient expresses suicidal thoughts. What is the nurse's PRIORITY assessment?",
            answer: "Ask directly if the patient has a plan and access to means",
            wrongAnswers: ["Avoid discussing suicide to prevent giving ideas", "Immediately place in physical restraints", "Call family members before talking to patient"],
            rationale: "CORRECT: DIRECT QUESTIONING is essential. Research proves asking about suicide does NOT increase risk - it provides opportunity for intervention and shows the nurse cares.\n\nSUICIDE ASSESSMENT - Ask Directly:\n• Ideation: \"Are you thinking about killing yourself?\"\n• Plan: \"Do you have a plan for how you would do it?\"\n• Means: \"Do you have access to [method mentioned]?\"\n• Timeline: \"When are you thinking of doing this?\"\n• Protective factors: \"What has stopped you from acting on these thoughts?\"\n\nSUICIDE RISK LEVELS:\n• LOW: Vague ideation, no plan, future orientation, good support\n• MODERATE: Frequent thoughts, vague plan, some risk factors\n• HIGH: Specific plan, available means, recent attempt, giving away possessions, hopelessness\n\nWHY OTHER ANSWERS ARE WRONG:\n• Avoid discussing = MYTH! Silence increases isolation; asking reduces risk\n• Restraints = Excessive and inappropriate initial response; may traumatize patient\n• Call family first = Breaches confidentiality; assess patient first, then involve family appropriately\n\nNURSING INTERVENTIONS FOR SUICIDAL PATIENT:\n1. Ensure safety (remove means, 1:1 observation)\n2. Therapeutic communication (nonjudgmental)\n3. Establish safety plan/no-harm contract\n4. Notify provider for psychiatric evaluation\n5. Document thoroughly",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A toddler with acute otitis media is prescribed amoxicillin. What should the nurse teach the parents?",
            answer: "Complete the full course of antibiotics even if symptoms improve",
            wrongAnswers: ["Stop when ear pain resolves", "Give only when fever is present", "Skip doses if child seems better"],
            rationale: "CORRECT: Incomplete antibiotic courses lead to resistant bacteria and recurrent infection. Complete full 10-day course regardless of symptom improvement.\n\nANTIBIOTIC COMPLIANCE TEACHING:\n\nWHY COMPLETE THE COURSE:\n• Bacteria not fully eliminated if stopped early\n• Surviving bacteria may become resistant\n• Infection can recur (often worse)\n• Full course needed to eradicate infection\n\nOTITIS MEDIA TREATMENT:\n• First-line: Amoxicillin 80-90 mg/kg/day\n• Duration: 10 days (under age 2)\n• Duration: 5-7 days (over age 2, mild)\n• If allergic: azithromycin or cephalosporin\n\nWHY OTHER ANSWERS ARE WRONG:\n• Stop when pain resolves = Symptoms improve before bacteria eliminated\n• Give only with fever = Need consistent dosing, not PRN\n• Skip doses = Inconsistent levels allow bacterial survival\n\nADMINISTRATION TIPS:\n• Give at same times daily\n• Complete entire prescription\n• Store properly (refrigerate if liquid)\n• Use measuring device (not household spoons)\n• Can give with food if GI upset\n\nSIGNS OF COMPLICATIONS (Report to provider):\n• Fever persisting >48-72 hours on antibiotics\n• Worsening pain\n• Swelling behind ear\n• Drainage from ear\n• Hearing changes\n• Balance problems\n\nPREVENTION:\n• Breastfeeding (protective)\n• Avoid bottle propping\n• Avoid secondhand smoke\n• Pneumococcal vaccine\n• Influenza vaccine",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A child with cystic fibrosis is prescribed pancreatic enzymes. When should these be given?",
            answer: "With meals and snacks",
            wrongAnswers: ["Only at bedtime", "2 hours before meals", "Only when experiencing symptoms"],
            rationale: "CORRECT: Pancreatic enzymes MUST be taken with ALL food to digest it. Without enzymes, fats and proteins pass through undigested.\n\nCYSTIC FIBROSIS PATHOPHYSIOLOGY:\n• Defective CFTR gene → thick, sticky mucus\n• Affects: lungs, pancreas, liver, intestines, sweat glands\n• Pancreatic insufficiency in 85-90% of CF patients\n\nPANCREATIC ENZYME (PANCRELIPASE) ADMINISTRATION:\n• Take with EVERY meal and snack\n• Swallow capsules whole or sprinkle on acidic food (applesauce)\n• Never crush or chew beads\n• Don't mix with hot food or milk (destroys enzymes)\n• Dose adjusted based on fat intake and stool character\n\nWHY OTHER ANSWERS ARE WRONG:\n• Bedtime only = Food needs to be present for digestion\n• 2 hours before = Enzymes only work when food is present\n• Only with symptoms = Too late; need consistent use with all food\n\nSIGNS OF INADEQUATE ENZYME REPLACEMENT:\n• Steatorrhea (fatty, foul-smelling, floating stools)\n• Abdominal pain, bloating\n• Poor weight gain\n• Increased flatus\n\nOTHER CF MANAGEMENT:\n• Airway clearance techniques (chest physiotherapy)\n• Bronchodilators, mucolytics (dornase alfa)\n• CFTR modulators (ivacaftor, lumacaftor) - for specific mutations\n• High-calorie, high-fat diet\n• Fat-soluble vitamin supplements (A, D, E, K)\n• Salt replacement (especially in hot weather)",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "At what age should an infant double their birth weight?",
            answer: "4-6 months",
            wrongAnswers: ["1-2 months", "8-10 months", "12 months"],
            rationale: "CORRECT: Growth milestones for weight are: double by 4-6 months, triple by 12 months.\n\nINFANT GROWTH MILESTONES:\n| Time | Weight Milestone |\n|------|------------------|\n| 4-6 months | DOUBLE birth weight |\n| 12 months | TRIPLE birth weight |\n| 2 years | QUADRUPLE birth weight |\n\nEXPECTED WEIGHT GAIN:\n• First 6 months: ~1 oz (30g) per day, 1.5 lb per month\n• 6-12 months: ~0.5 oz (15g) per day, 1 lb per month\n\nWHY OTHER ANSWERS ARE WRONG:\n• 1-2 months = Too early; infants may lose up to 10% birth weight in first week\n• 8-10 months = Too late; suggests possible failure to thrive\n• 12 months = Time to TRIPLE, not double\n\nOTHER IMPORTANT MILESTONES:\n• Birth: Average 7.5 lbs (3.4 kg)\n• Length doubles by 4 years\n• Head circumference: Rapid growth first 2 years (brain growth)\n\nFAILURE TO THRIVE (FTT): Weight <5th percentile or weight drops 2 major percentiles. Warrants investigation for feeding issues, underlying illness, or psychosocial factors.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What finding in a newborn requires IMMEDIATE intervention?",
            answer: "Central cyanosis",
            wrongAnswers: ["Acrocyanosis of hands and feet", "Mottled skin", "Mild jaundice at 3 days"],
            rationale: "CORRECT: CENTRAL cyanosis (blue lips, tongue, trunk) = inadequate oxygenation = EMERGENCY. Requires immediate assessment and intervention.\n\nCENTRAL VS PERIPHERAL CYANOSIS:\n\nCENTRAL CYANOSIS (Emergency):\n• Blue lips, tongue, mucous membranes\n• Blue trunk/torso\n• Indicates systemic hypoxia\n• Requires immediate action\n\nPERIPHERAL CYANOSIS/ACROCYANOSIS (Normal in newborns):\n• Blue hands and feet only\n• Central areas PINK\n• Normal in first 24-48 hours\n• Due to immature circulation\n\nWHY OTHER ANSWERS ARE WRONG:\n• Acrocyanosis = Normal in newborns up to 48 hours\n• Mottled skin = Can be normal with cold or normal circulation changes\n• Mild jaundice day 3 = Physiologic jaundice peaks day 3-5; monitor but not emergency\n\nCAUSES OF CENTRAL CYANOSIS IN NEWBORNS:\n• Congenital heart defects\n• Respiratory distress syndrome\n• Pneumonia\n• Meconium aspiration\n• Persistent pulmonary hypertension\n• Airway obstruction\n\nIMMEDIATE ACTIONS:\n• Stimulate breathing if needed\n• Clear airway\n• Provide oxygen\n• Assess respiratory effort\n• Check heart rate\n• Call for help\n• Consider resuscitation\n\nAPGAR SCORING (Color component):\n0 = Blue/pale all over\n1 = Body pink, extremities blue (acrocyanosis)\n2 = Completely pink",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A child with suspected appendicitis has sudden relief of pain. What does this indicate?",
            answer: "Possible perforation of the appendix",
            wrongAnswers: ["The appendicitis has resolved", "Medication is working", "Normal variation in pain"],
            rationale: "CORRECT: SUDDEN PAIN RELIEF in appendicitis = PERFORATION. The stretched, inflamed appendix has ruptured, temporarily relieving pressure. Medical emergency!\n\nAPPENDICITIS PROGRESSION:\n\nCLASSIC PRESENTATION:\n• Periumbilical pain → localizes to RLQ (McBurney point)\n• Anorexia\n• Nausea/vomiting (after pain starts)\n• Low-grade fever\n• Rebound tenderness\n• Guarding\n\nPERFORATION SIGNS:\n• Sudden relief of pain (concerning!)\n• Followed by increasing generalized abdominal pain\n• Rigid abdomen\n• High fever\n• Signs of peritonitis\n• Tachycardia\n• Altered mental status\n\nWHY OTHER ANSWERS ARE WRONG:\n• Resolved = Appendicitis does not spontaneously resolve\n• Medication working = Pain relief this sudden is pathological\n• Normal variation = Sudden relief is ominous sign\n\nNURSING ACTIONS IF PERFORATION SUSPECTED:\n• NPO\n• IV fluids\n• Antibiotics\n• Prepare for emergency surgery\n• Monitor for sepsis\n• Pain management\n\nPEDIATRIC CONSIDERATIONS:\n• Children often have atypical presentation\n• May not localize pain to RLQ\n• Perforation rate higher in young children (cant communicate symptoms)\n• Higher index of suspicion needed\n\nASSESSMENT TECHNIQUES:\n• Rebound tenderness (Blumberg sign)\n• Rovsing sign (RLQ pain with LLQ palpation)\n• Psoas sign (pain with hip extension)\n• Obturator sign (pain with internal rotation of hip)",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient is prescribed warfarin. Which lab value should the nurse monitor?",
            answer: "INR (International Normalized Ratio)",
            wrongAnswers: ["aPTT (activated Partial Thromboplastin Time)", "Platelet count only", "Hemoglobin and hematocrit only"],
            rationale: "CORRECT: Warfarin affects vitamin K-dependent clotting factors (II, VII, IX, X). INR measures this pathway.\n\nTHERAPEUTIC INR RANGES:\n• Standard (DVT, PE, A-fib): 2.0-3.0\n• Mechanical heart valve: 2.5-3.5\n\nWHY OTHER ANSWERS ARE WRONG:\n• aPTT = Monitors HEPARIN, not warfarin (different pathway - intrinsic)\n• Platelet count only = Warfarin doesn't affect platelet count; it affects clotting factors\n• H&H only = Important for detecting bleeding but doesn't monitor anticoagulation level\n\nWARFARIN TEACHING POINTS:\n• Takes 3-5 days to reach therapeutic level (overlap with heparin initially)\n• Vitamin K is antidote (reverses effect)\n• Consistent vitamin K intake (don't suddenly change green leafy vegetable consumption)\n• Many drug interactions (check all new meds)\n• Avoid NSAIDs, aspirin (increase bleeding risk)\n\nMEMORY AID: \"War(farin) needs INR\" - also remember PT (prothrombin time) is part of INR.\n\nMNEMONIC for Warfarin factors: \"1972\" = factors 10, 9, 7, 2",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with rheumatoid arthritis asks when to take prescribed ibuprofen. What is the best instruction?",
            answer: "Take with food to reduce GI irritation",
            wrongAnswers: ["Take on an empty stomach for faster absorption", "Take at bedtime only", "Take only when pain is severe"],
            rationale: "CORRECT: NSAIDs like ibuprofen irritate GI mucosa. Taking with food or milk reduces this irritation and risk of ulcers.\n\nNSAID GI EFFECTS:\n• Inhibit prostaglandins (including protective ones in stomach)\n• Reduce mucus production\n• Decrease blood flow to stomach lining\n• Risk: gastritis, ulcers, GI bleeding\n\nWHY OTHER ANSWERS ARE WRONG:\n• Empty stomach = Increases GI irritation, despite faster absorption\n• Bedtime only = Should be taken regularly for RA inflammation\n• Only when severe = RA needs consistent anti-inflammatory treatment\n\nNSAID TEACHING:\n• Take with food, milk, or antacids\n• Take regularly as prescribed (not just PRN for RA)\n• Watch for signs of GI bleeding (black tarry stools, abdominal pain)\n• Avoid alcohol (increases GI risk)\n• Report unusual bleeding or bruising\n\nOTHER NSAID SIDE EFFECTS:\n• Renal impairment (avoid in kidney disease)\n• Cardiovascular risk (especially with long-term use)\n• Platelet inhibition (bleeding risk)\n• Hypersensitivity reactions\n• Fluid retention\n\nRHEUMATOID ARTHRITIS TREATMENT:\n• NSAIDs (symptom relief, not disease-modifying)\n• DMARDs (methotrexate - slows disease progression)\n• Biologics (TNF inhibitors, etc.)\n• Corticosteroids (flares)\n• Physical therapy\n• Joint protection\n\nRA CHARACTERISTICS:\n• Autoimmune, systemic\n• Morning stiffness >1 hour\n• Symmetric joint involvement\n• Small joints first (hands, wrists)\n• Eventually larger joints",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with hypertension is prescribed lisinopril. Which assessment finding requires the nurse to hold the medication?",
            answer: "Potassium level of 5.8 mEq/L",
            wrongAnswers: ["Blood pressure of 138/88 mmHg", "Sodium level of 140 mEq/L", "Heart rate of 72 bpm"],
            rationale: "CORRECT: Lisinopril is an ACE inhibitor. ACE inhibitors RETAIN potassium (block aldosterone). K+ of 5.8 is HYPERKALEMIA - hold the med!\n\nACE INHIBITOR FACTS (-pril drugs):\n• Block conversion of angiotensin I to angiotensin II\n• Cause vasodilation (lower BP)\n• Reduce aldosterone (retain K+, excrete Na+)\n• Cardioprotective and renoprotective\n• First-line for HTN with diabetes or HF\n\nWHY OTHER ANSWERS ARE WRONG:\n• BP 138/88 = Still elevated but not contraindication; med is needed\n• Na+ 140 = Normal (135-145 mEq/L)\n• HR 72 = Normal; ACE inhibitors dont significantly affect HR\n\nNORMAL POTASSIUM: 3.5-5.0 mEq/L\n• >5.0 = Hyperkalemia\n• >6.0 = Dangerous - cardiac arrhythmia risk\n• >6.5 = Medical emergency\n\nACE INHIBITOR SIDE EFFECTS:\n• DRY COUGH (most common - bradykinin accumulation)\n• Hyperkalemia\n• First-dose hypotension\n• Angioedema (rare but serious)\n\nTEACHING POINTS:\n• Avoid potassium supplements and K+-sparing diuretics\n• Avoid salt substitutes (contain KCl)\n• Report persistent dry cough (may switch to ARB)\n• Report swelling of lips/tongue (angioedema - stop immediately)",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with a new diagnosis of type 2 diabetes is prescribed metformin. Which side effect should the nurse teach the patient to expect?",
            answer: "GI upset including diarrhea",
            wrongAnswers: ["Significant weight gain", "Hypoglycemia when used alone", "Increased appetite"],
            rationale: "CORRECT: Metformin commonly causes GI side effects (nausea, diarrhea, abdominal discomfort). Usually improves with time. Take with food to reduce.\n\nMETFORMIN FACTS:\n• First-line oral medication for type 2 diabetes\n• Biguanide class\n• Decreases hepatic glucose production\n• Improves insulin sensitivity\n• Does NOT cause hypoglycemia when used alone\n\nWHY OTHER ANSWERS ARE WRONG:\n• Weight gain = Metformin is WEIGHT NEUTRAL or causes slight weight loss\n• Hypoglycemia alone = Does not stimulate insulin; wont cause hypo alone\n• Increased appetite = Opposite - may decrease appetite slightly\n\nMETFORMIN BENEFITS:\n• Weight neutral/slight loss\n• No hypoglycemia risk alone\n• Cardiovascular benefits\n• Inexpensive\n• Well-studied\n\nSIDE EFFECTS:\n• GI: nausea, diarrhea, metallic taste (most common)\n• B12 deficiency (long-term)\n• Lactic acidosis (rare but serious)\n\nLACTIC ACIDOSIS RISK:\n• Rare but can be fatal\n• Risk factors: renal impairment, contrast dye, hypoxia\n• Hold for 48 hours around contrast procedures\n\nCONTRAINDICATIONS:\n• Significant renal impairment (eGFR <30)\n• Active liver disease\n• Conditions causing hypoxia\n• Heavy alcohol use\n\nPATIENT TEACHING:\n• Take with meals (reduces GI effects)\n• GI effects usually temporary\n• Not holding before contrast procedures\n• Monitor B12 levels annually",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which antibiotic class should be avoided during pregnancy due to effects on fetal teeth and bones?",
            answer: "Tetracyclines",
            wrongAnswers: ["Penicillins", "Cephalosporins", "Macrolides"],
            rationale: "CORRECT: Tetracyclines cross placenta and deposit in developing teeth and bones, causing permanent tooth discoloration (yellow-brown) and potential bone growth issues.\n\nTETRACYCLINE EFFECTS ON FETUS:\n• Tooth enamel hypoplasia and discoloration\n• Bone growth inhibition\n• Risk highest in 2nd and 3rd trimesters\n• Also contraindicated in children <8 years (same reasons)\n\nTETRACYCLINE EXAMPLES:\n• Tetracycline\n• Doxycycline\n• Minocycline\n\nWHY OTHER ANSWERS ARE WRONG - These are generally SAFE in pregnancy:\n• Penicillins = Category B, safe, first-line for many infections\n• Cephalosporins = Category B, safe\n• Macrolides = Erythromycin and azithromycin are Category B\n\nANTIBIOTICS TO AVOID IN PREGNANCY:\n• Tetracyclines - teeth and bone effects\n• Fluoroquinolones - cartilage damage\n• Aminoglycosides - ototoxicity, nephrotoxicity\n• Sulfonamides (near term) - kernicterus risk\n• Metronidazole (first trimester) - potential teratogen\n\nSAFE ANTIBIOTICS IN PREGNANCY (generally):\n• Penicillins\n• Cephalosporins\n• Erythromycin (not estolate form)\n• Azithromycin\n• Nitrofurantoin (avoid near term)\n\nFDA PREGNANCY CATEGORIES (old system):\nA = Safe | B = Probably safe | C = Weigh risks | D = Evidence of risk | X = Contraindicated",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient receiving chemotherapy develops nausea and vomiting. When should antiemetics be most effective?",
            answer: "Before chemotherapy administration",
            wrongAnswers: ["After vomiting begins", "Only if nausea is severe", "24 hours after treatment"],
            rationale: "CORRECT: PROPHYLACTIC antiemetics work best. Give 30-60 minutes BEFORE chemo to prevent nausea/vomiting rather than treat after it starts.\n\nCHEMOTHERAPY-INDUCED NAUSEA AND VOMITING (CINV):\n• Very common (up to 80% of patients)\n• Major cause of treatment discontinuation\n• Prevention is more effective than treatment\n\nTIMING OF CINV:\nACUTE: Within 24 hours of treatment\nDELAYED: 24 hours to several days after\nANTICIPATORY: Before treatment (conditioned response)\nBREAKTHROUGH: Despite prophylaxis\n\nWHY OTHER ANSWERS ARE WRONG:\n• After vomiting = Once vomiting starts, harder to control\n• Only if severe = Should be prevented, not just treated\n• 24 hours after = Misses acute phase\n\nANTIEMETIC MEDICATIONS:\n\n5-HT3 ANTAGONISTS (ondansetron, granisetron):\n• Block serotonin receptors\n• Given before chemo\n• Very effective\n\nNK1 ANTAGONISTS (aprepitant):\n• For highly emetogenic chemo\n• Given with steroids and 5-HT3\n\nCORTICOSTEROIDS (dexamethasone):\n• Enhance other antiemetics\n• Reduce inflammation\n\nBENZODIAZEPINES (lorazepam):\n• Help with anticipatory nausea\n• Reduce anxiety\n\nNURSING TEACHING:\n• Take antiemetics as prescribed (even if not nauseous)\n• Small, frequent meals\n• Avoid strong odors\n• Stay hydrated\n• Rest after treatment\n• Ginger may help some patients",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient has an order for albuterol and ipratropium nebulizer treatments. Which medication should be administered first?",
            answer: "Albuterol first, then ipratropium",
            wrongAnswers: ["Ipratropium first, then albuterol", "Both medications mixed together", "Either order is acceptable"],
            rationale: "CORRECT: Give short-acting BETA-AGONIST (albuterol) FIRST. It opens airways fast, allowing ipratropium to reach deeper into lungs.\n\nBRONCHODILATOR ORDER:\n1. Short-acting beta-agonist (albuterol) - works in 5 minutes\n2. Anticholinergic (ipratropium) - works in 15-20 minutes\n3. Corticosteroid inhaler (if prescribed) - last\n\nWHY ALBUTEROL FIRST:\n• Fastest onset (5 minutes)\n• Opens airways quickly\n• Allows subsequent medications better distribution\n• \"Open the door before you walk through\"\n\nWHY OTHER ANSWERS ARE WRONG:\n• Ipratropium first = Slower onset, less effective delivery\n• Mixed together = Can be done with DuoNeb, but if separate, order matters\n• Either order = Not optimal; albuterol first is preferred\n\nMEDICATION CLASSES:\nSABA (Short-Acting Beta-Agonist):\n• Albuterol (Proventil, Ventolin)\n• Rescue medication\n• Works quickly, lasts 4-6 hours\n\nSAMA (Short-Acting Muscarinic Antagonist):\n• Ipratropium (Atrovent)\n• Blocks acetylcholine\n• Slower onset but longer duration\n\nINHALER TECHNIQUE TEACHING:\n• Shake well (MDI)\n• Exhale completely\n• Inhale slowly and deeply\n• Hold breath 10 seconds\n• Wait 1 minute between puffs\n• Rinse mouth after corticosteroids",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A nurse is teaching a client about preventing fungal infections. Which of the following instructions should the nurse include?",
            answer: "Maintain good personal hygiene, including keeping skin clean and dry.",
            wrongAnswers: ["Activate the rapid response team if the patient's condition deteriorates", "Ensure the patient's identification band is verified before any procedure", "Use two patient identifiers before administering medications or treatments"],
            rationale: "Maintaining good personal hygiene, including keeping the skin clean and dry, is essential for preventing fungal infections. Fungi thrive in warm, moist environments, so minimizing moisture and practicing good hygiene can reduce the risk of infection. While a balanced diet and avoiding crowds are generally good health practices, they are not specifically related to preventing fungal infections. Sharing personal items increases the risk of spreading infections.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient is receiving PCA morphine. Which assessment indicates potential oversedation?",
            answer: "Respiratory rate of 8 and difficult to arouse",
            wrongAnswers: ["Pain rating of 3/10", "Drowsy but easily arousable", "Requesting increased PCA dose"],
            rationale: "CORRECT: RR <10 and decreased arousability are DANGER SIGNS indicating opioid overdose. Sedation precedes respiratory depression.\n\nPASERO OPIOID-INDUCED SEDATION SCALE:\nS = Sleep, easy to arouse - ACCEPTABLE\n1 = Awake and alert - ACCEPTABLE\n2 = Slightly drowsy, easily aroused - ACCEPTABLE\n3 = Frequently drowsy, arousable, drifts off - UNACCEPTABLE (hold opioid, monitor)\n4 = Somnolent, minimal response - UNACCEPTABLE (stop opioid, stimulate, naloxone)\n\nWHY OTHER ANSWERS ARE WRONG:\n• Pain 3/10 = Acceptable pain level; PCA is working\n• Drowsy but arousable = Normal with opioids; easily aroused is key\n• Requesting increase = May indicate inadequate pain control; requires assessment\n\nIMMEDIATE INTERVENTIONS FOR OVERSEDATION:\n1. Stop PCA\n2. Stimulate patient (call name, sternal rub)\n3. Maintain airway\n4. Apply oxygen\n5. Administer naloxone as ordered\n6. Stay with patient\n7. Notify provider\n\nPCA SAFETY:\n• Only patient should push button (no family dosing)\n• Lockout interval prevents overdose\n• Continuous monitoring (especially high-risk patients)\n• Assess sedation level before pain level\n\nNALOXONE (NARCAN):\n• Opioid antagonist\n• May need repeated doses (short half-life)\n• Can precipitate withdrawal in dependent patients\n• Titrate to respiratory rate, not consciousness",
            contentCategory: .safety,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient is scheduled for a lumbar MRI to investigate suspected Tarlov cysts. What is the priority nursing intervention following the procedure?",
            answer: "Monitor the puncture site for bleeding or CSF leakage.",
            wrongAnswers: ["Educate the patient on the proper use of the nurse call system", "Implement contact isolation precautions for the patient immediately", "Place the patient on continuous fall precaution monitoring"],
            rationale: "Following a lumbar puncture, whether for MRI contrast injection or diagnostic sampling, the priority is to monitor for complications such as bleeding, CSF leakage, or infection at the puncture site. This ensures early detection and management of potential adverse events. While assessing pain, encouraging fluids, and reviewing the MRI results are important, they are secondary to ensuring immediate post-procedure safety.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
    ]


    // PREMIUM CARDS (450 more) - Available to subscribers
    static let premiumCards: [Flashcard] = [
        // Additional Med-Surg (60 cards)
        Flashcard(
            question: "A patient with acute pancreatitis is NPO. What is the PRIMARY reason?",
            answer: "To rest the pancreas by reducing stimulation of pancreatic enzyme secretion",
            wrongAnswers: ["To prepare for emergency surgery", "To prevent aspiration", "To reduce caloric intake"],
            rationale: "Eating stimulates pancreatic enzyme secretion, worsening inflammation. NPO status allows the pancreas to rest and heal. Nutrition is provided via TPN or jejunal feeding if prolonged NPO is needed.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIORITY assessment for a patient receiving a blood transfusion?",
            answer: "Monitor for signs of transfusion reaction in the first 15-30 minutes",
            wrongAnswers: ["Check blood glucose levels", "Assess pain level", "Measure urine output hourly"],
            rationale: "Most severe transfusion reactions (hemolytic, anaphylactic) occur within the first 15-30 minutes. Stay with patient, monitor vital signs every 5-15 minutes initially. Signs: fever, chills, back pain, hypotension, dyspnea.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient has a chest tube connected to water-seal drainage. Which finding requires immediate action?",
            answer: "Continuous bubbling in the water-seal chamber",
            wrongAnswers: ["Tidaling in the water-seal chamber during respirations", "Drainage of 50 mL serous fluid in the past hour", "The drainage system positioned below the chest level"],
            rationale: "Continuous bubbling indicates an air leak - either in the patient (pneumothorax not resolved) or in the system (loose connection). Tidaling is normal and shows the system is patent. The system should be below chest level.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with Addison's disease is in crisis. Which intervention is PRIORITY?",
            answer: "Administer IV corticosteroids and fluids as ordered",
            wrongAnswers: ["Restrict sodium intake", "Administer insulin", "Place in Trendelenburg position"],
            rationale: "Addisonian crisis is life-threatening adrenal insufficiency. Treatment: IV hydrocortisone (replaces deficient cortisol), IV fluids (for hypotension/dehydration), correct electrolytes. These patients need MORE sodium, not restriction.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "Which patient is at HIGHEST risk for developing pressure injuries?",
            answer: "Elderly patient who is bedbound, incontinent, and has poor nutritional intake",
            wrongAnswers: ["Young athlete recovering from knee surgery", "Middle-aged patient admitted for observation", "Ambulatory patient with well-controlled diabetes"],
            rationale: "Pressure injury risk factors: immobility, moisture (incontinence), poor nutrition, advanced age, decreased sensation. Use Braden Scale to assess risk. Prevention includes repositioning every 2 hours, moisture management, nutrition optimization.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is diagnosed with SIADH. Which finding should the nurse expect?",
            answer: "Hyponatremia with concentrated urine",
            wrongAnswers: ["Hypernatremia with dilute urine", "Normal sodium with polyuria", "Hyperkalemia with oliguria"],
            rationale: "SIADH causes excess ADH secretion, leading to water retention and dilutional hyponatremia. Urine is concentrated (high specific gravity) despite low serum sodium. Treatment: fluid restriction, hypertonic saline for severe cases.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with myasthenia gravis develops respiratory distress. What should the nurse suspect?",
            answer: "Myasthenic or cholinergic crisis",
            wrongAnswers: ["Pulmonary embolism", "Asthma exacerbation", "Pneumonia"],
            rationale: "Both crises cause respiratory failure. Myasthenic crisis = undertreated disease; Cholinergic crisis = overmedication with anticholinesterase. Edrophonium (Tensilon) test differentiates: improvement = myasthenic crisis; worsening = cholinergic crisis.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST sign of increased intracranial pressure (ICP)?",
            answer: "Change in level of consciousness",
            wrongAnswers: ["Cushing's triad", "Pupil changes", "Projectile vomiting"],
            rationale: "LOC changes (confusion, lethargy, restlessness) are the earliest and most sensitive indicator of rising ICP. Cushing's triad (hypertension, bradycardia, irregular respirations) is a late sign indicating brainstem herniation.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient has a pH of 7.30, PaCO2 of 55, and HCO3 of 26. What is the acid-base imbalance?",
            answer: "Respiratory acidosis (uncompensated)",
            wrongAnswers: ["Metabolic acidosis", "Respiratory alkalosis", "Metabolic alkalosis"],
            rationale: "pH <7.35 = acidosis. High CO2 (>45) indicates respiratory cause. Normal HCO3 (22-26) shows no metabolic compensation yet. ROME: Respiratory Opposite (pH and CO2 move opposite in respiratory disorders), Metabolic Equal.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Select ALL interventions appropriate for a patient with acute kidney injury (AKI):",
            answer: "Monitor strict I&O, Weigh daily, Restrict potassium and sodium, Monitor for fluid overload",
            wrongAnswers: ["Encourage high-protein diet"],
            rationale: "AKI requires careful fluid and electrolyte management. Monitor I&O and daily weights to assess fluid status. Restrict K+ (kidneys can't excrete), restrict Na+ and fluid if oliguric. Moderate protein restriction reduces BUN. Watch for fluid overload and hyperkalemia.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .sata,
            isPremium: true
        ),

        // Additional Pharmacology (50 cards)
        Flashcard(
            question: "A patient on lithium has a level of 2.0 mEq/L. What should the nurse do FIRST?",
            answer: "Hold the lithium and notify the provider immediately",
            wrongAnswers: ["Administer the next scheduled dose", "Encourage increased fluid intake", "Document and continue to monitor"],
            rationale: "Therapeutic lithium level is 0.6-1.2 mEq/L. Level of 2.0 is toxic. Symptoms: severe GI distress, tremors, confusion, seizures. Hold medication, notify provider, prepare for possible dialysis. Ensure adequate hydration and sodium intake.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "Which instruction should the nurse give a patient taking MAOIs?",
            answer: "Avoid aged cheeses, cured meats, and wine to prevent hypertensive crisis",
            wrongAnswers: ["Take with grapefruit juice to enhance absorption", "Expect significant weight loss", "Discontinue abruptly when feeling better"],
            rationale: "MAOIs prevent breakdown of tyramine. Foods high in tyramine (aged cheese, wine, cured meats, soy sauce) cause severe hypertension (hypertensive crisis). Patient must follow dietary restrictions for 2 weeks after stopping MAOI.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the mechanism of action of beta-blockers (medications ending in '-olol')?",
            answer: "Block beta-adrenergic receptors, decreasing heart rate and blood pressure",
            wrongAnswers: ["Block calcium channels in the heart", "Inhibit ACE enzyme", "Directly dilate blood vessels"],
            rationale: "Beta-blockers block beta-1 receptors (heart) reducing HR, contractility, and BP. Beta-2 blockade can cause bronchoconstriction (caution in asthma/COPD). Never stop abruptly - taper to prevent rebound hypertension.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is starting amiodarone. Which baseline test is ESSENTIAL?",
            answer: "Thyroid function tests, liver function tests, and pulmonary function tests",
            wrongAnswers: ["Renal function only", "Complete blood count only", "Blood glucose levels"],
            rationale: "Amiodarone can cause thyroid dysfunction (hypo or hyper due to iodine content), hepatotoxicity, and pulmonary fibrosis. Baseline and periodic monitoring of thyroid, liver, and lungs is essential. Also causes corneal deposits and photosensitivity.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which medication requires monitoring for gray baby syndrome in neonates?",
            answer: "Chloramphenicol",
            wrongAnswers: ["Amoxicillin", "Cephalexin", "Azithromycin"],
            rationale: "Neonates lack glucuronyl transferase enzyme to metabolize chloramphenicol. Accumulation causes gray baby syndrome: abdominal distension, vomiting, gray skin color, cardiovascular collapse. Rarely used due to this risk and aplastic anemia.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the antidote for magnesium sulfate toxicity?",
            answer: "Calcium gluconate",
            wrongAnswers: ["Protamine sulfate", "Vitamin K", "Flumazenil"],
            rationale: "Magnesium sulfate (used for preeclampsia/eclampsia and preterm labor) toxicity causes respiratory depression, absent reflexes, cardiac arrest. Calcium gluconate reverses effects. Monitor: DTRs, respiratory rate (>12), urine output (>30 mL/hr).",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Select ALL medications that require renal dose adjustment:",
            answer: "Vancomycin, Metformin, Gabapentin, Enoxaparin",
            wrongAnswers: ["Acetaminophen"],
            rationale: "Renally cleared drugs accumulate in kidney dysfunction. Vancomycin requires trough monitoring. Metformin is contraindicated in severe renal impairment (lactic acidosis risk). Gabapentin and enoxaparin need dose reduction. Many antibiotics require adjustment.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .sata,
            isPremium: true
        ),
        Flashcard(
            question: "Which assessment is MOST important before administering potassium IV?",
            answer: "Verify adequate urine output (at least 30 mL/hr)",
            wrongAnswers: ["Check blood glucose level", "Assess pain level", "Verify last bowel movement"],
            rationale: "Potassium is excreted by the kidneys. Giving IV K+ to a patient with inadequate urine output can cause fatal hyperkalemia. Also: never give IV push, use infusion pump, max concentration and rate per protocol, cardiac monitor for high doses.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // Additional Pediatrics (45 cards)
        Flashcard(
            question: "A child with cystic fibrosis is prescribed pancreatic enzymes. When should these be given?",
            answer: "With meals and snacks",
            wrongAnswers: ["Only at bedtime", "2 hours before meals", "Only when experiencing symptoms"],
            rationale: "Pancreatic enzymes (pancrelipase) replace deficient digestive enzymes in CF. Must be taken with ALL meals and snacks to digest fats and proteins. Without enzymes, nutrients pass through undigested causing malnutrition and steatorrhea.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the classic triad of symptoms in a child with intussusception?",
            answer: "Colicky abdominal pain, vomiting, and currant jelly stools",
            wrongAnswers: ["Fever, rash, and joint pain", "Cough, wheeze, and fever", "Headache, vomiting, and stiff neck"],
            rationale: "Intussusception is telescoping of intestine, causing obstruction. Classic triad: intermittent severe colicky pain (child draws up knees), vomiting, and 'currant jelly' stools (blood and mucus). Medical emergency - requires air/barium enema or surgery.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which immunization is contraindicated for a child with severe egg allergy?",
            answer: "Influenza vaccine (injection form)",
            wrongAnswers: ["MMR vaccine", "Hepatitis B vaccine", "DTaP vaccine"],
            rationale: "Influenza vaccine is grown in eggs and may contain egg protein. Severe egg allergy requires observation after vaccination or use of egg-free alternatives. MMR is grown in chick embryo fibroblasts (not egg) and is safe for egg-allergic children.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child is diagnosed with acute glomerulonephritis. Which findings should the nurse expect?",
            answer: "Periorbital edema, dark-colored urine, and hypertension",
            wrongAnswers: ["Polyuria and weight loss", "Hypotension and pale urine", "Increased appetite and fever"],
            rationale: "Post-streptococcal glomerulonephritis (usually follows strep throat) causes: edema (especially periorbital in AM), tea/cola-colored urine (hematuria), hypertension, and oliguria. Treat underlying infection, manage symptoms, usually self-limiting.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIORITY nursing intervention for a child in sickle cell crisis?",
            answer: "Administer pain medication and IV fluids",
            wrongAnswers: ["Apply ice to affected areas", "Restrict fluids", "Encourage deep breathing exercises only"],
            rationale: "Vaso-occlusive crisis causes severe pain from sickling and vessel occlusion. PRIORITY: aggressive pain management (often opioids), hydration (helps prevent further sickling), oxygen if hypoxic. Heat (not ice) may help. Avoid cold and dehydration.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),

        // Additional Maternity (45 cards)
        Flashcard(
            question: "A pregnant patient at 28 weeks has Rh-negative blood. When should RhoGAM be administered?",
            answer: "At 28 weeks gestation and within 72 hours after delivery if baby is Rh-positive",
            wrongAnswers: ["Only after delivery", "Only if antibodies are present", "At every prenatal visit"],
            rationale: "RhoGAM prevents Rh sensitization. Given at 28 weeks (when fetal cells may enter maternal circulation) and within 72 hours postpartum if baby is Rh-positive. Also given after any bleeding, amniocentesis, or trauma during pregnancy.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the expected fundal height at 20 weeks gestation?",
            answer: "At the level of the umbilicus",
            wrongAnswers: ["Just above the symphysis pubis", "Halfway between umbilicus and xiphoid", "At the xiphoid process"],
            rationale: "Fundal height in cm approximately equals gestational age in weeks (McDonald's rule). At 20 weeks, fundus is at umbilicus. At 36 weeks, at xiphoid. After 36 weeks, may drop as baby engages. Discrepancy may indicate multiple gestation, IUGR, or wrong dates.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient in labor has an umbilical cord prolapse. What is the PRIORITY nursing action?",
            answer: "Elevate the presenting part off the cord and call for emergency cesarean",
            wrongAnswers: ["Push the cord back into the vagina", "Apply oxygen and wait for spontaneous delivery", "Have the patient push to expedite delivery"],
            rationale: "Cord prolapse is an emergency - compression causes fetal hypoxia/death. Position: knee-chest or Trendelenburg. Use gloved hand to elevate presenting part off cord. Do NOT attempt to replace cord. Emergency cesarean is usually needed.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What does a Bishop score assess?",
            answer: "Cervical readiness for induction of labor",
            wrongAnswers: ["Fetal lung maturity", "Risk of cesarean section", "Neonatal well-being after delivery"],
            rationale: "Bishop score evaluates: cervical dilation, effacement, station, consistency, and position. Score ≥8 indicates favorable cervix likely to respond to induction. Lower scores may need cervical ripening agents (prostaglandins) before oxytocin.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Select ALL warning signs of postpartum depression that require intervention:",
            answer: "Thoughts of harming self or baby, Inability to care for baby, Persistent crying and hopelessness, Severe anxiety or panic attacks",
            wrongAnswers: ["Mild mood swings in first 2 weeks"],
            rationale: "Postpartum 'blues' (mild mood swings, tearfulness) is normal in first 2 weeks. PPD is more severe and persistent: prolonged sadness, inability to function, sleep/appetite changes, thoughts of harm. PPD requires treatment. Postpartum psychosis is psychiatric emergency.",
            contentCategory: .maternity,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .sata,
            isPremium: true
        ),

        // Additional Mental Health (50 cards)
        Flashcard(
            question: "A patient with bipolar disorder is in a manic episode. Which intervention is MOST appropriate?",
            answer: "Provide a calm, low-stimulation environment with consistent boundaries",
            wrongAnswers: ["Encourage participation in group activities", "Allow the patient to make all decisions", "Engage in lengthy conversations about behavior"],
            rationale: "During mania, patients are easily overstimulated, have poor judgment, and need structure. Reduce stimuli, set clear limits, provide high-calorie finger foods (they won't sit to eat), ensure safety. Redirect rather than argue.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which defense mechanism is demonstrated when a patient diagnosed with cancer says 'The lab must have made a mistake'?",
            answer: "Denial",
            wrongAnswers: ["Projection", "Rationalization", "Displacement"],
            rationale: "Denial is refusing to accept reality as a way to cope with overwhelming information. It's often a first response to bad news and can be protective initially. Denial becomes problematic when it prevents necessary treatment or coping.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with anorexia nervosa is admitted with a BMI of 14. What is the PRIORITY concern?",
            answer: "Cardiac arrhythmias due to electrolyte imbalances",
            wrongAnswers: ["Body image disturbance", "Family dynamics", "Self-esteem issues"],
            rationale: "Severe anorexia causes life-threatening electrolyte imbalances (especially hypokalemia) leading to fatal arrhythmias. Medical stabilization is priority before psychological treatment. Refeeding syndrome is also a risk - reintroduce nutrition slowly.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST-LINE treatment for mild to moderate depression?",
            answer: "SSRIs (Selective Serotonin Reuptake Inhibitors)",
            wrongAnswers: ["MAOIs", "Tricyclic antidepressants", "Electroconvulsive therapy"],
            rationale: "SSRIs (fluoxetine, sertraline, etc.) are first-line due to favorable side effect profile and safety in overdose compared to older antidepressants. Takes 2-4 weeks for full effect. MAOIs require dietary restrictions. TCAs have cardiac risks.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with PTSD avoids all reminders of their trauma. This is an example of which symptom cluster?",
            answer: "Avoidance symptoms",
            wrongAnswers: ["Intrusion symptoms", "Arousal symptoms", "Negative cognition symptoms"],
            rationale: "PTSD has 4 symptom clusters: Intrusion (flashbacks, nightmares), Avoidance (avoiding triggers, emotional numbing), Negative cognitions (guilt, detachment), and Arousal (hypervigilance, startle response, sleep problems). All must be present for diagnosis.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // Additional Leadership (40 cards)
        Flashcard(
            question: "A nurse suspects a colleague is diverting controlled substances. What is the APPROPRIATE action?",
            answer: "Report concerns to the nurse manager or appropriate authority",
            wrongAnswers: ["Confront the colleague directly", "Ignore it to avoid conflict", "Search the colleague's belongings"],
            rationale: "Nurses have an ethical and legal obligation to report suspected impairment or diversion. Follow facility policy - typically report to manager or compliance. Documentation of observed behaviors is important. Do not investigate independently.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which situation represents a HIPAA violation?",
            answer: "Discussing a patient's diagnosis in the hospital elevator",
            wrongAnswers: ["Sharing patient information with the treatment team", "Giving report to the oncoming nurse", "Documenting assessment findings in the chart"],
            rationale: "HIPAA protects patient privacy. Violations include: discussing patients in public areas, accessing records without need, sharing login credentials, leaving PHI visible. Sharing with treatment team and documentation are appropriate and necessary.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nursing student asks to observe a procedure. What must occur FIRST?",
            answer: "Obtain the patient's consent for the student's presence",
            wrongAnswers: ["Allow observation without discussion", "Have the student introduce themselves after the procedure", "Document that a student was present"],
            rationale: "Patient autonomy and privacy require consent before allowing students to observe or participate in care. The patient has the right to refuse. Introduce the student, explain their role, and obtain verbal consent. Document appropriately.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the nurse's responsibility when receiving an unclear or potentially harmful order?",
            answer: "Clarify the order with the prescriber before acting",
            wrongAnswers: ["Carry out the order as written", "Ignore the order", "Have another nurse carry out the order"],
            rationale: "Nurses are legally and ethically obligated to question orders that are unclear, incomplete, or potentially harmful. Clarify directly with prescriber. If still concerned, escalate through chain of command. Document communication.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // Infection Control (40 cards)
        Flashcard(
            question: "Which isolation precaution is required for a patient with tuberculosis?",
            answer: "Airborne precautions with N95 respirator",
            wrongAnswers: ["Contact precautions only", "Droplet precautions with surgical mask", "Standard precautions only"],
            rationale: "TB spreads via airborne droplet nuclei (<5 microns) that remain suspended in air. Requires: private negative-pressure room, N95 respirator (fit-tested), patient wears surgical mask during transport. Healthcare workers need annual TB testing.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the CORRECT order for donning PPE?",
            answer: "Gown, mask/respirator, goggles/face shield, gloves",
            wrongAnswers: ["Gloves, gown, mask, goggles", "Mask, gloves, gown, goggles", "Goggles, gloves, mask, gown"],
            rationale: "Donning sequence protects from contamination: Gown first (ties in back), then mask/respirator (requires both hands), eye protection, gloves last (cover gown cuffs). Removal is reverse, with gloves first (most contaminated).",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient has C. difficile infection. Which precautions are required?",
            answer: "Contact precautions with hand washing (not alcohol-based sanitizer)",
            wrongAnswers: ["Droplet precautions only", "Airborne precautions", "Standard precautions only"],
            rationale: "C. diff spores are NOT killed by alcohol-based sanitizers - must wash hands with soap and water. Contact precautions: gown and gloves, dedicated equipment. C. diff is spread by fecal-oral route. Strict environmental cleaning with sporicidal agents.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Select ALL conditions requiring droplet precautions:",
            answer: "Influenza, Pertussis, Meningococcal meningitis, Mumps",
            wrongAnswers: ["Tuberculosis"],
            rationale: "Droplet precautions for pathogens spread by large droplets (>5 microns) that travel <6 feet: influenza, pertussis, meningococcal disease, mumps, rubella. Require surgical mask within 6 feet. Private room preferred. TB requires airborne precautions.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .sata,
            isPremium: true
        ),
        Flashcard(
            question: "How long should surgical hand scrub be performed?",
            answer: "3-5 minutes with systematic scrubbing of hands and forearms",
            wrongAnswers: ["15 seconds", "30 seconds", "10 minutes"],
            rationale: "Surgical hand antisepsis requires longer contact time than routine hand hygiene. Scrub hands and forearms to 2 inches above elbows using systematic pattern. Keep hands elevated. Dry with sterile towel. Some facilities use alcohol-based surgical scrubs.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),

        // Safety (40 cards)
        Flashcard(
            question: "A patient is receiving PCA morphine. Which assessment indicates potential oversedation?",
            answer: "Respiratory rate of 8 and difficult to arouse",
            wrongAnswers: ["Pain rating of 3/10", "Drowsy but easily arousable", "Requesting increased PCA dose"],
            rationale: "Sedation precedes respiratory depression with opioids. Use sedation scale: Level 3 (difficult to arouse) or RR <10 requires immediate intervention. Hold PCA, stimulate patient, administer naloxone if ordered, notify provider.",
            contentCategory: .safety,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which finding indicates a patient is at HIGH risk for aspiration?",
            answer: "Absent gag reflex and difficulty swallowing",
            wrongAnswers: ["Intact cough reflex", "Alert and oriented", "Taking small sips of water without difficulty"],
            rationale: "Aspiration risk factors: decreased LOC, absent gag reflex, dysphagia, stroke, NG tube, mechanical ventilation. Prevention: elevate HOB 30-45°, assess swallow before oral intake, proper positioning, suction available.",
            contentCategory: .safety,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the nurse's FIRST action when a fire alarm sounds?",
            answer: "Implement RACE: Rescue patients in immediate danger",
            wrongAnswers: ["Continue current activities until notified", "Evacuate all patients immediately", "Call the fire department"],
            rationale: "RACE: Rescue patients in immediate danger, Activate alarm (if not already), Contain fire (close doors), Extinguish (if small and safe) or Evacuate. Patients closest to fire rescued first. Know fire exits and extinguisher locations.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient has a latex allergy. Which items should the nurse AVOID?",
            answer: "Latex gloves, urinary catheters with latex, and some adhesive bandages",
            wrongAnswers: ["Vinyl gloves", "Silicone-based products", "Non-latex tourniquets"],
            rationale: "Latex allergy ranges from skin irritation to anaphylaxis. Avoid: latex gloves, catheters, tourniquets, some adhesives. Use latex-free alternatives (nitrile, vinyl gloves; silicone catheters). Also note cross-reactivity with certain foods (bananas, kiwi, avocado).",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which patient is at HIGHEST priority for discharge teaching before leaving the hospital?",
            answer: "Patient going home on new anticoagulant therapy",
            wrongAnswers: ["Patient with well-controlled chronic hypertension", "Patient with unchanged home medications", "Patient with home health nurse visits scheduled"],
            rationale: "New anticoagulants require extensive teaching: signs of bleeding, dietary interactions (warfarin/vitamin K), drug interactions, lab monitoring schedule, when to seek emergency care. Improper use can cause serious bleeding or clots.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),

        // Additional mixed content to reach 450 premium cards
        Flashcard(
            question: "A patient with a tracheostomy is having difficulty breathing. What should the nurse do FIRST?",
            answer: "Suction the tracheostomy tube",
            wrongAnswers: ["Remove the tracheostomy tube", "Administer oxygen via nasal cannula", "Call a code blue"],
            rationale: "Mucus plugging is the most common cause of respiratory distress in tracheostomy patients. First action is suctioning to clear the airway. If suctioning doesn't help, assess tube position, deflate cuff if present, and be prepared to change tube if obstructed.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the nurse's PRIORITY when caring for a patient after a lumbar puncture?",
            answer: "Keep the patient flat and monitor for headache and signs of infection",
            wrongAnswers: ["Encourage immediate ambulation", "Restrict fluids", "Apply ice to the puncture site"],
            rationale: "Post-LP care: flat position for 4-6 hours reduces headache risk from CSF leak. Encourage fluids. Monitor for headache (worse when upright), signs of infection, neurological changes. Headache treatment: bed rest, fluids, caffeine, blood patch if severe.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with heart failure is prescribed furosemide (Lasix). Which finding indicates the medication is effective?",
            answer: "Decreased peripheral edema and weight loss",
            wrongAnswers: ["Weight gain", "Increased blood pressure", "Decreased urine output"],
            rationale: "Furosemide is a loop diuretic that removes excess fluid. Effectiveness shown by: decreased edema, weight loss (fluid loss), increased urine output, improved breathing, decreased JVD. Monitor potassium - furosemide causes hypokalemia.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which vaccine can be given to an immunocompromised patient?",
            answer: "Inactivated influenza vaccine",
            wrongAnswers: ["MMR vaccine", "Varicella vaccine", "Live attenuated influenza vaccine (nasal spray)"],
            rationale: "Immunocompromised patients should NOT receive live vaccines (MMR, varicella, live influenza, oral polio). Inactivated vaccines (injection flu, tetanus, hepatitis B, pneumococcal) are safe. Live vaccines can cause disease in immunocompromised hosts.",
            contentCategory: .fundamentals,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is teaching a patient about preventing DVT during a long flight. Which instruction is MOST important?",
            answer: "Perform ankle circles and walk periodically",
            wrongAnswers: ["Keep legs crossed for comfort", "Limit fluid intake to avoid bathroom trips", "Wear tight clothing for support"],
            rationale: "Virchow's triad: stasis, hypercoagulability, vessel damage. Long periods of immobility cause venous stasis. Prevention: ankle exercises, walking, hydration, loose clothing. Compression stockings for high-risk patients. Avoid crossing legs.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the correct technique for administering insulin using a pen?",
            answer: "Prime the pen, inject at 90-degree angle, hold for 10 seconds after injection",
            wrongAnswers: ["Inject at 45-degree angle without priming", "Remove needle immediately after injection", "Massage the site vigorously after injection"],
            rationale: "Insulin pen technique: prime 2 units before first use/after needle change, clean site, inject at 90° (45° if thin), depress plunger slowly, hold 10 seconds to ensure full dose delivery. Don't massage. Rotate sites within same region.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child is admitted with severe dehydration. Which finding is expected?",
            answer: "Sunken fontanels, decreased skin turgor, and tachycardia",
            wrongAnswers: ["Bulging fontanels and bradycardia", "Excessive tearing and wet diapers", "Slow capillary refill and low blood pressure only"],
            rationale: "Dehydration signs: sunken fontanels (in infants), decreased skin turgor (tenting), tachycardia, dry mucous membranes, decreased tears/urine, prolonged cap refill, eventually hypotension. Severity guides treatment (oral vs IV rehydration).",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A newborn has a positive Ortolani sign. What does this indicate?",
            answer: "Developmental dysplasia of the hip (DDH)",
            wrongAnswers: ["Normal hip development", "Congenital heart defect", "Clubfoot deformity"],
            rationale: "Ortolani test: examiner abducts flexed hips, feeling for 'clunk' as femoral head relocates into acetabulum (positive = hip was dislocated). Barlow test does opposite (adduction dislocates). DDH treatment: Pavlik harness to keep hips in proper position.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which assessment finding in a pregnant patient suggests placental abruption?",
            answer: "Painful vaginal bleeding with a rigid, board-like abdomen",
            wrongAnswers: ["Painless bright red bleeding", "Bloody show with regular contractions", "Leaking clear fluid without bleeding"],
            rationale: "Placental abruption: premature separation of placenta from uterus. Signs: painful bleeding (may be concealed), rigid/tender uterus, fetal distress. Emergency - can cause maternal hemorrhage and fetal death. Placenta previa is painless bleeding.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with depression has not responded to two different SSRIs. Which treatment might be considered next?",
            answer: "Augmentation therapy or switching to a different medication class",
            wrongAnswers: ["Continue the same SSRI indefinitely", "Stop all medications immediately", "Increase SSRI to toxic levels"],
            rationale: "Treatment-resistant depression (no response to 2+ adequate trials) options: augment with lithium/atypical antipsychotic/thyroid hormone, switch classes (SNRI, bupropion, TCA, MAOI), or consider ECT. Never stop antidepressants abruptly - taper slowly.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the MOST important factor when applying physical restraints?",
            answer: "Use the least restrictive device for the shortest time necessary",
            wrongAnswers: ["Apply restraints as tight as possible", "Check restraints every 4 hours", "Apply to all four extremities for safety"],
            rationale: "Restraints are a last resort for patient safety. Least restrictive, shortest duration. Physician order required, renewed every 24 hours (varies). Check circulation and release every 2 hours for toileting, ROM, nutrition. Document behavior, alternatives tried.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Select ALL components of the Glasgow Coma Scale:",
            answer: "Eye opening response, Verbal response, Motor response",
            wrongAnswers: ["Pupil response"],
            rationale: "GCS assesses LOC: Eye opening (4 points max), Verbal response (5 points max), Motor response (6 points max). Total: 15 (fully conscious) to 3 (deep coma). Score ≤8 generally indicates severe brain injury and need for airway protection.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .sata,
            isPremium: true
        ),

        // BATCH 2: Additional Med-Surg (40 cards)
        Flashcard(
            question: "A patient with cirrhosis develops asterixis. What does this indicate?",
            answer: "Hepatic encephalopathy",
            wrongAnswers: ["Alcohol withdrawal", "Hypoglycemia", "Hypokalemia"],
            rationale: "Asterixis (liver flap) is a flapping tremor of the hands when arms are extended. It indicates elevated ammonia levels affecting the brain. Treatment includes lactulose to reduce ammonia absorption and protein restriction.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIORITY nursing action for a patient with suspected pulmonary embolism?",
            answer: "Administer oxygen and notify the provider immediately",
            wrongAnswers: ["Encourage deep breathing exercises", "Ambulate the patient", "Apply compression stockings"],
            rationale: "PE is life-threatening. Priority: high-flow O2, maintain airway, IV access, prepare for anticoagulation. Never ambulate - may dislodge more clots. Classic signs: sudden dyspnea, chest pain, tachycardia, anxiety.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with heart failure is prescribed furosemide. Which lab value requires monitoring?",
            answer: "Potassium level",
            wrongAnswers: ["Calcium level", "Sodium level", "Magnesium level"],
            rationale: "Furosemide (Lasix) is a loop diuretic that causes potassium loss. Monitor for hypokalemia (weakness, arrhythmias, muscle cramps). Normal K: 3.5-5.0 mEq/L. May need potassium supplements or potassium-sparing diuretic.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient post-thyroidectomy reports tingling around the mouth. What should the nurse assess?",
            answer: "Chvostek's and Trousseau's signs for hypocalcemia",
            wrongAnswers: ["Blood glucose level", "Oxygen saturation", "Pupil response"],
            rationale: "Parathyroid glands may be damaged during thyroidectomy, causing hypocalcemia. Perioral tingling is early sign. Chvostek's: facial twitch when cheek tapped. Trousseau's: carpal spasm with BP cuff. Have calcium gluconate available.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which position is BEST for a patient with increased intracranial pressure?",
            answer: "Head of bed elevated 30 degrees with head midline",
            wrongAnswers: ["Flat with legs elevated", "Trendelenburg position", "Side-lying with head flexed"],
            rationale: "HOB 30° promotes venous drainage from brain, reducing ICP. Head midline prevents jugular vein compression. Avoid neck flexion, hip flexion >90°, prone position. These all increase ICP.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with COPD has oxygen ordered. What is the safe flow rate?",
            answer: "1-2 L/min via nasal cannula",
            wrongAnswers: ["6-10 L/min via face mask", "15 L/min via non-rebreather", "4-5 L/min via nasal cannula"],
            rationale: "COPD patients rely on hypoxic drive to breathe. High O2 removes this drive, causing respiratory depression. Target SpO2: 88-92%. Start low (1-2 L) and titrate carefully. Monitor for CO2 retention.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the antidote for heparin overdose?",
            answer: "Protamine sulfate",
            wrongAnswers: ["Vitamin K", "Fresh frozen plasma", "Naloxone"],
            rationale: "Protamine sulfate reverses heparin by binding to it. 1 mg protamine neutralizes ~100 units heparin. Vitamin K is antidote for warfarin. Give slowly - rapid infusion causes hypotension, bradycardia.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with diabetes has a blood glucose of 45 mg/dL. What is the FIRST action?",
            answer: "Give 15-20 grams of fast-acting carbohydrate",
            wrongAnswers: ["Administer insulin", "Call the physician", "Check ketones"],
            rationale: "Rule of 15: Give 15g fast-acting carbs (4 oz juice, glucose tablets), wait 15 min, recheck. If still <70, repeat. If unconscious, give glucagon IM or IV dextrose. Never give food/drink to unconscious patient.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "Which sign indicates a patient is experiencing digoxin toxicity?",
            answer: "Visual disturbances with yellow-green halos",
            wrongAnswers: ["Elevated blood pressure", "Increased appetite", "Hyperactivity"],
            rationale: "Digoxin toxicity signs: visual changes (yellow-green halos, blurred vision), GI symptoms (anorexia, nausea, vomiting), bradycardia, arrhythmias. Check level (therapeutic: 0.5-2.0 ng/mL) and potassium (hypokalemia increases toxicity).",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with acute MI is diaphoretic with crushing chest pain. Which medication is given FIRST?",
            answer: "Aspirin 325 mg chewed",
            wrongAnswers: ["Morphine IV", "Nitroglycerin sublingual", "Metoprolol"],
            rationale: "MONA for MI: Morphine, Oxygen, Nitroglycerin, Aspirin. But Aspirin is actually given FIRST - inhibits platelet aggregation immediately. Chewing speeds absorption. Contraindicated if aspirin allergy or active bleeding.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What assessment finding indicates compartment syndrome?",
            answer: "Pain out of proportion to injury, especially with passive stretch",
            wrongAnswers: ["Warm, pink extremity", "Strong distal pulses", "Normal capillary refill"],
            rationale: "6 P's of compartment syndrome: Pain (severe, with passive stretch), Pressure, Paresthesia, Pallor, Pulselessness (late), Paralysis (late). Medical emergency - fasciotomy needed within 6 hours to prevent permanent damage.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a hip fracture is at risk for which life-threatening complication?",
            answer: "Fat embolism syndrome",
            wrongAnswers: ["Urinary retention", "Constipation", "Skin breakdown"],
            rationale: "Fat embolism occurs 24-72 hours after long bone/pelvis fracture. Fat globules enter bloodstream, lodge in lungs/brain. Classic triad: respiratory distress, neurological changes, petechial rash on chest/axillae. Prevention: early immobilization.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which laboratory value indicates disseminated intravascular coagulation (DIC)?",
            answer: "Decreased platelets, prolonged PT/PTT, elevated D-dimer",
            wrongAnswers: ["Increased platelets, decreased PT/PTT", "Normal clotting studies", "Elevated hemoglobin"],
            rationale: "DIC: widespread clotting depletes clotting factors and platelets, causing bleeding. Labs: low platelets, low fibrinogen, prolonged PT/PTT, elevated D-dimer/FDP. Treatment: treat underlying cause, replace blood products.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a pacemaker should avoid which item?",
            answer: "MRI machines",
            wrongAnswers: ["Microwave ovens", "Television remote controls", "Electric blankets"],
            rationale: "MRI's strong magnetic field can damage pacemaker, cause burns, or alter settings. Modern microwaves, TVs, and most household items are safe. Patients should carry pacemaker ID card and alert medical personnel before procedures.",
            contentCategory: .medSurg,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST action when a patient's chest tube becomes disconnected?",
            answer: "Submerge the tube end in sterile water or saline",
            wrongAnswers: ["Clamp the chest tube immediately", "Have patient perform Valsalva maneuver", "Remove the chest tube"],
            rationale: "Submerging in sterile water creates water seal, preventing air entry. Clamping risks tension pneumothorax. Reconnect to drainage system ASAP. If tube falls out of patient, cover site with petroleum gauze taped on 3 sides.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient receiving TPN develops fever and chills. What should the nurse suspect?",
            answer: "Catheter-related bloodstream infection",
            wrongAnswers: ["Hypoglycemia", "Fluid overload", "Allergic reaction to lipids"],
            rationale: "Central line infections are common with TPN. Signs: fever, chills, redness/drainage at site. Blood cultures needed (peripheral and from line). May need line removal. Prevention: strict aseptic technique, site care per protocol.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which electrolyte imbalance causes tall, peaked T waves on ECG?",
            answer: "Hyperkalemia",
            wrongAnswers: ["Hypokalemia", "Hypercalcemia", "Hyponatremia"],
            rationale: "Hyperkalemia (K >5.0): tall peaked T waves, widened QRS, flattened P waves, can progress to V-fib/asystole. Treatment: calcium gluconate (stabilizes heart), insulin+glucose, kayexalate, dialysis. Causes: renal failure, ACE inhibitors, potassium supplements.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a tracheostomy has thick secretions. What intervention helps?",
            answer: "Increase humidification and ensure adequate hydration",
            wrongAnswers: ["Decrease fluid intake", "Use heated dry oxygen", "Suction more frequently without other interventions"],
            rationale: "Tracheostomy bypasses normal humidification of upper airway. Thick secretions indicate inadequate humidity. Increase humidification, ensure fluid intake of 2-3L/day (if not contraindicated), and instill saline before suctioning if needed.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the normal central venous pressure (CVP) range?",
            answer: "2-6 mmHg (or 3-8 cm H2O)",
            wrongAnswers: ["10-15 mmHg", "0-1 mmHg", "20-25 mmHg"],
            rationale: "CVP reflects right heart preload/fluid status. Low CVP: hypovolemia. High CVP: fluid overload, right heart failure, cardiac tamponade. Measured via central line, patient flat, at end-expiration.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with peptic ulcer disease has black, tarry stools. What does this indicate?",
            answer: "Upper GI bleeding",
            wrongAnswers: ["Lower GI bleeding", "Constipation", "Normal finding with iron supplements"],
            rationale: "Melena (black tarry stool) indicates upper GI bleed - blood is digested as it passes through GI tract. Bright red blood per rectum (hematochezia) usually indicates lower GI bleed. Iron supplements cause dark but not tarry stools.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 3: Additional Pharmacology (50 cards)
        Flashcard(
            question: "A patient on warfarin has an INR of 5.2. What should the nurse expect?",
            answer: "Hold warfarin and possibly administer vitamin K",
            wrongAnswers: ["Increase the warfarin dose", "Continue warfarin as ordered", "Administer heparin"],
            rationale: "Therapeutic INR for most conditions: 2.0-3.0. INR >4 increases bleeding risk significantly. Hold warfarin, give vitamin K for high INR (oral for non-bleeding, IV for severe bleeding). Monitor for bleeding signs.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which medication requires the patient to avoid tyramine-rich foods?",
            answer: "MAO inhibitors (phenelzine, tranylcypromine)",
            wrongAnswers: ["SSRIs", "Benzodiazepines", "Tricyclic antidepressants"],
            rationale: "MAOIs prevent tyramine breakdown. Tyramine causes norepinephrine release, leading to hypertensive crisis. Avoid: aged cheese, cured meats, red wine, soy sauce, sauerkraut. Crisis signs: severe headache, hypertension, stiff neck.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the antidote for benzodiazepine overdose?",
            answer: "Flumazenil (Romazicon)",
            wrongAnswers: ["Naloxone", "Acetylcysteine", "Protamine sulfate"],
            rationale: "Flumazenil competitively inhibits benzodiazepines at receptor site. Use cautiously - can precipitate seizures in chronic benzodiazepine users or those who ingested seizure-causing drugs. Short half-life may require repeated doses.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient on lithium has a level of 2.1 mEq/L. What should the nurse do?",
            answer: "Hold the medication and notify the provider immediately",
            wrongAnswers: ["Give the next scheduled dose", "Increase fluid intake only", "Wait for next scheduled level check"],
            rationale: "Lithium therapeutic range: 0.6-1.2 mEq/L. Level >1.5 is toxic. Signs: tremors, GI upset, confusion, seizures. Hold drug, hydrate, may need dialysis. Causes: dehydration, NSAIDs, ACE inhibitors, sodium restriction.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "Which medication should be taken on an empty stomach?",
            answer: "Levothyroxine (Synthroid)",
            wrongAnswers: ["Ibuprofen", "Metformin", "Prednisone"],
            rationale: "Levothyroxine absorption is decreased by food, calcium, iron, antacids. Take 30-60 minutes before breakfast or at bedtime. Consistent timing important for stable levels. Monitor TSH every 6-8 weeks when adjusting dose.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIMARY concern when giving IV potassium?",
            answer: "Never give IV push - can cause fatal cardiac arrhythmias",
            wrongAnswers: ["It must be given with insulin", "It causes severe hypotension", "It must be refrigerated"],
            rationale: "IV potassium must be diluted and given slowly (usually 10 mEq/hour max via peripheral line). Rapid infusion causes cardiac arrest. Never give IV push. Infusion should be on a pump. Causes burning - may need central line for high concentrations.",
            contentCategory: .pharmacology,
            nclexCategory: .safeEffectiveCare,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient taking metformin is scheduled for a CT with contrast. What should occur?",
            answer: "Hold metformin for 48 hours after the procedure",
            wrongAnswers: ["Continue metformin as scheduled", "Take double dose after procedure", "Stop metformin permanently"],
            rationale: "Contrast media can cause acute kidney injury. Metformin is renally excreted - combining with AKI can cause lactic acidosis. Hold 48 hours after contrast, resume after renal function confirmed normal.",
            contentCategory: .pharmacology,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which assessment is essential before giving an ACE inhibitor?",
            answer: "Blood pressure and potassium level",
            wrongAnswers: ["Blood glucose level", "Heart rate only", "Respiratory rate"],
            rationale: "ACE inhibitors cause hypotension (especially first dose) and hyperkalemia (reduce aldosterone). Also monitor for angioedema, dry cough, and renal function. Contraindicated in pregnancy. Examples: lisinopril, enalapril (-pril ending).",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is prescribed gentamicin. Which labs require monitoring?",
            answer: "Peak and trough levels, BUN, and creatinine",
            wrongAnswers: ["Liver enzymes only", "Complete blood count only", "Cholesterol levels"],
            rationale: "Aminoglycosides (gentamicin, tobramycin) are nephrotoxic and ototoxic. Monitor: peak (efficacy), trough (toxicity), renal function. Assess for hearing loss, tinnitus, vertigo. Ensure adequate hydration.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the mechanism of action of beta-blockers?",
            answer: "Block beta-adrenergic receptors, decreasing heart rate and blood pressure",
            wrongAnswers: ["Increase calcium influx into heart cells", "Stimulate alpha receptors", "Directly dilate blood vessels"],
            rationale: "Beta-blockers (-olol ending) block sympathetic stimulation. Effects: decreased HR, BP, contractility, oxygen demand. Used for HTN, angina, MI, heart failure, arrhythmias. Contraindicated in asthma, severe bradycardia.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient on phenytoin has gingival hyperplasia. What teaching is appropriate?",
            answer: "Maintain meticulous oral hygiene and regular dental visits",
            wrongAnswers: ["Stop taking the medication immediately", "This will resolve without intervention", "Increase the medication dose"],
            rationale: "Gingival hyperplasia is common side effect of phenytoin. Good oral hygiene (brushing, flossing, dental visits) minimizes severity. Other side effects: hirsutism, ataxia, nystagmus. Monitor drug levels (therapeutic: 10-20 mcg/mL).",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which medication requires a filter needle for withdrawal from ampule?",
            answer: "Any medication drawn from a glass ampule",
            wrongAnswers: ["Only insulin preparations", "Only IV antibiotics", "Only narcotic medications"],
            rationale: "Glass particles can fall into ampule when broken. Filter needle (or straw) removes glass fragments during withdrawal. Change to regular needle before injection. This prevents injection of glass particles into patient.",
            contentCategory: .pharmacology,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is receiving vancomycin. What adverse effect requires immediate attention?",
            answer: "Red man syndrome (flushing of face and trunk)",
            wrongAnswers: ["Mild nausea", "Injection site discomfort", "Drowsiness"],
            rationale: "Red man syndrome: histamine release causing flushing, pruritus, hypotension. Caused by rapid infusion. Treatment: slow/stop infusion, antihistamines. Infuse over at least 60 minutes. Also monitor for ototoxicity, nephrotoxicity.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What teaching should be provided about nitroglycerin sublingual tablets?",
            answer: "Store in dark glass container, replace every 6 months, should cause slight burning under tongue",
            wrongAnswers: ["Chew the tablet thoroughly", "Take with a full glass of water", "Store in plastic container"],
            rationale: "Nitroglycerin is light-sensitive and volatile. Dark container, away from heat/moisture. Slight burning/tingling indicates potency. If no relief after 3 tablets (5 min apart), call 911. Sit or lie down - causes hypotension.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient taking amlodipine reports swollen ankles. What should the nurse explain?",
            answer: "Peripheral edema is a common side effect of calcium channel blockers",
            wrongAnswers: ["This indicates heart failure", "The medication is not working", "This is an allergic reaction"],
            rationale: "CCBs (-dipine ending) cause vasodilation, which can lead to peripheral edema. Not related to fluid overload. Usually dose-related. Other side effects: headache, flushing, dizziness, constipation (especially verapamil).",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the antidote for acetaminophen overdose?",
            answer: "Acetylcysteine (Mucomyst)",
            wrongAnswers: ["Flumazenil", "Naloxone", "Vitamin K"],
            rationale: "Acetylcysteine replenishes glutathione, which detoxifies acetaminophen metabolites. Most effective within 8 hours but may help up to 24 hours. Overdose causes hepatotoxicity. Max daily dose: 4g/day (less in alcoholics).",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient on corticosteroids should be monitored for which condition?",
            answer: "Hyperglycemia and adrenal suppression",
            wrongAnswers: ["Hypoglycemia", "Excessive weight loss", "Hypotension"],
            rationale: "Corticosteroids cause: hyperglycemia, immunosuppression, osteoporosis, adrenal suppression, weight gain, mood changes, peptic ulcers. Never stop abruptly after long-term use - taper gradually to prevent adrenal crisis.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which statement indicates understanding of albuterol inhaler use?",
            answer: "I should use this when I feel short of breath for quick relief",
            wrongAnswers: ["I should use this on a regular schedule twice daily", "This will reduce the inflammation in my airways", "I should take this before my steroid inhaler"],
            rationale: "Albuterol is a short-acting beta-2 agonist (SABA) - rescue inhaler for acute symptoms. Works in minutes. If using steroid inhaler too, use albuterol first to open airways. Overuse indicates poor asthma control.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient on clozapine requires monitoring for which serious adverse effect?",
            answer: "Agranulocytosis (severe drop in white blood cells)",
            wrongAnswers: ["Elevated cholesterol", "Hair loss", "Weight loss"],
            rationale: "Clozapine can cause life-threatening agranulocytosis. Requires weekly WBC monitoring initially, then bi-weekly, then monthly. Also monitor for myocarditis, seizures, metabolic syndrome. Only dispensed through REMS program.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is important teaching about taking iron supplements?",
            answer: "Take on empty stomach with vitamin C, avoid taking with antacids or dairy",
            wrongAnswers: ["Take with milk for better absorption", "Take with antacids to prevent stomach upset", "Take with calcium supplements"],
            rationale: "Iron absorption enhanced by vitamin C, decreased by calcium, antacids, dairy, caffeine. Take 1 hour before or 2 hours after meals. Expect dark stools. Take liquid iron through straw to prevent tooth staining.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 4: Additional Pediatrics (50 cards)
        Flashcard(
            question: "At what age do most children achieve bowel and bladder control?",
            answer: "2-3 years old",
            wrongAnswers: ["6-12 months old", "4-5 years old", "6-7 years old"],
            rationale: "Most children show readiness signs around 18-24 months. Daytime control usually achieved by age 3, nighttime control may take longer (up to age 5-6 is normal). Signs: staying dry for 2 hours, awareness of urge.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A 2-year-old is admitted with epiglottitis. What is the PRIORITY nursing action?",
            answer: "Keep the child calm and prepare for possible emergency airway management",
            wrongAnswers: ["Examine the throat with a tongue depressor", "Place the child flat in bed", "Obtain a throat culture immediately"],
            rationale: "Epiglottitis is airway emergency. NEVER examine throat - can trigger complete obstruction. Keep child calm, upright (tripod position), prepare emergency airway equipment. Classic signs: drooling, dysphagia, distress, high fever.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate pain assessment tool for a 4-year-old?",
            answer: "FACES pain rating scale",
            wrongAnswers: ["Numeric 0-10 scale", "Visual analog scale", "McGill Pain Questionnaire"],
            rationale: "FACES scale uses cartoon faces from smiling to crying. Appropriate for children 3-8 years. Numeric scales appropriate around age 7-8 when child understands number concepts. Always believe child's self-report of pain.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with pyloric stenosis typically presents with what type of vomiting?",
            answer: "Projectile, nonbilious vomiting after feeding",
            wrongAnswers: ["Bilious (green) vomiting", "Vomiting with diarrhea", "Blood-tinged vomiting"],
            rationale: "Pyloric stenosis: thickened pylorus obstructs gastric outlet. Vomiting is projectile (forceful), nonbilious (obstruction is before bile duct entry). Occurs 2-4 weeks of age. \"Olive-shaped\" mass palpable. Treatment: pyloromyotomy.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What position should an infant with gastroesophageal reflux be placed after feeding?",
            answer: "Upright or elevated prone position for 30 minutes",
            wrongAnswers: ["Flat on back immediately", "Left side-lying flat", "Trendelenburg position"],
            rationale: "Upright position uses gravity to keep stomach contents down. Elevate HOB 30°. Feed smaller, frequent amounts. Thickened feedings may help. Burp frequently during feeding. For sleep, back position is still recommended (SIDS prevention).",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with croup has a barking cough. What intervention provides relief?",
            answer: "Cool mist humidifier or exposure to cool night air",
            wrongAnswers: ["Hot steam inhalation", "Cough suppressants", "Chest physiotherapy"],
            rationale: "Croup (laryngotracheobronchitis) causes barking seal-like cough, stridor, hoarseness. Cool mist reduces airway edema. Taking child outside in cool air often helps. Severe cases: racemic epinephrine, corticosteroids.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the MOST common cause of bacterial meningitis in infants?",
            answer: "Group B Streptococcus",
            wrongAnswers: ["Haemophilus influenzae", "Staphylococcus aureus", "Pseudomonas aeruginosa"],
            rationale: "In neonates/young infants: Group B Strep, E. coli, Listeria. In older children: S. pneumoniae, N. meningitidis. H. influenzae decreased due to vaccination. Classic signs in infants: bulging fontanel, poor feeding, irritability.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with sickle cell disease develops sudden severe chest pain and fever. What should the nurse suspect?",
            answer: "Acute chest syndrome",
            wrongAnswers: ["Anxiety attack", "Costochondritis", "Muscle strain"],
            rationale: "Acute chest syndrome is leading cause of death in sickle cell. Sickling in pulmonary vessels causes chest pain, fever, respiratory distress, new infiltrate on X-ray. Treatment: oxygen, hydration, transfusion, antibiotics, pain management.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "At what age should a child receive the MMR vaccine?",
            answer: "12-15 months with second dose at 4-6 years",
            wrongAnswers: ["Birth", "2 months", "6 months"],
            rationale: "MMR given at 12-15 months (maternal antibodies wane), second dose 4-6 years. Live vaccine - contraindicated in immunocompromised, pregnancy. Side effects: fever, rash 7-10 days post-vaccination. No MMR-autism link.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST sign of respiratory distress in infants?",
            answer: "Increased respiratory rate (tachypnea)",
            wrongAnswers: ["Cyanosis", "Bradycardia", "Loss of consciousness"],
            rationale: "Tachypnea is earliest sign. Other signs: nasal flaring, retractions (substernal, intercostal, supraclavicular), grunting, head bobbing, seesaw breathing. Cyanosis is late sign. Normal infant RR: 30-60/min.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child is diagnosed with Kawasaki disease. What is the MOST serious complication?",
            answer: "Coronary artery aneurysms",
            wrongAnswers: ["Skin rash", "Lymph node swelling", "Joint pain"],
            rationale: "Kawasaki disease causes vasculitis. Without treatment, 25% develop coronary artery aneurysms. Treatment: high-dose IVIG and aspirin within 10 days of onset reduces risk to 4%. Monitor with echocardiograms.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate nursing response to breath-holding spells in a toddler?",
            answer: "Reassure parents that spells are benign and child will resume breathing",
            wrongAnswers: ["Perform CPR immediately", "Splash cold water on the child's face", "Shake the child vigorously"],
            rationale: "Breath-holding spells occur in toddlers during frustration/anger. Child may turn blue, lose consciousness briefly. Self-limiting - child will breathe when CO2 rises. Stay calm, ensure safety, don't reinforce behavior with excessive attention.",
            contentCategory: .pediatrics,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with leukemia has a platelet count of 15,000/mm³. What precaution is essential?",
            answer: "Bleeding precautions - avoid contact sports, use soft toothbrush, no rectal temperatures",
            wrongAnswers: ["Strict isolation", "Increased physical activity", "High-fiber diet"],
            rationale: "Thrombocytopenia (<50,000) increases bleeding risk. Precautions: soft toothbrush, electric razor, no contact sports, avoid IM injections if possible, apply pressure to puncture sites, no rectal temps. Watch for petechiae, bruising.",
            contentCategory: .pediatrics,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the normal blood pressure for a 6-year-old child?",
            answer: "Approximately 95-105/55-65 mmHg",
            wrongAnswers: ["120/80 mmHg", "70/40 mmHg", "140/90 mmHg"],
            rationale: "Pediatric BP varies by age. Rough formula: systolic = 90 + (2 × age in years). Use appropriate size cuff (bladder covers 80-100% of arm circumference). HTN defined as ≥95th percentile for age/height/sex.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with nephrotic syndrome will have which characteristic finding?",
            answer: "Proteinuria, hypoalbuminemia, and generalized edema",
            wrongAnswers: ["Hematuria and hypertension", "Decreased urine protein", "Weight loss"],
            rationale: "Nephrotic syndrome: massive protein loss in urine → low albumin → decreased oncotic pressure → edema (periorbital, ascites, scrotal). Hyperlipidemia also common. Treatment: corticosteroids, manage edema, prevent infection.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What immunization is given at birth?",
            answer: "Hepatitis B vaccine",
            wrongAnswers: ["MMR vaccine", "Varicella vaccine", "DTaP vaccine"],
            rationale: "Hepatitis B is given within 24 hours of birth (especially if mother is HBsAg positive). Series completed at 1-2 months and 6-18 months. If mother is HBsAg positive, infant also receives HBIG within 12 hours.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What developmental milestone should a 9-month-old infant demonstrate?",
            answer: "Sits without support, crawls, says 'mama/dada' nonspecifically",
            wrongAnswers: ["Walks independently", "Speaks in sentences", "Draws circles"],
            rationale: "9-month milestones: sits well, crawls, pulls to stand, pincer grasp developing, stranger anxiety, understands 'no,' babbles with consonant sounds. Red flags: not sitting, no babbling, doesn't respond to name.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child is receiving IV fluids. What is the hourly maintenance rate for a 15 kg child?",
            answer: "50 mL/hour (4-2-1 rule)",
            wrongAnswers: ["15 mL/hour", "100 mL/hour", "150 mL/hour"],
            rationale: "4-2-1 rule: 4 mL/kg/hr for first 10 kg + 2 mL/kg/hr for next 10 kg + 1 mL/kg/hr for remaining. 15 kg = (10×4) + (5×2) = 40 + 10 = 50 mL/hour. Always verify calculations.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the BEST way to assess pain in a preverbal infant?",
            answer: "Use behavioral cues: facial expression, crying, body movement (FLACC scale)",
            wrongAnswers: ["Ask the parent to rate pain 0-10", "Assume no crying means no pain", "Use numeric rating scale"],
            rationale: "FLACC: Face, Legs, Activity, Cry, Consolability - scored 0-2 each. Total 0-10. Infants show pain through grimacing, rigid body, high-pitched cry, inconsolability. Physiologic signs (HR, BP) are less reliable.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with suspected intussusception will have which classic stool finding?",
            answer: "Currant jelly stools (blood and mucus)",
            wrongAnswers: ["Clay-colored stools", "Black tarry stools", "Green watery stools"],
            rationale: "Intussusception: bowel telescopes into itself, causing obstruction and ischemia. Classic triad: colicky abdominal pain, vomiting, currant jelly stools. Sausage-shaped mass palpable. Treatment: air/barium enema reduction or surgery.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 5: Additional Maternity/OB (50 cards)
        Flashcard(
            question: "During labor, what fetal heart rate pattern indicates cord compression?",
            answer: "Variable decelerations",
            wrongAnswers: ["Early decelerations", "Late decelerations", "Accelerations"],
            rationale: "Variable decelerations: abrupt drops in FHR with variable timing relative to contractions - caused by cord compression. Early decels (mirror contractions) = head compression (benign). Late decels = uteroplacental insufficiency (concerning).",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIORITY nursing action for late decelerations?",
            answer: "Turn mother to left side, increase IV fluids, administer oxygen, stop Pitocin if running",
            wrongAnswers: ["Prepare for immediate cesarean", "Continue monitoring only", "Increase Pitocin rate"],
            rationale: "Late decels indicate fetal hypoxia from uteroplacental insufficiency. Intrauterine resuscitation: position change (left lateral), O2 by mask, increase fluids, stop oxytocin, notify provider. If pattern persists, prepare for delivery.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A woman at 32 weeks gestation reports sudden gush of fluid from vagina. What is the FIRST action?",
            answer: "Assess for umbilical cord prolapse",
            wrongAnswers: ["Perform vaginal exam to check dilation", "Start Pitocin to induce labor", "Discharge home with instructions"],
            rationale: "Premature rupture of membranes (PROM) risk: cord prolapse, infection. Assess for cord at introitus or in vagina. If cord visible, elevate presenting part, position knee-chest, prepare for emergency cesarean. Use sterile speculum (not digital) exam.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the normal fetal heart rate baseline?",
            answer: "110-160 beats per minute",
            wrongAnswers: ["80-100 beats per minute", "60-80 beats per minute", "160-200 beats per minute"],
            rationale: "Normal FHR: 110-160 bpm. Tachycardia >160 (maternal fever, fetal hypoxia, infection). Bradycardia <110 (cord compression, congenital heart block, prolonged hypoxia). Moderate variability is reassuring (6-25 bpm fluctuation).",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A pregnant woman has a positive glucose challenge test. What is the next step?",
            answer: "3-hour glucose tolerance test",
            wrongAnswers: ["Start insulin immediately", "Repeat 1-hour test in one week", "No further testing needed"],
            rationale: "1-hour GCT is screening (50g glucose, abnormal if ≥140). If positive, confirm with 3-hour GTT (100g glucose, fasting then 1, 2, 3 hours). GDM diagnosed if 2+ values abnormal. Manage with diet first, then insulin if needed.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What medication is given to prevent neonatal Group B Strep infection during labor?",
            answer: "Intravenous penicillin or ampicillin",
            wrongAnswers: ["Oral erythromycin", "Intramuscular ceftriaxone", "Topical antibiotics"],
            rationale: "GBS prophylaxis: IV penicillin G or ampicillin during labor, starting at least 4 hours before delivery. Given to GBS+ mothers or those with risk factors (preterm, prolonged ROM, fever). Prevents early-onset neonatal GBS sepsis.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A woman 2 hours postpartum has a boggy uterus and heavy bleeding. What is the FIRST action?",
            answer: "Massage the uterine fundus",
            wrongAnswers: ["Administer pain medication", "Insert Foley catheter", "Prepare for surgery"],
            rationale: "Boggy uterus = uterine atony, #1 cause of postpartum hemorrhage. First intervention: fundal massage to stimulate contraction. Keep bladder empty (full bladder displaces uterus). Oxytocin, methylergonovine, or prostaglandins if massage ineffective.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the expected fundal height at 20 weeks gestation?",
            answer: "At the level of the umbilicus",
            wrongAnswers: ["At the symphysis pubis", "Halfway between umbilicus and xiphoid", "At the xiphoid process"],
            rationale: "Fundal height in cm ≈ weeks gestation (16-36 weeks). At 12 weeks: at symphysis pubis. At 20 weeks: at umbilicus. At 36 weeks: at xiphoid. After 36 weeks may decrease as baby drops. Discrepancy >3 cm warrants evaluation.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A laboring woman requests an epidural. What must occur before administration?",
            answer: "IV fluid bolus (500-1000 mL) and verify platelet count is adequate",
            wrongAnswers: ["Complete cervical dilation", "Rupture of membranes", "Administration of Pitocin"],
            rationale: "Pre-epidural: IV access, fluid bolus (prevents hypotension from sympathetic block), normal coagulation (platelets >100,000), baseline vitals. No specific dilation required. Contraindicated: coagulopathy, infection at site, increased ICP.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is Naegele's rule for calculating estimated due date?",
            answer: "First day of LMP minus 3 months plus 7 days plus 1 year",
            wrongAnswers: ["First day of LMP plus 9 months", "Last day of LMP plus 280 days", "First day of LMP plus 40 days"],
            rationale: "Naegele's rule: LMP + 7 days - 3 months + 1 year. Example: LMP January 1 → EDD October 8. Assumes 28-day cycle with ovulation day 14. Ultrasound dating most accurate in first trimester.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A pregnant woman at 34 weeks has severe headache, visual changes, and BP 168/110. What condition is suspected?",
            answer: "Severe preeclampsia",
            wrongAnswers: ["Migraine headache", "Normal pregnancy discomfort", "Gestational hypertension"],
            rationale: "Preeclampsia: HTN + proteinuria after 20 weeks. Severe features: BP ≥160/110, headache, visual changes, RUQ pain, elevated liver enzymes, low platelets, renal dysfunction. Treatment: magnesium sulfate (seizure prevention), antihypertensives, delivery.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the antidote for magnesium sulfate toxicity?",
            answer: "Calcium gluconate",
            wrongAnswers: ["Protamine sulfate", "Vitamin K", "Naloxone"],
            rationale: "Magnesium toxicity signs (in order): loss of DTRs, respiratory depression, cardiac arrest. Monitor: DTRs (should be present), respirations (>12/min), urine output (>30 mL/hr). Therapeutic level: 4-7 mEq/L. Keep calcium gluconate at bedside.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the purpose of giving Rh immune globulin (RhoGAM)?",
            answer: "To prevent Rh sensitization in Rh-negative mothers exposed to Rh-positive blood",
            wrongAnswers: ["To treat Rh disease in the newborn", "To prevent GBS infection", "To stimulate fetal lung maturity"],
            rationale: "RhoGAM prevents maternal antibody formation against Rh+ fetal cells. Given at 28 weeks and within 72 hours of delivery (if baby Rh+), and after any bleeding event, amniocentesis, or pregnancy loss. Not needed if father confirmed Rh-negative.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A woman is in the second stage of labor. What characterizes this stage?",
            answer: "Complete cervical dilation (10 cm) until delivery of the baby",
            wrongAnswers: ["Onset of contractions until complete dilation", "Delivery of baby until delivery of placenta", "From admission until active labor"],
            rationale: "Stage 1: early, active, transition - until 10 cm dilated. Stage 2: 10 cm to delivery (pushing stage). Stage 3: delivery to placenta expulsion. Stage 4: first 1-2 hours postpartum (recovery).",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What assessment finding indicates placental abruption?",
            answer: "Painful, rigid abdomen with dark red vaginal bleeding",
            wrongAnswers: ["Painless bright red bleeding", "Soft, nontender abdomen", "Gradual onset of mild cramping"],
            rationale: "Abruption: premature separation of placenta. Classic: painful contractions, rigid board-like abdomen, dark blood (may be concealed). Vs placenta previa: painless bright red bleeding. Both emergencies - continuous monitoring, prepare for delivery.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "How soon after delivery should breastfeeding be initiated?",
            answer: "Within the first hour (golden hour)",
            wrongAnswers: ["After 24 hours", "Only after milk comes in", "After infant has first bath"],
            rationale: "Early initiation (within 1 hour) promotes bonding, stimulates milk production, provides colostrum (rich in antibodies). Skin-to-skin contact helps regulate infant temperature and promotes rooting/latching. Delay bath until after first feed.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A newborn has a 1-minute Apgar score of 4. What is the PRIORITY action?",
            answer: "Provide positive pressure ventilation and stimulation",
            wrongAnswers: ["Perform chest compressions immediately", "Give IV epinephrine", "Place under warmer and observe"],
            rationale: "Apgar 4-6: moderately depressed. Steps: warm, dry, stimulate, suction if needed, provide oxygen/PPV. Chest compressions if HR <60 after 30 seconds of effective ventilation. Apgar reassessed at 5 minutes. Scores 7-10 normal.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "When does lochia normally change from rubra to serosa?",
            answer: "Around days 4-10 postpartum",
            wrongAnswers: ["Within 24 hours", "After 2 weeks", "After 6 weeks"],
            rationale: "Lochia rubra: days 1-3, bright red. Serosa: days 4-10, pinkish-brown. Alba: days 11-21+, yellowish-white. Return to rubra or foul odor suggests infection. Heavy bleeding with clots after first few hours is abnormal.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A pregnant woman should avoid which food due to listeria risk?",
            answer: "Unpasteurized soft cheeses and deli meats",
            wrongAnswers: ["Cooked chicken", "Pasteurized milk", "Well-done hamburgers"],
            rationale: "Listeriosis in pregnancy can cause miscarriage, stillbirth, preterm labor. Avoid: unpasteurized dairy, soft cheeses (brie, feta, queso fresco), deli meats (unless heated steaming hot), hot dogs, refrigerated smoked seafood.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What fetal position is ideal for vaginal delivery?",
            answer: "Occiput anterior (OA)",
            wrongAnswers: ["Occiput posterior (OP)", "Breech", "Transverse lie"],
            rationale: "OA: fetal occiput toward mother's front - smallest diameter presents, smoothest delivery. OP (sunny-side up): causes back labor, longer pushing. Breech: feet/buttocks first - usually cesarean. Transverse: shoulder presentation - cesarean required.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 6: Additional Mental Health (50 cards)
        Flashcard(
            question: "A patient with bipolar disorder in manic phase is talking rapidly and hasn't slept in 3 days. What is the PRIORITY?",
            answer: "Ensure safety and provide a calm, low-stimulation environment",
            wrongAnswers: ["Encourage group activities", "Provide detailed explanations", "Confront the behavior"],
            rationale: "Manic patients: flight of ideas, decreased sleep, impulsivity, poor judgment. Priority is safety (may harm self through reckless behavior). Low stimulation, brief simple communication, nutrition/hydration, set limits calmly.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "Which statement indicates a patient may be at HIGH risk for suicide?",
            answer: "I've given away my favorite things and written letters to my family",
            wrongAnswers: ["I sometimes feel sad", "I wish things were different", "I get frustrated easily"],
            rationale: "Giving away possessions, making final arrangements, sudden calmness after depression, having specific plan with means = HIGH risk. Always take seriously, ask directly about suicide, ensure safety, remove means, constant observation.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with schizophrenia believes the TV is sending special messages to them. This is an example of:",
            answer: "Delusion of reference",
            wrongAnswers: ["Hallucination", "Delusion of grandeur", "Delusion of persecution"],
            rationale: "Delusions of reference: belief that random events have personal significance. Grandeur: inflated self-importance. Persecution: belief others are plotting against them. Hallucinations are sensory experiences (hearing/seeing things not there).",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the therapeutic lithium level for maintenance?",
            answer: "0.6-1.2 mEq/L",
            wrongAnswers: ["2.0-3.0 mEq/L", "0.1-0.3 mEq/L", "3.0-4.0 mEq/L"],
            rationale: "Therapeutic: 0.6-1.2 mEq/L. Toxic >1.5 mEq/L. Narrow therapeutic index. Monitor levels regularly. Toxicity signs: GI upset, tremors, confusion, seizures. Maintain sodium/fluid intake, avoid NSAIDs which increase levels.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient taking haloperidol develops fever, muscle rigidity, and altered consciousness. What is suspected?",
            answer: "Neuroleptic malignant syndrome (NMS)",
            wrongAnswers: ["Extrapyramidal symptoms", "Tardive dyskinesia", "Akathisia"],
            rationale: "NMS: life-threatening reaction to antipsychotics. Classic tetrad: hyperthermia, muscle rigidity (lead-pipe), altered mental status, autonomic instability. Stop medication immediately, supportive care, dantrolene/bromocriptine. Mortality 10-20%.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the MOST effective therapy for panic disorder?",
            answer: "Cognitive behavioral therapy combined with medication",
            wrongAnswers: ["Psychoanalysis alone", "Medication alone long-term", "Group therapy only"],
            rationale: "CBT addresses catastrophic thinking and avoidance behaviors. SSRIs are first-line medication. Benzodiazepines for acute attacks only (short-term due to dependence). Combination therapy most effective for long-term management.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with anorexia nervosa refuses to eat. What is the PRIORITY concern?",
            answer: "Electrolyte imbalances and cardiac arrhythmias",
            wrongAnswers: ["Body image disturbance", "Family dynamics", "Self-esteem issues"],
            rationale: "Anorexia has highest mortality of psychiatric disorders. Life-threatening: hypokalemia causes arrhythmias, hypoglycemia, dehydration, organ failure. Medical stabilization first, then address psychological issues. Monitor refeeding syndrome.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with PTSD experiences flashbacks. What nursing intervention is MOST appropriate?",
            answer: "Help ground the patient to present reality using sensory techniques",
            wrongAnswers: ["Ask detailed questions about the trauma", "Leave them alone until it passes", "Restrain the patient for safety"],
            rationale: "Grounding techniques: name 5 things you see, 4 you hear, 3 you feel. Speak calmly, orient to present, ensure safety. Avoid retraumatizing by forcing details. Establish trust. Refer to trauma-focused therapy (EMDR, CPT).",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST-line medication class for generalized anxiety disorder?",
            answer: "SSRIs (selective serotonin reuptake inhibitors)",
            wrongAnswers: ["Benzodiazepines", "Barbiturates", "Typical antipsychotics"],
            rationale: "SSRIs (sertraline, escitalopram) are first-line for GAD - effective, fewer side effects, no dependence. Benzodiazepines for short-term use only due to dependence. Buspirone is non-addictive alternative. Takes 2-4 weeks for full effect.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient newly admitted to psychiatric unit is pacing and clenching fists. What is the PRIORITY?",
            answer: "Approach calmly, maintain safe distance, and use de-escalation techniques",
            wrongAnswers: ["Apply restraints immediately", "Ignore the behavior", "Gather multiple staff to confront patient"],
            rationale: "Agitation can escalate to violence. De-escalation: calm voice, open body language, safe distance, acknowledge feelings, offer choices, remove audience. Physical intervention last resort. PRN medications may help.",
            contentCategory: .mentalHealth,
            nclexCategory: .safeEffectiveCare,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient taking an SSRI wants to stop the medication abruptly. What should the nurse teach?",
            answer: "Stopping suddenly can cause discontinuation syndrome - taper under provider guidance",
            wrongAnswers: ["It's safe to stop any time", "Double the dose first then stop", "Switch to a benzodiazepine first"],
            rationale: "SSRI discontinuation syndrome: flu-like symptoms, dizziness, sensory disturbances (brain zaps), anxiety, insomnia. Gradual taper over weeks prevents symptoms. More common with short half-life SSRIs (paroxetine).",
            contentCategory: .mentalHealth,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIMARY characteristic of borderline personality disorder?",
            answer: "Unstable relationships, self-image, and emotions with fear of abandonment",
            wrongAnswers: ["Persistent suspicion of others", "Lack of empathy and disregard for others", "Social withdrawal and restricted emotions"],
            rationale: "BPD: pattern of unstable relationships, identity, emotions. Intense fear of abandonment, splitting (idealizing then devaluing), impulsivity, self-harm. Treatment: dialectical behavior therapy (DBT), no specific medication for BPD itself.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with OCD washes hands for hours daily. What initial approach is appropriate?",
            answer: "Allow reasonable time for rituals while building therapeutic relationship",
            wrongAnswers: ["Prevent all hand washing immediately", "Ignore the behavior completely", "Ridicule the behavior to show it's irrational"],
            rationale: "OCD rituals reduce anxiety; sudden prevention increases anxiety dramatically. Build trust first. ERP (exposure response prevention) therapy gradually reduces rituals. SSRIs help. Never ridicule - patient knows behavior is irrational but can't stop.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the difference between auditory hallucinations in schizophrenia vs delirium?",
            answer: "Schizophrenia: voices are often commanding/conversing; Delirium: usually simple sounds with visual hallucinations",
            wrongAnswers: ["There is no difference", "Delirium hallucinations are more complex", "Schizophrenia only has visual hallucinations"],
            rationale: "Schizophrenia: auditory hallucinations predominate, often voices discussing patient or giving commands, clear consciousness. Delirium: visual hallucinations more common, fluctuating consciousness, acute onset, reversible cause.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is in alcohol withdrawal. What is the most serious complication to monitor for?",
            answer: "Delirium tremens with seizures",
            wrongAnswers: ["Mild hand tremors", "Insomnia", "Loss of appetite"],
            rationale: "DTs occur 48-72 hours after last drink. Signs: severe agitation, hallucinations, tremors, fever, tachycardia, seizures. Can be fatal. Treatment: benzodiazepines (CIWA protocol), supportive care, thiamine. Monitor Q1-2H initially.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What nursing intervention is essential when a patient is placed in seclusion?",
            answer: "Check patient every 15 minutes, offer food/fluids, assess for removal criteria",
            wrongAnswers: ["Check every 4 hours", "Remove all monitoring", "Keep in seclusion until morning"],
            rationale: "Seclusion is restrictive - used only when less restrictive measures fail. Continuous observation or Q15 min checks. Regular assessment of physical/psychological status. Document behavior and rationale. Remove as soon as safe.",
            contentCategory: .mentalHealth,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient states 'The world would be better without me.' What is the BEST response?",
            answer: "Are you thinking about suicide?",
            wrongAnswers: ["Don't say that!", "Tell me about your hobbies", "That's not true, people care about you"],
            rationale: "Ask directly and nonjudgmentally about suicide. Asking does NOT plant the idea. Assess plan, means, intent, timeline. Take all statements seriously. Ensure safety, remove means, one-to-one observation, notify provider.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What symptom distinguishes serotonin syndrome from NMS?",
            answer: "Serotonin syndrome has hyperreflexia and clonus; NMS has muscle rigidity with normal/decreased reflexes",
            wrongAnswers: ["They are identical", "NMS has hyperreflexia", "Serotonin syndrome causes hypothermia"],
            rationale: "Both: hyperthermia, altered mental status. Serotonin syndrome: clonus, hyperreflexia, diarrhea, rapid onset. NMS: lead-pipe rigidity, normal/low reflexes, slower onset. Serotonin syndrome from serotonergic drugs, NMS from antipsychotics.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with depression has been on an SSRI for 3 days and reports no improvement. What should the nurse explain?",
            answer: "Antidepressants typically take 2-4 weeks to show full therapeutic effect",
            wrongAnswers: ["The medication isn't working", "Dose should be doubled immediately", "Add another antidepressant now"],
            rationale: "SSRIs take 2-4 weeks (some up to 6-8 weeks) for full effect. Early side effects often improve. Monitor for increased suicidal ideation initially (especially in youth). Continue medication as prescribed; premature stopping common.",
            contentCategory: .mentalHealth,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the therapeutic relationship boundary being crossed if a nurse shares personal problems with a patient?",
            answer: "Self-disclosure that shifts focus to nurse's needs",
            wrongAnswers: ["Appropriate empathy building", "Professional rapport development", "Required information sharing"],
            rationale: "Therapeutic relationship is patient-focused. Limited self-disclosure may be appropriate if it benefits patient. Sharing personal problems shifts focus inappropriately, burdens patient, blurs boundaries. Maintain professional boundaries.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 7: Additional Leadership/Management (40 cards)
        Flashcard(
            question: "Which task can the RN delegate to unlicensed assistive personnel (UAP)?",
            answer: "Taking vital signs on a stable patient",
            wrongAnswers: ["Initial patient assessment", "Patient teaching about new medications", "Interpreting ECG rhythms"],
            rationale: "Delegation uses the 5 Rights: Right task, circumstance, person, direction, supervision. UAPs can do routine tasks on stable patients: vitals, hygiene, feeding, ambulation. RN retains: assessment, teaching, evaluation, unstable patients.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "An RN receives report on 4 patients. Which should be assessed FIRST?",
            answer: "Patient with acute chest pain and diaphoresis",
            wrongAnswers: ["Patient requesting pain medication", "Patient due for scheduled insulin", "Patient awaiting discharge teaching"],
            rationale: "Prioritize using ABCs and Maslow: actual/potential life threats first. Chest pain with diaphoresis = possible MI - immediate threat. Others are important but not immediately life-threatening. Assess, then notify provider.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse witnesses another nurse taking controlled substances. What is the FIRST action?",
            answer: "Report to nurse manager or supervisor immediately",
            wrongAnswers: ["Confront the nurse directly", "Ignore it to avoid conflict", "Tell coworkers about it"],
            rationale: "Diversion is serious - patient safety and legal issue. Report to supervisor per facility policy. Don't confront alone or gossip. Documentation of observations important. Most states have peer assistance programs vs punitive action.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIMARY purpose of incident/occurrence reports?",
            answer: "To identify patterns and improve quality/safety",
            wrongAnswers: ["To punish staff members", "To be used in malpractice lawsuits", "To document in the patient's medical record"],
            rationale: "Incident reports are internal QI documents, not part of medical record. Purpose: identify trends, prevent recurrence, improve systems. Not punitive. Do document facts of incident in medical record, but don't reference the incident report.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient refuses a blood transfusion due to religious beliefs. What should the nurse do?",
            answer: "Respect the decision, document it, and inform the provider",
            wrongAnswers: ["Try to convince the patient", "Administer anyway if life-threatening", "Ignore religious concerns"],
            rationale: "Competent adults have right to refuse treatment, even life-saving. Ensure informed decision (understanding of consequences). Document thoroughly. Explore alternatives. Court order may be sought for minors or incompetent adults.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which patient can be safely assigned to an LPN/LVN?",
            answer: "Stable patient with chronic conditions requiring routine care",
            wrongAnswers: ["Patient with acute MI", "Newly admitted patient requiring full assessment", "Patient receiving IV push medications"],
            rationale: "LPN/LVN scope: stable patients, predictable outcomes, routine procedures, data collection (not initial assessment in most states). RN needed for: complex assessment, IV push meds, patient teaching, care planning, unstable patients.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse makes a medication error. What is the FIRST action?",
            answer: "Assess the patient for adverse effects",
            wrongAnswers: ["Complete incident report immediately", "Notify the family", "Wait to see if symptoms develop"],
            rationale: "Patient safety first - assess for harm. Then: notify provider, implement orders, document in chart, complete incident report, notify supervisor. Be honest with patient. Don't try to cover up. Follow facility policy.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What does SBAR communication stand for?",
            answer: "Situation, Background, Assessment, Recommendation",
            wrongAnswers: ["Signs, Blood pressure, Action, Response", "Symptoms, Behavior, Analysis, Report", "Status, Background, Analysis, Result"],
            rationale: "SBAR standardizes handoff communication. Situation: what's happening now. Background: relevant history. Assessment: what you think is the problem. Recommendation: what you think should be done. Reduces communication errors.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "In a disaster/mass casualty situation, which patient receives care LAST (triage)?",
            answer: "Patient with severe head injury, fixed dilated pupils, and agonal breathing",
            wrongAnswers: ["Patient with fractured femur", "Patient with moderate bleeding laceration", "Patient with anxiety attack"],
            rationale: "Mass casualty triage: save the most lives with limited resources. Black tag (expectant/deceased): injuries incompatible with survival. Red: immediate threat to life. Yellow: serious but can wait. Green: minor injuries. This patient is expectant.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the nurse's legal responsibility regarding informed consent?",
            answer: "Witness the patient's signature and ensure they had opportunity to ask questions",
            wrongAnswers: ["Explain all risks and benefits of the procedure", "Obtain consent from family members", "Determine if procedure is necessary"],
            rationale: "Provider is responsible for explaining procedure, risks, benefits, alternatives. Nurse witnesses signature, ensures patient had questions answered, verifies identity. Nurse can reinforce teaching and assess understanding.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient's family member requests all medical information. What should the nurse do?",
            answer: "Verify patient's authorization or healthcare proxy status before sharing",
            wrongAnswers: ["Share all information since they are family", "Refuse any information completely", "Only share positive information"],
            rationale: "HIPAA protects patient privacy. Only share with patient's written authorization or legal healthcare proxy. Verify identity. Patient determines who receives information. In emergencies, limited disclosure may be appropriate.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which situation demonstrates appropriate advocacy?",
            answer: "Questioning a medication order that seems inappropriate for the patient's condition",
            wrongAnswers: ["Following all orders without question", "Only advocating for compliant patients", "Agreeing with the family against medical advice"],
            rationale: "Patient advocacy: protecting patient rights and safety. Question orders that seem wrong, speak up about safety concerns, ensure informed consent, support patient decisions even if different from your own. Always act in patient's best interest.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is floated to an unfamiliar unit. What is the appropriate action?",
            answer: "Accept the assignment but request orientation and assignments within competency",
            wrongAnswers: ["Refuse to go under any circumstances", "Accept any assignment without question", "Call in sick to avoid the situation"],
            rationale: "Nurses can be floated but should work within competency. Request orientation, ask for experienced staff as resource, accept appropriate assignments, speak up about training needs. Document concerns. Don't abandon patients.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the MOST effective method to prevent healthcare-associated infections?",
            answer: "Hand hygiene before and after patient contact",
            wrongAnswers: ["Prophylactic antibiotics for all patients", "Keeping patients in isolation", "Environmental cleaning only"],
            rationale: "Hand hygiene is #1 prevention method. WHO 5 moments: before patient contact, before aseptic tasks, after body fluid exposure, after patient contact, after touching patient surroundings. Use soap/water or alcohol-based rub.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is on airborne precautions. What PPE is required to enter the room?",
            answer: "N95 respirator (must be fit-tested)",
            wrongAnswers: ["Standard surgical mask", "Face shield only", "Gloves only"],
            rationale: "Airborne precautions (TB, measles, varicella, COVID-19): N95 or higher respirator, negative pressure room, door closed. Fit-testing required. Patient wears surgical mask during transport. Droplet precautions use surgical mask.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the proper sequence for donning PPE?",
            answer: "Gown, mask/respirator, goggles/face shield, gloves",
            wrongAnswers: ["Gloves, gown, mask, goggles", "Mask, gloves, gown, goggles", "Any order is acceptable"],
            rationale: "Donning order: hand hygiene, gown (ties in back), mask/N95, eye protection, gloves (over gown cuffs). Doffing: gloves, hand hygiene, goggles, gown, hand hygiene, mask, hand hygiene. Sequence prevents contamination.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 8: Additional Safety & Fundamentals (41 cards)
        Flashcard(
            question: "A patient with a latex allergy is scheduled for surgery. What precaution is essential?",
            answer: "Schedule as first case of the day and ensure latex-free equipment",
            wrongAnswers: ["No special precautions needed", "Extra latex gloves available", "Pre-medicate with antibiotics"],
            rationale: "Latex allergy can cause anaphylaxis. First case avoids latex particles in air from prior surgeries. Use latex-free gloves, catheters, supplies. Also avoid cross-reactive foods (bananas, avocados, kiwis, chestnuts).",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the CORRECT angle for intramuscular injection in an adult?",
            answer: "90-degree angle",
            wrongAnswers: ["15-degree angle", "45-degree angle", "5-degree angle"],
            rationale: "IM: 90° angle into muscle. Subcutaneous: 45-90° depending on tissue. Intradermal: 5-15° almost parallel to skin. For IM, use appropriate needle length based on site and patient size. Aspirate not routinely recommended.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient has a nasogastric tube for decompression. What finding indicates proper placement?",
            answer: "pH of aspirate is 5 or less and X-ray confirmation",
            wrongAnswers: ["Auscultation of air bolus only", "Patient can speak normally", "Tube marking at 50 cm at nares"],
            rationale: "X-ray is gold standard for initial placement. pH <5 indicates gastric contents. Auscultation alone is unreliable. Check placement before each use. Feeding tubes require X-ray before initial feeding.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient receiving enteral feeding has residual volume of 450 mL. What should the nurse do?",
            answer: "Hold feeding and notify the provider per facility protocol",
            wrongAnswers: ["Continue feeding as scheduled", "Discard residual and restart feeding", "Increase feeding rate"],
            rationale: "High residual (usually >250-500 mL per protocol) indicates delayed gastric emptying - aspiration risk. Hold feeding, notify provider, assess for distension/nausea. May need prokinetic agent. Replace residual to avoid electrolyte loss.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate nursing action when discontinuing a peripheral IV?",
            answer: "Apply pressure for 2-3 minutes after removal, then apply bandage",
            wrongAnswers: ["Apply pressure while removing the catheter", "Leave site open to air", "Apply tourniquet above the site"],
            rationale: "Remove catheter at angle of insertion while applying gauze above site. Apply firm pressure for 2-3 minutes (longer if anticoagulated). Check catheter tip is intact. Document removal and site condition.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient's oxygen saturation is 88% on room air. What is the FIRST action?",
            answer: "Apply oxygen via nasal cannula and reassess",
            wrongAnswers: ["Call a rapid response immediately", "Wait and recheck in 30 minutes", "Document the finding only"],
            rationale: "SpO2 <90% requires intervention. Start O2, reassess, determine cause. For COPD patients, target 88-92%. If not improving or declining, escalate care. Also assess respiratory rate, work of breathing, LOC.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the preferred site for IM injection in infants?",
            answer: "Vastus lateralis (thigh)",
            wrongAnswers: ["Dorsogluteal", "Deltoid", "Ventrogluteal"],
            rationale: "Vastus lateralis preferred for infants/children <12 months - most developed muscle. Dorsogluteal avoided until walking well established (underdeveloped, sciatic nerve risk). Deltoid for older children/adults if small volume.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient needs to be repositioned but is too heavy for one nurse. What should be done?",
            answer: "Get assistance from another staff member and use proper lift equipment",
            wrongAnswers: ["Try alone using good body mechanics", "Leave patient in current position", "Ask family to help lift"],
            rationale: "Safe patient handling prevents nurse injury (leading cause of disability). Use lift equipment, slide sheets, get help. ANA recommends mechanical lifts. Know facility policy and patient's lift status. Don't rely on manual lifting alone.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the proper order for physical assessment?",
            answer: "Inspection, palpation, percussion, auscultation (except abdomen: auscultate before palpation)",
            wrongAnswers: ["Palpation, percussion, inspection, auscultation", "Auscultation first for all systems", "Any order is acceptable"],
            rationale: "Standard sequence: inspection (look), palpation (feel), percussion (tap), auscultation (listen). Abdomen exception: auscultate before palpation/percussion to avoid altering bowel sounds.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A fire alarm sounds on your unit. What is the FIRST action?",
            answer: "Rescue patients in immediate danger (RACE: Rescue, Alarm, Contain, Extinguish)",
            wrongAnswers: ["Locate fire extinguisher first", "Open all windows", "Continue current tasks"],
            rationale: "RACE: Rescue (remove from danger), Alarm (pull alarm, call 911), Contain (close doors), Extinguish (or evacuate). PASS for extinguisher: Pull pin, Aim at base, Squeeze handle, Sweep side to side.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is prescribed enoxaparin (Lovenox) subcutaneously. Where should it be administered?",
            answer: "Abdomen, at least 2 inches from umbilicus",
            wrongAnswers: ["Upper arm deltoid area", "Anterior thigh", "Dorsogluteal muscle"],
            rationale: "Low molecular weight heparin (enoxaparin) given in abdominal fat, rotating sites, 2 inches from umbilicus. Do NOT aspirate or rub. Leave air bubble in syringe. Don't expel before injecting.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the normal range for blood urea nitrogen (BUN)?",
            answer: "10-20 mg/dL",
            wrongAnswers: ["50-100 mg/dL", "0.6-1.2 mg/dL", "100-200 mg/dL"],
            rationale: "BUN: 10-20 mg/dL. Elevated in dehydration, high protein intake, GI bleed, renal failure. Creatinine (0.6-1.2) is more specific for kidney function. BUN:creatinine ratio helps differentiate causes.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient has a wound with serous drainage. What does this indicate?",
            answer: "Normal clear, watery drainage from plasma",
            wrongAnswers: ["Infection requiring antibiotics", "Hemorrhage from wound", "Necrotic tissue in wound"],
            rationale: "Serous: clear, watery, normal early healing. Sanguineous: bloody (early post-op). Serosanguineous: pink, mixed. Purulent: thick, yellow/green, indicates infection. Document amount, color, odor, wound appearance.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What nursing intervention helps prevent deep vein thrombosis in a bedridden patient?",
            answer: "Sequential compression devices and early mobilization when possible",
            wrongAnswers: ["Strict bedrest with leg elevation", "Apply warm compresses to legs", "Restrict fluid intake"],
            rationale: "DVT prevention: SCDs (mechanical compression), anticoagulation if ordered, early ambulation, leg exercises, adequate hydration, avoid leg crossing. Risk factors: immobility, surgery, cancer, pregnancy, clotting disorders.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient refuses morning medications. What should the nurse do?",
            answer: "Document refusal, assess reason, educate on importance, and notify provider",
            wrongAnswers: ["Force patient to take medications", "Hide medications in food", "Skip documentation"],
            rationale: "Patients have right to refuse. Assess understanding and reason (side effects, beliefs, cost). Educate on consequences. Document refusal, reason if given, education provided. Notify provider. Don't coerce or trick patient.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the BEST indicator of adequate fluid resuscitation?",
            answer: "Urine output of at least 30 mL/hour (0.5 mL/kg/hour)",
            wrongAnswers: ["Normal blood pressure only", "Absence of thirst", "Moist skin"],
            rationale: "Urine output reflects end-organ perfusion. Adequate: ≥0.5 mL/kg/hr (30 mL/hr in average adult). Also monitor: mental status, capillary refill, vital signs, skin turgor. Foley helps monitor critically ill patients.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which instruction is important for a patient using a metered-dose inhaler (MDI)?",
            answer: "Exhale completely, then inhale slowly and deeply while pressing canister",
            wrongAnswers: ["Inhale quickly and forcefully", "Hold breath for 1 second only", "Use without spacer even if prescribed"],
            rationale: "MDI technique: shake, exhale fully, seal lips around mouthpiece (or spacer), press canister while inhaling slowly, hold breath 10 seconds. Spacer improves delivery. Rinse mouth after steroid inhalers to prevent thrush.",
            contentCategory: .fundamentals,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is NPO for surgery. When should oral medications be given?",
            answer: "With sips of water as ordered by the provider",
            wrongAnswers: ["Skip all medications", "Give with full glass of water", "Give with food as usual"],
            rationale: "Essential medications (cardiac, BP, seizure) often continued with minimal water per provider order. Check preop orders specifically. Some medications held (anticoagulants, diabetic meds). Verify with provider and anesthesia.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate response when a patient questions their medication?",
            answer: "Thank them for being alert, verify the order, and explain the medication",
            wrongAnswers: ["Tell them to trust the nurse", "Give medication without discussion", "Become defensive"],
            rationale: "Patients are partners in safety. Verify the 6 rights, check order, explain medication. If error found, thank patient, follow procedure. Patient questioning is a safety barrier, not a challenge to authority.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A postoperative patient has absent bowel sounds. What should the nurse document?",
            answer: "Listen in all four quadrants for 2-5 minutes before documenting absent bowel sounds",
            wrongAnswers: ["Document immediately after 30 seconds", "Absent bowel sounds require no action", "This is always an emergency"],
            rationale: "Bowel sounds may be hypoactive after surgery. Listen systematically in all 4 quadrants for at least 2-5 minutes total before documenting absence. Report absent sounds with abdominal distension or other concerning symptoms.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the normal serum sodium range?",
            answer: "136-145 mEq/L",
            wrongAnswers: ["3.5-5.0 mEq/L", "98-106 mEq/L", "8.5-10.5 mg/dL"],
            rationale: "Sodium 136-145 mEq/L. Hyponatremia: <136 (confusion, seizures). Hypernatremia: >145 (thirst, altered LOC). Potassium: 3.5-5.0. Chloride: 98-106. Calcium: 8.5-10.5 mg/dL.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient develops hives and itching after starting an IV antibiotic. What is the FIRST action?",
            answer: "Stop the infusion immediately",
            wrongAnswers: ["Slow the infusion rate", "Administer diphenhydramine and continue", "Wait to see if symptoms worsen"],
            rationale: "Allergic reaction: stop medication immediately. Assess airway/breathing. Mild reaction: antihistamines. Severe/anaphylaxis: epinephrine, call rapid response. Keep IV access (change tubing). Document allergy in chart.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "When obtaining a blood pressure, the cuff bladder should cover what percentage of the arm circumference?",
            answer: "80% of the arm circumference",
            wrongAnswers: ["50% of the arm circumference", "100% of the arm circumference", "25% of the arm circumference"],
            rationale: "Cuff bladder should cover 80% of arm circumference (width should be 40%). Too small cuff = falsely high reading. Too large = falsely low. Proper positioning: arm at heart level, patient relaxed 5 minutes before.",
            contentCategory: .fundamentals,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a hearing impairment is being admitted. What is the BEST communication strategy?",
            answer: "Face the patient, speak clearly at normal volume, reduce background noise",
            wrongAnswers: ["Shout loudly", "Write everything down only", "Speak rapidly to finish faster"],
            rationale: "Face-to-face allows lip reading and visual cues. Speak clearly, normal pace and volume. Reduce background noise. Use written communication or interpreter as needed. Verify understanding. Don't cover mouth.",
            contentCategory: .fundamentals,
            nclexCategory: .psychosocial,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the therapeutic range for INR in a patient on warfarin for atrial fibrillation?",
            answer: "2.0-3.0",
            wrongAnswers: ["1.0-1.5", "3.5-4.5", "4.0-5.0"],
            rationale: "INR 2.0-3.0 for most indications (A-fib, DVT, PE). Mechanical heart valves: 2.5-3.5. Higher INR = increased bleeding risk. Monitor regularly. Vitamin K rich foods (leafy greens) should be consistent, not avoided.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A confused patient keeps trying to climb out of bed. What is the MOST appropriate intervention?",
            answer: "Use bed alarm and keep bed in lowest position with frequent checks",
            wrongAnswers: ["Apply bilateral wrist restraints", "Sedate the patient", "Place in a chair unsupervised"],
            rationale: "Least restrictive measures first: bed alarm, low bed, frequent checks, non-slip footwear, toileting schedule, address underlying cause (pain, infection). Restraints are last resort and require order. Sitter if available.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate nursing action for a patient with suspected opioid overdose?",
            answer: "Administer naloxone, support respirations, and call for help",
            wrongAnswers: ["Give more pain medication", "Wait for symptoms to resolve", "Administer flumazenil"],
            rationale: "Opioid overdose: respiratory depression, pinpoint pupils, unresponsiveness. Naloxone (Narcan) is antidote. Support airway/breathing. May need repeat doses (naloxone has shorter half-life than most opioids). Monitor for recurrence.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is receiving a continuous heparin infusion. What is the MOST important lab to monitor?",
            answer: "Activated partial thromboplastin time (aPTT)",
            wrongAnswers: ["Prothrombin time (PT)", "INR", "Platelet count only"],
            rationale: "aPTT monitors heparin therapy. Therapeutic: 1.5-2.5 times control. PT/INR monitors warfarin. Also monitor platelet count for heparin-induced thrombocytopenia (HIT). Signs of bleeding: bruising, blood in stool/urine.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What action is essential when administering blood products?",
            answer: "Verify patient identity with two identifiers and have second nurse verify blood product",
            wrongAnswers: ["One nurse verification is sufficient", "Check ID once at the blood bank", "Start infusion at maximum rate"],
            rationale: "Two nurses must verify: patient ID (2 identifiers), blood type, Rh factor, expiration, patient name on blood matches armband. Check vital signs before, 15 min into transfusion, and after. Transfusion reactions are preventable.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST sign of infection in an elderly patient?",
            answer: "Acute confusion or change in mental status",
            wrongAnswers: ["High fever", "Elevated white blood cell count", "Localized pain and swelling"],
            rationale: "Elderly often have atypical infection presentation: may not have fever, WBC may be normal. Acute confusion/delirium is often first sign. Other subtle signs: decreased appetite, functional decline, falls. High suspicion needed.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with left-sided heart failure will exhibit which symptom?",
            answer: "Crackles in lungs and dyspnea",
            wrongAnswers: ["Peripheral edema only", "Jugular vein distension only", "Hepatomegaly"],
            rationale: "Left-sided failure: blood backs up into lungs. Symptoms: pulmonary congestion (crackles), dyspnea, orthopnea, cough with frothy sputum. Right-sided failure: systemic congestion (edema, JVD, hepatomegaly). Often occur together.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the correct procedure for obtaining a clean-catch urine specimen?",
            answer: "Clean the urethral area, start voiding into toilet, then collect midstream sample",
            wrongAnswers: ["Collect first morning void without cleaning", "Collect the first part of urine stream", "No special procedure needed"],
            rationale: "Clean-catch midstream reduces contamination. Clean urethral meatus front to back (females) or in circular motion (males). Start voiding, then collect middle portion. Cap without touching inside. Transport promptly or refrigerate.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient has a new order for sliding scale insulin. What must the nurse do before administering?",
            answer: "Check current blood glucose level",
            wrongAnswers: ["Give fixed dose regardless of glucose", "Wait until after meals only", "Check hemoglobin A1C first"],
            rationale: "Sliding scale: insulin dose based on current blood glucose. Check glucose per order (before meals, at bedtime, or specific times). Document glucose and insulin given. Monitor for hypoglycemia. Know onset/peak/duration of insulin type.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the MOST reliable indicator of fluid balance in a hospitalized patient?",
            answer: "Daily weight",
            wrongAnswers: ["Intake and output estimation", "Skin turgor", "Patient's report of thirst"],
            rationale: "Daily weight is most accurate - 1 kg (2.2 lbs) = 1 liter fluid. Weigh same time daily, same scale, similar clothing. I&O helpful but often inaccurate. Combine with assessment: edema, lung sounds, JVD, urine output.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with pneumonia is placed on droplet precautions. What PPE is needed?",
            answer: "Surgical mask when within 3 feet of patient",
            wrongAnswers: ["N95 respirator", "No mask needed", "Face shield only"],
            rationale: "Droplet precautions: surgical mask within 6 feet (some say 3 feet), private room (or cohort), patient wears mask during transport. Used for: influenza, pertussis, bacterial meningitis, pneumonia. Not airborne - regular mask sufficient.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the purpose of an incentive spirometer?",
            answer: "To promote deep breathing and prevent atelectasis",
            wrongAnswers: ["To measure oxygen saturation", "To administer bronchodilators", "To suction secretions"],
            rationale: "Incentive spirometry prevents postoperative pulmonary complications. Technique: exhale, seal lips, inhale slowly and deeply, hold 3-5 seconds. Use 10 times/hour while awake. Documents lung expansion with visual feedback.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a wound vac (negative pressure wound therapy) has an alarm sounding. What is the FIRST action?",
            answer: "Check for leaks in the dressing seal",
            wrongAnswers: ["Turn off the device", "Remove the dressing completely", "Increase the suction pressure"],
            rationale: "Alarm usually indicates loss of seal/suction. Check: dressing seal (most common), tubing connections, canister placement, power. Press around dressing edges to reseal. If unable to resolve, notify wound care team.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Select ALL factors that increase fall risk in hospitalized patients:",
            answer: "Medications causing drowsiness, History of falls, Urinary urgency, Age over 65",
            wrongAnswers: ["None of these factors increase fall risk"],
            rationale: "Fall risk factors: age >65, history of falls, altered mental status, medications (sedatives, antihypertensives, opioids), mobility impairment, urinary frequency, vision problems, environmental hazards. Use validated fall risk assessment tool.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .sata,
            isPremium: true
        ),
        Flashcard(
            question: "What information MUST be included in a proper hand-off report?",
            answer: "Patient identification, current status, recent changes, pending tasks, and safety concerns",
            wrongAnswers: ["Only the patient's diagnosis", "Personal opinions about the patient", "Information from three shifts ago"],
            rationale: "Hand-off includes: patient identifiers, diagnosis, current status/VS, changes in condition, medications/IVs, labs pending, pending tests/procedures, code status, safety concerns, family updates. Use SBAR format. Allow time for questions.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient's PCA pump is alarming for 'maximum dose reached.' What does this mean?",
            answer: "Patient has received the maximum allowed doses in the set time period",
            wrongAnswers: ["The pump is malfunctioning", "Patient needs a higher dose programmed", "Medication reservoir is empty"],
            rationale: "PCA has lockout interval and hourly maximum for safety. Alarm means patient reached limit - protects against overdose. Assess pain level, may need provider to adjust settings. Never disable safety features. Document pain management.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 9: More Med-Surg (40 cards)
        Flashcard(
            question: "A patient with chronic kidney disease has a potassium level of 6.8 mEq/L. What ECG change is expected?",
            answer: "Tall, peaked T waves and widened QRS complex",
            wrongAnswers: ["Flattened T waves", "Prolonged QT interval", "ST elevation"],
            rationale: "Hyperkalemia ECG progression: peaked T waves → prolonged PR → widened QRS → sine wave → V-fib/asystole. Treatment: calcium gluconate (cardiac protection), insulin+glucose, kayexalate, dialysis. Life-threatening above 6.5 mEq/L.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate nursing intervention for a patient experiencing autonomic dysreflexia?",
            answer: "Sit patient up, identify and remove the triggering stimulus (often bladder distension)",
            wrongAnswers: ["Lay patient flat", "Administer stimulants", "Apply cold compresses"],
            rationale: "Autonomic dysreflexia occurs in spinal cord injury T6 or above. Triggered by noxious stimuli below injury (full bladder, constipation, tight clothing). Sit up (lowers BP), remove cause, may need antihypertensives. Can be life-threatening.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with acute respiratory distress syndrome (ARDS) is on mechanical ventilation. What is the target tidal volume?",
            answer: "6 mL/kg of ideal body weight (low tidal volume ventilation)",
            wrongAnswers: ["12 mL/kg of ideal body weight", "15 mL/kg of actual weight", "Any volume that maintains SpO2"],
            rationale: "ARDS management: low tidal volumes (6 mL/kg IBW) prevent ventilator-induced lung injury. Higher PEEP, prone positioning may help. Target plateau pressure <30 cm H2O. Accept permissive hypercapnia if needed.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What finding indicates a positive Homans' sign?",
            answer: "Calf pain upon dorsiflexion of the foot",
            wrongAnswers: ["Pain with knee extension", "Numbness in the foot", "Swelling of the ankle only"],
            rationale: "Homans' sign historically associated with DVT, but unreliable (low sensitivity/specificity). Do not rely on it alone. Better indicators: unilateral leg swelling, warmth, redness, palpable cord. Confirm with Doppler ultrasound.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with liver cirrhosis develops hepatorenal syndrome. What characterizes this condition?",
            answer: "Renal failure secondary to severe liver disease without primary kidney pathology",
            wrongAnswers: ["Primary kidney disease causing liver failure", "Gallstone obstruction", "Urinary tract infection"],
            rationale: "Hepatorenal syndrome: functional renal failure from severe liver disease. Kidneys are structurally normal but fail due to altered hemodynamics. Poor prognosis. Treatment: liver transplant, vasoconstrictors, albumin. Avoid nephrotoxins.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIORITY assessment for a patient with suspected stroke?",
            answer: "Time of symptom onset (last known well time)",
            wrongAnswers: ["Family history", "Medication allergies first", "Insurance information"],
            rationale: "Time is brain! tPA can be given within 4.5 hours of symptom onset. Document exact time symptoms started or when patient was last seen normal. FAST: Face drooping, Arm weakness, Speech difficulty, Time to call 911.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with ulcerative colitis is at risk for which serious complication?",
            answer: "Toxic megacolon",
            wrongAnswers: ["Small bowel obstruction", "Gallstones", "Pancreatitis"],
            rationale: "Toxic megacolon: severe colonic dilation with systemic toxicity. Signs: abdominal distension, fever, tachycardia, hypotension. Can perforate. Treatment: NPO, NG decompression, IV steroids, antibiotics, may need colectomy.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the hallmark symptom of Parkinson's disease?",
            answer: "Resting tremor that decreases with purposeful movement",
            wrongAnswers: ["Tremor that worsens with movement", "Sudden paralysis", "Memory loss as first symptom"],
            rationale: "Parkinson's cardinal signs: resting tremor (pill-rolling), rigidity (cogwheel), bradykinesia (slow movement), postural instability. Tremor decreases with intentional movement. Caused by dopamine deficiency in substantia nigra.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is diagnosed with acute angle-closure glaucoma. What is the PRIORITY intervention?",
            answer: "Administer medications to reduce intraocular pressure immediately",
            wrongAnswers: ["Schedule surgery for next week", "Apply warm compresses", "Dilate the pupil"],
            rationale: "Acute angle-closure is emergency - can cause blindness within hours. Symptoms: severe eye pain, halos around lights, nausea/vomiting, mid-dilated pupil. Treatment: IV mannitol, pilocarpine (constricts pupil), laser iridotomy. Never dilate!",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the difference between Crohn's disease and ulcerative colitis?",
            answer: "Crohn's can affect any GI area and is transmural; UC affects only colon and is mucosal",
            wrongAnswers: ["They are the same disease", "UC affects the entire GI tract", "Crohn's only affects the colon"],
            rationale: "Crohn's: skip lesions, mouth to anus, transmural (fistulas), cobblestone appearance, right lower quadrant pain. UC: continuous, colon only, mucosal, bloody diarrhea, left lower quadrant pain. Both are inflammatory bowel diseases.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with hypothyroidism should be monitored for which cardiovascular complication?",
            answer: "Bradycardia and hyperlipidemia",
            wrongAnswers: ["Tachycardia and hypotension", "Atrial fibrillation", "Hypertensive crisis"],
            rationale: "Hypothyroidism slows metabolism: bradycardia, hyperlipidemia, weight gain, fatigue, cold intolerance, constipation, dry skin, hair loss. Myxedema coma is severe complication. Treatment: levothyroxine, start low and go slow in elderly.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What assessment finding is expected in a patient with right-sided heart failure?",
            answer: "Peripheral edema, hepatomegaly, and jugular vein distension",
            wrongAnswers: ["Pulmonary crackles only", "Frothy sputum", "Orthopnea without edema"],
            rationale: "Right-sided failure: blood backs up into systemic circulation. Signs: JVD, peripheral edema, hepatomegaly, ascites, weight gain. Often caused by left-sided failure or pulmonary hypertension. Compare to left-sided: pulmonary congestion.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with pheochromocytoma should avoid which medication?",
            answer: "Beta-blockers (before alpha-blockade is established)",
            wrongAnswers: ["ACE inhibitors", "Calcium channel blockers", "Diuretics"],
            rationale: "Pheochromocytoma: catecholamine-secreting tumor causing severe hypertension. Beta-blockers alone cause unopposed alpha stimulation → hypertensive crisis. Must give alpha-blocker (phenoxybenzamine) first, then add beta-blocker if needed.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST sign of acute kidney injury?",
            answer: "Decreased urine output (oliguria)",
            wrongAnswers: ["Elevated creatinine", "Uremic frost", "Asterixis"],
            rationale: "Oliguria (<400 mL/day or <0.5 mL/kg/hr) is often first sign of AKI. Then see rising BUN/creatinine, electrolyte imbalances. Uremic symptoms (frost, confusion, pericarditis) are late signs. Identify cause: prerenal, intrarenal, postrenal.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with multiple myeloma should be monitored for which complication?",
            answer: "Hypercalcemia and pathologic fractures",
            wrongAnswers: ["Hypocalcemia", "Iron deficiency anemia", "Hypertension"],
            rationale: "Multiple myeloma: plasma cell cancer destroying bone → hypercalcemia, bone pain, pathologic fractures. Also causes: renal failure, anemia, recurrent infections. CRAB: Calcium elevation, Renal insufficiency, Anemia, Bone lesions.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the treatment for malignant hyperthermia?",
            answer: "Stop triggering agent, administer dantrolene, and cool the patient",
            wrongAnswers: ["Administer more anesthesia", "Warm the patient", "Give muscle relaxants"],
            rationale: "Malignant hyperthermia: genetic reaction to volatile anesthetics/succinylcholine. Causes: extreme hyperthermia, muscle rigidity, tachycardia, hypercarbia. Treatment: stop trigger, IV dantrolene (blocks calcium), cool aggressively, treat hyperkalemia.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with Cushing's syndrome will exhibit which classic features?",
            answer: "Moon face, buffalo hump, central obesity, and purple striae",
            wrongAnswers: ["Weight loss and hypotension", "Bronze skin pigmentation", "Heat intolerance"],
            rationale: "Cushing's: excess cortisol. Features: moon face, buffalo hump, truncal obesity, thin extremities, purple striae, hirsutism, hyperglycemia, hypertension, osteoporosis, easy bruising. Causes: exogenous steroids, pituitary adenoma, adrenal tumor.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the cardinal sign of peritonitis?",
            answer: "Rigid, board-like abdomen with rebound tenderness",
            wrongAnswers: ["Soft, non-tender abdomen", "Hyperactive bowel sounds", "Diarrhea"],
            rationale: "Peritonitis: inflammation of peritoneum (infection, perforation, trauma). Signs: severe pain, rigid abdomen, guarding, rebound tenderness, absent bowel sounds, fever, tachycardia. Surgical emergency. NPO, IV fluids, antibiotics, surgery.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with syndrome of inappropriate antidiuretic hormone (SIADH) should have which fluid restriction?",
            answer: "800-1000 mL/day",
            wrongAnswers: ["3000 mL/day", "No fluid restriction needed", "NPO status"],
            rationale: "SIADH: excess ADH causes water retention and dilutional hyponatremia. Treatment: fluid restriction (800-1000 mL/day), treat underlying cause, hypertonic saline for severe hyponatremia (slowly to prevent osmotic demyelination). Monitor sodium closely.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the MOST important dietary modification for a patient with ascites?",
            answer: "Sodium restriction (2000 mg/day or less)",
            wrongAnswers: ["Protein restriction", "Increased sodium intake", "Fluid loading"],
            rationale: "Ascites (fluid in peritoneum) in liver disease managed with: sodium restriction (1-2 g/day), fluid restriction if hyponatremic, diuretics (spironolactone + furosemide), paracentesis for tense ascites. Monitor weight, abdominal girth daily.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 10: More Pharmacology (40 cards)
        Flashcard(
            question: "A patient on methotrexate should take which supplement to reduce toxicity?",
            answer: "Folic acid",
            wrongAnswers: ["Vitamin D", "Iron", "Calcium"],
            rationale: "Methotrexate inhibits folate metabolism. Folic acid supplementation reduces side effects (stomatitis, GI upset, bone marrow suppression) without decreasing efficacy. Monitor CBC, liver function. Avoid alcohol, live vaccines, NSAIDs.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which medication requires monitoring for ototoxicity and nephrotoxicity?",
            answer: "Aminoglycosides (gentamicin, tobramycin)",
            wrongAnswers: ["Penicillins", "Cephalosporins", "Macrolides"],
            rationale: "Aminoglycosides: potent antibiotics for gram-negative infections. Toxicities: nephrotoxicity (reversible), ototoxicity (irreversible - hearing loss, vestibular damage). Monitor: peak/trough levels, renal function, hearing. Ensure adequate hydration.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the mechanism of action of warfarin?",
            answer: "Inhibits vitamin K-dependent clotting factor synthesis",
            wrongAnswers: ["Directly inhibits thrombin", "Inhibits platelet aggregation", "Breaks down existing clots"],
            rationale: "Warfarin blocks vitamin K epoxide reductase, preventing synthesis of factors II, VII, IX, X. Takes 3-5 days for full effect (existing factors must deplete). Monitored by PT/INR. Antidote: vitamin K, FFP for severe bleeding.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient taking spironolactone should avoid which food?",
            answer: "Foods high in potassium (bananas, oranges, salt substitutes)",
            wrongAnswers: ["Dairy products", "Leafy green vegetables", "Whole grains"],
            rationale: "Spironolactone is potassium-sparing diuretic - blocks aldosterone. Hyperkalemia risk. Avoid: potassium supplements, salt substitutes (KCl), high-potassium foods. Monitor potassium levels. Side effects: gynecomastia, menstrual irregularities.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the BLACK BOX warning for fluoroquinolones (ciprofloxacin)?",
            answer: "Tendinitis and tendon rupture, especially Achilles tendon",
            wrongAnswers: ["Liver failure", "Heart attack", "Kidney stones"],
            rationale: "Fluoroquinolones (-floxacin): risk of tendinitis/rupture, peripheral neuropathy, CNS effects, aortic aneurysm. Higher risk: >60 years, steroids, kidney/heart/lung transplant. Stop immediately if tendon pain occurs. Avoid in myasthenia gravis.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient on isoniazid (INH) for tuberculosis should take which supplement?",
            answer: "Vitamin B6 (pyridoxine)",
            wrongAnswers: ["Vitamin C", "Vitamin A", "Vitamin E"],
            rationale: "INH causes peripheral neuropathy by depleting pyridoxine. Supplement vitamin B6 (25-50 mg/day) especially in high-risk patients: malnourished, alcoholics, diabetics, HIV, pregnant. Also monitor for hepatotoxicity - avoid alcohol.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the antidote for organophosphate poisoning?",
            answer: "Atropine and pralidoxime",
            wrongAnswers: ["Naloxone", "Flumazenil", "N-acetylcysteine"],
            rationale: "Organophosphates (insecticides, nerve agents) inhibit acetylcholinesterase → cholinergic crisis. SLUDGE/BBB: Salivation, Lacrimation, Urination, Defecation, GI distress, Emesis, Bradycardia, Bronchospasm, Bronchorrhea. Atropine blocks effects; pralidoxime reactivates enzyme.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient on phenytoin has a serum level of 25 mcg/mL. What does this indicate?",
            answer: "Toxic level - therapeutic range is 10-20 mcg/mL",
            wrongAnswers: ["Therapeutic level", "Subtherapeutic level", "Normal finding"],
            rationale: "Phenytoin therapeutic: 10-20 mcg/mL. Signs of toxicity: nystagmus (first sign), ataxia, slurred speech, lethargy, confusion. Severe: seizures, coma. Zero-order kinetics - small dose increases cause large level changes. Monitor levels closely.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which medication class is contraindicated in patients with asthma?",
            answer: "Non-selective beta-blockers (propranolol)",
            wrongAnswers: ["ACE inhibitors", "Calcium channel blockers", "Thiazide diuretics"],
            rationale: "Non-selective beta-blockers block both beta-1 (heart) and beta-2 (lungs) receptors. Beta-2 blockade causes bronchoconstriction - dangerous in asthma/COPD. Cardioselective (beta-1 selective) like metoprolol safer but still use caution.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the loading dose strategy for digoxin called?",
            answer: "Digitalization",
            wrongAnswers: ["Titration", "Tapering", "Bolusing"],
            rationale: "Digitalization: giving loading doses to reach therapeutic level faster. Can be rapid (IV over 24 hours) or slow (oral over several days). Monitor for toxicity during loading. Maintenance dose follows. Check potassium - hypokalemia increases toxicity.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient starting an MAOI must wait how long before starting an SSRI?",
            answer: "At least 14 days (2 weeks)",
            wrongAnswers: ["24 hours", "3 days", "No waiting period needed"],
            rationale: "MAOI + serotonergic drugs = serotonin syndrome risk. MAOIs need 14-day washout (irreversibly inhibit MAO). When switching from SSRI to MAOI, also wait (5 weeks for fluoxetine due to long half-life). Serotonin syndrome is potentially fatal.",
            contentCategory: .pharmacology,
            nclexCategory: .safeEffectiveCare,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What effect do NSAIDs have on lithium levels?",
            answer: "NSAIDs increase lithium levels by decreasing renal excretion",
            wrongAnswers: ["NSAIDs decrease lithium levels", "No interaction exists", "NSAIDs are safe with lithium"],
            rationale: "NSAIDs reduce renal blood flow and lithium excretion → increased lithium levels and toxicity risk. Also avoid: ACE inhibitors, thiazide diuretics, dehydration. Acetaminophen is safer alternative for pain. Monitor lithium levels closely.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient on amiodarone should be monitored for which organ toxicities?",
            answer: "Pulmonary fibrosis, thyroid dysfunction, hepatotoxicity, and corneal deposits",
            wrongAnswers: ["Only cardiac effects", "Kidney damage only", "No monitoring needed"],
            rationale: "Amiodarone has many serious toxicities. Pulmonary: fibrosis (check PFTs). Thyroid: hypo- or hyperthyroidism (check TSH). Liver: hepatotoxicity (check LFTs). Eyes: corneal microdeposits, optic neuropathy. Skin: photosensitivity, blue-gray discoloration.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the reversal agent for dabigatran (Pradaxa)?",
            answer: "Idarucizumab (Praxbind)",
            wrongAnswers: ["Vitamin K", "Protamine sulfate", "Fresh frozen plasma"],
            rationale: "Dabigatran is direct thrombin inhibitor. Idarucizumab specifically reverses it. For rivaroxaban/apixaban (factor Xa inhibitors): andexanet alfa. Traditional anticoagulants: warfarin → vitamin K; heparin → protamine sulfate.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which antihypertensive is safe during pregnancy?",
            answer: "Methyldopa or labetalol",
            wrongAnswers: ["ACE inhibitors", "ARBs", "Direct renin inhibitors"],
            rationale: "Methyldopa and labetalol are preferred for hypertension in pregnancy. ACE inhibitors, ARBs, direct renin inhibitors are contraindicated (cause fetal renal damage, oligohydramnios, death). Hydralazine also acceptable for acute treatment.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient on carbamazepine needs monitoring of which lab values?",
            answer: "Complete blood count and liver function tests",
            wrongAnswers: ["Renal function only", "Lipid panel", "Blood glucose only"],
            rationale: "Carbamazepine can cause aplastic anemia, agranulocytosis, hepatotoxicity, SIADH. Monitor: CBC (watch WBC, platelets), LFTs, sodium levels. Also causes many drug interactions (CYP inducer). Steven-Johnson syndrome risk with HLA-B*1502 gene.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the mechanism of action of allopurinol?",
            answer: "Inhibits xanthine oxidase, reducing uric acid production",
            wrongAnswers: ["Increases uric acid excretion", "Dissolves existing crystals", "Anti-inflammatory action"],
            rationale: "Allopurinol prevents uric acid formation (prophylaxis for gout). Not for acute attacks - may worsen flare. Start low dose, gradually increase. Drink plenty of fluids. For acute gout: NSAIDs, colchicine, or corticosteroids.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient taking statins reports muscle pain. What should be assessed?",
            answer: "Creatine kinase (CK) levels for rhabdomyolysis",
            wrongAnswers: ["Liver enzymes only", "Complete blood count", "Blood glucose"],
            rationale: "Statins can cause myopathy → rhabdomyolysis (rare but serious). Symptoms: muscle pain, weakness, dark urine. Check CK level - if markedly elevated, discontinue statin. Risk increases with high doses, interacting drugs, hypothyroidism.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate time to administer NPH insulin?",
            answer: "30 minutes before meals (intermediate-acting insulin)",
            wrongAnswers: ["Only at bedtime", "Immediately after meals", "Once weekly"],
            rationale: "NPH: intermediate-acting, cloudy appearance. Onset 1-2 hours, peak 4-12 hours, duration 18-24 hours. Usually given twice daily. Roll vial gently to mix (don't shake). Draw regular insulin first when mixing (clear before cloudy).",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient on prednisone long-term should be monitored for which complications?",
            answer: "Hyperglycemia, osteoporosis, adrenal suppression, and infection",
            wrongAnswers: ["Hypoglycemia only", "Increased bone density", "Enhanced immunity"],
            rationale: "Long-term corticosteroids: glucose intolerance, osteoporosis, cataracts, thin skin, poor wound healing, immunosuppression, adrenal suppression, mood changes, cushingoid features. Taper slowly after long-term use. Consider bone protection (calcium, vitamin D, bisphosphonate).",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 11: More Pediatrics (40 cards)
        Flashcard(
            question: "A child with cystic fibrosis should have which dietary modification?",
            answer: "High-calorie, high-protein, high-fat diet with pancreatic enzyme supplements",
            wrongAnswers: ["Low-fat diet", "Sodium restriction", "Protein restriction"],
            rationale: "CF causes malabsorption due to pancreatic insufficiency. Need increased calories (120-150% normal), high protein, liberal fat, extra salt (lost in sweat). Pancreatic enzymes (Creon) taken with all meals/snacks. Fat-soluble vitamin supplements (ADEK).",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What immunization is given to prevent Haemophilus influenzae type b meningitis?",
            answer: "Hib vaccine",
            wrongAnswers: ["MMR vaccine", "Hepatitis B vaccine", "Varicella vaccine"],
            rationale: "Hib vaccine dramatically reduced bacterial meningitis in children. Given at 2, 4, 6, and 12-15 months. Before vaccine, Hib was leading cause of bacterial meningitis in children <5 years. Now rare in vaccinated populations.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST sign of tetralogy of Fallot in an infant?",
            answer: "Cyanosis, especially during crying or feeding (tet spells)",
            wrongAnswers: ["Hypertension", "Bradycardia", "Excessive weight gain"],
            rationale: "Tetralogy of Fallot: VSD, pulmonary stenosis, overriding aorta, right ventricular hypertrophy. Tet spells: sudden cyanosis during crying/feeding. Position knee-to-chest to increase systemic resistance. Surgical repair needed.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with rheumatic fever should be monitored for which cardiac complication?",
            answer: "Mitral valve damage (stenosis or regurgitation)",
            wrongAnswers: ["Atrial septal defect", "Coarctation of aorta", "Tetralogy of Fallot"],
            rationale: "Rheumatic fever follows Group A strep infection. Can cause pancarditis affecting all heart layers. Mitral valve most commonly affected, then aortic. Diagnosed by Jones criteria. Prevention: treat strep throat with antibiotics. Long-term prophylaxis.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIORITY nursing action for a child with suspected lead poisoning?",
            answer: "Remove the child from the source of lead exposure",
            wrongAnswers: ["Administer chelation therapy immediately", "Induce vomiting", "Apply topical medication"],
            rationale: "First priority: identify and remove lead source (old paint, contaminated soil, imported toys). Then test blood lead level. Chelation therapy (EDTA, succimer) for high levels. Assess developmental effects. Screen siblings. Notify public health.",
            contentCategory: .pediatrics,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A neonate has a positive Ortolani maneuver. What does this indicate?",
            answer: "Developmental dysplasia of the hip (DDH)",
            wrongAnswers: ["Normal hip examination", "Clubfoot", "Spina bifida"],
            rationale: "Ortolani: thighs abducted, femur lifted - click/clunk as femoral head enters acetabulum indicates DDH. Barlow: push posteriorly, hip dislocates. Treatment: Pavlik harness for infants <6 months. Risk factors: breech, family history, female.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the treatment for a child with moderate dehydration?",
            answer: "Oral rehydration therapy (ORT) with frequent small amounts",
            wrongAnswers: ["IV fluids only", "NPO for 24 hours", "Regular formula in large amounts"],
            rationale: "Mild-moderate dehydration: oral rehydration solution (Pedialyte) - small frequent amounts (5-10 mL every 5 minutes). Severe dehydration or inability to drink: IV fluids. ORS replaces water, glucose, and electrolytes. Continue breast/formula feeding.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "At what age should a child receive the first dose of DTaP vaccine?",
            answer: "2 months",
            wrongAnswers: ["Birth", "6 months", "12 months"],
            rationale: "DTaP series: 2, 4, 6, 15-18 months, 4-6 years. Protects against diphtheria, tetanus, pertussis. Tdap booster at age 11-12 and during pregnancy. Side effects: local reactions, fever, fussiness. Contraindicated if severe reaction to previous dose.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with hemophilia falls and bumps their head. What should the nurse assess?",
            answer: "Signs of intracranial bleeding (headache, vomiting, altered LOC)",
            wrongAnswers: ["External bleeding only", "Skin rash", "Abdominal pain"],
            rationale: "Hemophilia: deficiency of clotting factors (VIII or IX). Head trauma can cause life-threatening intracranial hemorrhage. Signs: headache, vomiting, irritability, lethargy, seizures. May need immediate factor replacement. Any bleeding needs prompt treatment.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the normal respiratory rate for a newborn?",
            answer: "30-60 breaths per minute",
            wrongAnswers: ["12-20 breaths per minute", "80-100 breaths per minute", "20-30 breaths per minute"],
            rationale: "Newborn RR: 30-60. Infant: 30-40. Toddler: 24-40. Preschool: 22-34. School-age: 18-30. Adolescent: 12-20. Tachypnea in newborn: >60 (consider RDS, TTN, infection). Count for full minute. Periodic breathing normal, apnea >20 sec is not.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with Type 1 diabetes is sweaty, shaky, and confused. What is the PRIORITY action?",
            answer: "Give fast-acting glucose (juice, glucose tabs) immediately",
            wrongAnswers: ["Administer insulin", "Call for blood glucose monitor first", "Wait for parent to arrive"],
            rationale: "Signs indicate hypoglycemia - treat immediately, don't wait for glucose check. Give 15g fast-acting carbs. Recheck in 15 minutes. If unconscious: glucagon. Rule of 15: 15g carbs, 15 min wait, recheck. Then give protein/complex carb snack.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What developmental milestone should a 6-month-old demonstrate?",
            answer: "Sits with support, rolls over, transfers objects between hands",
            wrongAnswers: ["Walks independently", "Speaks in sentences", "Toilet trained"],
            rationale: "6 months: sits with support, rolls both ways, reaches and grasps, transfers objects, babbles, responds to name, shows stranger anxiety beginning. Red flags: no reaching, doesn't respond to sounds, no babbling, poor head control.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child is diagnosed with phenylketonuria (PKU). What dietary restriction is required?",
            answer: "Limit phenylalanine intake (avoid high-protein foods, aspartame)",
            wrongAnswers: ["Limit fat intake", "Avoid all carbohydrates", "Sodium restriction"],
            rationale: "PKU: cannot metabolize phenylalanine → brain damage if untreated. Diet: restrict phenylalanine (found in protein foods, aspartame). Special PKU formula provides other amino acids. Lifelong dietary management. Newborn screening detects PKU.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the BEST position for a child with increased intracranial pressure?",
            answer: "Head of bed elevated 30 degrees, head midline",
            wrongAnswers: ["Flat supine", "Trendelenburg", "Prone with head turned"],
            rationale: "Same as adults: HOB 30°, head midline promotes venous drainage, reduces ICP. Avoid neck flexion, hip flexion >90°, valsalva maneuvers. Monitor: LOC (most sensitive indicator), pupil changes, vital signs (Cushing's triad is late sign).",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A newborn has café-au-lait spots. What condition might this indicate?",
            answer: "Neurofibromatosis (if 6 or more spots)",
            wrongAnswers: ["Normal finding requiring no follow-up", "Leukemia", "Vitamin deficiency"],
            rationale: "Café-au-lait spots: light brown macules. 1-2 spots common and benign. 6+ spots larger than 5mm suggests neurofibromatosis type 1. Also look for: axillary freckling, neurofibromas, optic gliomas. Genetic referral if criteria met.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the treatment for bronchiolitis caused by RSV?",
            answer: "Supportive care: oxygen, hydration, suctioning",
            wrongAnswers: ["Antibiotics", "Bronchodilators routinely", "Steroids"],
            rationale: "RSV bronchiolitis is viral - antibiotics ineffective. Supportive care: oxygen for hypoxia, IV/NG fluids if unable to feed, nasal suctioning, elevated HOB. Ribavirin for severe cases or high-risk children. Palivizumab (Synagis) for prophylaxis in high-risk infants.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with Wilms' tumor should have which precaution?",
            answer: "Do not palpate the abdomen to prevent tumor rupture/spread",
            wrongAnswers: ["Perform abdominal assessment frequently", "Apply pressure to abdomen", "No special precautions needed"],
            rationale: "Wilms' tumor (nephroblastoma): kidney tumor in children 2-5 years. DO NOT palpate abdomen - may rupture tumor capsule, spreading cancer cells. Post a sign on bed. Usually presents as firm, nontender flank mass. Treatment: surgery, chemo, possibly radiation.",
            contentCategory: .pediatrics,
            nclexCategory: .safeEffectiveCare,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What condition causes a child to assume a tripod position and drool?",
            answer: "Epiglottitis",
            wrongAnswers: ["Croup", "Asthma", "Bronchiolitis"],
            rationale: "Epiglottitis: bacterial infection (H. influenzae, now rare due to Hib vaccine) causing swollen epiglottis. 4 D's: Drooling, Dysphagia, Dysphonia, Distress. Tripod position to maintain airway. Don't examine throat - can cause complete obstruction. Emergency airway management.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "At what age can a child be switched from a rear-facing to forward-facing car seat?",
            answer: "At least age 2 and meet weight/height requirements per car seat",
            wrongAnswers: ["6 months", "At first birthday", "When they can sit unsupported"],
            rationale: "AAP recommends rear-facing until at least age 2 OR until exceeding car seat height/weight limits. Rear-facing provides better head/neck/spine protection. Never place rear-facing seat in front of airbag. Use age-appropriate restraints until proper seat belt fit.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child with suspected appendicitis has which classic finding?",
            answer: "Right lower quadrant pain (McBurney's point) with rebound tenderness",
            wrongAnswers: ["Left upper quadrant pain", "Painless abdominal distension", "Pain relieved by eating"],
            rationale: "Appendicitis: periumbilical pain → localizes to RLQ (McBurney's point: 1/3 distance from ASIS to umbilicus). Rebound tenderness, guarding, fever, vomiting, anorexia. Rovsing's sign: RLQ pain with LLQ palpation. Surgical emergency.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 12: More Maternity/OB (40 cards)
        Flashcard(
            question: "What is the normal amount of amniotic fluid at term?",
            answer: "Approximately 800-1200 mL",
            wrongAnswers: ["100-200 mL", "3000-4000 mL", "50-100 mL"],
            rationale: "Normal AFI: 5-25 cm or fluid pocket >2 cm. Oligohydramnios (<500 mL): associated with renal agenesis, IUGR, post-term, ROM. Polyhydramnios (>2000 mL): GI obstruction, neural tube defects, diabetes, multiple gestation. Both need investigation.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A pregnant woman at 28 weeks receives Rh immune globulin (RhoGAM). Why is this given?",
            answer: "To prevent maternal Rh sensitization in an Rh-negative mother",
            wrongAnswers: ["To treat anemia", "To prevent gestational diabetes", "To boost fetal immune system"],
            rationale: "RhoGAM prevents formation of maternal antibodies against Rh-positive fetal cells. Given at 28 weeks (some fetal cells may cross placenta) and within 72 hours of delivery if baby is Rh-positive. Also after any potential fetal-maternal hemorrhage event.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is Bishop's score used for?",
            answer: "To assess cervical readiness for induction of labor",
            wrongAnswers: ["To measure fetal heart rate", "To diagnose preeclampsia", "To estimate gestational age"],
            rationale: "Bishop's score assesses: cervical dilation, effacement, station, consistency, position. Score >6 indicates favorable cervix for induction. Lower scores may need cervical ripening (prostaglandins, mechanical dilators) before oxytocin.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST stage of labor divided into?",
            answer: "Latent phase, active phase, and transition",
            wrongAnswers: ["Pushing, crowning, and delivery", "Engagement, descent, and expulsion", "Effacement, dilation, and rotation"],
            rationale: "Stage 1: latent (0-6 cm, slow), active (6-10 cm, faster), transition (8-10 cm, intense). Stage 2: complete dilation to delivery. Stage 3: delivery to placenta expulsion. Stage 4: recovery (first 1-2 hours postpartum).",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A woman's membranes have been ruptured for 20 hours without delivery. What is the PRIORITY concern?",
            answer: "Chorioamnionitis (intrauterine infection)",
            wrongAnswers: ["Fetal macrosomia", "Gestational diabetes", "Postpartum hemorrhage"],
            rationale: "Prolonged ROM (>18 hours) increases infection risk. Chorioamnionitis signs: maternal fever, fetal tachycardia, uterine tenderness, foul-smelling fluid. Treatment: antibiotics and expedient delivery. Risk increases hourly after ROM.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the normal umbilical cord structure?",
            answer: "Two arteries and one vein (AVA)",
            wrongAnswers: ["Two veins and one artery", "One artery and one vein", "Three veins"],
            rationale: "Normal cord: 2 arteries (carry deoxygenated blood to placenta) and 1 vein (carries oxygenated blood to fetus). Single umbilical artery (SUA) found in 1% - associated with renal and cardiac anomalies. Examine cord at delivery.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A newborn has Apgar scores of 3 at 1 minute and 7 at 5 minutes. What does this indicate?",
            answer: "Initial depression with good response to resuscitation",
            wrongAnswers: ["Normal delivery without intervention", "Poor prognosis requiring NICU", "Need for immediate surgery"],
            rationale: "Apgar assesses: heart rate, respirations, muscle tone, reflex irritability, color. Score 0-3: severe depression, 4-6: moderate, 7-10: good. Improvement from 3 to 7 shows good response to resuscitation. Continue monitoring.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the purpose of Leopold's maneuvers?",
            answer: "To determine fetal position, presentation, and engagement",
            wrongAnswers: ["To assess cervical dilation", "To measure fundal height", "To check fetal heart rate"],
            rationale: "Leopold's maneuvers: systematic abdominal palpation. 1st: fundal contents (head or breech). 2nd: locate fetal back. 3rd: presenting part. 4th: descent/engagement. Helps determine fetal lie (longitudinal/transverse) and position.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient in labor has a cervix that is 6 cm dilated, 80% effaced, and at 0 station. What does this indicate?",
            answer: "Active labor with presenting part at the level of ischial spines",
            wrongAnswers: ["Latent labor", "Complete dilation", "Presenting part deeply engaged"],
            rationale: "6 cm = active labor. 80% effacement = cervix mostly thinned. 0 station = presenting part at ischial spines (engaged). Negative stations above spines, positive stations below. Complete = 10 cm, 100%, typically +2 to +3 station.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What indicates a reassuring fetal heart rate tracing?",
            answer: "Baseline 110-160 bpm with moderate variability and accelerations",
            wrongAnswers: ["Baseline 180 bpm with no variability", "Repetitive late decelerations", "Sinusoidal pattern"],
            rationale: "Reassuring FHR: baseline 110-160, moderate variability (6-25 bpm), accelerations (increase ≥15 bpm for ≥15 seconds), no decelerations. Concerning: absent variability, recurrent late/variable decels, bradycardia, sinusoidal pattern.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A woman has a positive contraction stress test (CST). What does this mean?",
            answer: "Late decelerations with more than 50% of contractions - concerning for fetal compromise",
            wrongAnswers: ["The fetus is tolerating contractions well", "Labor should be induced immediately", "Normal finding in all pregnancies"],
            rationale: "CST assesses fetal response to contractions. Positive: late decelerations with >50% contractions - suggests uteroplacental insufficiency. Negative: no late decels - reassuring. Suspicious/equivocal: intermediate results. Positive test requires further evaluation.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What condition does betamethasone prevent when given before preterm delivery?",
            answer: "Respiratory distress syndrome by accelerating fetal lung maturity",
            wrongAnswers: ["Neonatal jaundice", "Congenital heart defects", "Cerebral palsy"],
            rationale: "Betamethasone (antenatal corticosteroids) given 24-34 weeks if preterm delivery expected. Accelerates surfactant production, reduces RDS, intraventricular hemorrhage, and mortality. Optimal benefit 24 hours to 7 days after administration.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIORITY nursing action for shoulder dystocia?",
            answer: "Call for help and prepare for McRoberts maneuver",
            wrongAnswers: ["Apply fundal pressure", "Pull firmly on the fetal head", "Instruct mother to push harder"],
            rationale: "Shoulder dystocia: anterior shoulder impacted behind symphysis. HELPERR: Help, Episiotomy, Legs (McRoberts - hyperflexed), Pressure (suprapubic, not fundal), Enter (rotational maneuvers), Remove posterior arm, Roll to all fours. Time-sensitive emergency.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A postpartum patient reports passing large clots. What size clot should be reported?",
            answer: "Clots larger than a golf ball or heavy bleeding saturating a pad in less than 1 hour",
            wrongAnswers: ["Any small clot", "Only clots with tissue", "Only clots with foul odor"],
            rationale: "Small clots (<1 inch) may be normal early postpartum. Report: large clots (>golf ball), saturation >1 pad/hour, boggy uterus, tachycardia, hypotension. Postpartum hemorrhage: >500 mL vaginal or >1000 mL cesarean.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What teaching is appropriate for a woman with mastitis?",
            answer: "Continue breastfeeding from both breasts, apply warm compresses, take prescribed antibiotics",
            wrongAnswers: ["Stop breastfeeding completely", "Only feed from the unaffected breast", "Apply cold compresses before feeding"],
            rationale: "Mastitis: breast infection usually from S. aureus. Continue nursing (helps drain infected breast). Warm compresses before feeding, complete prescribed antibiotics, adequate rest/fluids. If abscess forms, may need I&D but can still nurse.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the treatment for gestational diabetes that cannot be controlled by diet?",
            answer: "Insulin therapy",
            wrongAnswers: ["Oral hypoglycemics only", "Increased caloric intake", "No treatment until delivery"],
            rationale: "GDM management: diet, exercise, glucose monitoring. If not controlled, insulin is preferred - doesn't cross placenta significantly. Some oral agents (metformin, glyburide) used but insulin remains first-line for pharmacologic treatment.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the danger sign a pregnant woman should report immediately?",
            answer: "Sudden gush or continuous leakage of fluid from vagina",
            wrongAnswers: ["Mild ankle swelling in evening", "Occasional Braxton-Hicks contractions", "Increased vaginal discharge"],
            rationale: "Danger signs: vaginal bleeding, fluid leakage (ROM), severe headache, visual changes, severe abdominal pain, decreased fetal movement, signs of preeclampsia, fever. These require immediate evaluation. Patient education essential.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A laboring woman suddenly becomes dyspneic, hypotensive, and develops DIC. What complication is suspected?",
            answer: "Amniotic fluid embolism",
            wrongAnswers: ["Postpartum hemorrhage", "Uterine inversion", "Retained placenta"],
            rationale: "AFE: catastrophic complication, amniotic fluid enters maternal circulation. Classic triad: sudden respiratory distress, cardiovascular collapse, DIC. High mortality. Treatment: supportive, airway management, treat DIC, prepare for CPR and emergent delivery.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the recommended weight gain during pregnancy for a woman with normal BMI?",
            answer: "25-35 pounds",
            wrongAnswers: ["10-15 pounds", "40-50 pounds", "No weight gain needed"],
            rationale: "Weight gain recommendations by pre-pregnancy BMI: Underweight: 28-40 lbs. Normal: 25-35 lbs. Overweight: 15-25 lbs. Obese: 11-20 lbs. First trimester: 2-4 lbs total. Second/third: about 1 lb/week. Inadequate or excessive gain both have risks.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the expected uterine position immediately after delivery?",
            answer: "At the level of the umbilicus or slightly below, firm, and midline",
            wrongAnswers: ["At the level of the symphysis pubis", "Soft and boggy to the right", "Above the umbilicus and displaced"],
            rationale: "Immediately postpartum: fundus at umbilicus, firm, midline. Descends about 1 cm (fingerbreadth) per day. Soft/boggy suggests atony - massage. Displaced to right often indicates full bladder. Should be non-palpable by 2 weeks.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 13: More Mental Health & Critical Care (34 cards)
        Flashcard(
            question: "A patient with bulimia nervosa is at risk for which electrolyte imbalance?",
            answer: "Hypokalemia from purging behaviors",
            wrongAnswers: ["Hyperkalemia", "Hypercalcemia", "Hypernatremia"],
            rationale: "Bulimia: binge eating followed by compensatory behaviors (vomiting, laxatives, diuretics). Purging causes: hypokalemia (cardiac arrhythmias), metabolic alkalosis, dehydration, dental erosion, esophageal tears. Medical stabilization first, then psychological treatment.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST-line treatment for major depressive disorder?",
            answer: "Combination of psychotherapy and antidepressant medication (SSRI)",
            wrongAnswers: ["Electroconvulsive therapy", "Benzodiazepines", "Antipsychotics"],
            rationale: "Mild-moderate depression: psychotherapy may be sufficient. Moderate-severe: medication + therapy most effective. SSRIs are first-line (sertraline, escitalopram). ECT reserved for severe, treatment-resistant, or emergency cases (acute suicidality).",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with schizophrenia says 'I invented the internet and saved the world.' This is an example of:",
            answer: "Delusion of grandeur",
            wrongAnswers: ["Delusion of reference", "Delusion of persecution", "Hallucination"],
            rationale: "Grandiose delusion: inflated sense of worth, power, identity, or special relationship to deity/famous person. Common in schizophrenia and bipolar mania. Don't argue with delusions - don't reinforce them either. Focus on reality-based topics.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What medication is used for acute dystonic reactions from antipsychotics?",
            answer: "Diphenhydramine (Benadryl) or benztropine (Cogentin)",
            wrongAnswers: ["More antipsychotic medication", "Haloperidol", "Lithium"],
            rationale: "Acute dystonia: sudden muscle spasms (neck, eyes, tongue) from dopamine blockade. Give anticholinergics: diphenhydramine IV/IM or benztropine. Works rapidly. Prevent with prophylactic anticholinergics when starting high-potency antipsychotics in young males.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the MOST important factor in establishing a therapeutic relationship?",
            answer: "Building trust through consistency, honesty, and appropriate boundaries",
            wrongAnswers: ["Solving all the patient's problems", "Becoming friends with the patient", "Sharing personal experiences frequently"],
            rationale: "Therapeutic relationship elements: trust, respect, genuineness, empathy, clear boundaries. Nurse is consistent, honest, non-judgmental. Focus on patient needs, not nurse's. Boundaries prevent dual relationships. Self-disclosure minimal and patient-focused.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient in the ICU develops sudden confusion, hallucinations, and agitation. What should the nurse suspect?",
            answer: "ICU delirium",
            wrongAnswers: ["New psychiatric disorder", "Normal response to hospitalization", "Medication seeking behavior"],
            rationale: "ICU delirium: acute confusion common in critically ill. Risk factors: sedation, sleep deprivation, mechanical ventilation, infection, advanced age. Use CAM-ICU for assessment. Treatment: identify cause, minimize sedation, promote sleep, reorient, early mobilization.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient on mechanical ventilation has high peak pressures. What could this indicate?",
            answer: "Increased airway resistance (secretions, bronchospasm, kinked tube)",
            wrongAnswers: ["Decreased lung compliance", "Normal finding", "Machine malfunction only"],
            rationale: "High peak pressure with normal plateau = airway resistance (bronchospasm, secretions, tube problems). High peak AND plateau = compliance issue (ARDS, pneumothorax, pulmonary edema). Assess patient, check tube, suction, auscultate lungs.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIORITY intervention for a patient in cardiogenic shock?",
            answer: "Improve cardiac output while reducing cardiac workload",
            wrongAnswers: ["Aggressive fluid resuscitation", "Diuresis only", "Increased activity"],
            rationale: "Cardiogenic shock: pump failure. Goals: improve contractility (dobutamine, milrinone), reduce preload/afterload, may need IABP. NOT fluid loading (heart can't handle more volume). Monitor: MAP, urine output, cardiac output, lactate.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient has a pulmonary artery catheter. What does the wedge pressure (PCWP) reflect?",
            answer: "Left ventricular preload/left atrial pressure",
            wrongAnswers: ["Right atrial pressure", "Systemic vascular resistance", "Cardiac output"],
            rationale: "PCWP (normal 8-12 mmHg) reflects left heart filling pressure. Elevated in: LV failure, mitral stenosis, fluid overload. Low in: hypovolemia. CVP reflects right heart. PA catheter also measures cardiac output, mixed venous oxygen saturation.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What are the signs of cardiac tamponade?",
            answer: "Beck's triad: hypotension, muffled heart sounds, jugular vein distension",
            wrongAnswers: ["Hypertension and bradycardia", "Clear lung sounds and tachypnea", "Wide pulse pressure"],
            rationale: "Tamponade: fluid accumulation in pericardium compresses heart. Beck's triad + pulsus paradoxus (>10 mmHg drop in SBP during inspiration) + electrical alternans on ECG. Emergency pericardiocentesis needed. Common after cardiac surgery, trauma, malignancy.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient in septic shock requires which type of fluid resuscitation?",
            answer: "Crystalloid bolus (30 mL/kg) within first 3 hours",
            wrongAnswers: ["Colloids only", "Blood products immediately", "Minimal fluids to prevent overload"],
            rationale: "Sepsis bundles: crystalloid 30 mL/kg for hypotension/lactate >4. Obtain cultures, give antibiotics within 1 hour. Vasopressors (norepinephrine) if hypotension persists after fluids. Target MAP ≥65. Early goal-directed therapy improves outcomes.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What indicates successful resuscitation in a patient receiving CPR?",
            answer: "Return of spontaneous circulation (ROSC) with pulse and blood pressure",
            wrongAnswers: ["Patient opens eyes during compressions", "ETCO2 of 10 mmHg", "Asystole on the monitor"],
            rationale: "ROSC: return of sustained pulse/BP. Check pulse during rhythm check. ETCO2 >40 suggests ROSC. After ROSC: targeted temperature management, identify cause, cardiac catheterization if indicated, neuroprognostication not before 72 hours.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient has an arterial blood gas showing pH 7.48, PaCO2 28, HCO3 24. What is the interpretation?",
            answer: "Respiratory alkalosis (uncompensated)",
            wrongAnswers: ["Metabolic alkalosis", "Respiratory acidosis", "Metabolic acidosis"],
            rationale: "pH >7.45 = alkalosis. Low CO2 (<35) indicates respiratory cause (hyperventilation). Normal HCO3 = uncompensated. Causes: anxiety, hypoxia, pain, fever, mechanical overventilation. Treatment: address underlying cause, slow breathing if anxiety.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What does a high lactate level in a critically ill patient indicate?",
            answer: "Tissue hypoperfusion and anaerobic metabolism",
            wrongAnswers: ["Normal finding in ICU patients", "Adequate tissue oxygenation", "Liver failure only"],
            rationale: "Elevated lactate (>2 mmol/L) indicates inadequate oxygen delivery to tissues → anaerobic metabolism. Causes: shock, sepsis, cardiac arrest, severe hypoxemia. Used to guide resuscitation. Persistent elevation despite treatment = poor prognosis.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the indication for emergent dialysis?",
            answer: "AEIOU: Acidosis, Electrolytes (hyperkalemia), Intoxication, Overload (fluid), Uremia symptoms",
            wrongAnswers: ["Creatinine level of 2.0", "Any acute kidney injury", "Mild metabolic acidosis"],
            rationale: "Emergent dialysis indications: severe metabolic acidosis refractory to bicarb, hyperkalemia >6.5 or symptomatic, toxic ingestions (lithium, methanol, ethylene glycol), fluid overload refractory to diuretics, uremic pericarditis/encephalopathy/bleeding.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with severe traumatic brain injury has ICP of 25 mmHg. What is the cerebral perfusion pressure if MAP is 85?",
            answer: "CPP = 60 mmHg (MAP - ICP)",
            wrongAnswers: ["CPP = 110 mmHg", "CPP = 25 mmHg", "CPP = 85 mmHg"],
            rationale: "CPP = MAP - ICP. Normal ICP: 5-15 mmHg. Target CPP: 60-70 mmHg. In this case: 85 - 25 = 60 (borderline). Need to reduce ICP (osmotic therapy, sedation, drainage) or increase MAP (vasopressors) to maintain adequate brain perfusion.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient being weaned from mechanical ventilation fails a spontaneous breathing trial. What should the nurse assess?",
            answer: "Increased respiratory rate, tachycardia, desaturation, patient distress, accessory muscle use",
            wrongAnswers: ["Only oxygen saturation", "Blood pressure only", "Decreased respiratory effort"],
            rationale: "Weaning failure signs: RR >35, HR change >20%, SpO2 <90%, diaphoresis, agitation, paradoxical breathing, accessory muscle use. Return to previous vent settings, address causes (fluid overload, infection, weakness, anxiety). Retry when optimized.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the antidote for tissue plasminogen activator (tPA) if bleeding occurs?",
            answer: "Aminocaproic acid (Amicar) or tranexamic acid, plus cryoprecipitate for fibrinogen",
            wrongAnswers: ["Vitamin K", "Protamine sulfate", "No antidote exists"],
            rationale: "tPA activates plasminogen → fibrinolysis. For severe bleeding: stop infusion, give cryoprecipitate (fibrinogen), aminocaproic acid (antifibrinolytic), platelets and RBCs as needed. Screen carefully before giving tPA - strict inclusion/exclusion criteria.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with traumatic injury has massive hemorrhage. What is the appropriate blood product ratio?",
            answer: "Balanced transfusion (1:1:1 ratio of RBCs:FFP:platelets)",
            wrongAnswers: ["RBCs only", "FFP only", "10:1:1 ratio"],
            rationale: "Massive transfusion protocol: balanced approach (1:1:1) mimics whole blood, prevents dilutional coagulopathy. Give blood warmer, calcium (citrate toxicity), monitor for hypothermia, acidosis, hyperkalemia (lethal triad prevention).",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the target glucose range for critically ill patients?",
            answer: "140-180 mg/dL",
            wrongAnswers: ["80-110 mg/dL", "200-250 mg/dL", "Below 70 mg/dL"],
            rationale: "Moderate glucose control (140-180) recommended for most ICU patients. Tight control (80-110) increases hypoglycemia risk without mortality benefit. Use insulin infusion protocol. Hypoglycemia is dangerous - check glucose frequently.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 14: Additional Comprehensive NCLEX Questions (134 cards)
        Flashcard(
            question: "A patient asks why they need to take their blood pressure medication even when they feel fine. What is the BEST response?",
            answer: "Hypertension is often called the silent killer because it usually has no symptoms but can cause serious damage",
            wrongAnswers: ["You'll feel sick if you don't take it", "The doctor ordered it so you must take it", "You can skip doses when you feel okay"],
            rationale: "Hypertension is typically asymptomatic until complications occur (stroke, MI, kidney damage). Patient education emphasizes lifelong treatment, medication adherence even when feeling well, and regular BP monitoring.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which electrolyte imbalance causes muscle weakness, decreased reflexes, and cardiac arrhythmias?",
            answer: "Both hypokalemia and hyperkalemia",
            wrongAnswers: ["Only hyperkalemia", "Only hypokalemia", "Neither affects muscles"],
            rationale: "Both potassium extremes cause muscle weakness and cardiac effects. Hypokalemia: weakness, flat T waves, U waves. Hyperkalemia: weakness, peaked T waves, wide QRS. Normal K: 3.5-5.0 mEq/L. Assess cardiac rhythm with either abnormality.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with tuberculosis is started on rifampin. What teaching is essential?",
            answer: "Body fluids (urine, tears, sweat) will turn orange-red, and birth control pills may be less effective",
            wrongAnswers: ["Take on empty stomach only", "Avoid all sunlight", "This medication causes weight gain"],
            rationale: "Rifampin: potent CYP450 inducer - reduces effectiveness of many drugs including oral contraceptives. Orange discoloration of body fluids is expected and harmless. Take TB medications consistently for full course (6-9 months typically).",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIORITY nursing diagnosis for a patient with heart failure who has gained 5 pounds in 3 days?",
            answer: "Excess fluid volume",
            wrongAnswers: ["Impaired nutrition", "Activity intolerance", "Knowledge deficit"],
            rationale: "Rapid weight gain (2+ lbs in 24h or 5+ lbs in week) indicates fluid retention, a hallmark of HF exacerbation. Assess: edema, lung sounds, JVD. Report to provider, expect diuretics. Daily weights same time, same scale essential for monitoring.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A child is prescribed oral penicillin. What should parents be taught about administration?",
            answer: "Give on an empty stomach, 1 hour before or 2 hours after meals",
            wrongAnswers: ["Give with high-fat meals", "Mix with acidic juices for better taste", "Give at bedtime only"],
            rationale: "Oral penicillin absorption is reduced by food. Give on empty stomach with full glass of water. Complete entire course even if child feels better. Watch for allergic reactions (rash, hives, difficulty breathing).",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Select ALL appropriate interventions for a patient at risk for aspiration:",
            answer: "Elevate HOB 30-45 degrees, Thicken liquids as ordered, Supervise meals, Ensure proper positioning",
            wrongAnswers: ["Give liquids only"],
            rationale: "Aspiration precautions: elevate HOB during and 30-60 min after meals, proper positioning, swallow evaluation, thickened liquids/modified diet as ordered, suction available, small frequent meals, supervise eating, check gag reflex.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .sata,
            isPremium: true
        ),
        Flashcard(
            question: "A patient receiving chemotherapy has a WBC of 1,500/mm³. What is the PRIORITY nursing action?",
            answer: "Implement neutropenic precautions and protect from infection",
            wrongAnswers: ["Encourage visitors", "Serve raw fruits and vegetables", "Administer live vaccines"],
            rationale: "Neutropenia (ANC <1500): high infection risk. Precautions: private room, strict hand hygiene, no live plants/flowers, cooked foods only, avoid crowds, monitor for subtle infection signs (fever may be only sign), no rectal procedures.",
            contentCategory: .medSurg,
            nclexCategory: .safeEffectiveCare,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the nurse's FIRST action when a patient complains of chest pain?",
            answer: "Stop all activity and assess the characteristics of the pain",
            wrongAnswers: ["Administer morphine", "Perform 12-lead ECG immediately", "Call the physician first"],
            rationale: "ASSESSMENT comes first: PQRST (Provocation, Quality, Region/Radiation, Severity, Timing). Then: O2, vital signs, ECG, notify provider. Keep patient calm and still. Have crash cart available. Don't leave patient alone.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with chronic pain asks why non-opioid medications are being tried first. What is the BEST explanation?",
            answer: "The WHO pain ladder recommends starting with non-opioids and escalating based on response",
            wrongAnswers: ["Opioids are too expensive", "You don't look like you're in enough pain", "Insurance won't cover opioids"],
            rationale: "WHO analgesic ladder: Step 1 (mild pain): non-opioids (acetaminophen, NSAIDs). Step 2 (moderate): weak opioids + non-opioids. Step 3 (severe): strong opioids + non-opioids. Multimodal approach often most effective.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What normal finding might concern new parents during a newborn assessment?",
            answer: "Milia (small white bumps on nose/chin) and erythema toxicum (red blotchy rash)",
            wrongAnswers: ["Blue hands and feet", "Irregular breathing patterns", "All of these are concerning"],
            rationale: "Normal newborn findings that may alarm parents: milia, erythema toxicum, stork bites, Mongolian spots, acrocyanosis, periodic breathing, sneezing, hiccups. Educate parents that these are normal and will resolve.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with diabetes has a foot wound that won't heal. What is the MOST likely contributing factor?",
            answer: "Peripheral vascular disease and neuropathy from chronic hyperglycemia",
            wrongAnswers: ["Poor hygiene only", "Vitamin deficiency only", "Normal aging process"],
            rationale: "Diabetic wounds heal poorly due to: microvascular disease (poor perfusion), neuropathy (unnoticed injuries), immune dysfunction, hyperglycemia (impairs WBC function). Prevention: daily foot exams, proper footwear, glucose control, podiatry care.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is being discharged on warfarin. Which statement indicates need for more teaching?",
            answer: "I should take extra vitamin K supplements to stay healthy",
            wrongAnswers: ["I need to have my INR checked regularly", "I should avoid contact sports", "I'll use an electric razor for shaving"],
            rationale: "Vitamin K is warfarin's antidote - supplements would decrease anticoagulation effect. Keep vitamin K intake CONSISTENT (not avoid, not supplement). Report bleeding, new medications, dietary changes. Wear medical ID.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the difference between type 1 and type 2 diabetes mellitus?",
            answer: "Type 1: absolute insulin deficiency (autoimmune); Type 2: insulin resistance with relative deficiency",
            wrongAnswers: ["Type 1 only occurs in elderly", "Type 2 never requires insulin", "They are the same disease"],
            rationale: "Type 1: autoimmune destruction of beta cells, usually young onset, always needs insulin. Type 2: insulin resistance → beta cell exhaustion, usually adult onset, may manage with diet/oral meds initially but often needs insulin eventually.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a colostomy has watery output. Where is the stoma MOST likely located?",
            answer: "Ascending colon (right side)",
            wrongAnswers: ["Descending colon (left side)", "Sigmoid colon", "Rectum"],
            rationale: "Ascending colostomy: liquid output (little water absorbed). Transverse: paste-like. Descending/sigmoid: formed stool. Ileostomy: liquid, high output, more electrolyte concerns. Pouch changes and skin care vary by location.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the MOST effective way to prevent catheter-associated urinary tract infections (CAUTI)?",
            answer: "Avoid unnecessary catheter use and remove as soon as clinically appropriate",
            wrongAnswers: ["Change catheter every 24 hours", "Use prophylactic antibiotics", "Irrigate catheter daily"],
            rationale: "CAUTI prevention: avoid catheterization when possible, use alternatives (condom catheter, bladder scanner), remove ASAP (daily assessment), maintain closed system, keep bag below bladder, perineal care. Duration is biggest risk factor.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is scheduled for a stress test. What teaching is appropriate?",
            answer: "Avoid caffeine for 24 hours and wear comfortable walking shoes",
            wrongAnswers: ["Eat a large meal beforehand", "Take all cardiac medications as usual", "Plan to drive yourself home"],
            rationale: "Stress test prep: NPO or light meal, no caffeine (affects results), hold certain cardiac meds (beta-blockers may be held), wear comfortable clothes/shoes, may have activity restrictions after depending on results.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the purpose of pursed-lip breathing for a COPD patient?",
            answer: "To prevent airway collapse and improve gas exchange by maintaining positive pressure",
            wrongAnswers: ["To increase respiratory rate", "To clear mucus from airways", "To strengthen inspiratory muscles"],
            rationale: "Pursed-lip breathing: inhale through nose (2 counts), exhale slowly through pursed lips (4 counts). Creates back-pressure preventing airway collapse in emphysema, prolongs exhalation, improves ventilation, reduces air trapping.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with pneumonia has thick, rusty-colored sputum. What type of pneumonia is likely?",
            answer: "Streptococcus pneumoniae (pneumococcal) pneumonia",
            wrongAnswers: ["Viral pneumonia", "Mycoplasma pneumonia", "Aspiration pneumonia"],
            rationale: "Classic pneumococcal pneumonia: sudden onset, high fever, pleuritic chest pain, rusty sputum, consolidation on CXR. Most common community-acquired pneumonia. Treatment: antibiotics. Prevention: pneumococcal vaccine (PCV13, PPSV23).",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What nursing intervention is MOST important for a patient on bedrest to prevent complications?",
            answer: "Turn and reposition every 2 hours and perform range of motion exercises",
            wrongAnswers: ["Keep in same position for comfort", "Only move when patient requests", "Wait for physical therapy orders"],
            rationale: "Bedrest complications: pressure injuries, DVT, pneumonia, muscle atrophy, contractures, constipation. Prevention: position changes Q2H, ROM exercises, SCDs, coughing/deep breathing, adequate hydration, early mobilization when possible.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with angina reports the pain is now occurring at rest. What type of angina is this?",
            answer: "Unstable angina",
            wrongAnswers: ["Stable angina", "Prinzmetal's angina", "Silent ischemia"],
            rationale: "Stable angina: predictable, occurs with exertion, relieved by rest/nitro. Unstable angina: unpredictable, occurs at rest, longer duration, not fully relieved by nitro - EMERGENCY, may progress to MI. Prinzmetal's: variant, caused by coronary spasm.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient taking diuretics for heart failure should monitor for which sign of fluid imbalance at home?",
            answer: "Daily weight - report gain of 2+ pounds in 24 hours or 5+ pounds in a week",
            wrongAnswers: ["Monthly blood pressure only", "Skin color changes", "Hair loss"],
            rationale: "Daily weights are best home monitoring for fluid status. Weight gain indicates fluid retention. Report to provider if threshold exceeded. Also monitor: dyspnea, edema, activity tolerance. Call if worsening symptoms.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the recommended dietary modification for a patient with chronic kidney disease?",
            answer: "Restrict protein, potassium, phosphorus, and sodium",
            wrongAnswers: ["High protein diet", "Unrestricted potassium", "Increased phosphorus intake"],
            rationale: "CKD diet: restrict protein (reduces uremic toxins), potassium (kidneys can't excrete), phosphorus (causes bone disease), sodium and fluid (prevent overload). May need phosphate binders, potassium binders, renal vitamins.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with GERD should avoid which foods?",
            answer: "Caffeine, alcohol, chocolate, fatty foods, citrus, and tomatoes",
            wrongAnswers: ["Whole grains and vegetables", "Lean proteins", "All dairy products"],
            rationale: "GERD triggers: caffeine, alcohol, chocolate (relaxes LES), fatty/fried foods, citrus, tomatoes, peppermint, spicy foods, large meals. Also: don't lie down after eating, elevate HOB, avoid tight clothing, lose weight if needed.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with seizures is prescribed phenytoin. What is the therapeutic serum level?",
            answer: "10-20 mcg/mL",
            wrongAnswers: ["0.5-2.0 ng/mL", "1-2.5 mEq/L", "50-100 mcg/mL"],
            rationale: "Phenytoin therapeutic: 10-20 mcg/mL. Signs of toxicity: nystagmus (first sign at 20+), ataxia (30+), confusion, lethargy. Has zero-order kinetics - small dose changes cause large level changes. Monitor levels regularly.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is being treated for hypothyroidism. What symptoms indicate the dose needs adjustment?",
            answer: "Persistent fatigue, weight gain, cold intolerance suggest underdosing; palpitations, weight loss, tremors suggest overdosing",
            wrongAnswers: ["No symptoms relate to dosing", "All symptoms mean stop medication", "Only lab values matter"],
            rationale: "Hypothyroid symptoms (underdosed): fatigue, weight gain, constipation, cold intolerance, dry skin, bradycardia. Hyperthyroid symptoms (overdosed): palpitations, weight loss, heat intolerance, tremors, anxiety. Adjust dose based on TSH and symptoms.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the recommended breast cancer screening for average-risk women?",
            answer: "Mammography starting at age 40-50, then annually or biennially based on guidelines",
            wrongAnswers: ["No screening until age 65", "Only if symptoms present", "MRI for all women annually"],
            rationale: "Screening recommendations vary by organization. Generally: mammography starting 40-50, then every 1-2 years. Clinical breast exam varies. Self-breast awareness encouraged. High-risk women may need earlier or additional screening (MRI).",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with hepatic encephalopathy should have which medication administered?",
            answer: "Lactulose to reduce ammonia absorption",
            wrongAnswers: ["High-protein supplements", "Sedatives for confusion", "Stimulant laxatives"],
            rationale: "Hepatic encephalopathy: elevated ammonia affects brain. Lactulose: acidifies colon, traps ammonia as ammonium, increases excretion. Goal: 2-3 soft stools/day. Also: protein restriction, rifaximin (antibiotic), avoid sedatives, treat underlying cause.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What teaching is essential for a patient with a permanent pacemaker?",
            answer: "Carry pacemaker ID card, avoid MRI, report signs of infection or dizziness",
            wrongAnswers: ["Avoid all electronic devices", "Pacemaker needs daily resetting", "Never exercise again"],
            rationale: "Pacemaker teaching: carry ID, avoid MRI (some newer pacemakers are MRI-conditional), alert medical staff, monitor for infection (fever, redness), report dizziness/syncope. Cell phones safe if >6 inches away. Most activities okay after healing.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A postoperative patient has not voided for 8 hours. What should the nurse assess FIRST?",
            answer: "Bladder distension and fluid intake",
            wrongAnswers: ["Insert catheter immediately", "Increase IV fluids", "Notify physician immediately"],
            rationale: "Assess first: bladder distension (palpation, bladder scan), fluid intake vs output, pain level, ability to ambulate to bathroom, history of voiding issues. Try non-invasive methods (running water, privacy, warm water over perineum) before catheterization.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the MOST accurate method to assess fluid balance in an infant?",
            answer: "Daily weights and monitoring wet diapers",
            wrongAnswers: ["Skin turgor on abdomen", "Asking parents about intake", "Blood pressure only"],
            rationale: "Infant fluid assessment: daily weights (most accurate), wet diapers (6-8/day indicates adequate hydration), fontanel (sunken = dehydration), mucous membranes, skin turgor, tears, capillary refill. Infants dehydrate quickly due to high body water percentage.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is caring for a patient with end-stage renal disease. Which lab value requires IMMEDIATE action?",
            answer: "Potassium of 6.8 mEq/L",
            wrongAnswers: ["BUN of 45 mg/dL", "Creatinine of 5.0 mg/dL", "Hemoglobin of 10 g/dL"],
            rationale: "Potassium >6.5 mEq/L is life-threatening - can cause fatal arrhythmias. Requires immediate treatment: calcium gluconate, insulin/glucose, kayexalate, possible emergent dialysis. Elevated BUN/creatinine and low Hgb are expected in ESRD.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIORITY when caring for a patient with a new tracheostomy?",
            answer: "Keep emergency equipment at bedside: extra trach, obturator, suction, O2",
            wrongAnswers: ["Deflate cuff continuously", "Change trach tube daily", "Discourage coughing"],
            rationale: "New tracheostomy: emergency equipment at bedside (same size trach, one size smaller, obturator, suction, O2, scissors, hemostat). First tube change by MD after tract forms (5-7 days). Suction PRN, humidification essential, assess for complications.",
            contentCategory: .medSurg,
            nclexCategory: .safeEffectiveCare,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a history of alcohol abuse is admitted. When should withdrawal symptoms be expected?",
            answer: "Within 6-24 hours after last drink, peaking at 24-72 hours",
            wrongAnswers: ["Immediately upon admission", "After one week", "Only if patient was drinking heavily"],
            rationale: "Alcohol withdrawal timeline: 6-24 hrs: tremors, anxiety, tachycardia, hypertension. 24-72 hrs: hallucinations, seizures. 48-72+ hrs: delirium tremens (DTs). Use CIWA protocol for assessment. Benzodiazepines are treatment of choice.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the antidote for methotrexate toxicity?",
            answer: "Leucovorin (folinic acid) rescue",
            wrongAnswers: ["Vitamin B12", "Folic acid only", "Protamine sulfate"],
            rationale: "Leucovorin bypasses methotrexate's folate metabolism blockade, rescuing normal cells. Given on schedule after high-dose methotrexate. Monitor methotrexate levels, renal function, hydration. Folic acid alone is not sufficient for rescue.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with deep vein thrombosis asks why they can't get out of bed. What is the BEST explanation?",
            answer: "Activity restrictions vary - follow provider orders as movement may dislodge the clot initially",
            wrongAnswers: ["You must stay in bed for two weeks", "Walking is always safe with DVT", "Only bedrest prevents DVT"],
            rationale: "DVT management has evolved - early ambulation is often recommended once anticoagulated, but varies by clot size/location. Initially may restrict activity, then progress. Always follow provider orders. Anticoagulation is primary treatment.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child has been diagnosed with acute otitis media. What teaching should the nurse provide?",
            answer: "Complete entire course of antibiotics even if symptoms improve",
            wrongAnswers: ["Stop antibiotics when pain resolves", "Antibiotics are never needed", "Insert objects to relieve pressure"],
            rationale: "Otitis media: may need antibiotics (especially <2 years, bilateral, severe). Complete full course to prevent resistance and recurrence. Pain management important. Avoid water in ears. Follow-up to ensure resolution. Prevent: vaccines, avoid smoke exposure.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the MOST important teaching for a patient taking oral contraceptives?",
            answer: "Take at the same time each day, and use backup contraception if doses are missed",
            wrongAnswers: ["Timing doesn't matter", "Missing one dose has no effect", "Double up on missed doses is always safe"],
            rationale: "Consistent timing optimizes effectiveness. If missed: take ASAP, use backup method 7 days. Know warning signs (ACHES: Abdominal pain, Chest pain, Headache, Eye problems, Severe leg pain) - may indicate serious complications.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with schizophrenia is responding to internal stimuli. What is the BEST nursing response?",
            answer: "Acknowledge the patient's experience without reinforcing the hallucination, and present reality",
            wrongAnswers: ["Argue that the voices aren't real", "Pretend to hear the voices too", "Ignore the behavior completely"],
            rationale: "Don't argue with or reinforce hallucinations. Acknowledge the patient's experience: 'I understand you're hearing something. I don't hear it, but I can see it's distressing.' Present reality, focus on real stimuli, ensure safety, medicate as ordered.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate action when a patient refuses to sign a consent form for surgery?",
            answer: "Document the refusal, ensure patient understands consequences, and notify the physician",
            wrongAnswers: ["Have family sign instead", "Proceed without consent", "Tell patient they have no choice"],
            rationale: "Competent adults can refuse any treatment. Ensure understanding of risks of refusing, document the discussion and refusal, notify provider. Explore reasons for refusal. Never coerce or proceed without consent (except life-threatening emergency).",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse receives a verbal order for a medication. What is the correct procedure?",
            answer: "Read back the order to verify, document with date/time/prescriber name, and have order signed within timeframe per policy",
            wrongAnswers: ["Wait for written order before giving", "Give medication without documentation", "Only accept verbal orders in emergencies"],
            rationale: "Verbal/phone orders: write order, read back, receive confirmation, document with date/time/prescriber name/'verbal order' or 'telephone order', provider must sign within timeframe (usually 24-48 hours). Minimize verbal orders when possible.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is hyperventilating due to anxiety. What acid-base imbalance is occurring?",
            answer: "Respiratory alkalosis",
            wrongAnswers: ["Respiratory acidosis", "Metabolic alkalosis", "Metabolic acidosis"],
            rationale: "Hyperventilation → excessive CO2 loss → respiratory alkalosis (pH >7.45, PaCO2 <35). Symptoms: lightheadedness, tingling, carpopedal spasm. Treatment: slow breathing, breathe into paper bag (controversial), treat underlying cause.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the purpose of a negative pressure room?",
            answer: "To prevent airborne pathogens from escaping into the hallway",
            wrongAnswers: ["To provide extra oxygen", "To filter out allergens", "To keep the room warmer"],
            rationale: "Negative pressure rooms: air flows in, not out - prevents airborne pathogen transmission (TB, measles, varicella). Required for airborne precautions. Check pressure indicator before entering. Keep door closed. N95 or PAPR required.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A pregnant patient at 36 weeks reports decreased fetal movement. What is the PRIORITY action?",
            answer: "Instruct patient to come for fetal monitoring immediately",
            wrongAnswers: ["Reassure that decreased movement is normal at term", "Schedule appointment for next week", "Advise her to drink juice and wait"],
            rationale: "Decreased fetal movement can indicate fetal distress. While 'count to 10' and kick counts are used, significant decrease needs immediate evaluation with NST/BPP. Don't delay evaluation at term when fetal compromise is possible.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate response when a patient with dementia becomes agitated?",
            answer: "Speak calmly, reduce stimulation, and redirect to a familiar or pleasant topic",
            wrongAnswers: ["Restrain the patient immediately", "Argue and correct their confusion", "Leave them alone in their room"],
            rationale: "Dementia agitation: speak slowly and calmly, reduce environmental stimulation, don't argue or try to orient, redirect to calming activities, assess for unmet needs (pain, hunger, toileting), use familiar objects/music. Restraints are last resort.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with atrial fibrillation is on digoxin. What should the nurse assess before administration?",
            answer: "Apical pulse for one full minute - hold if below 60 bpm",
            wrongAnswers: ["Blood pressure only", "Radial pulse for 15 seconds", "Respiratory rate"],
            rationale: "Digoxin slows heart rate and strengthens contraction. Check apical pulse for full minute (irregular rhythms need full assessment). Hold if HR <60 (adult), notify provider. Also monitor for toxicity signs: visual changes, nausea, arrhythmias.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What position is contraindicated after a lumbar puncture?",
            answer: "Sitting upright - patient should lie flat for several hours",
            wrongAnswers: ["Side-lying with knees flexed", "Supine with one pillow", "Prone position"],
            rationale: "After LP: lie flat 1-4 hours (varies by protocol) to prevent post-LP headache from CSF leak. Increase fluids. Post-LP headache: worse when upright, relieved when lying down. Report severe headache, fever, drainage from site.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is prescribed metoprolol. What is essential teaching about this medication?",
            answer: "Do not stop abruptly - can cause rebound hypertension or angina",
            wrongAnswers: ["Take only when symptoms occur", "Stop if heart rate decreases", "Safe to stop anytime"],
            rationale: "Beta-blockers must be tapered, not stopped abruptly - can cause rebound tachycardia, hypertension, angina, or MI. Take as prescribed, monitor heart rate and BP, report dizziness, fatigue, or breathing problems.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Select ALL components of the nursing process:",
            answer: "Assessment, Diagnosis, Planning, Implementation, Evaluation (ADPIE)",
            wrongAnswers: ["Documentation only"],
            rationale: "ADPIE: Assessment (collect data), Diagnosis (identify problems), Planning (set goals), Implementation (carry out interventions), Evaluation (assess outcomes). Systematic, continuous, patient-centered approach to nursing care.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .sata,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is prescribed clopidogrel (Plavix). What teaching is essential?",
            answer: "Report any unusual bleeding, avoid NSAIDs, and inform all healthcare providers you take this medication",
            wrongAnswers: ["This medication has no significant interactions", "Stop taking if you need dental work", "Bleeding is not a concern"],
            rationale: "Clopidogrel: antiplatelet, increases bleeding risk. Avoid ASA, NSAIDs (unless prescribed). Report: unusual bruising/bleeding, black stools, blood in urine, prolonged bleeding from cuts. Alert all providers, including dentists. Usually not stopped before minor procedures.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the expected output from a patient with a nasogastric tube connected to low intermittent suction?",
            answer: "Green or yellow-tinged gastric contents, 200-500 mL in 8 hours",
            wrongAnswers: ["Clear fluid only", "No output expected", "Bright red blood normally"],
            rationale: "NG output varies but is typically greenish/yellow gastric secretions. Monitor: amount, color, pH. Large volumes may need electrolyte replacement. Bloody output: notify provider. Assess for proper function and placement before use.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is receiving IV antibiotics and develops wheezing and lip swelling. What is the FIRST action?",
            answer: "Stop the infusion immediately",
            wrongAnswers: ["Slow the infusion rate", "Administer antihistamine and continue", "Call the pharmacy first"],
            rationale: "Signs of anaphylaxis: stop causative agent immediately. Then: maintain airway, epinephrine (if severe), IV fluids, call for help, monitor vitals. Wheezing and angioedema indicate serious allergic reaction requiring immediate intervention.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is administering ear drops to an adult. What is the correct technique?",
            answer: "Pull pinna up and back, instill drops, have patient remain on side for 5 minutes",
            wrongAnswers: ["Pull pinna down and back", "Insert dropper into ear canal", "Have patient sit upright after drops"],
            rationale: "Adult ear drops: pull pinna UP and BACK (straightens ear canal). Child <3 years: pull pinna DOWN and BACK. Warm drops to body temperature. Don't touch dropper to ear. Remain on side to promote absorption.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the primary purpose of incentive spirometry after surgery?",
            answer: "To prevent atelectasis by promoting deep breathing and lung expansion",
            wrongAnswers: ["To measure oxygen levels", "To strengthen expiratory muscles", "To clear mucus from airways"],
            rationale: "Incentive spirometry prevents postoperative pulmonary complications. Patient inhales slowly to lift indicator, holds breath 3-5 seconds. Use 10 times/hour while awake. Visual feedback encourages adequate deep breaths.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is scheduled for a colonoscopy. What bowel preparation is typically required?",
            answer: "Clear liquid diet the day before and bowel cleansing solution as prescribed",
            wrongAnswers: ["No preparation needed", "Regular diet until midnight", "Enema only morning of procedure"],
            rationale: "Colonoscopy prep: clear liquids day before, NPO after midnight, bowel prep solution (polyethylene glycol). Complete bowel clearance essential for visualization. Assess prep adequacy. Some medications may be held.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a thoracotomy has a chest tube. What is a normal finding?",
            answer: "Tidaling (fluctuation) in the water-seal chamber during respirations",
            wrongAnswers: ["Continuous bubbling in water-seal chamber", "No fluctuation at any time", "Chest tube clamped routinely"],
            rationale: "Tidaling (water level rises/falls with breathing) indicates patent tube and intact system. Continuous bubbling in water-seal = air leak (check connections, may be expected initially). Bubbling in suction control chamber is normal if suction applied.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the minimum urine output expected from an adult patient?",
            answer: "30 mL/hour or 0.5 mL/kg/hour",
            wrongAnswers: ["10 mL/hour", "100 mL/hour", "5 mL/hour"],
            rationale: "Adequate urine output indicates kidney perfusion. Minimum: 30 mL/hr (0.5 mL/kg/hr). Less than this suggests inadequate renal perfusion (hypovolemia, hypotension, renal failure). Foley catheter helps accurate measurement in critical patients.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is NPO for surgery tomorrow. The nurse receives an order for morning medications. What should the nurse do?",
            answer: "Clarify with the provider which medications should be given with sips of water",
            wrongAnswers: ["Hold all medications", "Give all medications as usual", "Give all medications without water"],
            rationale: "Some medications (cardiac, BP, antiseizure) are often continued with sips of water. Others (oral hypoglycemics, anticoagulants) may be held. Always clarify - don't assume. Provider and anesthesia determine which medications to continue.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the FIRST action if a patient starts to fall while ambulating?",
            answer: "Ease the patient gently to the floor while protecting the head",
            wrongAnswers: ["Try to catch and hold the patient upright", "Call for help before doing anything", "Let the patient fall to avoid self-injury"],
            rationale: "If fall is inevitable: ease to floor, protect head, lower body gently. Don't try to catch full body weight - causes injury to both. After fall: assess for injury, check vitals, notify provider, complete incident report.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient has an advance directive refusing intubation. The patient is now unresponsive and in respiratory failure. What should the nurse do?",
            answer: "Respect the advance directive and provide comfort measures",
            wrongAnswers: ["Intubate to save the patient's life", "Wait for family to make decision", "Ignore the directive in emergencies"],
            rationale: "Advance directives are legally binding when patient cannot make decisions. If valid DNI in place, respect it. Provide comfort measures, contact family, notify provider. POLST/MOLST orders provide clear guidance. Document thoroughly.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which assessment finding indicates a patient is experiencing a hypoglycemic reaction to insulin?",
            answer: "Diaphoresis, tremors, tachycardia, confusion",
            wrongAnswers: ["Hot, dry skin and fruity breath", "Polyuria and polydipsia", "Slow, deep respirations"],
            rationale: "Hypoglycemia: sweating, shakiness, tachycardia, confusion, hunger, pallor (sympathetic response). Hyperglycemia/DKA: polyuria, polydipsia, Kussmaul respirations, fruity breath. Treat hypoglycemia immediately - rule of 15.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with chronic obstructive pulmonary disease asks why they need to use oxygen carefully. What is the BEST response?",
            answer: "High oxygen levels can reduce your breathing drive because your body has adapted to lower oxygen levels",
            wrongAnswers: ["Oxygen is addictive", "You don't actually need oxygen", "Oxygen causes lung damage immediately"],
            rationale: "Some COPD patients have hypoxic drive to breathe (chronic CO2 retention shifts to O2 as primary drive). High-flow O2 can suppress drive, causing hypoventilation and CO2 retention. Titrate O2 to 88-92% SpO2.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What lab value indicates effectiveness of heparin therapy?",
            answer: "Activated partial thromboplastin time (aPTT) 1.5-2.5 times the control",
            wrongAnswers: ["PT/INR", "Complete blood count", "Basic metabolic panel"],
            rationale: "Heparin monitored by aPTT. Therapeutic: 1.5-2.5 times control. Warfarin monitored by PT/INR. Low molecular weight heparin (enoxaparin) doesn't require routine monitoring. Direct oral anticoagulants (DOACs) don't require monitoring.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with pneumonia is receiving oxygen via nasal cannula at 3 L/min. What is the approximate FiO2?",
            answer: "Approximately 32% (each L/min adds about 4% to room air 21%)",
            wrongAnswers: ["100%", "21%", "50%"],
            rationale: "Nasal cannula: each L/min adds ~4% FiO2 (approximation). 1L = 24%, 2L = 28%, 3L = 32%, 4L = 36%, 5L = 40%, 6L = 44%. Actual varies with breathing pattern. Higher flows: consider high-flow nasal cannula or mask for precise delivery.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the nurse's responsibility regarding incident reports?",
            answer: "Complete accurately and objectively, don't reference in patient chart, submit per facility policy",
            wrongAnswers: ["Document in patient chart that report was filed", "Only complete if patient was harmed", "Complete only if supervisor requests"],
            rationale: "Incident reports: complete for any unusual occurrence, document facts objectively, don't reference report in medical record. Chart factual events in patient record. Reports are for quality improvement, not punitive. Submit per facility policy.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a history of bariatric surgery is admitted. What vitamin deficiency is this patient at risk for?",
            answer: "Vitamin B12, iron, calcium, and fat-soluble vitamins (A, D, E, K)",
            wrongAnswers: ["No vitamin deficiency risk", "Only vitamin C", "Only vitamin B6"],
            rationale: "Bariatric surgery causes malabsorption. Lifelong supplementation needed: B12, iron, calcium with vitamin D, fat-soluble vitamins (especially after bypass procedures). Regular lab monitoring for deficiencies. Protein malnutrition also possible.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is an early sign of increased intracranial pressure in an infant?",
            answer: "Bulging fontanel and increased head circumference",
            wrongAnswers: ["Sunken fontanel", "Bradycardia as first sign", "Pinpoint pupils"],
            rationale: "Infants: open fontanels allow expansion before classic ICP signs. Early: bulging fontanel, increasing head circumference, irritability, poor feeding, high-pitched cry. Later: setting-sun eyes, Cushing's triad. Adults: LOC change is earliest sign.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is prescribed simvastatin. When should this medication be taken?",
            answer: "In the evening, as cholesterol production peaks at night",
            wrongAnswers: ["Only in the morning", "With each meal", "Only when eating high-fat foods"],
            rationale: "Some statins (simvastatin, lovastatin) work best in evening when cholesterol synthesis peaks. Others (atorvastatin, rosuvastatin) have longer half-lives and can be taken any time. Consistent timing is important.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the most appropriate initial intervention for a patient experiencing acute shortness of breath?",
            answer: "Place in high Fowler's position and apply oxygen",
            wrongAnswers: ["Lay the patient flat", "Have patient breathe into paper bag", "Administer sedative"],
            rationale: "Dyspnea: upright position (high Fowler's) maximizes lung expansion, apply O2, remain calm, assess ABC, vital signs, determine cause. Don't leave patient alone. Prepare for further interventions based on assessment.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is admitted with acute pancreatitis. Which lab value is expected to be elevated?",
            answer: "Serum amylase and lipase",
            wrongAnswers: ["Blood urea nitrogen only", "Hemoglobin", "Albumin"],
            rationale: "Pancreatitis: elevated amylase (rises early, normalizes quickly) and lipase (more specific, stays elevated longer). Also: hyperglycemia, hypocalcemia, elevated WBC, elevated liver enzymes if gallstone-related.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the correct procedure for removing personal protective equipment (PPE)?",
            answer: "Gloves, goggles, gown, mask/respirator - with hand hygiene between steps",
            wrongAnswers: ["Mask first, then gown, gloves last", "Remove all at once quickly", "Any order is acceptable"],
            rationale: "Doffing order minimizes contamination: gloves (most contaminated), hand hygiene, goggles/face shield, gown, hand hygiene, mask/respirator (last - still need respiratory protection), final hand hygiene. Remove carefully to avoid self-contamination.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is caring for a dying patient whose family is present. What is the MOST important nursing action?",
            answer: "Provide comfort measures and support for both the patient and family",
            wrongAnswers: ["Leave the room to give privacy", "Focus only on the patient's physical needs", "Discourage family from expressing emotion"],
            rationale: "End-of-life care: comfort (pain management, positioning, mouth care), dignity, emotional/spiritual support for patient and family. Allow family presence and participation. Provide privacy but be available. Answer questions honestly.",
            contentCategory: .fundamentals,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What assessment is essential before administering morning medications to a patient on digoxin and furosemide?",
            answer: "Apical pulse and serum potassium level",
            wrongAnswers: ["Blood pressure only", "Temperature only", "Respiratory rate only"],
            rationale: "Digoxin: check apical pulse, hold if <60. Furosemide: causes potassium loss. Hypokalemia increases digoxin toxicity risk. Check K+ level. Common combination in heart failure - be aware of drug interactions.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A postoperative patient reports 10/10 pain but is laughing and talking on the phone. What should the nurse do?",
            answer: "Believe the patient's self-report of pain and assess further",
            wrongAnswers: ["Refuse pain medication since behavior doesn't match", "Document that patient is lying", "Give half the ordered dose"],
            rationale: "Pain is subjective - patient's report is most reliable indicator. Pain tolerance and coping mechanisms vary widely. Don't judge pain by behavior (laughing may be coping). Assess, medicate as appropriate, reassess effectiveness.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "Which patient should the nurse see FIRST?",
            answer: "Patient with chest pain and ST elevation on monitor",
            wrongAnswers: ["Patient requesting pain medication", "Patient with blood glucose of 180", "Patient due for scheduled medications"],
            rationale: "ST elevation = STEMI - life-threatening, time-sensitive emergency ('time is muscle'). See immediately, activate emergency response. Other patients have important needs but are not immediately life-threatening.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is admitted with suspected meningitis. What precaution should be implemented immediately?",
            answer: "Droplet precautions until bacterial meningitis is ruled out",
            wrongAnswers: ["Standard precautions only", "Airborne precautions", "Contact precautions only"],
            rationale: "Bacterial meningitis (N. meningitidis): droplet precautions until 24 hours of effective antibiotics. Close contacts may need prophylaxis. Viral meningitis: standard precautions usually sufficient. Lumbar puncture confirms diagnosis.",
            contentCategory: .infectionControl,
            nclexCategory: .safeEffectiveCare,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse administers the wrong medication to a patient. What is the FIRST action?",
            answer: "Assess the patient for adverse effects",
            wrongAnswers: ["Complete the incident report first", "Call the physician first", "Inform the charge nurse first"],
            rationale: "Patient safety first: assess for adverse effects, take necessary actions. Then: notify provider, follow up with appropriate interventions, notify supervisor, document factually in chart, complete incident report. Don't delay patient assessment.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the maximum recommended time for suctioning a tracheostomy?",
            answer: "10-15 seconds per pass",
            wrongAnswers: ["30-60 seconds", "1-2 minutes", "Until secretions clear"],
            rationale: "Suction only during withdrawal, maximum 10-15 seconds to prevent hypoxia. Pre-oxygenate before suctioning. Allow recovery between passes. Use appropriate catheter size (no more than half the internal diameter of trach). Assess need before routine suctioning.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient receiving IV potassium reports burning at the IV site. What should the nurse do?",
            answer: "Slow the infusion rate and assess the IV site",
            wrongAnswers: ["Stop the infusion completely", "Increase the rate to finish faster", "Ignore the complaint"],
            rationale: "IV potassium commonly causes vein irritation and burning. Slow rate, dilute further if possible, may need central line for concentrated solutions. Never give IV push. Assess site for infiltration/phlebitis. Maximum peripheral rate usually 10-20 mEq/hour.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the purpose of performing Allen's test before arterial blood gas collection?",
            answer: "To assess collateral circulation to the hand before radial artery puncture",
            wrongAnswers: ["To locate the artery", "To assess patient's pain tolerance", "To determine blood pressure"],
            rationale: "Allen's test ensures adequate ulnar artery blood supply before radial artery puncture (in case of damage or thrombosis). Compress both arteries, have patient make fist, release ulnar pressure - hand should pink up within 5-10 seconds.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse notes that a patient's urine in the collection bag is cloudy with sediment and has a strong odor. What should the nurse suspect?",
            answer: "Urinary tract infection",
            wrongAnswers: ["Normal finding with catheter", "Dehydration only", "Renal failure"],
            rationale: "UTI signs in catheterized patient: cloudy urine, sediment, strong odor, fever, flank pain. Culture before antibiotics. Ensure closed system, meatal care, adequate hydration, remove catheter ASAP. CAUTI is common hospital-acquired infection.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What teaching is essential for a patient taking alendronate (Fosamax)?",
            answer: "Take first thing in morning with full glass of water, remain upright for 30 minutes",
            wrongAnswers: ["Take with breakfast for better absorption", "Lie down after taking", "Take at bedtime"],
            rationale: "Bisphosphonates can cause severe esophageal irritation. Take on empty stomach with 8 oz water, remain upright (sitting/standing) 30-60 minutes. Don't eat/drink other items for 30 minutes. Stop and report chest pain or difficulty swallowing.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is in Buck's traction for a hip fracture. What nursing assessment is PRIORITY?",
            answer: "Neurovascular status of the affected extremity",
            wrongAnswers: ["Weight is hanging freely only", "Patient's activity level", "Appetite assessment"],
            rationale: "Traction: neurovascular checks (5 P's: Pain, Pulse, Pallor, Paresthesia, Paralysis). Also: skin integrity, proper alignment, weights hanging freely, ropes/pulleys intact. Report any neurovascular changes immediately.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the PRIMARY purpose of a peripherally inserted central catheter (PICC)?",
            answer: "Long-term IV access for medications, nutrition, or blood draws",
            wrongAnswers: ["Emergency medication administration", "Short-term IV fluids only", "Blood transfusions only"],
            rationale: "PICC: inserted in upper arm, tip in superior vena cava. For long-term antibiotics, TPN, chemotherapy, frequent blood draws. Can stay weeks to months. Requires placement verification (X-ray). Care includes dressing changes, flushing, infection monitoring.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child is admitted with suspected abuse. What is the nurse's legal obligation?",
            answer: "Report to appropriate authorities as mandated by law",
            wrongAnswers: ["Confront the parents first", "Wait for concrete proof", "Only report if child requests"],
            rationale: "Nurses are mandated reporters - legally required to report suspected abuse. Report to child protective services or designated agency. Don't investigate or confront family. Document objective findings. Protect the child. Failure to report is illegal.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate nursing intervention for a patient with vertigo?",
            answer: "Assist with ambulation, keep environment dim, avoid sudden movements",
            wrongAnswers: ["Encourage rapid position changes", "Keep room brightly lit", "Restrict all fluids"],
            rationale: "Vertigo: room spinning sensation. Safety priority: assist with ambulation (fall risk), dim lights, move slowly, avoid sudden head movements, antiemetics if nauseated, side rails up, call light within reach. Determine and treat underlying cause.",
            contentCategory: .medSurg,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with heart failure is receiving an ACE inhibitor. Which lab value should be monitored?",
            answer: "Serum potassium and creatinine",
            wrongAnswers: ["Sodium only", "Glucose only", "Hemoglobin only"],
            rationale: "ACE inhibitors: can cause hyperkalemia (reduce aldosterone → potassium retention) and affect renal function. Monitor K+ and creatinine. Also watch for hypotension, dry cough (common side effect), angioedema (rare but serious).",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the nurse's role in informed consent?",
            answer: "Witness the signature and ensure the patient has had questions answered",
            wrongAnswers: ["Explain the procedure and risks", "Obtain consent from family members", "Decide if surgery is necessary"],
            rationale: "Provider explains procedure, risks, benefits, alternatives. Nurse: witnesses signature, verifies patient identity, ensures patient understood and questions were answered. If patient has new questions about procedure itself, notify provider.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),

        // BATCH 15: Final 47 cards to reach 500 total
        Flashcard(
            question: "A patient with chronic pain asks about non-pharmacological pain management. What options should the nurse discuss?",
            answer: "Heat/cold therapy, massage, relaxation techniques, guided imagery, music therapy, TENS",
            wrongAnswers: ["Only medications help chronic pain", "These methods don't work", "Only surgery can help"],
            rationale: "Non-pharmacological methods complement medication therapy. Heat/cold, positioning, massage, relaxation, distraction, guided imagery, music therapy, acupuncture, TENS unit. Multimodal approach often most effective for chronic pain.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the best way to communicate with a patient who has hearing loss?",
            answer: "Face the patient, speak clearly without shouting, reduce background noise, use written communication as needed",
            wrongAnswers: ["Speak loudly into their ear", "Exaggerate mouth movements", "Only use written communication"],
            rationale: "Face patient for lip reading, speak clearly at normal pace, reduce noise, get attention first, check hearing aids, use written communication as supplement, verify understanding. Don't shout (distorts words) or cover mouth.",
            contentCategory: .fundamentals,
            nclexCategory: .psychosocial,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is receiving continuous tube feeding and develops diarrhea. What should the nurse assess FIRST?",
            answer: "Rate of feeding and osmolality of formula",
            wrongAnswers: ["Stop feeding permanently", "Increase the rate", "Add fiber immediately"],
            rationale: "Diarrhea with tube feeding: assess rate (too fast?), formula strength/osmolality, contamination, medications (sorbitol content, antibiotics). May need to slow rate, dilute formula, or change formula. Rule out C. diff if on antibiotics.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the nurse's priority when caring for a patient with a seizure disorder?",
            answer: "Maintain patient safety and airway during a seizure",
            wrongAnswers: ["Restrain the patient tightly", "Insert tongue blade", "Give oral medications during seizure"],
            rationale: "During seizure: stay with patient, protect from injury, don't restrain, don't put anything in mouth, turn to side after (if possible), time the seizure, note characteristics. After: assess, keep side-lying, provide privacy, reassure.",
            contentCategory: .medSurg,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient taking lithium should maintain adequate intake of which substance?",
            answer: "Sodium and fluids",
            wrongAnswers: ["Potassium supplements", "Caffeine", "High-fat foods"],
            rationale: "Lithium and sodium compete for reabsorption. Low sodium → lithium retention → toxicity. Maintain consistent sodium and fluid intake. Dehydration, low-sodium diet, diuretics, sweating increase lithium levels. Monitor levels and symptoms.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What position should a patient assume during a paracentesis?",
            answer: "Sitting upright on side of bed or semi-Fowler's with support",
            wrongAnswers: ["Prone position", "Trendelenburg", "Flat supine"],
            rationale: "Paracentesis: upright or semi-Fowler's positions fluid in lower abdomen for safer access. Empty bladder before procedure. Monitor vitals, assess for hypotension (fluid shifts). Post-procedure: monitor site, vitals, albumin if large volume removed.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is being discharged with a new prescription for metformin. What teaching is essential?",
            answer: "Take with meals, monitor blood glucose, report GI upset which usually improves over time",
            wrongAnswers: ["Take on empty stomach", "No blood glucose monitoring needed", "Stop if you experience any GI upset"],
            rationale: "Metformin: take with meals to reduce GI upset (common initially, usually improves). Monitor glucose, avoid excess alcohol, hold before contrast procedures, report symptoms of lactic acidosis (rare but serious): weakness, muscle pain, difficulty breathing.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the priority nursing intervention for a patient receiving a blood transfusion who develops fever and chills?",
            answer: "Stop the transfusion immediately and maintain IV access with normal saline",
            wrongAnswers: ["Slow the transfusion rate", "Administer antipyretic and continue", "Complete the transfusion quickly"],
            rationale: "Transfusion reaction signs: stop transfusion, keep IV open with NS (new tubing), notify blood bank and provider, monitor vitals frequently, return blood bag and tubing to blood bank. Never restart a questioned transfusion.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is teaching a patient about self-administration of insulin. What technique should be emphasized?",
            answer: "Rotate injection sites within the same body region, avoid using the same spot",
            wrongAnswers: ["Use the exact same spot every time", "Rotate between all body regions daily", "Inject through clothing to save time"],
            rationale: "Rotate within same region (e.g., abdomen) for consistent absorption, avoiding same spot (lipohypertrophy). Different regions have different absorption rates. Abdomen: fastest. Don't inject in areas that will be exercised. Store insulin properly.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the expected appearance of colostrum in a breastfeeding mother?",
            answer: "Thick, yellowish fluid present in the first few days after delivery",
            wrongAnswers: ["Thin, white milk immediately", "No fluid until day 5", "Clear, watery fluid"],
            rationale: "Colostrum: thick, yellow, rich in antibodies and protein. Present first 2-4 days. Transitional milk: days 4-14. Mature milk: after ~2 weeks. Colostrum is perfectly suited for newborn's needs even in small amounts.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient asks why they need to take antibiotics for 10 days when they feel better after 3. What should the nurse explain?",
            answer: "The full course is needed to completely eliminate the infection and prevent antibiotic resistance",
            wrongAnswers: ["You don't actually need to finish", "Feeling better means you're cured", "Antibiotics work better the longer you take them"],
            rationale: "Incomplete antibiotic courses: surviving bacteria can develop resistance, infection may recur. Complete prescribed course even if symptoms resolve. Exception: some newer guidelines allow shorter courses for specific conditions - follow provider orders.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the priority assessment for a patient who just returned from cardiac catheterization via femoral approach?",
            answer: "Assess puncture site for bleeding/hematoma and distal pulses",
            wrongAnswers: ["Check cardiac enzymes immediately", "Ambulate the patient", "Remove pressure dressing right away"],
            rationale: "Post-cath care: frequent vital signs, assess insertion site (bleeding, hematoma), distal pulses, extremity color/temp/sensation. Keep affected leg straight per protocol. Monitor for complications: bleeding, hematoma, pseudoaneurysm, retroperitoneal bleed.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is caring for a patient with a pressure injury. What factor most affects wound healing?",
            answer: "Adequate nutrition, especially protein and vitamin C",
            wrongAnswers: ["Age alone determines healing", "Wound size is the only factor", "Activity level only"],
            rationale: "Wound healing requires: protein (tissue repair), vitamin C (collagen synthesis), zinc, adequate calories, hydration, good circulation. Other factors: underlying disease, infection, moisture balance, pressure offloading. Address all modifiable factors.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate response when a patient expresses anger about their diagnosis?",
            answer: "Acknowledge the feelings and allow the patient to express emotions in a safe environment",
            wrongAnswers: ["Tell them not to be angry", "Leave the room until they calm down", "Argue that the diagnosis isn't that bad"],
            rationale: "Anger is normal stage of grief. Acknowledge: 'I can see you're upset. It's okay to feel angry.' Active listening, don't take personally, maintain safety, be present. Don't argue, minimize feelings, or become defensive.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with liver disease should avoid which over-the-counter medication?",
            answer: "Acetaminophen (Tylenol) in high doses",
            wrongAnswers: ["Calcium carbonate (Tums)", "Fiber supplements", "Vitamin B12"],
            rationale: "Acetaminophen is metabolized by liver - hepatotoxic in excessive doses or with liver disease. Maximum 2-3 g/day with liver disease (lower than standard 4 g max). Avoid alcohol. Many OTC products contain acetaminophen - check labels.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the most appropriate nursing action for an infant with jaundice receiving phototherapy?",
            answer: "Protect the eyes with opaque eye shields and expose maximum skin area",
            wrongAnswers: ["Keep eyes uncovered for stimulation", "Dress infant warmly under lights", "Limit feeding to reduce bilirubin"],
            rationale: "Phototherapy: eye shields prevent retinal damage, expose maximum skin (diaper only), turn frequently, monitor temperature, increase feedings (promotes stooling to excrete bilirubin). Monitor bilirubin levels. Bronze baby syndrome is temporary.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is preparing to administer medications through a nasogastric tube. What is essential before administration?",
            answer: "Verify tube placement and flush with 30 mL water before and after medications",
            wrongAnswers: ["Give medications rapidly", "Mix all medications together", "Skip flushing to prevent fluid overload"],
            rationale: "NG medication administration: verify placement (pH/X-ray), flush before, give each medication separately with flushes between (prevents interactions/clogging), flush after, clamp tube 30-60 minutes if on suction. Use liquid forms when possible.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate intervention for a patient with orthostatic hypotension?",
            answer: "Teach patient to rise slowly: sit before standing, dangle legs, stand slowly",
            wrongAnswers: ["Rise quickly to get blood flowing", "Take blood pressure only lying down", "Restrict all fluids"],
            rationale: "Orthostatic hypotension: rise slowly from lying to sitting to standing. Dangle legs at bedside. Ensure adequate hydration. Check orthostatic BP (lying, sitting, standing). Compression stockings may help. Review medications for contributors.",
            contentCategory: .fundamentals,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is scheduled for an MRI. What must the nurse assess before the procedure?",
            answer: "Any metal implants, pacemaker, or claustrophobia",
            wrongAnswers: ["Allergies to iodine only", "Blood glucose level only", "Recent food intake only"],
            rationale: "MRI contraindications: pacemakers (most), some implants, metal fragments, some tattoos. Assess for claustrophobia (may need sedation or open MRI). Remove all metal objects. Contrast (gadolinium) different from CT contrast - assess kidney function.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What teaching is appropriate for a patient discharged with a new ostomy?",
            answer: "Empty pouch when 1/3 to 1/2 full, change every 3-7 days, inspect stoma and skin",
            wrongAnswers: ["Empty only when completely full", "Change pouch daily", "Stoma should be pale and dry"],
            rationale: "Ostomy care: empty at 1/3-1/2 full (prevents leaks and heavy pulling), change per manufacturer guidance (typically 3-7 days), stoma should be pink/red and moist, skin barrier protects peristomal skin. Report color changes, bleeding, or skin breakdown.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A postoperative patient has not had a bowel movement in 4 days. What intervention is most appropriate FIRST?",
            answer: "Assess bowel sounds, diet, fluid intake, activity, and medications",
            wrongAnswers: ["Administer an enema immediately", "Give a strong laxative", "Insert a rectal tube"],
            rationale: "Assess before intervening: bowel sounds, abdomen, last BM, diet/fluids, activity level, medications (opioids common cause). Then progressive interventions: increased fluids/fiber, ambulation, stool softeners, laxatives, enemas if needed.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "What is the priority nursing diagnosis for a patient admitted with diabetic ketoacidosis?",
            answer: "Deficient fluid volume",
            wrongAnswers: ["Knowledge deficit", "Activity intolerance", "Impaired skin integrity"],
            rationale: "DKA causes severe dehydration from osmotic diuresis. Fluid resuscitation is priority (NS initially). Also: insulin infusion, electrolyte replacement (especially potassium once urinating), frequent monitoring. Address knowledge after stabilization.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a history of falls is being admitted. What should be included in the fall prevention plan?",
            answer: "Bed in low position, call light within reach, non-skid footwear, frequent toileting",
            wrongAnswers: ["Restraints on all fall-risk patients", "Keep room completely dark", "Bed in highest position"],
            rationale: "Fall prevention: low bed, call light in reach, non-skid footwear, clear pathways, adequate lighting, frequent toileting (many falls going to bathroom), bed/chair alarms, high fall-risk identification. Restraints are last resort.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the purpose of applying sequential compression devices (SCDs)?",
            answer: "To prevent deep vein thrombosis by promoting venous return",
            wrongAnswers: ["To treat existing DVT", "To reduce arterial blood flow", "To prevent ankle swelling only"],
            rationale: "SCDs mechanically compress legs, promoting venous return and preventing stasis → DVT prevention. Use on both legs (unless contraindicated), ensure proper fit, remove only briefly for skin assessment. Not for treatment of existing DVT.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient asks about the difference between generic and brand-name medications. What should the nurse explain?",
            answer: "Generic medications contain the same active ingredient and are equally effective as brand-name drugs",
            wrongAnswers: ["Generic drugs are less effective", "Brand-name drugs are always safer", "Generic drugs have different ingredients"],
            rationale: "Generic drugs: same active ingredient, dosage, strength, route, and efficacy as brand name. FDA-approved. May have different inactive ingredients (fillers, colors). Usually less expensive. Safe, effective alternatives.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate nursing action when a patient reports feeling suicidal?",
            answer: "Stay with the patient, notify the provider, ensure safety by removing dangerous items",
            wrongAnswers: ["Leave to get help, letting patient be alone", "Dismiss feelings as attention-seeking", "Promise to keep it a secret"],
            rationale: "Suicidal ideation: stay with patient (never leave alone), ask directly about plan, remove dangerous items, notify provider/supervisor, ensure constant observation, document. Don't promise confidentiality for safety issues. Take all statements seriously.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is receiving vancomycin. What assessment indicates the infusion may be too rapid?",
            answer: "Flushing of face and neck (Red Man Syndrome)",
            wrongAnswers: ["Decreased blood pressure only", "Increased urine output", "Hyperglycemia"],
            rationale: "Red Man Syndrome: histamine release from rapid vancomycin infusion. Symptoms: flushing, pruritus, hypotension. Prevention: infuse over ≥60 minutes. If occurs: slow/stop infusion, give antihistamines. Not a true allergy - can usually continue with slower rate.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the recommended fluid intake for a patient with kidney stones?",
            answer: "At least 2-3 liters (8-12 glasses) of fluid daily",
            wrongAnswers: ["Restrict fluids to 1 liter daily", "Fluids don't affect stone formation", "Drink only fruit juice"],
            rationale: "Increased fluid dilutes urine and promotes stone passage/prevention. Water best, some citrus juices helpful (citrate). Avoid excess sodium, animal protein. Dietary modifications depend on stone type (calcium, uric acid, etc.). Strain urine to catch stones for analysis.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse discovers that a coworker has been diverting controlled substances. What is the appropriate action?",
            answer: "Report to the nurse manager or appropriate supervisor per facility policy",
            wrongAnswers: ["Confront the coworker privately", "Ignore it to avoid conflict", "Tell other coworkers about it"],
            rationale: "Drug diversion is serious - affects patient safety and is illegal. Report to supervisor/manager per policy. Don't confront directly or gossip. Document observations objectively. Many states have confidential peer assistance programs.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the priority nursing action for a patient with chest tube drainage that suddenly stops?",
            answer: "Assess the patient and check the tubing for kinks or clots",
            wrongAnswers: ["Milk the chest tube aggressively", "Clamp the tube immediately", "Remove the chest tube"],
            rationale: "Sudden stop: assess patient first (respiratory distress?). Check system: kinks, clots, tube position, suction settings. Gentle milking controversial - can increase negative pressure. Report changes, may need X-ray. Never clamp without order.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with congestive heart failure asks why they need to weigh themselves daily. What is the BEST response?",
            answer: "Daily weights help detect fluid retention early, before symptoms worsen",
            wrongAnswers: ["To track your diet progress", "It's just routine, not important", "To determine medication doses"],
            rationale: "HF: fluid retention causes weight gain before obvious edema or dyspnea. 2-3 lb gain in 24 hours or 5 lb in week indicates fluid retention - report to provider for intervention before symptoms worsen. Same time, same scale, same clothing daily.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the most appropriate diet for a patient with cirrhosis and ascites?",
            answer: "Low sodium (2 grams or less daily) with adequate protein unless encephalopathy present",
            wrongAnswers: ["High sodium to retain fluids", "No protein at all", "Unrestricted diet"],
            rationale: "Ascites management: sodium restriction (1-2 g/day), fluid restriction if hyponatremic, adequate protein (1-1.2 g/kg/day) unless hepatic encephalopathy (then restrict). May need diuretics, paracentesis. Monitor weight, girth daily.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is prescribed oxycodone for pain. What teaching is essential?",
            answer: "Constipation is common - increase fluids, fiber, and use stool softener as prescribed",
            wrongAnswers: ["Opioids don't cause constipation", "Take laxatives only if constipated for a week", "Decrease fluid intake"],
            rationale: "Opioid-induced constipation: almost universal, doesn't resolve with tolerance. Prophylactic stool softener/mild laxative for all patients on chronic opioids. Also teach: avoid alcohol, CNS depressants, don't drive initially, store securely.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the most reliable method to verify placement of a newly inserted nasogastric tube?",
            answer: "X-ray confirmation",
            wrongAnswers: ["Auscultation of air bolus", "Aspiration of stomach contents alone", "Patient's report of comfort"],
            rationale: "X-ray is gold standard for initial NG tube placement verification. pH testing of aspirate (<5 suggests gastric) can be used for ongoing verification. Auscultation alone is unreliable. Never instill anything until placement confirmed.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is caring for a patient who speaks a different language. What is the appropriate way to communicate?",
            answer: "Use a professional medical interpreter, not family members for important discussions",
            wrongAnswers: ["Use family members to translate everything", "Speak louder in English", "Use only gestures"],
            rationale: "Professional interpreters ensure accurate, confidential communication. Family may omit, modify, or misunderstand medical terms. Use qualified medical interpreter for consent, education, history. May use phone/video interpretation services.",
            contentCategory: .leadership,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the expected duration of lochia after delivery?",
            answer: "4-6 weeks total, progressing from rubra to serosa to alba",
            wrongAnswers: ["Only 3-4 days", "Continues for 3-4 months", "Ends by day 7"],
            rationale: "Lochia duration: rubra (1-3 days, red), serosa (4-10 days, pink), alba (11 days-6 weeks, white/yellow). Report: return to rubra, foul odor, heavy bleeding, large clots, fever. Involution takes about 6 weeks.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with a hip replacement asks when they can resume sexual activity. What should the nurse advise?",
            answer: "Discuss with your surgeon; usually safe after 6 weeks with precautions to avoid certain positions",
            wrongAnswers: ["Never resume sexual activity", "As soon as you feel like it", "Only after 1 year"],
            rationale: "Hip replacement: avoid hip flexion >90°, internal rotation, adduction. Usually safe to resume sexual activity around 6 weeks post-op with positioning precautions. Discuss specific restrictions with surgeon. Comfort and communication with partner important.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate nursing intervention for a patient experiencing a panic attack?",
            answer: "Stay with patient, speak calmly, use slow deep breathing, reduce stimulation",
            wrongAnswers: ["Leave them alone to calm down", "Encourage vigorous exercise", "Give detailed explanations"],
            rationale: "Panic attack: intense fear, physical symptoms (palpitations, sweating, trembling). Stay with patient, remain calm, use slow deep breathing, simple reassurances, reduce stimulation. Attacks peak around 10 minutes and resolve. Medication PRN as ordered.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient's potassium level is 5.8 mEq/L. What food should the nurse instruct the patient to avoid?",
            answer: "Bananas, oranges, potatoes, tomatoes, and salt substitutes",
            wrongAnswers: ["Rice and pasta", "Chicken and fish", "Bread and crackers"],
            rationale: "High-potassium foods: bananas, oranges, potatoes, tomatoes, melons, dried fruits, avocados, spinach. Salt substitutes contain KCl. With hyperkalemia, also review medications (ACE inhibitors, potassium-sparing diuretics). Monitor cardiac rhythm.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the nurse's role in quality improvement?",
            answer: "Identify problems, participate in data collection, suggest solutions, implement changes",
            wrongAnswers: ["QI is only management's responsibility", "Nurses don't participate in QI", "Only report issues, never suggest solutions"],
            rationale: "Nurses are essential to quality improvement: identify issues at point of care, participate in data collection (audits, surveys), suggest solutions based on frontline experience, implement evidence-based changes. QI is everyone's responsibility.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is being discharged on subcutaneous injections. What should the nurse teach about site rotation?",
            answer: "Rotate sites within the same area, keeping sites at least 1 inch apart",
            wrongAnswers: ["Use the exact same spot daily", "Rotate from arm to abdomen to thigh daily", "No rotation needed for subcutaneous injections"],
            rationale: "Subcutaneous injection rotation: prevents lipohypertrophy (tissue buildup) and ensures consistent absorption. Rotate within same area (abdomen has most consistent absorption for insulin). Keep sites 1 inch apart. Record injection sites.",
            contentCategory: .fundamentals,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the purpose of a Foley catheter balloon?",
            answer: "To anchor the catheter in the bladder",
            wrongAnswers: ["To measure urine output", "To prevent infection", "To deliver medication"],
            rationale: "Foley (indwelling) catheter has balloon that is inflated with sterile water after insertion to anchor catheter in bladder. Deflate balloon completely before removal. Document balloon size and amount of water used. Never inflate with air.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient reports numbness and tingling in their hands and feet after starting chemotherapy. What is this called?",
            answer: "Peripheral neuropathy",
            wrongAnswers: ["Central nervous system toxicity", "Allergic reaction", "Normal chemotherapy effect that will resolve immediately"],
            rationale: "Chemotherapy-induced peripheral neuropathy (CIPN): numbness, tingling, burning, pain in hands/feet. Common with certain agents (vincristine, taxanes, platinum drugs). May be dose-limiting. Report promptly. May or may not be reversible.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate response when a patient asks to see their medical records?",
            answer: "Patients have the right to access their records; explain the facility's process for requesting them",
            wrongAnswers: ["Refuse the request", "Only allow if a family member approves", "Require a court order"],
            rationale: "HIPAA: patients have right to access their health records. Explain the request process (written request, possible copying fee, turnaround time). Facilities must provide copies or access within specified timeframe (usually 30 days).",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with chronic kidney disease should avoid which over-the-counter medications?",
            answer: "NSAIDs (ibuprofen, naproxen)",
            wrongAnswers: ["Acetaminophen in appropriate doses", "Antihistamines", "Cough suppressants"],
            rationale: "NSAIDs can worsen kidney function by reducing renal blood flow and causing fluid retention. Avoid in CKD. Acetaminophen (appropriate doses) generally safer for pain. Many OTC products contain NSAIDs - read labels carefully.",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "What is the appropriate nursing action for a patient on telemetry who suddenly shows asystole?",
            answer: "Assess the patient and check lead placement before calling a code",
            wrongAnswers: ["Call a code without checking the patient", "Wait for rhythm to return", "Document and continue monitoring"],
            rationale: "Artifact vs true asystole: ALWAYS assess patient first. Check responsiveness, pulse, breathing. Loose leads cause asystole appearance. If patient unresponsive and pulseless, begin CPR and call code. If artifact, fix leads and monitor.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is taking metoprolol for hypertension. What vital sign should be checked before administration?",
            answer: "Heart rate and blood pressure",
            wrongAnswers: ["Temperature only", "Oxygen saturation only", "Respiratory rate only"],
            rationale: "Beta-blockers (metoprolol): lower heart rate and blood pressure. Check both before administration. Hold if HR <60 or BP significantly low per facility guidelines. Report to provider. Don't stop abruptly - taper.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        // Additional 26 Premium Cards
        Flashcard(
            question: "A nurse is caring for a patient with diabetic ketoacidosis (DKA). Which laboratory finding is expected?",
            answer: "Blood glucose > 300 mg/dL and pH < 7.35",
            wrongAnswers: ["Blood glucose < 70 mg/dL and pH > 7.45", "Normal glucose with elevated potassium", "Low sodium with metabolic alkalosis"],
            rationale: "DKA presents with hyperglycemia (>300), metabolic acidosis (pH <7.35), ketonemia, and dehydration. Treatment includes IV fluids, insulin drip, and electrolyte replacement. Monitor potassium closely as insulin drives K+ into cells.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with heart failure is prescribed furosemide. Which electrolyte imbalance should the nurse monitor for?",
            answer: "Hypokalemia",
            wrongAnswers: ["Hyperkalemia", "Hypernatremia", "Hypercalcemia"],
            rationale: "Loop diuretics like furosemide cause potassium wasting. Monitor K+ levels, watch for muscle weakness, irregular heartbeat, and fatigue. Encourage potassium-rich foods or supplements as ordered. Normal K+: 3.5-5.0 mEq/L.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is teaching a patient about warfarin therapy. Which statement indicates understanding?",
            answer: "I should eat consistent amounts of green leafy vegetables",
            wrongAnswers: ["I should avoid all vegetables completely", "I can take aspirin whenever I have a headache", "I should double my dose if I miss one"],
            rationale: "Warfarin is antagonized by Vitamin K. Patients should maintain consistent Vitamin K intake, not eliminate it. Avoid NSAIDs/aspirin (bleeding risk). Never double doses. Monitor INR regularly (therapeutic: 2-3 for most conditions).",
            contentCategory: .pharmacology,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A 6-month-old infant is brought to the clinic. Which developmental milestone should the nurse expect?",
            answer: "Sits with support and transfers objects between hands",
            wrongAnswers: ["Walks independently", "Speaks in full sentences", "Rides a tricycle"],
            rationale: "6-month milestones: sits with support, rolls over, transfers objects hand-to-hand, babbles, recognizes familiar faces. Walking occurs around 12 months. Speech develops gradually through first years.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A pregnant patient at 28 weeks reports decreased fetal movement. What is the nurse's priority action?",
            answer: "Perform a non-stress test to assess fetal well-being",
            wrongAnswers: ["Tell the patient this is normal", "Schedule an appointment for next week", "Advise the patient to drink caffeine"],
            rationale: "Decreased fetal movement can indicate fetal distress. Priority is assessment via non-stress test (NST) to evaluate fetal heart rate patterns. Kick counts: <10 movements in 2 hours warrants evaluation. Never dismiss maternal concerns about movement.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with schizophrenia reports hearing voices telling him to hurt himself. What is the priority intervention?",
            answer: "Ensure patient safety and initiate suicide precautions",
            wrongAnswers: ["Ignore the voices as they are not real", "Leave the patient alone to rest", "Tell the patient to stop pretending"],
            rationale: "Command hallucinations ordering self-harm are psychiatric emergencies. Priority: safety. Initiate suicide precautions, one-to-one observation, remove harmful objects, notify provider immediately. Never dismiss or argue about hallucinations.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse discovers a medication error made by a colleague. What is the appropriate action?",
            answer: "Complete an incident report and notify the charge nurse",
            wrongAnswers: ["Hide the error to protect your colleague", "Only tell the patient's family", "Wait until the next shift to report"],
            rationale: "Medication errors require immediate reporting through proper channels: incident report, notify charge nurse/supervisor, assess patient, document objectively. Never hide errors. This is about patient safety and system improvement, not punishment.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is receiving a blood transfusion and develops fever, chills, and back pain. What should the nurse do first?",
            answer: "Stop the transfusion immediately",
            wrongAnswers: ["Slow the transfusion rate", "Give acetaminophen and continue", "Increase IV fluids"],
            rationale: "These symptoms suggest transfusion reaction. STOP transfusion immediately, keep IV open with normal saline, notify provider and blood bank, monitor vitals, save blood bag and tubing for analysis. Reactions can be fatal if transfusion continues.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is caring for a patient in restraints. How often should circulation and skin integrity be assessed?",
            answer: "Every 15-30 minutes",
            wrongAnswers: ["Every 4 hours", "Once per shift", "Only when removing restraints"],
            rationale: "Restraints require frequent monitoring: circulation, skin integrity, and vital signs every 15-30 minutes. Document behavior, offer toileting, ROM exercises, nutrition. Restraints are last resort and require ongoing physician orders.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with COPD is on 2L oxygen via nasal cannula. The SpO2 is 91%. What action should the nurse take?",
            answer: "Maintain current oxygen settings as this is acceptable for COPD",
            wrongAnswers: ["Increase oxygen to 6L immediately", "Remove the oxygen completely", "Prepare for intubation"],
            rationale: "COPD patients retain CO2 and rely on hypoxic drive. Target SpO2: 88-92%. Higher oxygen can suppress respiratory drive. 91% is within acceptable range. Monitor closely, but don't over-oxygenate. High-flow O2 can cause respiratory failure in COPD.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is teaching about proper hand hygiene. When is alcohol-based hand rub NOT appropriate?",
            answer: "When hands are visibly soiled or contaminated with blood",
            wrongAnswers: ["Before entering a patient room", "After removing gloves", "Between caring for different patients"],
            rationale: "Alcohol-based rubs are effective for most situations but cannot remove visible soil, blood, or body fluids. Use soap and water when hands are visibly dirty, after caring for C. diff patients, and before eating. Rub hands for 20+ seconds.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A child is prescribed amoxicillin for otitis media. What should the nurse teach the parents?",
            answer: "Complete the entire course of antibiotics even if symptoms improve",
            wrongAnswers: ["Stop medication when fever resolves", "Give only half the dose to reduce side effects", "Save remaining medication for future infections"],
            rationale: "Incomplete antibiotic courses contribute to antibiotic resistance. Even when symptoms improve, bacteria may remain. Complete full course as prescribed. Don't save antibiotics. Report allergic reactions (rash, difficulty breathing) immediately.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient in labor has a prolapsed umbilical cord. What is the nurse's priority action?",
            answer: "Apply upward pressure to the presenting part to relieve cord compression",
            wrongAnswers: ["Push the cord back into the vagina", "Have the patient bear down", "Wait for spontaneous delivery"],
            rationale: "Prolapsed cord is an emergency. Push presenting part UP off the cord (not cord back in). Position patient in Trendelenburg or knee-chest. Keep cord moist with saline. Prepare for emergency cesarean. Continuous fetal monitoring.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with depression states 'I have a plan to end my life tonight.' What is the nurse's priority response?",
            answer: "Ask directly about the plan and means, then initiate safety precautions",
            wrongAnswers: ["Change the subject to something positive", "Leave to get the physician", "Promise to keep it confidential"],
            rationale: "Direct questioning about suicide does NOT increase risk. Assess plan, means, and intent. Having a specific plan with available means = high risk. Never leave patient alone. Never promise confidentiality for safety issues. Initiate suicide precautions immediately.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is delegating tasks to unlicensed assistive personnel (UAP). Which task is appropriate to delegate?",
            answer: "Measuring and recording vital signs on a stable patient",
            wrongAnswers: ["Administering IV push medications", "Performing initial patient assessment", "Teaching a newly diagnosed diabetic about insulin"],
            rationale: "UAP can perform routine tasks on stable patients: vital signs, hygiene, feeding, ambulation, I&O. RNs cannot delegate assessment, teaching, IV medications, or unstable patient care. Remember the 5 Rights of Delegation.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient is admitted with suspected meningitis. Which isolation precaution should be implemented?",
            answer: "Droplet precautions",
            wrongAnswers: ["Contact precautions only", "Airborne precautions", "Standard precautions only"],
            rationale: "Bacterial meningitis requires droplet precautions: private room, mask within 3 feet of patient. N. meningitidis spreads via respiratory droplets. Healthcare workers in close contact need prophylactic antibiotics. Different from TB which requires airborne precautions.",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with cirrhosis has a serum ammonia level of 90 mcg/dL. Which medication should the nurse anticipate?",
            answer: "Lactulose",
            wrongAnswers: ["Spironolactone", "Propranolol", "Vitamin K"],
            rationale: "Elevated ammonia causes hepatic encephalopathy. Lactulose traps ammonia in the gut for excretion. Goal: 2-3 soft stools/day. Also restrict protein temporarily. Monitor for asterixis, confusion. Normal ammonia: 15-45 mcg/dL.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is caring for a patient with chest tubes. Which finding requires immediate intervention?",
            answer: "Continuous bubbling in the water seal chamber",
            wrongAnswers: ["Tidaling in the water seal chamber", "Drainage of 50 mL/hour", "Fluctuation with breathing"],
            rationale: "Continuous bubbling indicates air leak in the system. Check all connections, assess insertion site. Tidaling (fluctuation with breathing) is NORMAL. Absence of tidaling may indicate obstruction or lung re-expansion. Never clamp chest tubes without order.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A 2-year-old is admitted with suspected epiglottitis. Which action should the nurse avoid?",
            answer: "Examining the throat with a tongue depressor",
            wrongAnswers: ["Keeping the child calm", "Monitoring oxygen saturation", "Preparing emergency airway equipment"],
            rationale: "NEVER examine the throat in suspected epiglottitis - can cause complete airway obstruction. Keep child calm, upright, NPO. Have emergency intubation equipment ready. Classic signs: drooling, tripod position, stridor, high fever.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A postpartum patient's fundus is boggy and displaced to the right. What should the nurse do first?",
            answer: "Have the patient empty her bladder",
            wrongAnswers: ["Administer oxytocin immediately", "Prepare for surgery", "Apply ice packs to the abdomen"],
            rationale: "Fundus displaced to the right usually indicates full bladder. Have patient void first, then reassess. If still boggy after emptying bladder, massage fundus and notify provider. Full bladder prevents uterine contraction and increases hemorrhage risk.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient taking lithium has a level of 2.0 mEq/L. What symptoms should the nurse expect?",
            answer: "Severe toxicity: confusion, seizures, cardiac arrhythmias",
            wrongAnswers: ["Therapeutic effect with no symptoms", "Mild hand tremor only", "Increased energy and alertness"],
            rationale: "Lithium therapeutic range: 0.6-1.2 mEq/L. Level of 2.0 = severe toxicity. Symptoms: confusion, ataxia, seizures, arrhythmias, renal failure. Hold lithium, notify provider, monitor cardiac rhythm, prepare for dialysis. Ensure adequate hydration and sodium intake.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is caring for a patient with a new colostomy. Which food should be recommended to reduce odor?",
            answer: "Yogurt and parsley",
            wrongAnswers: ["Beans and cabbage", "Eggs and fish", "Onions and garlic"],
            rationale: "Odor-reducing foods: yogurt, parsley, buttermilk. Odor-causing foods: eggs, fish, onions, garlic, cabbage, beans. Gas-producing: beans, carbonated drinks, chewing gum. Each patient responds differently - keep a food diary.",
            contentCategory: .medSurg,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A patient with borderline personality disorder threatens to harm herself if the nurse leaves the room. What is the best response?",
            answer: "Set clear limits while ensuring safety monitoring continues",
            wrongAnswers: ["Stay in the room indefinitely", "Tell the patient you don't believe her", "Ignore the behavior completely"],
            rationale: "Borderline PD often involves manipulation and fear of abandonment. Set firm, consistent limits while ensuring safety. Don't reinforce manipulative behavior by staying, but don't dismiss safety concerns. Arrange for appropriate observation level.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .hard,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "During a fire emergency, what does the 'A' in RACE stand for?",
            answer: "Alarm - activate the fire alarm",
            wrongAnswers: ["Assess - check patient conditions", "Assist - help firefighters", "Avoid - stay away from flames"],
            rationale: "RACE: R-Rescue patients in immediate danger, A-Alarm (pull fire alarm, call 911), C-Confine/Contain (close doors), E-Extinguish/Evacuate. Know fire extinguisher use: PASS (Pull, Aim, Squeeze, Sweep).",
            contentCategory: .safety,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        ),
        Flashcard(
            question: "A nurse is triaging patients in the emergency department. Which patient should be seen first?",
            answer: "Patient with chest pain radiating to the left arm",
            wrongAnswers: ["Patient with sprained ankle", "Patient with sore throat for 3 days", "Patient requesting prescription refill"],
            rationale: "Chest pain radiating to arm suggests MI - life-threatening emergency. Triage priority: immediate threats to life (airway, breathing, circulation). Sprained ankle, sore throat, and prescription refills are lower priority.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: true
        ),
        Flashcard(
            question: "A patient asks why the nurse is checking two identifiers before medication administration. What is the best response?",
            answer: "This ensures I'm giving the right medication to the right patient",
            wrongAnswers: ["It's just hospital policy that I have to follow", "I don't trust what you tell me", "The computer makes me do it"],
            rationale: "Two patient identifiers (name + DOB, or name + MRN) are required before any medication, treatment, or procedure. This is a critical safety measure to prevent wrong-patient errors. Explain rationale to promote patient involvement in safety.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: true
        )
    ]

    static var allCards: [Flashcard] {
        freeCards + premiumCards
    }
}

// MARK: - Managers

class AppManager: ObservableObject {
    @Published var currentScreen: Screen

    init() {
        // Check if user has seen onboarding
        if !PersistenceManager.shared.hasSeenOnboarding() {
            currentScreen = .onboarding
        } else if !AuthManager.shared.isAuthenticated {
            // Onboarding done but not authenticated
            currentScreen = .auth
        } else {
            currentScreen = .menu
        }
    }

    func completeOnboarding() {
        PersistenceManager.shared.setOnboardingComplete()
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreen = .auth
        }
    }

    func completeAuth() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreen = .menu
        }
        // Auto-sync data after login
        Task {
            print("🔄 Auto-syncing after login...")
            await CloudSyncManager.shared.syncAll()
            print("🔄 Auto-sync complete")
        }
    }

    func signOut() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreen = .auth
        }
    }
}

class SubscriptionManager: ObservableObject {
    @Published var isSubscribed: Bool = false {
        didSet { updatePremiumAccess() }
    }
    @Published var hasSupabasePremium: Bool = false {
        didSet { updatePremiumAccess() }
    }
    @Published var hasPremiumAccess: Bool = false
    @Published var products: [Product] = []
    @Published var lifetimeProduct: Product?
    @Published var purchaseError: String?
    @Published var isLoading: Bool = false

    private let subscriptionIDs = ["com.cozynclex.premium.weekly", "com.cozynclex.premium.monthly", "com.cozynclex.premium.yearly"]
    private let lifetimeProductID = "com.cozynclex.lifetime"
    private var updateListenerTask: Task<Void, Error>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Debug Flag (set to true for testing premium features)
    #if DEBUG
    private let forceDebugPremium = false  // Set to true to test premium features
    #else
    private let forceDebugPremium = false
    #endif

    private func updatePremiumAccess() {
        hasPremiumAccess = isSubscribed || hasSupabasePremium
    }

    init() {
        // Load cached subscription status
        isSubscribed = PersistenceManager.shared.loadSubscriptionStatus()

        // Debug override for testing
        if forceDebugPremium {
            isSubscribed = true
        }

        // Update premium access based on initial values
        updatePremiumAccess()

        // Start listening for transactions
        updateListenerTask = listenForTransactions()

        // Observe AuthManager's userProfile changes for Supabase premium
        AuthManager.shared.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                let isPremium = profile?.isPremium ?? false
                print("💎 SubscriptionManager: profile changed, isPremium = \(isPremium)")
                self?.hasSupabasePremium = isPremium
            }
            .store(in: &cancellables)

        // Load products and check subscription status
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
            // Sync any StoreKit premium to Supabase
            await syncPremiumToSupabase()
        }

        // Also sync when auth state changes
        AuthManager.shared.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    Task {
                        await self?.syncPremiumToSupabase()
                    }
                } else {
                    // User logged out - reset premium state to prevent leaking to next user
                    self?.isSubscribed = false
                    self?.hasSupabasePremium = false
                    // Re-check StoreKit for actual subscription status
                    Task {
                        await self?.checkSubscriptionStatus()
                    }
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        updateListenerTask?.cancel()
    }

    @MainActor
    func loadProducts() async {
        do {
            // Load subscription products
            products = try await Product.products(for: subscriptionIDs)
            products.sort { $0.price < $1.price }

            // Load lifetime product separately
            let lifetimeProducts = try await Product.products(for: [lifetimeProductID])
            lifetimeProduct = lifetimeProducts.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    @MainActor
    func purchase(_ product: Product) async {
        isLoading = true
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateSubscriptionStatus()
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval"
            @unknown default:
                break
            }
        } catch StoreError.failedVerification {
            purchaseError = "Purchase verification failed"
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    @MainActor
    func checkSubscriptionStatus() async {
        // Debug override - skip StoreKit check
        if forceDebugPremium {
            isSubscribed = true
            return
        }

        var hasStoreKitAccess = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                // Check for active subscription OR lifetime purchase
                if transaction.productType == .autoRenewable || transaction.productType == .nonConsumable {
                    hasStoreKitAccess = true
                    break
                }
            } catch {
                continue
            }
        }

        isSubscribed = hasStoreKitAccess
        PersistenceManager.shared.saveSubscriptionStatus(hasStoreKitAccess)
    }

    @MainActor
    func updateSubscriptionStatus() async {
        await checkSubscriptionStatus()
        // Sync premium status to Supabase for cross-device access
        await syncPremiumToSupabase()
    }

    @MainActor
    private func syncPremiumToSupabase() async {
        guard AuthManager.shared.isAuthenticated,
              let profile = AuthManager.shared.userProfile else { return }

        // Only sync if user has StoreKit premium and profile isn't already premium
        guard isSubscribed && !profile.isPremium else { return }

        do {
            struct PremiumUpdate: Encodable {
                let is_premium: Bool
                let updated_at: String
            }
            let update = PremiumUpdate(is_premium: true, updated_at: ISO8601DateFormatter().string(from: Date()))

            try await SupabaseConfig.client
                .from("user_profiles")
                .update(update)
                .eq("id", value: profile.id.uuidString)
                .execute()
            print("💎 Synced premium status to Supabase")

            // Reload profile to get updated premium status
            await AuthManager.shared.checkSession()
        } catch {
            print("💎 Failed to sync premium to Supabase: \(error)")
        }
    }

    @MainActor
    func restore() async {
        isLoading = true
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // Legacy method - now requires actual product
    func subscribe() {
        if let product = products.first {
            Task {
                await purchase(product)
            }
        }
        // Do nothing if no products - user must wait for products to load
    }

    /// Resets subscription state for new user (called on logout)
    @MainActor
    func resetForNewUser() {
        isSubscribed = false
        hasSupabasePremium = false
        hasPremiumAccess = false
        purchaseError = nil
        // Re-check actual subscription status from StoreKit
        Task {
            await checkSubscriptionStatus()
        }
    }
}

enum StoreError: Error {
    case failedVerification
}

class CardManager: ObservableObject {
    static let shared = CardManager()

    @Published var savedCardIDs: Set<UUID> = []
    @Published var masteredCardIDs: Set<UUID> = []
    @Published var consecutiveCorrect: [UUID: Int] = [:]
    @Published var currentFilter: CardFilter = .all
    @Published var userCreatedCards: [Flashcard] = []
    @Published var studySets: [StudySet] = []
    @Published var selectedCategories: Set<ContentCategory> = Set(ContentCategory.allCases)
    @Published var spacedRepData: [UUID: SpacedRepetitionData] = [:]
    @Published var cardNotes: [UUID: CardNote] = [:]
    @Published var flaggedCardIDs: Set<UUID> = []
    @Published var testHistory: [TestResult] = []
    @Published var sessionCards: [Flashcard] = [] // Cards selected for current game session
    @Published var resumeProgress: SessionProgress? // Progress to restore when resuming a session
    @Published var remoteCardsCount: Int = 0 // Triggers view updates when remote cards change

    let masteryThreshold = 3
    private let persistence = PersistenceManager.shared
    private let syncManager = SyncManager.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadData()

        // Observe changes to remote cards and trigger view updates
        SupabaseContentProvider.shared.$remoteCards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cards in
                self?.remoteCardsCount = cards.count
            }
            .store(in: &cancellables)
    }

    // MARK: - Remote Cards (from Supabase)

    /// Get cards from remote content provider (Supabase)
    var remoteCards: [Flashcard] {
        SupabaseContentProvider.shared.allRemoteCards
    }

    /// Get free remote cards
    var freeRemoteCards: [Flashcard] {
        SupabaseContentProvider.shared.freeRemoteCards
    }

    /// Get premium remote cards
    var premiumRemoteCards: [Flashcard] {
        SupabaseContentProvider.shared.premiumRemoteCards
    }

    // MARK: - Persistence

    func loadData() {
        savedCardIDs = persistence.loadSavedCards()
        masteredCardIDs = persistence.loadMasteredCards()
        consecutiveCorrect = persistence.loadConsecutiveCorrect()
        userCreatedCards = persistence.loadUserCards()
        studySets = persistence.loadStudySets()
        spacedRepData = persistence.loadSpacedRepData()
        selectedCategories = persistence.loadSelectedCategories()
        cardNotes = persistence.loadCardNotes()
        flaggedCardIDs = persistence.loadFlaggedCards()
        testHistory = persistence.loadTestHistory()
    }

    func saveAll() {
        persistence.saveSavedCards(savedCardIDs)
        persistence.saveMasteredCards(masteredCardIDs)
        persistence.saveConsecutiveCorrect(consecutiveCorrect)
        persistence.saveUserCards(userCreatedCards)
        persistence.saveStudySets(studySets)
        persistence.saveSpacedRepData(spacedRepData)
        persistence.saveSelectedCategories(selectedCategories)
        persistence.saveCardNotes(cardNotes)
        persistence.saveFlaggedCards(flaggedCardIDs)
        persistence.saveTestHistory(testHistory)

        // Mark user progress for sync
        syncManager.markChanged(CloudKitConfig.RecordType.userProgress, id: "main")
    }

    /// Resets all in-memory state for a new user (called on logout)
    func resetForNewUser() {
        savedCardIDs = []
        masteredCardIDs = []
        consecutiveCorrect = [:]
        currentFilter = .all
        userCreatedCards = []
        studySets = []
        selectedCategories = Set(ContentCategory.allCases)
        spacedRepData = [:]
        cardNotes = [:]
        flaggedCardIDs = []
        testHistory = []
        sessionCards = []
        resumeProgress = nil
    }

    // MARK: - Notes

    func getNote(for cardID: UUID) -> CardNote? {
        return cardNotes[cardID]
    }

    func saveNote(for cardID: UUID, text: String) {
        if text.isEmpty {
            cardNotes.removeValue(forKey: cardID)
        } else {
            if var existing = cardNotes[cardID] {
                existing.note = text
                existing.modifiedDate = Date()
                cardNotes[cardID] = existing
            } else {
                cardNotes[cardID] = CardNote(cardID: cardID, note: text)
            }
        }
        persistence.saveCardNotes(cardNotes)
        syncManager.markChanged(CloudKitConfig.RecordType.cardNote, id: cardID.uuidString)
    }

    // MARK: - Flagging

    func toggleFlagged(_ card: Flashcard) {
        if flaggedCardIDs.contains(card.id) {
            flaggedCardIDs.remove(card.id)
        } else {
            flaggedCardIDs.insert(card.id)
        }
        persistence.saveFlaggedCards(flaggedCardIDs)
    }

    func isFlagged(_ card: Flashcard) -> Bool {
        flaggedCardIDs.contains(card.id)
    }

    func getFlaggedCards(isSubscribed: Bool) -> [Flashcard] {
        getAvailableCards(isSubscribed: isSubscribed).filter { flaggedCardIDs.contains($0.id) }
    }

    // MARK: - Test History

    func saveTestResult(_ result: TestResult) {
        testHistory.insert(result, at: 0)
        // Keep only last 50 tests
        if testHistory.count > 50 {
            testHistory = Array(testHistory.prefix(50))
        }
        persistence.saveTestHistory(testHistory)
        syncManager.markChanged(CloudKitConfig.RecordType.testResult, id: result.id.uuidString)
    }

    var allCards: [Flashcard] {
        // Prefer remote cards if available, otherwise use bundled
        if !remoteCards.isEmpty {
            return remoteCards + userCreatedCards
        }
        return Flashcard.freeCards + (SubscriptionManager().isSubscribed ? Flashcard.premiumCards : []) + userCreatedCards
    }

    /// Maximum free cards for non-subscribers
    private let maxFreeCards = 50

    func getAvailableCards(isSubscribed: Bool) -> [Flashcard] {
        // If remote cards are available, use those
        if !remoteCards.isEmpty {
            if isSubscribed {
                return remoteCards + userCreatedCards
            } else {
                // For free users: pick the best 50 cards across all categories
                // Prioritize non-premium cards first, then fill from premium to reach 50
                let nonPremium = freeRemoteCards
                if nonPremium.count >= maxFreeCards {
                    return Array(nonPremium.prefix(maxFreeCards)) + userCreatedCards
                } else {
                    // Not enough non-premium cards — fill with a curated selection
                    // Pick a balanced mix across categories and difficulties
                    let remaining = maxFreeCards - nonPremium.count
                    let premiumPool = remoteCards.filter { $0.isPremium }
                    let selected = selectBalancedCards(from: premiumPool, count: remaining)
                    return nonPremium + selected + userCreatedCards
                }
            }
        }
        // Fall back to bundled cards
        let baseCards = isSubscribed ? Flashcard.allCards : Flashcard.freeCards
        return baseCards + userCreatedCards
    }

    /// Select a balanced mix of cards across categories and difficulties
    private func selectBalancedCards(from cards: [Flashcard], count: Int) -> [Flashcard] {
        guard count > 0, !cards.isEmpty else { return [] }

        var result: [Flashcard] = []
        let categories = ContentCategory.allCases
        let perCategory = max(count / categories.count, 1)

        // Pick cards evenly across categories, preferring easy/medium difficulty
        for category in categories {
            let catCards = cards.filter { $0.contentCategory == category }
                .sorted { ($0.difficulty == .easy ? 0 : $0.difficulty == .medium ? 1 : 2) < ($1.difficulty == .easy ? 0 : $1.difficulty == .medium ? 1 : 2) }
            result.append(contentsOf: catCards.prefix(perCategory))
        }

        // If we still need more, fill from remaining cards
        if result.count < count {
            let usedIDs = Set(result.map { $0.id })
            let remaining = cards.filter { !usedIDs.contains($0.id) }
            result.append(contentsOf: remaining.prefix(count - result.count))
        }

        return Array(result.prefix(count))
    }

    func getFilteredCards(isSubscribed: Bool) -> [Flashcard] {
        var available = getAvailableCards(isSubscribed: isSubscribed)

        // For free users, skip category filtering (the 50 cards are the complete set)
        if !isSubscribed {
            switch currentFilter {
            case .all:
                return available
            case .mastered:
                let baseCards = remoteCards.isEmpty ? Flashcard.allCards : remoteCards
                let allCards = baseCards + userCreatedCards
                return allCards.filter { masteredCardIDs.contains($0.id) }
            case .saved:
                let baseCards = remoteCards.isEmpty ? Flashcard.allCards : remoteCards
                let allCards = baseCards + userCreatedCards
                return allCards.filter { savedCardIDs.contains($0.id) }
            case .userCreated:
                return userCreatedCards
            }
        }

        // Apply category filter
        if selectedCategories.count < ContentCategory.allCases.count {
            available = available.filter { selectedCategories.contains($0.contentCategory) }
        }

        switch currentFilter {
        case .all:
            return available
        case .mastered:
            // Show ALL mastered cards regardless of subscription or category filters
            let baseCards = remoteCards.isEmpty ? Flashcard.allCards : remoteCards
            let allCards = baseCards + userCreatedCards
            return allCards.filter { masteredCardIDs.contains($0.id) }
        case .saved:
            // Show ALL saved cards regardless of subscription or category filters
            let baseCards = remoteCards.isEmpty ? Flashcard.allCards : remoteCards
            let allCards = baseCards + userCreatedCards
            return allCards.filter { savedCardIDs.contains($0.id) }
        case .userCreated:
            return userCreatedCards.filter { selectedCategories.contains($0.contentCategory) }
        }
    }

    func getGameCards(isSubscribed: Bool) -> [Flashcard] {
        var cards = getAvailableCards(isSubscribed: isSubscribed).filter { !masteredCardIDs.contains($0.id) }
        // Apply category filter for games
        if selectedCategories.count < ContentCategory.allCases.count {
            cards = cards.filter { selectedCategories.contains($0.contentCategory) }
        }

        // Sort by weakness (prioritize cards with lower consecutive correct - i.e., cards user struggles with)
        // Cards with 0 correct streak come first, then 1, then 2
        cards.sort { card1, card2 in
            let streak1 = consecutiveCorrect[card1.id] ?? 0
            let streak2 = consecutiveCorrect[card2.id] ?? 0
            return streak1 < streak2
        }

        // Shuffle within weakness tiers to add variety
        // Group by streak and shuffle each group
        var weakCards: [Flashcard] = []    // streak 0
        var mediumCards: [Flashcard] = []  // streak 1
        var strongCards: [Flashcard] = []  // streak 2

        for card in cards {
            let streak = consecutiveCorrect[card.id] ?? 0
            if streak == 0 {
                weakCards.append(card)
            } else if streak == 1 {
                mediumCards.append(card)
            } else {
                strongCards.append(card)
            }
        }

        // Shuffle each tier and combine (weak first, then medium, then strong)
        return weakCards.shuffled() + mediumCards.shuffled() + strongCards.shuffled()
    }

    // MARK: - Spaced Repetition

    func getCardsForSpacedReview(isSubscribed: Bool) -> [Flashcard] {
        let available = getAvailableCards(isSubscribed: isSubscribed)
        var dueCards: [Flashcard] = []
        var newCards: [Flashcard] = []

        for card in available {
            if let srData = spacedRepData[card.id] {
                if srData.isDue {
                    dueCards.append(card)
                }
            } else {
                // New card - never reviewed
                newCards.append(card)
            }
        }

        // Apply category filter
        if selectedCategories.count < ContentCategory.allCases.count {
            dueCards = dueCards.filter { selectedCategories.contains($0.contentCategory) }
            newCards = newCards.filter { selectedCategories.contains($0.contentCategory) }
        }

        // Prioritize due cards, then add new cards (limit new cards to 20 per session)
        let limitedNewCards = Array(newCards.prefix(20))
        return dueCards + limitedNewCards
    }

    func getDueCardCount(isSubscribed: Bool) -> Int {
        let available = getAvailableCards(isSubscribed: isSubscribed)
        return available.filter { card in
            guard let srData = spacedRepData[card.id] else { return true }
            return srData.isDue
        }.count
    }

    func recordSpacedRepResponse(card: Flashcard, quality: Int) {
        var data = spacedRepData[card.id] ?? SpacedRepetitionData()
        data.processResponse(quality: quality)
        spacedRepData[card.id] = data
        persistence.saveSpacedRepData(spacedRepData)
    }

    func getSpacedRepInfo(card: Flashcard) -> SpacedRepetitionData? {
        return spacedRepData[card.id]
    }

    // MARK: - Category Management

    func toggleCategory(_ category: ContentCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        persistence.saveSelectedCategories(selectedCategories)
    }

    func selectAllCategories() {
        selectedCategories = Set(ContentCategory.allCases)
        persistence.saveSelectedCategories(selectedCategories)
    }

    func deselectAllCategories() {
        selectedCategories = []
        persistence.saveSelectedCategories(selectedCategories)
    }

    // MARK: - Card Actions

    func toggleSaved(_ card: Flashcard) {
        let isSaved: Bool
        if savedCardIDs.contains(card.id) {
            savedCardIDs.remove(card.id)
            isSaved = false
        } else {
            savedCardIDs.insert(card.id)
            isSaved = true
        }
        persistence.saveSavedCards(savedCardIDs)

        // Sync to cloud
        Task {
            await CloudSyncManager.shared.updateCardProgress(cardId: card.id, isSaved: isSaved)
        }
    }

    func recordCorrectAnswer(_ card: Flashcard) {
        let current = consecutiveCorrect[card.id] ?? 0
        let newCount = current + 1
        consecutiveCorrect[card.id] = newCount
        var wasMastered = false
        if newCount >= masteryThreshold {
            let wasNewlyMastered = !masteredCardIDs.contains(card.id)
            masteredCardIDs.insert(card.id)
            persistence.saveMasteredCards(masteredCardIDs)
            wasMastered = true

            // Trigger review prompt at mastery milestones
            if wasNewlyMastered {
                ReviewManager.shared.recordMasteryMilestone(totalMastered: masteredCardIDs.count)
            }
        }
        persistence.saveConsecutiveCorrect(consecutiveCorrect)

        // Sync to cloud
        Task {
            await CloudSyncManager.shared.updateCardProgress(
                cardId: card.id,
                isMastered: wasMastered ? true : nil,
                consecutiveCorrect: newCount
            )
        }

        // Also update spaced repetition (quality 4 = correct with hesitation)
        recordSpacedRepResponse(card: card, quality: 4)
    }

    func recordWrongAnswer(_ card: Flashcard) {
        consecutiveCorrect[card.id] = 0
        persistence.saveConsecutiveCorrect(consecutiveCorrect)

        // Sync to cloud
        Task {
            await CloudSyncManager.shared.updateCardProgress(cardId: card.id, consecutiveCorrect: 0)
        }

        // Also update spaced repetition (quality 1 = wrong)
        recordSpacedRepResponse(card: card, quality: 1)
    }

    func recordEasyAnswer(_ card: Flashcard) {
        // Perfect recall - update spaced repetition with quality 5
        recordCorrectAnswer(card)
        recordSpacedRepResponse(card: card, quality: 5)
    }

    func toggleMastered(_ card: Flashcard) {
        let isMastered: Bool
        if masteredCardIDs.contains(card.id) {
            masteredCardIDs.remove(card.id)
            consecutiveCorrect[card.id] = 0
            isMastered = false
        } else {
            masteredCardIDs.insert(card.id)
            isMastered = true
        }
        persistence.saveMasteredCards(masteredCardIDs)
        persistence.saveConsecutiveCorrect(consecutiveCorrect)

        // Sync to cloud
        Task {
            await CloudSyncManager.shared.updateCardProgress(
                cardId: card.id,
                isMastered: isMastered,
                consecutiveCorrect: isMastered ? masteryThreshold : 0
            )
        }
    }

    func isSaved(_ card: Flashcard) -> Bool { savedCardIDs.contains(card.id) }
    func isMastered(_ card: Flashcard) -> Bool { masteredCardIDs.contains(card.id) }
    func progressTowardsMastery(_ card: Flashcard) -> Int { consecutiveCorrect[card.id] ?? 0 }

    // Count of mastered cards that actually exist in the database
    var validMasteredCount: Int {
        // Use remote cards if available, otherwise fallback to bundled cards
        let baseCards = remoteCards.isEmpty ? Flashcard.allCards : remoteCards
        let allCards = baseCards + userCreatedCards
        let allCardIDs = Set(allCards.map { $0.id })
        return masteredCardIDs.filter { allCardIDs.contains($0) }.count
    }

    // Count of saved cards that actually exist in the database
    var validSavedCount: Int {
        // Use remote cards if available, otherwise fallback to bundled cards
        let baseCards = remoteCards.isEmpty ? Flashcard.allCards : remoteCards
        let allCards = baseCards + userCreatedCards
        let allCardIDs = Set(allCards.map { $0.id })
        return savedCardIDs.filter { allCardIDs.contains($0) }.count
    }

    // MARK: - User Cards

    func addUserCard(_ card: Flashcard) {
        userCreatedCards.append(card)
        persistence.saveUserCards(userCreatedCards)
        syncManager.markChanged(CloudKitConfig.RecordType.userCard, id: card.id.uuidString)
    }

    func deleteUserCard(_ card: Flashcard) {
        userCreatedCards.removeAll { $0.id == card.id }
        persistence.saveUserCards(userCreatedCards)
        // Mark for deletion sync
        syncManager.markChanged(CloudKitConfig.RecordType.userCard, id: card.id.uuidString)
    }

    // MARK: - Study Sets

    func addStudySet(_ set: StudySet) {
        studySets.append(set)
        persistence.saveStudySets(studySets)
        syncManager.markChanged(CloudKitConfig.RecordType.studySet, id: set.id.uuidString)
    }

    func updateStudySet(_ set: StudySet) {
        if let index = studySets.firstIndex(where: { $0.id == set.id }) {
            studySets[index] = set
            persistence.saveStudySets(studySets)
            syncManager.markChanged(CloudKitConfig.RecordType.studySet, id: set.id.uuidString)
        }
    }

    func deleteStudySet(_ set: StudySet) {
        studySets.removeAll { $0.id == set.id }
        persistence.saveStudySets(studySets)
        syncManager.markChanged(CloudKitConfig.RecordType.studySet, id: set.id.uuidString)
    }

    // MARK: - Search

    func searchCards(query: String, isSubscribed: Bool) -> [Flashcard] {
        guard !query.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        return getAvailableCards(isSubscribed: isSubscribed).filter {
            $0.question.lowercased().contains(lowercasedQuery) ||
            $0.answer.lowercased().contains(lowercasedQuery) ||
            $0.contentCategory.rawValue.lowercased().contains(lowercasedQuery)
        }
    }
}

class StatsManager: ObservableObject {
    static let shared = StatsManager()

    @Published var stats: UserStats = UserStats()

    private let persistence = PersistenceManager.shared
    private let syncManager = SyncManager.shared

    private var isInitializing = true

    private init() {
        stats = persistence.loadUserStats()
        checkStreakReset()
        isInitializing = false
    }

    func loadData() {
        stats = persistence.loadUserStats()
        checkStreakReset()
    }

    func recordSession(cardsStudied: Int, correct: Int, timeSeconds: Int, mode: String) {
        stats.totalCardsStudied += cardsStudied
        stats.totalCorrectAnswers += correct
        stats.totalTimeSpentSeconds += timeSeconds

        let session = StudySession(date: Date(), cardsStudied: cardsStudied, correctAnswers: correct, timeSpentSeconds: timeSeconds, mode: mode)
        stats.sessions.append(session)

        // Keep only last 100 sessions to avoid bloat
        if stats.sessions.count > 100 {
            stats.sessions = Array(stats.sessions.suffix(100))
        }

        updateStreak()
        save()
    }

    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = stats.lastStudyDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysDiff == 1 {
                stats.currentStreak += 1
            } else if daysDiff > 1 {
                stats.currentStreak = 1
            }
            // daysDiff == 0 means same day, don't change streak
        } else {
            stats.currentStreak = 1
        }

        stats.lastStudyDate = Date()
        stats.longestStreak = max(stats.longestStreak, stats.currentStreak)
    }

    func checkStreakReset() {
        // Check if streak should be reset (missed a day)
        guard let lastDate = stats.lastStudyDate else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        if daysDiff > 1 {
            stats.currentStreak = 0
            // Only persist, don't call full save() which triggers widget update
            // and can cause circular dependency during init
            persistence.saveUserStats(stats)
        }
    }

    func recordCategoryResult(category: String, correct: Bool) {
        var current = stats.categoryAccuracy[category] ?? CategoryStats()
        current.total += 1
        if correct { current.correct += 1 }
        stats.categoryAccuracy[category] = current
        save()
    }

    func getWeakCategories() -> [String] {
        // Return categories with accuracy below 70% (minimum 1 question answered)
        return stats.categoryAccuracy
            .filter { $0.value.total >= 1 && $0.value.accuracy < 70 }
            .sorted { $0.value.accuracy < $1.value.accuracy }
            .map { $0.key }
    }

    func getStrongCategories() -> [String] {
        // Return categories with accuracy above 80%
        return stats.categoryAccuracy
            .filter { $0.value.total >= 5 && $0.value.accuracy >= 80 }
            .sorted { $0.value.accuracy > $1.value.accuracy }
            .map { $0.key }
    }

    func save() {
        persistence.saveUserStats(stats)
        syncManager.markChanged(CloudKitConfig.RecordType.userStats, id: "main")

        // Skip widget update during init to avoid circular dependency with DailyGoalsManager
        guard !isInitializing else { return }

        // Update widget data
        let goals = DailyGoalsManager.shared
        let completedGoals = goals.dailyGoals.filter { $0.isCompleted }.count
        WidgetDataManager.update(
            streak: goals.currentStreak, level: goals.currentLevel, levelTitle: goals.levelTitle,
            totalXP: goals.totalXP, xpProgress: goals.xpProgressPercent,
            totalCardsStudied: stats.totalCardsStudied,
            accuracy: stats.overallAccuracy,
            dailyGoalsCompleted: completedGoals, dailyGoalsTotal: goals.dailyGoals.count,
            cardOfTheDayQuestion: goals.cardOfTheDay?.question ?? "Start studying to see your Card of the Day!",
            cardOfTheDayCategory: goals.cardOfTheDay?.contentCategory.rawValue ?? "General"
        )
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Resets all in-memory state for a new user (called on logout)
    func resetForNewUser() {
        stats = UserStats()
    }
}

// MARK: - App Review Manager
import StoreKit

class ReviewManager {
    static let shared = ReviewManager()

    private let defaults = UserDefaults.standard
    private let reviewRequestCountKey = "reviewRequestCount"
    private let lastReviewRequestDateKey = "lastReviewRequestDate"
    private let hasRequestedReviewKey = "hasRequestedReview"

    private var reviewRequestCount: Int {
        get { defaults.integer(forKey: reviewRequestCountKey) }
        set { defaults.set(newValue, forKey: reviewRequestCountKey) }
    }

    private var lastReviewRequestDate: Date? {
        get { defaults.object(forKey: lastReviewRequestDateKey) as? Date }
        set { defaults.set(newValue, forKey: lastReviewRequestDateKey) }
    }

    private var hasRequestedReview: Bool {
        get { defaults.bool(forKey: hasRequestedReviewKey) }
        set { defaults.set(newValue, forKey: hasRequestedReviewKey) }
    }

    /// Call this when the user completes a quiz with good results
    func recordPositiveExperience() {
        reviewRequestCount += 1
        checkAndRequestReview()
    }

    /// Call this when user unlocks an achievement
    func recordAchievementUnlocked() {
        reviewRequestCount += 2 // Achievements count double
        checkAndRequestReview()
    }

    /// Call this when user reaches a streak milestone (3, 7, 14 days)
    func recordStreakMilestone() {
        reviewRequestCount += 3 // Streaks count triple
        checkAndRequestReview()
    }

    /// Call this when user masters a card at certain milestones
    func recordMasteryMilestone(totalMastered: Int) {
        let milestones = [10, 25, 50, 100, 200, 500]
        if milestones.contains(totalMastered) {
            reviewRequestCount += 2 // Mastery milestones count double
            checkAndRequestReview()
        }
    }

    private func checkAndRequestReview() {
        // Don't request too frequently - minimum 30 days between requests
        if let lastRequest = lastReviewRequestDate {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequest, to: Date()).day ?? 0
            if daysSinceLastRequest < 30 {
                return
            }
        }

        // Request review after 5+ positive interactions
        // Or immediately if user unlocks achievement and hasn't been asked before
        if reviewRequestCount >= 5 || (!hasRequestedReview && reviewRequestCount >= 3) {
            requestReview()
        }
    }

    private func requestReview() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
                self.lastReviewRequestDate = Date()
                self.hasRequestedReview = true
                self.reviewRequestCount = 0 // Reset counter after request
            }
        }
    }
}

// MARK: - Speech Synthesizer
class SpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    /// Preferred female voices in order of quality (enhanced voices sound more natural)
    private var preferredVoice: AVSpeechSynthesisVoice? {
        // Try enhanced/premium Samantha first (most natural US female voice)
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.enhanced.en-US.Samantha") {
            return voice
        }
        // Fall back to premium Samantha
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Samantha") {
            return voice
        }
        // Fall back to compact Samantha
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-US.Samantha") {
            return voice
        }
        // Last resort: default US English voice
        return AVSpeechSynthesisVoice(language: "en-US")
    }

    func speak(_ text: String) {
        // Stop any current speech first
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = preferredVoice

        // Natural speech rate (0.5 is default, 0.52 is slightly faster and more natural)
        utterance.rate = 0.52

        // Slight pitch adjustment for warmth (1.0 is default, 1.05 is slightly higher/warmer)
        utterance.pitchMultiplier = 1.05

        // Add small delays for more natural pacing
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1

        // Volume (1.0 is max)
        utterance.volume = 0.9

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @StateObject private var appManager = AppManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var cardManager = CardManager.shared
    @StateObject private var statsManager = StatsManager.shared
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var appearanceManager = AppearanceManager.shared

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()

            switch appManager.currentScreen {
            case .onboarding: OnboardingView()
            case .auth: AuthView(onAuthenticated: { appManager.completeAuth() })
            case .menu: MainMenuView()
            case .flashcardsGame: StudyFlashcardsView()
            case .learnGame: BearLearnView()
            case .matchGame: CozyMatchView()
            case .cardBrowser: CardBrowserView()
            case .createCard: CreateCardView()
            case .studySets: StudySetsView()
            case .testMode: TestModeView()
            case .writeMode: WriteModeView()
            case .stats: StatsView()
            case .search: SearchView()
            case .blocksGame: CozyBlocksView()
            }
        }
        .environmentObject(appManager)
        .environmentObject(subscriptionManager)
        .environmentObject(cardManager)
        .environmentObject(statsManager)
        .environmentObject(speechManager)
        .preferredColorScheme(appearanceManager.currentMode.colorScheme)
        .task {
            // Load content from Supabase on app startup
            await SupabaseContentProvider.shared.loadContent()
        }
    }
}


// MARK: - Onboarding View

struct OnboardingView: View {
    @EnvironmentObject var appManager: AppManager
    @State private var currentPage = 0
    @State private var showContent = false
    @State private var mascotOffset: CGFloat = 50
    @State private var mascotOpacity: Double = 0
    @State private var categoryAnimationProgress: [Bool] = [false, false, false, false]
    @State private var typingText: String = ""
    @State private var bearWiggle: Double = 0
    @State private var promiseChecks: [Bool] = [false, false, false]
    @State private var showPromiseButton = false
    @State private var promiseHoldProgress: CGFloat = 0
    @State private var isHoldingPromise = false
    @State private var statCounters: [Int] = [0, 0, 0]
    @State private var statsAnimated = false
    @State private var featureAnimationProgress: [Bool] = [false, false, false, false]
    @State private var pulseScale: CGFloat = 1.0
    @State private var showPaywall = false

    enum PageType {
        case welcome
        case painPoint
        case sources
        case promise
        case notifications
        case getStarted
    }

    private let pages: [(title: String, subtitle: String, icon: String, color: Color, pageType: PageType)] = [
        ("Hey future nurse!", "I'm CozyBear, and I'm here to help you crush the NCLEX", "hand.wave.fill", .pastelPink, .welcome),
        ("The NCLEX is tough.", "42% of repeat test-takers fail again. But not you.", "exclamationmark.triangle.fill", .softLavender, .painPoint),
        ("Exam-Grade Quality", "Built to meet the standard you need to pass", "checkmark.seal.fill", .skyBlue, .sources),
        ("Make a Promise", "Students who commit to daily practice are 3x more likely to pass", "heart.fill", .pastelPink, .promise),
        ("Let Bear Help You", "You promised to study daily. I'll send you one gentle nudge to keep that streak alive. No spam, just support.", "bell.fill", .peachOrange, .notifications),
        ("You're Ready!", "Let's turn that anxiety into confidence", "star.fill", .mintGreen, .getStarted)
    ]

    // NCLEX Categories data
    private var nclexCategories: [(icon: String, name: String, description: String, color: Color)] {
        [
            ("shield.checkered", "Safe & Effective Care", "Infection control, safety, legal & ethical", .skyBlue),
            ("heart.circle", "Health Promotion", "Wellness, prevention & screening", .mintGreen),
            ("brain.head.profile", "Psychosocial Integrity", "Mental health & coping", .softLavender),
            ("waveform.path.ecg", "Physiological Integrity", "Body systems & pharmacology", .pastelPink)
        ]
    }

    private let fullWelcomeText = "I'm CozyBear, and I'm here to help you crush the NCLEX"

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
                Spacer().frame(height: geo.size.height * 0.04)

                // Mascot - proportional to screen, with wiggle on welcome
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
                        // Wiggle after landing
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

                // Page content
                VStack(spacing: 12) {
                    // Icon
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

                    // Title
                    Text(pages[currentPage].title)
                        .font(.system(size: min(geo.size.width * 0.065, 26), weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .offset(y: showContent ? 0 : 20)
                        .opacity(showContent ? 1 : 0)

                    // Subtitle — typing effect on welcome page
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
                            // Animated stat counters
                            HStack(spacing: 20) {
                                OnboardingStatBubble(
                                    value: "1,000+",
                                    label: "Questions",
                                    color: .skyBlue,
                                    isAnimated: statsAnimated
                                )
                                OnboardingStatBubble(
                                    value: "9",
                                    label: "Categories",
                                    color: .mintGreen,
                                    isAnimated: statsAnimated
                                )
                                OnboardingStatBubble(
                                    value: "24/7",
                                    label: "Access",
                                    color: .softLavender,
                                    isAnimated: statsAnimated
                                )
                            }
                            .padding(.top, 8)

                            // Reassurance message
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

                    // (Categories slide removed)

                    // MARK: - Sources page
                    if pages[currentPage].pageType == .sources {
                        VStack(spacing: 10) {
                            SourceBadge(name: "Aligned with NCSBN Standards", color: .purple)
                            SourceBadge(name: "Next Gen (NGN) Format", color: .blue)
                            SourceBadge(name: "Detailed Rationales", color: .orange)
                            SourceBadge(name: "Clinical Judgment Focus", color: .mintGreen)
                        }
                        .padding(.horizontal)
                        .offset(y: showContent ? 0 : 30)
                        .opacity(showContent ? 1 : 0)
                    }

                    // (Features slide removed)

                    // MARK: - Promise page
                    if pages[currentPage].pageType == .promise {
                        VStack(spacing: 14) {
                            OnboardingPromiseRow(
                                text: "I'll study a little every day",
                                isChecked: promiseChecks[0],
                                delay: 0
                            ) { }

                            OnboardingPromiseRow(
                                text: "I won't give up when it gets hard",
                                isChecked: promiseChecks[1],
                                delay: 1
                            ) { }

                            OnboardingPromiseRow(
                                text: "I believe I can pass the NCLEX",
                                isChecked: promiseChecks[2],
                                delay: 2
                            ) { }
                        }
                        .padding(.horizontal, 20)
                        .offset(y: showContent ? 0 : 30)
                        .opacity(showContent ? 1 : 0)
                        .allowsHitTesting(false)
                    }

                    // MARK: - Notifications page
                    if pages[currentPage].pageType == .notifications {
                        VStack(spacing: 20) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.peachOrange)
                                .scaleEffect(showContent ? 1 : 0.5)
                                .opacity(showContent ? 1 : 0)

                            Text("One gentle reminder a day.\nNo spam, just support.")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
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
                    statsAnimated = false
                    promiseChecks = [false, false, false]
                    showPromiseButton = false
                    promiseHoldProgress = 0
                    isHoldingPromise = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation { showContent = true }
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
                        if pages[currentPage].pageType == .promise {
                            animatePromisesSequentially()
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
                        // Promise page: hold "I Promise" button to confirm
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.pastelPink.opacity(0.3))

                            // Fill progress
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [.pastelPink, .pastelPink.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * promiseHoldProgress)
                            }

                            // Label
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                Text(showPromiseButton ? "Hold to Promise" : "I Promise")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .gesture(
                            LongPressGesture(minimumDuration: 1.5)
                                .onChanged { _ in
                                    guard showPromiseButton, !isHoldingPromise else { return }
                                    isHoldingPromise = true
                                    HapticManager.shared.light()
                                    withAnimation(.linear(duration: 1.5)) {
                                        promiseHoldProgress = 1.0
                                    }
                                }
                                .onEnded { _ in
                                    guard showPromiseButton else { return }
                                    HapticManager.shared.success()
                                    nextPage()
                                }
                        )
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { _ in
                                    // Reset if released early
                                    if promiseHoldProgress < 1.0 {
                                        isHoldingPromise = false
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            promiseHoldProgress = 0
                                        }
                                    }
                                }
                        )
                        .opacity(showPromiseButton ? 1 : 0.4)
                        .scaleEffect(showPromiseButton ? 1 : 0.95)
                        .allowsHitTesting(showPromiseButton)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showPromiseButton)
                    } else if pages[currentPage].pageType == .notifications {
                        VStack(spacing: 10) {
                            Button(action: requestNotificationPermission) {
                                HStack(spacing: 8) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 16))
                                    Text("Turn on Reminders")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [.peachOrange, .peachOrange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                            }

                            Button(action: nextPage) {
                                Text("Not now")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
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
                        Button(action: { showPaywall = true }) {
                            HStack {
                                Text("Let's Do This")
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
                    }

                    if currentPage < pages.count - 1 && pages[currentPage].pageType != .promise && pages[currentPage].pageType != .notifications {
                        Button(action: { showPaywall = true }) {
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
            } // GeometryReader
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showContent = true }
            }
            // Start typing animation on first page
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
        .sheet(isPresented: $showPaywall, onDismiss: {
            appManager.completeOnboarding()
        }) {
            OnboardingPaywallView()
        }
    }

    func nextPage() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentPage += 1
        }
    }

    private func requestNotificationPermission() {
        NotificationManager.shared.requestPermissionAndSchedule {
            nextPage()
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

    private func animatePromisesSequentially() {
        let promiseTexts = ["I'll study a little every day", "I won't give up when it gets hard", "I believe I can pass the NCLEX"]
        for index in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.6 + 0.5) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    promiseChecks[index] = true
                }
                HapticManager.shared.light()
                if index == 2 {
                    checkAllPromises()
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
                // Wiggle the bear when all promises checked
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

// MARK: - Onboarding Paywall View

struct OnboardingPaywallView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SubscriptionSheet()

                Button(action: { dismiss() }) {
                    Text("Maybe Later")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 24)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
        }
    }
}

// MARK: - Onboarding Stat Bubble

struct OnboardingStatBubble: View {
    let value: String
    let label: String
    let color: Color
    let isAnimated: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.adaptiveWhite)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .scaleEffect(isAnimated ? 1 : 0.7)
        .opacity(isAnimated ? 1 : 0)
    }
}

// MARK: - Onboarding Feature Row

struct OnboardingFeatureRow: View {
    let icon: String
    let title: String
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
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Text(description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
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

// MARK: - Onboarding Promise Row

struct OnboardingPromiseRow: View {
    let text: String
    let isChecked: Bool
    let delay: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            if !isChecked { onTap() }
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isChecked ? Color.mintGreen : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 32, height: 32)

                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.mintGreen)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(isChecked ? .primary : .secondary)
                    .strikethrough(false)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(isChecked ? Color.mintGreen.opacity(0.08) : Color.adaptiveWhite)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Onboarding Category Card (Inline version for ContentView)

struct OnboardingCategoryCardInline: View {
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

struct SourceBadge: View {
    let name: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(color)
                .font(.system(size: 18))
            Text(name)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 30)
    }
}

// MARK: - Main Menu View

struct MainMenuView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @ObservedObject private var dailyGoalsManager = DailyGoalsManager.shared
    @StateObject private var coachMarkManager = CoachMarkManager.shared
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showSubscriptionSheet = false
    @State private var showCategoryFilter = false
    @State private var showCardOfTheDay = false
    @State private var cardOfTheDayFlipped = false
    @State private var selectedTab = 0 // 0 = Study, 1 = Progress
    @State private var showDailyMotivation = false
    @State private var showShareProgress = false
    @State private var showCardBrowse = false
    @State private var selectedGameMode: GameMode?
    @State private var showResumePrompt = false
    @State private var pendingGameMode: GameMode?
    @State private var sidebarSelection: SidebarItem? = .studyModes

    enum SidebarItem: String, Hashable, CaseIterable {
        case studyModes = "Study Modes"
        case browseCards = "Browse Cards"
        case createCard = "Create Card"
        case studySets = "Study Sets"
        case stats = "Stats"
        case progress = "Progress"
        case dailyGoals = "Daily Goals"
        case nclexReadiness = "NCLEX Readiness"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .studyModes: return "graduationcap.fill"
            case .browseCards: return "rectangle.stack.fill"
            case .createCard: return "plus.circle.fill"
            case .studySets: return "folder.fill"
            case .stats: return "chart.bar.fill"
            case .progress: return "star.fill"
            case .dailyGoals: return "target"
            case .nclexReadiness: return "checkmark.seal.fill"
            case .settings: return "gearshape.fill"
            }
        }

        var color: Color {
            switch self {
            case .studyModes: return .mintGreen
            case .browseCards: return .blue
            case .createCard: return .mintGreen
            case .studySets: return .peachOrange
            case .stats: return .softLavender
            case .progress: return .pastelPink
            case .dailyGoals: return .mintGreen
            case .nclexReadiness: return .green
            case .settings: return .gray
            }
        }

        static var studyItems: [SidebarItem] { [.studyModes, .browseCards, .createCard, .studySets] }
        static var progressItems: [SidebarItem] { [.progress, .stats, .nclexReadiness] }
    }

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet()
        }
        .sheet(isPresented: $showCategoryFilter) {
            CategoryFilterSheet()
        }
        .sheet(isPresented: $dailyGoalsManager.showLevelUpCelebration) {
            LevelUpCelebrationView()
        }
        .sheet(isPresented: $showShareProgress) {
            ShareProgressView(stats: ShareableStats(
                level: dailyGoalsManager.currentLevel,
                levelTitle: dailyGoalsManager.levelTitle,
                totalXP: dailyGoalsManager.totalXP,
                masteredCards: cardManager.validMasteredCount,
                currentStreak: dailyGoalsManager.currentStreak,
                accuracy: statsManager.stats.overallAccuracy / 100.0,
                totalStudyTimeSeconds: statsManager.stats.totalTimeSpentSeconds
            ))
        }
        .sheet(isPresented: $showDailyMotivation) {
            DailyMotivationView {
                markMotivationSeen()
            }
        }
        .sheet(isPresented: $dailyGoalsManager.showMilestoneCelebration) {
            MilestoneCelebrationView(milestone: dailyGoalsManager.milestoneCelebrationValue) {
                dailyGoalsManager.showMilestoneCelebration = false
            }
        }
        .sheet(isPresented: $showCardBrowse) {
            BrowseCardsHomeView()
        }
        .sheet(item: $selectedGameMode) { mode in
            StudySessionSetupView(gameMode: mode) { selectedCards in
                startGameMode(mode, with: selectedCards)
            }
        }
        .alert("Continue Session?", isPresented: $showResumePrompt) {
            Button("Resume", role: nil) {
                if let mode = pendingGameMode {
                    resumeGameMode(mode)
                }
                pendingGameMode = nil
            }
            Button("Start New", role: .destructive) {
                if let mode = pendingGameMode {
                    SessionProgressManager.shared.clearProgress(for: mode)
                    selectedGameMode = mode
                }
                pendingGameMode = nil
            }
            Button("Cancel", role: .cancel) {
                pendingGameMode = nil
            }
        } message: {
            if let mode = pendingGameMode,
               let progress = SessionProgressManager.shared.loadProgress(for: mode) {
                if mode == .learn {
                    let learned = progress.currentIndex
                    let remaining = progress.cardIDs.count
                    Text("You have \(learned) terms learned with \(remaining) remaining. Would you like to continue?")
                } else {
                    Text("You have a saved session with \(progress.currentIndex) of \(progress.cardIDs.count) cards completed. Would you like to continue?")
                }
            } else {
                Text("Would you like to continue your previous session?")
            }
        }
        .onAppear {
            let cards = cardManager.getAvailableCards(isSubscribed: subscriptionManager.hasPremiumAccess)
            dailyGoalsManager.selectCardOfTheDay(from: cards)
            dailyGoalsManager.checkAndResetDailyGoals()
            dailyGoalsManager.checkMilestone(masteredCount: cardManager.validMasteredCount)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                let seenToday = hasSeenMotivationToday()
                let otherModalActive = dailyGoalsManager.showMilestoneCelebration || dailyGoalsManager.showLevelUpCelebration
                if !seenToday && !otherModalActive {
                    showDailyMotivation = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if coachMarkManager.isFirstTime && !dailyGoalsManager.showMilestoneCelebration && !dailyGoalsManager.showLevelUpCelebration && !showDailyMotivation {
                    coachMarkManager.showIfNeeded(.studyTab)
                }
            }
        }
        .overlay {
            CoachMarkOverlay()
        }
        .onOpenURL { url in
            if url.scheme == "cozynclex" && url.host == "cardoftheday" {
                if dailyGoalsManager.cardOfTheDay != nil {
                    appManager.currentScreen = .flashcardsGame
                }
            }
        }
    }

    // MARK: - iPad Layout (NavigationSplitView)

    private var iPadLayout: some View {
        NavigationSplitView {
            List(selection: $sidebarSelection) {
                Section("Study") {
                    ForEach(SidebarItem.studyItems, id: \.self) { item in
                        Label {
                            Text(item.rawValue)
                        } icon: {
                            Image(systemName: item.icon)
                                .foregroundColor(item.color)
                        }
                    }
                }
                Section("Progress") {
                    ForEach(SidebarItem.progressItems, id: \.self) { item in
                        Label {
                            Text(item.rawValue)
                        } icon: {
                            Image(systemName: item.icon)
                                .foregroundColor(item.color)
                        }
                    }
                }
                Section {
                    Label(SidebarItem.settings.rawValue, systemImage: SidebarItem.settings.icon)
                        .tag(SidebarItem.settings)
                }
            }
            .navigationTitle("CozyNCLEX")
            .listStyle(.sidebar)
        } detail: {
            iPadDetailView
        }
        .background(Color.creamyBackground)
    }

    @ViewBuilder
    private var iPadDetailView: some View {
        switch sidebarSelection {
        case .studyModes:
            ScrollView {
                VStack(spacing: 16) {
                    CompactHeaderView(showCategoryFilter: $showCategoryFilter)

                    if !subscriptionManager.hasPremiumAccess && !(authManager.userProfile?.isPremium ?? false) {
                        LibraryAccessCard(showSubscriptionSheet: $showSubscriptionSheet, totalPremiumCardCount: cardManager.getAvailableCards(isSubscribed: true).count)
                    }

                    GameModesGridSection(
                        showSubscriptionSheet: $showSubscriptionSheet,
                        selectedGameMode: $selectedGameMode,
                        showResumePrompt: $showResumePrompt,
                        pendingGameMode: $pendingGameMode
                    )

                    QuickActionsSection(showCardBrowse: $showCardBrowse)
                    CategoryFilterBadge(showCategoryFilter: $showCategoryFilter)
                }
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .background(Color.creamyBackground)
        case .browseCards:
            BrowseCardsHomeView()
        case .createCard:
            CreateCardView()
        case .studySets:
            StudySetsView()
        case .stats:
            StatsView()
        case .progress, .dailyGoals:
            ScrollView {
                VStack(spacing: 16) {
                    LevelProgressSection()
                    StreakBanner()
                    DailyGoalsSection()

                    Button(action: {
                        HapticManager.shared.light()
                        showShareProgress = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share My Progress")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(20)
                    }

                    CardOfTheDaySection(showCard: $showCardOfTheDay, isFlipped: $cardOfTheDayFlipped)
                    CategoryProgressSection(categoryProgress: calculateCategoryProgress())
                }
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .background(Color.creamyBackground)
        case .nclexReadiness:
            ScrollView {
                NCLEXReadinessView(
                    masteredCount: cardManager.validMasteredCount,
                    totalCards: cardManager.getAvailableCards(isSubscribed: subscriptionManager.hasPremiumAccess).count,
                    categoryProgress: calculateCategoryProgress(),
                    averageAccuracy: statsManager.stats.overallAccuracy / 100.0,
                    isPremium: subscriptionManager.hasPremiumAccess || (authManager.userProfile?.isPremium ?? false),
                    onUpgradeTapped: { showSubscriptionSheet = true }
                )
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .background(Color.creamyBackground)
        case .settings:
            NavigationStack {
                SyncSettingsView()
            }
        case .none:
            Text("Select an item from the sidebar")
                .font(.system(size: 18, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - iPhone Layout (existing TabView)

    private var iPhoneLayout: some View {
        VStack(spacing: 0) {
            // Header with compact stats
            CompactHeaderView(showCategoryFilter: $showCategoryFilter)
                .padding(.horizontal)
                .padding(.top, 8)

            // Tab Picker
            Picker("", selection: $selectedTab) {
                Text("Study").tag(0)
                Text("Progress").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .onChange(of: selectedTab) { _, newTab in
                HapticManager.shared.selection()
                // Show coach marks for new tab
                if newTab == 0 && coachMarkManager.isFirstTime {
                    coachMarkManager.showIfNeeded(.flashcards)
                } else if newTab == 1 {
                    coachMarkManager.showIfNeeded(.progressTab)
                }
            }
            .onChange(of: coachMarkManager.pendingNavigation) { _, navigation in
                guard let navigation else { return }
                coachMarkManager.pendingNavigation = nil
                switch navigation {
                case .switchToTab(let tab):
                    withAnimation(.easeInOut(duration: 0.4)) {
                        selectedTab = tab
                    }
                    // After tab switch settles, show the next coach mark
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if tab == 1 {
                            coachMarkManager.showIfNeeded(.progressTab)
                        }
                    }
                }
            }

            // Tab Content
            TabView(selection: $selectedTab) {
                // STUDY TAB
                ScrollView {
                    VStack(spacing: 16) {
                        // Premium Upsell (immediately visible for free users)
                        if !subscriptionManager.hasPremiumAccess && !(authManager.userProfile?.isPremium ?? false) {
                            LibraryAccessCard(showSubscriptionSheet: $showSubscriptionSheet, totalPremiumCardCount: cardManager.getAvailableCards(isSubscribed: true).count)
                        }

                        // Study Modes Grid
                        GameModesGridSection(
                            showSubscriptionSheet: $showSubscriptionSheet,
                            selectedGameMode: $selectedGameMode,
                            showResumePrompt: $showResumePrompt,
                            pendingGameMode: $pendingGameMode
                        )

                        // Quick Actions (Browse, Create, Sets, Stats)
                        QuickActionsSection(showCardBrowse: $showCardBrowse)

                        // Category Filter
                        CategoryFilterBadge(showCategoryFilter: $showCategoryFilter)
                    }
                    .padding()
                }
                .tag(0)

                // PROGRESS TAB
                ScrollView {
                    VStack(spacing: 16) {
                        LevelProgressSection()
                        StreakBanner()
                        DailyGoalsSection()

                        // Share Progress Button
                        Button(action: {
                            HapticManager.shared.light()
                            showShareProgress = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share My Progress")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(20)
                        }

                        CardOfTheDaySection(showCard: $showCardOfTheDay, isFlipped: $cardOfTheDayFlipped)

                        // NCLEX Readiness (Premium Feature)
                        NCLEXReadinessView(
                            masteredCount: cardManager.validMasteredCount,
                            totalCards: cardManager.getAvailableCards(isSubscribed: subscriptionManager.hasPremiumAccess).count,
                            categoryProgress: calculateCategoryProgress(),
                            averageAccuracy: statsManager.stats.overallAccuracy / 100.0,
                            isPremium: subscriptionManager.hasPremiumAccess || (authManager.userProfile?.isPremium ?? false),
                            onUpgradeTapped: { showSubscriptionSheet = true }
                        )

                        // Category Progress Section
                        CategoryProgressSection(categoryProgress: calculateCategoryProgress())
                    }
                    .padding()
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.creamyBackground)
    }

    private func calculateCategoryProgress() -> [ContentCategory: Double] {
        var progress: [ContentCategory: Double] = [:]
        let allCards = cardManager.getAvailableCards(isSubscribed: subscriptionManager.hasPremiumAccess)

        for category in ContentCategory.allCases {
            let categoryCards = allCards.filter { $0.contentCategory == category }
            let masteredInCategory = categoryCards.filter { cardManager.masteredCardIDs.contains($0.id) }

            if categoryCards.isEmpty {
                progress[category] = 0
            } else {
                progress[category] = Double(masteredInCategory.count) / Double(categoryCards.count)
            }
        }

        return progress
    }

    private func hasSeenMotivationToday() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastSeen = UserDefaults.standard.object(forKey: "lastMotivationDate") as? Date {
            return calendar.isDate(lastSeen, inSameDayAs: today)
        }
        return false
    }

    private func markMotivationSeen() {
        UserDefaults.standard.set(Date(), forKey: "lastMotivationDate")
    }

    private func startGameMode(_ mode: GameMode, with cards: [Flashcard]) {
        // Store selected cards for the game session
        cardManager.sessionCards = cards

        // Clear selectedGameMode to dismiss the sheet
        selectedGameMode = nil

        // Navigate to the appropriate screen
        switch mode {
        case .flashcards: appManager.currentScreen = .flashcardsGame
        case .learn: appManager.currentScreen = .learnGame
        case .match: appManager.currentScreen = .matchGame
        case .write: appManager.currentScreen = .writeMode
        case .test: appManager.currentScreen = .testMode
        case .blocks: appManager.currentScreen = .blocksGame
        }
    }

    private func resumeGameMode(_ mode: GameMode) {
        guard let progress = SessionProgressManager.shared.loadProgress(for: mode) else { return }

        // Restore cards from saved IDs
        let allCards = cardManager.getAvailableCards(isSubscribed: subscriptionManager.hasPremiumAccess)
        let savedCardIDs = Set(progress.cardIDs.compactMap { UUID(uuidString: $0) })
        let restoredCards = allCards.filter { savedCardIDs.contains($0.id) }

        // Maintain the original order
        var orderedCards: [Flashcard] = []
        for idString in progress.cardIDs {
            if let uuid = UUID(uuidString: idString),
               let card = restoredCards.first(where: { $0.id == uuid }) {
                orderedCards.append(card)
            }
        }

        // Store cards for the session
        cardManager.sessionCards = orderedCards
        cardManager.resumeProgress = progress // Store progress for game view to pick up

        // Navigate to game
        switch mode {
        case .flashcards: appManager.currentScreen = .flashcardsGame
        case .learn: appManager.currentScreen = .learnGame
        case .match: appManager.currentScreen = .matchGame
        case .write: appManager.currentScreen = .writeMode
        case .test: appManager.currentScreen = .testMode
        case .blocks: appManager.currentScreen = .blocksGame
        }
    }
}

// MARK: - Compact Header View

struct CompactHeaderView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @ObservedObject private var dailyGoalsManager = DailyGoalsManager.shared
    @StateObject private var authManager = AuthManager.shared
    @Binding var showCategoryFilter: Bool
    @State private var showProfile = false
    @State private var currentAffirmation: String = ""
    @State private var showBubble = true
    @State private var bubbleId = UUID()

    var isFiltered: Bool {
        cardManager.selectedCategories.count < ContentCategory.allCases.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Bear + Title
                Image("NurseBear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .onTapGesture {
                        HapticManager.shared.soft()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showBubble = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            currentAffirmation = NotificationManager.nursingAffirmations.randomElement() ?? ""
                            bubbleId = UUID()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showBubble = true
                            }
                        }
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text("CozyNCLEX")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        Text("\(statsManager.stats.currentStreak)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                }

                Spacer()

            // Filter button
            Button(action: {
                HapticManager.shared.buttonTap()
                showCategoryFilter = true
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 3)

                    if isFiltered {
                        Circle()
                            .fill(Color.pastelPink)
                            .frame(width: 10, height: 10)
                            .offset(x: 2, y: -2)
                    }
                }
            }

            // Stats button
            Button(action: {
                HapticManager.shared.buttonTap()
                appManager.currentScreen = .stats
            }) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .padding(10)
                    .background(Color.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 3)
            }

            // Profile button
            Button(action: {
                HapticManager.shared.buttonTap()
                showProfile = true
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.mintGreen, .green.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                        .shadow(color: .black.opacity(0.08), radius: 3)

                    Text(userInitials)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            } // HStack

            // Speech bubble
            if showBubble && !currentAffirmation.isEmpty {
                BearSpeechBubble(text: currentAffirmation)
                    .id(bubbleId)
                    .padding(.leading, 8)
            }
        } // VStack
        .onAppear {
            currentAffirmation = NotificationManager.nursingAffirmations.randomElement() ?? ""
        }
        .sheet(isPresented: $showProfile) {
            ProfileView(onSignOut: {
                appManager.signOut()
            })
        }
    }

    private var userInitials: String {
        let name = authManager.userProfile?.displayName ?? "S"
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }
}

// MARK: - Bear Speech Bubble

struct BearSpeechBubble: View {
    let text: String
    @State private var appeared = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // Tail pointing left
            Triangle()
                .fill(Color.adaptiveWhite)
                .frame(width: 10, height: 12)
                .rotationEffect(.degrees(-90))
                .offset(x: 4, y: -8)

            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.adaptiveWhite)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        }
        .scaleEffect(appeared ? 1 : 0.5, anchor: .leading)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                appeared = true
            }
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Game Modes Grid Section (More Prominent)

struct GameModesGridSection: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var statsManager: StatsManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var showSubscriptionSheet: Bool
    @Binding var selectedGameMode: GameMode?
    @Binding var showResumePrompt: Bool
    @Binding var pendingGameMode: GameMode?

    var isNewUser: Bool {
        statsManager.stats.totalCardsStudied == 0
    }

    var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 12), count: count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Study Modes")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    GameModeGridCard(
                        mode: mode,
                        isNewUser: isNewUser,
                        showSubscriptionSheet: $showSubscriptionSheet,
                        selectedGameMode: $selectedGameMode,
                        showResumePrompt: $showResumePrompt,
                        pendingGameMode: $pendingGameMode
                    )
                }
            }
        }
    }
}

struct GameModeGridCard: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    let mode: GameMode
    let isNewUser: Bool
    @Binding var showSubscriptionSheet: Bool
    @Binding var selectedGameMode: GameMode?
    @Binding var showResumePrompt: Bool
    @Binding var pendingGameMode: GameMode?

    @State private var pulseAnimation = false

    var isLocked: Bool {
        mode.isPaid && !subscriptionManager.hasPremiumAccess
    }

    var hasSavedProgress: Bool {
        mode != .match && mode != .test && SessionProgressManager.shared.hasProgress(for: mode)
    }

    private var isSpotlit: Bool {
        isNewUser && mode == .flashcards
    }

    var cardColor: Color {
        switch mode {
        case .flashcards: return .mintGreen
        case .learn: return .softLavender
        case .match: return .peachOrange
        case .write: return .skyBlue
        case .test: return .coralPink
        case .blocks: return .peachOrange
        }
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            SoundManager.shared.buttonTap()
            if isLocked {
                showSubscriptionSheet = true
            } else if mode == .test {
                appManager.currentScreen = .testMode
            } else if hasSavedProgress {
                pendingGameMode = mode
                showResumePrompt = true
            } else {
                selectedGameMode = mode
            }
        }) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(cardColor.opacity(0.2))
                        .frame(width: 56, height: 56)
                    Image(systemName: mode.icon)
                        .font(.system(size: 24))
                        .foregroundColor(cardColor)

                    if isLocked {
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 56, height: 56)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }

                VStack(spacing: 2) {
                    Text(mode.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(mode.subtitle)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                }

                if isLocked {
                    Text("PRO")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(6)
                } else if hasSavedProgress {
                    Text("CONTINUE")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange)
                        .cornerRadius(6)
                } else if isSpotlit {
                    Text("START HERE")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .cornerRadius(6)
                } else if !mode.isPaid && !subscriptionManager.hasPremiumAccess {
                    Text("FREE")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.mintGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.mintGreen.opacity(0.15))
                        .cornerRadius(6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 6)
        }
        .buttonStyle(SoftBounceButtonStyle())
        .highlightable(for: mode.coachMarkType)
        .background(
            Group {
                if isSpotlit {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.mintGreen.opacity(0.3))
                        .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                        .opacity(pulseAnimation ? 0.0 : 0.6)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
                }
            }
        )
        .opacity(isNewUser && mode != .flashcards ? 0.7 : 1.0)
        .onAppear {
            if isSpotlit {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - GameMode Coach Mark Extension

extension GameMode {
    var coachMarkType: CoachMarkType {
        switch self {
        case .flashcards: return .flashcards
        case .learn: return .quickQuiz
        case .test: return .testYourself
        case .match, .write, .blocks: return .browseCards // Group other modes
        }
    }
}

// MARK: - Level Progress Section

struct LevelProgressSection: View {
    @ObservedObject private var dailyGoalsManager = DailyGoalsManager.shared

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                // Level badge
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                    Text("\(dailyGoalsManager.currentLevel)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .pulsingGlow(.pastelPink, isActive: true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(dailyGoalsManager.levelTitle)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("\(dailyGoalsManager.totalXP) XP total")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(dailyGoalsManager.xpProgressInCurrentLevel)/\(dailyGoalsManager.xpForNextLevel)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("to next level")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }

            // XP Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    Capsule()
                        .fill(LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * dailyGoalsManager.xpProgressPercent, height: 8)
                        .animation(.spring(response: 0.5), value: dailyGoalsManager.xpProgressPercent)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
        .highlightable(for: .xpAndLevel)
    }
}

// MARK: - Daily Goals Section

struct DailyGoalsSection: View {
    @ObservedObject private var dailyGoalsManager = DailyGoalsManager.shared

    var completedCount: Int {
        dailyGoalsManager.dailyGoals.filter { $0.isCompleted }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 16))
                    .foregroundColor(.mintGreen)
                Text("Daily Goals")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Spacer()
                Text("\(completedCount)/\(dailyGoalsManager.dailyGoals.count)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }

            ForEach(dailyGoalsManager.dailyGoals) { goal in
                DailyGoalRow(goal: goal)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}

struct DailyGoalRow: View {
    let goal: DailyGoal

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(goal.isCompleted ? Color.mintGreen.opacity(0.2) : goal.type.color.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: goal.isCompleted ? "checkmark" : goal.type.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(goal.isCompleted ? .mintGreen : goal.type.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(goal.type.rawValue)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .strikethrough(goal.isCompleted, color: .secondary)
                    .foregroundColor(goal.isCompleted ? .secondary : .primary)
                Text("\(goal.progress)/\(goal.target)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                    .frame(width: 32, height: 32)
                Circle()
                    .trim(from: 0, to: goal.progressPercent)
                    .stroke(goal.isCompleted ? Color.mintGreen : goal.type.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5), value: goal.progressPercent)

                if goal.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.mintGreen)
                }
            }

            // XP reward
            Text("+\(goal.xpReward) XP")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(goal.isCompleted ? .mintGreen : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(goal.isCompleted ? Color.mintGreen.opacity(0.15) : Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

// MARK: - Watch Ad for Premium Section

// MARK: - Card of the Day Section

struct CardOfTheDaySection: View {
    @EnvironmentObject var cardManager: CardManager
    @ObservedObject private var dailyGoalsManager = DailyGoalsManager.shared
    @Binding var showCard: Bool
    @Binding var isFlipped: Bool

    var body: some View {
        if let card = dailyGoalsManager.cardOfTheDay {
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.peachOrange)
                        Text("Card of the Day")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    Spacer()
                    if dailyGoalsManager.hasCompletedCardOfTheDay {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                            Text("Completed")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.mintGreen)
                    } else {
                        Text("+20 XP")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.peachOrange)
                            .shimmer(true)
                    }
                }

                Button(action: {
                    HapticManager.shared.cardFlip()
                    SoundManager.shared.cardFlip()
                    withAnimation(.spring(response: 0.5)) {
                        isFlipped.toggle()
                    }
                    if !dailyGoalsManager.hasCompletedCardOfTheDay && isFlipped {
                        // Mark as completed when they flip to see answer
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dailyGoalsManager.completeCardOfTheDay()
                        }
                    }
                }) {
                    ZStack {
                        // Back (Answer)
                        VStack(spacing: 8) {
                            Text("A")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.pastelPink)
                                .cornerRadius(6)
                            Text(card.answer)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(4)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(Color.pastelPink.opacity(0.15))
                        .cornerRadius(12)
                        .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
                        .opacity(isFlipped ? 1 : 0)

                        // Front (Question)
                        VStack(spacing: 8) {
                            Text("Q")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.mintGreen)
                                .cornerRadius(6)
                            Text(card.question)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(4)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(Color.mintGreen.opacity(0.15))
                        .cornerRadius(12)
                        .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
                        .opacity(isFlipped ? 0 : 1)
                    }
                }
                .buttonStyle(SoftBounceButtonStyle())

                Text("Tap to flip")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8)
        }
    }
}

// MARK: - Level Up Celebration View

struct LevelUpCelebrationView: View {
    @ObservedObject private var dailyGoalsManager = DailyGoalsManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showContent = false
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            // Confetti behind everything
            if showConfetti {
                LevelUpConfettiView()
                    .ignoresSafeArea()
            }

            // Centered content
            VStack(spacing: 20) {
                Text("LEVEL UP!")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.pastelPink, .softLavender, .mintGreen], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 140, height: 140)
                        .shadow(color: .pastelPink.opacity(0.6), radius: 25)
                    Text("\(dailyGoalsManager.currentLevel)")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .scaleEffect(showContent ? 1 : 0)

                Text(dailyGoalsManager.levelTitle)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 5)
                    .opacity(showContent ? 1 : 0)

                Text("Keep studying to level up!")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(showContent ? 1 : 0)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Continue button at bottom
            VStack {
                Spacer()
                Button(action: {
                    HapticManager.shared.buttonTap()
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.mintGreen, .softLavender], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                }
                .buttonStyle(BounceButtonStyle())
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            withAnimation(.easeOut.delay(0.3)) {
                showConfetti = true
            }
        }
    }
}

// MARK: - Level Up Confetti View

struct LevelUpConfettiView: View {
    @State private var confettiPieces: [LevelUpConfettiPiece] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(confettiPieces) { piece in
                    LevelUpConfettiPieceAnimatedView(piece: piece, screenHeight: geo.size.height)
                }
            }
            .onAppear {
                generateConfetti(width: geo.size.width)
            }
        }
    }

    func generateConfetti(width: CGFloat) {
        let colors: [Color] = [.pastelPink, .mintGreen, .softLavender, .peachOrange, .skyBlue, .yellow]
        confettiPieces = (0..<60).map { _ in
            LevelUpConfettiPiece(
                color: colors.randomElement() ?? .pastelPink,
                x: CGFloat.random(in: 0...width),
                delay: Double.random(in: 0...0.5)
            )
        }
    }
}

struct LevelUpConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let x: CGFloat
    let delay: Double
}

struct LevelUpConfettiPieceAnimatedView: View {
    let piece: LevelUpConfettiPiece
    let screenHeight: CGFloat
    @State private var yOffset: CGFloat = -50
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: CGFloat.random(in: 8...14), height: CGFloat.random(in: 8...14))
            .rotationEffect(.degrees(rotation))
            .position(x: piece.x, y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 3).delay(piece.delay)) {
                    yOffset = screenHeight + 100
                    rotation = Double.random(in: 360...720)
                }
                withAnimation(.easeIn(duration: 2.5).delay(piece.delay + 0.5)) {
                    opacity = 0
                }
            }
    }
}

struct CategoryFilterBadge: View {
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Binding var showCategoryFilter: Bool

    var selectedCount: Int { cardManager.selectedCategories.count }
    var totalCount: Int { ContentCategory.allCases.count }
    var isFiltered: Bool { selectedCount < totalCount }

    var isPremium: Bool {
        subscriptionManager.hasPremiumAccess
    }

    var body: some View {
        if isFiltered && isPremium {
            Button(action: { showCategoryFilter = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.system(size: 16))
                    Text("\(selectedCount) of \(totalCount) categories selected")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                    Spacer()
                    Text("Edit")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.pastelPink)
                        .cornerRadius(10)
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.softLavender.opacity(0.3))
                .cornerRadius(12)
            }
        }
    }
}

struct HeaderSection: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var cardManager: CardManager
    @Binding var showCategoryFilter: Bool

    var isFiltered: Bool {
        cardManager.selectedCategories.count < ContentCategory.allCases.count
    }

    var body: some View {
        HStack(spacing: 12) {
            Image("NurseBear")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            VStack(alignment: .leading, spacing: 2) {
                Text("CozyNCLEX").font(.system(size: 28, weight: .bold, design: .rounded))
                Text("Prep 2026").font(.system(size: 18, weight: .medium, design: .rounded)).foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { showCategoryFilter = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(Color.adaptiveWhite)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4)

                    if isFiltered {
                        Circle()
                            .fill(Color.pastelPink)
                            .frame(width: 10, height: 10)
                            .offset(x: 2, y: -2)
                    }
                }
            }
            Button(action: { appManager.currentScreen = .search }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .padding(10)
                    .background(Color.adaptiveWhite)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4)
            }
        }
    }
}

struct StreakBanner: View {
    @EnvironmentObject var statsManager: StatsManager

    var body: some View {
        if statsManager.stats.currentStreak > 0 {
            HStack {
                Text("🔥").font(.title)
                VStack(alignment: .leading) {
                    Text("\(statsManager.stats.currentStreak) Day Streak!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("Keep it up!")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("Best: \(statsManager.stats.longestStreak)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.orange)
            }
            .padding()
            .background(LinearGradient(colors: [.orange.opacity(0.2), .yellow.opacity(0.2)], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(16)
            .highlightable(for: .streaks)
        }
    }
}

// MARK: - Category Progress Section

struct CategoryProgressSection: View {
    let categoryProgress: [ContentCategory: Double]
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @ObservedObject var authManager = AuthManager.shared
    @State private var selectedCategory: ContentCategory?
    @State private var showSubscriptionSheet = false

    var isPremium: Bool {
        subscriptionManager.hasPremiumAccess || (authManager.userProfile?.isPremium ?? false)
    }

    var starterDeckProgress: Double {
        let freeCards = cardManager.getAvailableCards(isSubscribed: false)
        guard !freeCards.isEmpty else { return 0 }
        let mastered = freeCards.filter { cardManager.masteredCardIDs.contains($0.id) }.count
        return Double(mastered) / Double(freeCards.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Mastery")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .padding(.horizontal, 4)

            VStack(spacing: 8) {
                if !isPremium {
                    // NCLEX Essentials row for free users
                    Button(action: {
                        HapticManager.shared.light()
                        // Open with nil category to show all free cards
                        selectedCategory = ContentCategory.allCases.first
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.mintGreen.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "book.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.mintGreen)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("NCLEX Essentials")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 6)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.mintGreen)
                                            .frame(width: geometry.size.width * starterDeckProgress, height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }
                            Spacer()
                            Text("\(Int(starterDeckProgress * 100))%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(starterDeckProgress >= 0.7 ? .green : (starterDeckProgress >= 0.4 ? .orange : .secondary))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                ForEach(ContentCategory.allCases, id: \.self) { category in
                    if isPremium {
                        CategoryProgressRow(
                            category: category,
                            progress: categoryProgress[category] ?? 0
                        ) {
                            selectedCategory = category
                        }
                    } else {
                        // Locked category row for free users
                        Button(action: {
                            HapticManager.shared.light()
                            showSubscriptionSheet = true
                        }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(category.color.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: category.icon)
                                        .font(.system(size: 14))
                                        .foregroundColor(category.color)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.rawValue)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.primary)
                                    GeometryReader { geometry in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(height: 6)
                                    }
                                    .frame(height: 6)
                                }
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                            .opacity(0.6)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding()
        .background(Color.adaptiveWhite)
        .cornerRadius(16)
        .sheet(item: $selectedCategory) { category in
            CategoryDetailView(category: category)
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet()
        }
    }
}

struct CategoryProgressRow: View {
    let category: ContentCategory
    let progress: Double
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            onTap()
        }) {
            HStack(spacing: 12) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: category.icon)
                        .font(.system(size: 14))
                        .foregroundColor(category.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(category.rawValue)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(category.color)
                                .frame(width: geometry.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }

                Spacer()

                // Percentage
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(progress >= 0.7 ? .green : (progress >= 0.4 ? .orange : .secondary))

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Detail View

struct CategoryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @ObservedObject var authManager = AuthManager.shared
    let category: ContentCategory

    var isPremium: Bool {
        subscriptionManager.hasPremiumAccess || (authManager.userProfile?.isPremium ?? false)
    }

    var categoryCards: [Flashcard] {
        cardManager.getAvailableCards(isSubscribed: isPremium)
            .filter { $0.contentCategory == category }
    }

    var masteredCards: [Flashcard] {
        categoryCards.filter { cardManager.masteredCardIDs.contains($0.id) }
    }

    var inProgressCards: [Flashcard] {
        categoryCards.filter {
            !cardManager.masteredCardIDs.contains($0.id) &&
            cardManager.progressTowardsMastery($0) > 0
        }
    }

    var notStartedCards: [Flashcard] {
        categoryCards.filter {
            !cardManager.masteredCardIDs.contains($0.id) &&
            cardManager.progressTowardsMastery($0) == 0
        }
    }

    var masteryProgress: Double {
        guard !categoryCards.isEmpty else { return 0 }
        return Double(masteredCards.count) / Double(categoryCards.count)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with circular progress
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                                .frame(width: 120, height: 120)

                            Circle()
                                .trim(from: 0, to: masteryProgress)
                                .stroke(category.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))

                            VStack(spacing: 2) {
                                Text("\(Int(masteryProgress * 100))%")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(category.color)
                                Text("Mastered")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Stats row
                        HStack(spacing: 20) {
                            CategoryStatBadge(
                                icon: "checkmark.circle.fill",
                                value: masteredCards.count,
                                label: "Mastered",
                                color: .green
                            )
                            CategoryStatBadge(
                                icon: "arrow.triangle.2.circlepath",
                                value: inProgressCards.count,
                                label: "In Progress",
                                color: .orange
                            )
                            CategoryStatBadge(
                                icon: "circle.dashed",
                                value: notStartedCards.count,
                                label: "Not Started",
                                color: .gray
                            )
                        }
                    }
                    .padding()
                    .background(Color.adaptiveWhite)
                    .cornerRadius(16)

                    // Card lists
                    if !masteredCards.isEmpty {
                        CardListSection(
                            title: "Mastered",
                            cards: masteredCards,
                            color: .green,
                            cardManager: cardManager
                        )
                    }

                    if !inProgressCards.isEmpty {
                        CardListSection(
                            title: "In Progress",
                            cards: inProgressCards,
                            color: .orange,
                            cardManager: cardManager
                        )
                    }

                    if !notStartedCards.isEmpty {
                        CardListSection(
                            title: "Not Started",
                            cards: notStartedCards,
                            color: .gray,
                            cardManager: cardManager
                        )
                    }
                }
                .padding()
            }
            .background(Color.creamyBackground)
            .navigationTitle(category.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategoryStatBadge: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text("\(value)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CardListSection: View {
    let title: String
    let cards: [Flashcard]
    let color: Color
    let cardManager: CardManager
    @State private var isExpanded = false

    var displayCards: [Flashcard] {
        isExpanded ? cards : Array(cards.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Spacer()
                Text("\(cards.count) cards")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
            }

            ForEach(displayCards) { card in
                CardProgressRow(card: card, cardManager: cardManager)
            }

            if cards.count > 3 {
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack {
                        Text(isExpanded ? "Show Less" : "Show All \(cards.count) Cards")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(Color.adaptiveWhite)
        .cornerRadius(12)
    }
}

struct CardProgressRow: View {
    let card: Flashcard
    let cardManager: CardManager
    @State private var showDetail = false

    var consecutiveCorrect: Int {
        cardManager.progressTowardsMastery(card)
    }

    var body: some View {
        Button(action: { showDetail = true }) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.question)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Progress indicators
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(index < consecutiveCorrect ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                        if cardManager.masteredCardIDs.contains(card.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            CardDetailSheet(card: card)
        }
    }
}

struct QuickStatsSection: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var totalCards: Int {
        cardManager.getAvailableCards(isSubscribed: subscriptionManager.hasPremiumAccess).count
    }

    var body: some View {
        HStack(spacing: 12) {
            TappableStatCard(icon: "checkmark.circle.fill", value: "\(cardManager.validMasteredCount)", label: "Mastered", color: .mintGreen) {
                cardManager.currentFilter = .mastered
                appManager.currentScreen = .cardBrowser
            }
            TappableStatCard(icon: "heart.fill", value: "\(cardManager.validSavedCount)", label: "Saved", color: .pastelPink) {
                cardManager.currentFilter = .saved
                appManager.currentScreen = .cardBrowser
            }
            TappableStatCard(icon: "square.stack.fill", value: "\(totalCards)", label: "Cards", color: .softLavender) {
                cardManager.currentFilter = .all
                appManager.currentScreen = .cardBrowser
            }
        }
    }
}

struct TappableStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.title2).foregroundColor(color)
                Text(value).font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(.primary)
                Text(label).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.adaptiveWhite)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 6)
        }
    }
}

// MARK: - Study Flashcards Button (Primary Action)

struct StudyFlashcardsButton: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @ObservedObject var authManager = AuthManager.shared
    @Binding var selectedGameMode: GameMode?
    @Binding var showResumePrompt: Bool
    @Binding var pendingGameMode: GameMode?

    var isPremium: Bool {
        subscriptionManager.hasPremiumAccess ||
        (authManager.userProfile?.isPremium ?? false)
    }

    var weakCardCount: Int {
        let availableCards = cardManager.getAvailableCards(isSubscribed: isPremium)
        return availableCards.filter { card in
            !cardManager.masteredCardIDs.contains(card.id) &&
            (cardManager.consecutiveCorrect[card.id] ?? 0) == 0
        }.count
    }

    var hasSavedProgress: Bool {
        SessionProgressManager.shared.hasProgress(for: .flashcards)
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            if hasSavedProgress {
                pendingGameMode = .flashcards
                showResumePrompt = true
            } else {
                selectedGameMode = .flashcards
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.mintGreen.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: "rectangle.on.rectangle.angled")
                        .font(.system(size: 22))
                        .foregroundColor(.mintGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Study Flashcards")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    if hasSavedProgress {
                        Text("Continue where you left off")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.orange)
                    } else if weakCardCount > 0 {
                        Text("\(weakCardCount) cards need review")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.orange)
                    } else {
                        Text("Sort cards into Know & Still Learning")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
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

// MARK: - Quick Actions Section

struct QuickActionsSection: View {
    @EnvironmentObject var appManager: AppManager
    @Binding var showCardBrowse: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                QuickActionButton(icon: "rectangle.stack.fill", label: "Browse Cards", color: .blue) {
                    showCardBrowse = true
                }
                QuickActionButton(icon: "plus.circle.fill", label: "Create Card", color: .mintGreen) {
                    appManager.currentScreen = .createCard
                }
            }
            HStack(spacing: 12) {
                QuickActionButton(icon: "folder.fill", label: "Study Sets", color: .peachOrange) {
                    appManager.currentScreen = .studySets
                }
                QuickActionButton(icon: "chart.bar.fill", label: "Stats", color: .softLavender) {
                    appManager.currentScreen = .stats
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 24)).foregroundColor(color)
                Text(label).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.adaptiveWhite)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4)
        }
    }
}

struct GameModesSection: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Binding var showSubscriptionSheet: Bool

    var freeModes: [GameMode] { GameMode.allCases.filter { !$0.isPaid } }
    var paidModes: [GameMode] { GameMode.allCases.filter { $0.isPaid } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Study Modes").font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundColor(.secondary)

            // Free modes - full cards
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(freeModes, id: \.self) { mode in
                    GameModeCard(mode: mode, isLocked: false) {
                        handleModeTap(mode)
                    }
                }
            }

            // Paid modes - collapsed compact row
            if !subscriptionManager.hasPremiumAccess {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Premium Modes").font(.system(size: 14, weight: .medium, design: .rounded)).foregroundColor(.secondary)
                    HStack(spacing: 10) {
                        ForEach(paidModes, id: \.self) { mode in
                            CompactModeCard(mode: mode) {
                                showSubscriptionSheet = true
                            }
                        }
                    }
                }
            } else {
                // Show full cards when subscribed
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(paidModes, id: \.self) { mode in
                        GameModeCard(mode: mode, isLocked: false) {
                            handleModeTap(mode)
                        }
                    }
                }
            }
        }
    }

    private func handleModeTap(_ mode: GameMode) {
        if mode.isPaid && !subscriptionManager.hasPremiumAccess {
            showSubscriptionSheet = true
        } else {
            switch mode {
            case .flashcards: appManager.currentScreen = .flashcardsGame
            case .learn: appManager.currentScreen = .learnGame
            case .match: appManager.currentScreen = .matchGame
            case .write: appManager.currentScreen = .writeMode
            case .test: appManager.currentScreen = .testMode
            case .blocks: appManager.currentScreen = .blocksGame
            }
        }
    }
}

struct CompactModeCard: View {
    let mode: GameMode
    let action: () -> Void

    var modeColor: Color {
        switch mode {
        case .flashcards: return .mintGreen
        case .learn: return .softLavender
        case .match: return .softLavender
        case .write: return .skyBlue
        case .test: return .peachOrange
        case .blocks: return .peachOrange
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle().fill(modeColor.opacity(0.2)).frame(width: 36, height: 36)
                    Text("🔒").font(.system(size: 14))
                }
                Text(mode.rawValue).font(.system(size: 10, weight: .medium, design: .rounded)).foregroundColor(.secondary).lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.adaptiveWhite.opacity(0.7))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
        }
        .opacity(0.7)
    }
}

struct GameModeCard: View {
    let mode: GameMode
    let isLocked: Bool
    let action: () -> Void

    var modeColor: Color {
        switch mode {
        case .flashcards: return .mintGreen
        case .learn: return .softLavender
        case .match: return .softLavender
        case .write: return .skyBlue
        case .test: return .peachOrange
        case .blocks: return .peachOrange
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle().fill(modeColor.opacity(0.3)).frame(width: 50, height: 50)
                    if isLocked {
                        Text("🔒").font(.system(size: 24))
                    } else {
                        Image(systemName: mode.icon).font(.system(size: 22)).foregroundColor(modeColor)
                    }
                }
                Text(mode.rawValue).font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundColor(.primary)
                Text(mode.subtitle).font(.system(size: 11, design: .rounded)).foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.adaptiveWhite)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 6)
            .opacity(isLocked ? 0.6 : 1.0)
        }
    }
}

struct LibraryAccessCard: View {
    @EnvironmentObject var cardManager: CardManager
    @Binding var showSubscriptionSheet: Bool
    var totalPremiumCardCount: Int

    var masteredCount: Int {
        let freeCards = cardManager.getAvailableCards(isSubscribed: false)
        return freeCards.filter { cardManager.masteredCardIDs.contains($0.id) }.count
    }

    var body: some View {
        VStack(spacing: 12) {
            // Starter Deck row
            HStack {
                HStack(spacing: 6) {
                    Text("📚")
                    Text("Starter Deck")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                Spacer()
                Text("50 Cards")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }

            // Starter progress bar
            HStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.mintGreen)
                            .frame(width: geometry.size.width * min(Double(masteredCount) / 50.0, 1.0), height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(Int(min(Double(masteredCount) / 50.0, 1.0) * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.mintGreen)
            }

            Divider()

            // Full Library row
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("Full Library")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(totalPremiumCardCount)+ Cards")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .opacity(0.6)

            // Greyed progress bar
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 8)
            }
            .frame(height: 8)

            // Unlock button
            Button(action: { showSubscriptionSheet = true }) {
                HStack(spacing: 6) {
                    Text("Unlock Full Library")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.adaptiveWhite)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6)
    }
}

struct SubscribeButton: View {
    @Binding var showSheet: Bool
    var totalCardCount: Int = 0

    var body: some View {
        Button(action: { showSheet = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Text("Get NCLEX Ready").font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    Text("\(totalCardCount)+ cards • All study modes").font(.system(size: 13, design: .rounded)).opacity(0.9)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(16)
        }
    }
}

struct SubscriptionSheet: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedProduct: Product?

    private let privacyPolicyURL = "https://www.cozynclex.com/privacy.html"
    private let termsOfServiceURL = "https://www.cozynclex.com/terms"

    private var totalCardCount: Int {
        cardManager.getAvailableCards(isSubscribed: true).count
    }

    private var resolvedProduct: Product? {
        selectedProduct ?? preferredDefault
    }

    /// Default to yearly, then monthly — never weekly
    private var preferredDefault: Product? {
        let sorted = subscriptionManager.products
        let yearly = sorted.first { $0.id.lowercased().contains("yearly") }
        let monthly = sorted.first { $0.id.lowercased().contains("monthly") }
        return yearly ?? monthly ?? sorted.first
    }

    private func isMonthly(_ product: Product) -> Bool {
        product.id.lowercased().contains("monthly")
    }

    private func isYearly(_ product: Product) -> Bool {
        product.id.lowercased().contains("yearly")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Bear mascot — compact
                Image("NurseBear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .padding(.top, 24)

                // Headline
                VStack(spacing: 6) {
                    Text("Pass Your Boards. Keep Your Sanity.")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("Unlock the complete \(totalCardCount)+ Question Library & Smart AI Tutor.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                // Feature list
                VStack(alignment: .leading, spacing: 10) {
                    FeatureRow(icon: "square.stack.3d.up.fill", text: "\(totalCardCount)+ NCLEX Questions")
                    FeatureRow(icon: "lightbulb.fill", text: "Detailed Rationales for Every Card")
                    FeatureRow(icon: "brain.head.profile", text: "Smart Bear Learn (Adaptive Study)")
                    FeatureRow(icon: "checkmark.seal.fill", text: "NCLEX Readiness Tracker")
                    FeatureRow(icon: "gamecontroller.fill", text: "All Study Modes")
                    FeatureRow(icon: "doc.text.fill", text: "Practice Tests")
                }
                .padding()
                .background(Color.adaptiveWhite)
                .cornerRadius(16)
                .padding(.horizontal)

                // Trust badge
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.mintGreen)
                    Text("Updated for Next Gen NCLEX (NGN)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("Cancel Anytime")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Product options
                if subscriptionManager.products.isEmpty && subscriptionManager.lifetimeProduct == nil {
                    VStack(spacing: 12) {
                        ProgressView().scaleEffect(1.2)
                        Text("Loading subscription options...")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    VStack(spacing: 10) {
                        ForEach(subscriptionManager.products, id: \.id) { product in
                            SubscriptionProductRow(
                                product: product,
                                isSelected: resolvedProduct?.id == product.id,
                                isLifetime: false,
                                badge: isMonthly(product) ? "MOST POPULAR" : nil,
                                badgeColors: [.mintGreen, .blue],
                                savingsText: isYearly(product) ? "Save 58%" : nil,
                                action: { selectedProduct = product }
                            )
                        }

                        if let lifetime = subscriptionManager.lifetimeProduct {
                            SubscriptionProductRow(
                                product: lifetime,
                                isSelected: resolvedProduct?.id == lifetime.id,
                                isLifetime: true,
                                badge: "BEST VALUE",
                                badgeColors: [.orange, .pink],
                                savingsText: nil,
                                action: { selectedProduct = lifetime }
                            )
                        }
                    }
                    .padding(.horizontal)

                    // CTA Button
                    if let product = resolvedProduct {
                        Button(action: {
                            Task {
                                await subscriptionManager.purchase(product)
                                if subscriptionManager.hasPremiumAccess { dismiss() }
                            }
                        }) {
                            HStack {
                                if subscriptionManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    let isLifetime = product.type == .nonConsumable
                                    Text(isLifetime ? "Get Lifetime Access — One-Time" : "Start Full Access (Cancel Anytime)")
                                }
                            }
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                        }
                        .disabled(subscriptionManager.isLoading)
                        .padding(.horizontal)
                    }

                    if let error = subscriptionManager.purchaseError {
                        Text(error)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                Button(action: {
                    Task {
                        await subscriptionManager.restore()
                        if subscriptionManager.hasPremiumAccess { dismiss() }
                    }
                }) {
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                    } else {
                        Text("Restore Purchases")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .disabled(subscriptionManager.isLoading)

                // Auto-renewal disclosure (required by Apple)
                Text("Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Your Apple ID account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel subscriptions in your App Store account settings.")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                // Required legal links
                HStack(spacing: 20) {
                    if let privacyURL = URL(string: privacyPolicyURL) {
                        Link("Privacy Policy", destination: privacyURL)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.blue)
                    }
                    Text("•").font(.system(size: 12)).foregroundColor(.secondary)
                    if let termsURL = URL(string: termsOfServiceURL) {
                        Link("Terms of Use", destination: termsURL)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .background(Color.creamyBackground)
        .onAppear {
            selectedProduct = preferredDefault
        }
    }
}

struct SubscriptionProductRow: View {
    let product: Product
    let isSelected: Bool
    let isLifetime: Bool
    var badge: String? = nil
    var badgeColors: [Color] = [.orange, .pink]
    var savingsText: String? = nil
    let action: () -> Void

    var periodText: String {
        let id = product.id.lowercased()
        if id.contains("weekly") { return "week" }
        if id.contains("monthly") { return "month" }
        if id.contains("yearly") { return "year" }
        if let unit = product.subscription?.subscriptionPeriod.unit {
            switch unit {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            @unknown default: break
            }
        }
        return ""
    }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(product.displayName)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(LinearGradient(colors: badgeColors, startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(4)
                        }
                    }
                    HStack(spacing: 6) {
                        Text(isLifetime ? "\(product.displayPrice) one-time" : "\(product.displayPrice)/\(periodText)")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                        if let savings = savingsText {
                            Text(savings)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                    }
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .mintGreen : .gray.opacity(0.4))
            }
            .padding()
            .background(isSelected ? Color.mintGreen.opacity(0.1) : (isLifetime ? Color.orange.opacity(0.05) : Color.adaptiveWhite))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.mintGreen : (isLifetime ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2)), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(.pastelPink).frame(width: 28)
            Text(text).font(.system(size: 15, weight: .medium, design: .rounded))
            Spacer()
        }
    }
}

// MARK: - Card Browser View

struct CardBrowserView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @ObservedObject var authManager = AuthManager.shared
    @State private var selectedCard: Flashcard? = nil
    @State private var showCategoryFilter = false

    var isPremium: Bool {
        subscriptionManager.hasPremiumAccess ||
        (authManager.userProfile?.isPremium ?? false)
    }

    var filteredCards: [Flashcard] {
        cardManager.getFilteredCards(isSubscribed: isPremium)
    }

    var isFiltered: Bool {
        cardManager.selectedCategories.count < ContentCategory.allCases.count
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton { appManager.currentScreen = .menu }
                Spacer()
                Text(cardManager.currentFilter.rawValue).font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Button(action: { showCategoryFilter = true }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)

                        if isFiltered {
                            Circle()
                                .fill(Color.pastelPink)
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .padding(.trailing, 8)
                Text("\(filteredCards.count)").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 5).background(Color.pastelPink).cornerRadius(10)
            }
            .padding()


            HStack(spacing: 8) {
                ForEach(CardFilter.allCases, id: \.self) { filter in
                    Button(action: { cardManager.currentFilter = filter }) {
                        Text(filter.rawValue).font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(cardManager.currentFilter == filter ? .white : .primary)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(cardManager.currentFilter == filter ? Color.pastelPink : Color.adaptiveWhite)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            if filteredCards.isEmpty {
                Spacer()
                EmptyStateView(filter: cardManager.currentFilter)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredCards) { card in
                            CardListItem(card: card) { selectedCard = card }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.creamyBackground)
        .sheet(item: $selectedCard) { card in
            CardDetailSheet(card: card)
        }
        .sheet(isPresented: $showCategoryFilter) {
            CategoryFilterSheet()
        }
    }
}

struct EmptyStateView: View {
    let filter: CardFilter

    var message: String {
        switch filter {
        case .all: return "No cards available"
        case .mastered: return "Master cards by getting them right 3 times!"
        case .saved: return "Tap the heart to save cards"
        case .userCreated: return "Create your own flashcards!"
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            Text("📭").font(.system(size: 50))
            Text("No cards here yet!").font(.system(size: 18, weight: .semibold, design: .rounded))
            Text(message).font(.system(size: 13, design: .rounded)).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct CardListItem: View {
    @EnvironmentObject var cardManager: CardManager
    let card: Flashcard
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Circle().fill(card.contentCategory.color).frame(width: 8, height: 8)
                VStack(alignment: .leading, spacing: 3) {
                    Text(card.question).font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.primary).lineLimit(2).multilineTextAlignment(.leading)
                    HStack(spacing: 6) {
                        Text(card.contentCategory.rawValue).font(.system(size: 11, design: .rounded)).foregroundColor(.secondary)
                        Text("•").foregroundColor(.secondary)
                        Text(card.difficulty.rawValue).font(.system(size: 10, weight: .medium))
                            .foregroundColor(card.difficulty.color)
                        if cardManager.isMastered(card) {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 9))
                                Text("Mastered").font(.system(size: 9, weight: .semibold))
                            }.foregroundColor(.green)
                        }
                    }
                }
                Spacer()
                if cardManager.isSaved(card) {
                    Image(systemName: "heart.fill").font(.system(size: 12)).foregroundColor(.red)
                }
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.gray)
            }
            .padding(12)
            .background(Color.adaptiveWhite)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.04), radius: 3)
        }
    }
}

struct CardDetailSheet: View {
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var speechManager: SpeechManager
    @Environment(\.dismiss) var dismiss
    let card: Flashcard
    @State private var showAnswer = false
    @State private var showNoteEditor = false
    @State private var noteText = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary).padding(10).background(Color.gray.opacity(0.1)).clipShape(Circle())
                    }
                    Spacer()
                    // Save button
                    Button(action: {
                        HapticManager.shared.light()
                        cardManager.toggleSaved(card)
                    }) {
                        Image(systemName: cardManager.isSaved(card) ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(cardManager.isSaved(card) ? .red : .secondary)
                            .padding(10).background(Color.gray.opacity(0.1)).clipShape(Circle())
                    }
                    // Flag button
                    Button(action: { cardManager.toggleFlagged(card) }) {
                        Image(systemName: cardManager.isFlagged(card) ? "flag.fill" : "flag")
                            .font(.system(size: 14))
                            .foregroundColor(cardManager.isFlagged(card) ? .orange : .secondary)
                            .padding(10).background(Color.gray.opacity(0.1)).clipShape(Circle())
                    }
                    // Audio button
                    Button(action: { speechManager.speak(showAnswer ? card.answer : card.question) }) {
                        Image(systemName: "speaker.wave.2.fill").font(.system(size: 14))
                            .foregroundColor(.pastelPink).padding(10).background(Color.gray.opacity(0.1)).clipShape(Circle())
                    }
                }
                .padding()

                VStack(spacing: 14) {
                    // Category label
                    HStack(spacing: 4) {
                        Image(systemName: card.contentCategory.icon)
                            .font(.system(size: 11))
                            .foregroundColor(card.contentCategory.color)
                        Text(card.contentCategory.rawValue)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text(card.difficulty.rawValue).font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 4)
                            .background(card.difficulty.color).cornerRadius(8)
                        Text(card.questionType.rawValue).font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }

                    Text(showAnswer ? "Answer" : "Question")
                        .font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                    Text(showAnswer ? card.answer : card.question)
                        .font(.system(size: 18, weight: .medium, design: .rounded)).multilineTextAlignment(.center)
                        .padding()

                    Button(action: { withAnimation { showAnswer.toggle() }}) {
                        Text(showAnswer ? "Show Question" : "Show Answer")
                            .font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundColor(.pastelPink)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color.adaptiveWhite)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.08), radius: 8)
                .padding(.horizontal)

                if showAnswer && !card.rationale.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "lightbulb.fill").foregroundColor(.yellow)
                            Text("Rationale").font(.system(size: 15, weight: .semibold, design: .rounded))
                            if !subscriptionManager.hasPremiumAccess {
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.fill").font(.system(size: 10))
                                    Text("Premium").font(.system(size: 11, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                        Text(card.rationale).font(.system(size: 14, design: .rounded)).foregroundColor(.secondary)
                            .blur(radius: subscriptionManager.hasPremiumAccess ? 0 : 6)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                if !cardManager.isMastered(card) {
                    VStack(spacing: 6) {
                        Text("Progress to Mastery").font(.system(size: 11, design: .rounded)).foregroundColor(.secondary)
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { i in
                                Circle().fill(i < cardManager.progressTowardsMastery(card) ? Color.mintGreen : Color.gray.opacity(0.3))
                                    .frame(width: 10, height: 10)
                            }
                        }
                        Text("\(cardManager.progressTowardsMastery(card))/3 correct").font(.system(size: 10, design: .rounded)).foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 14) {
                    Button(action: { cardManager.toggleSaved(card) }) {
                        HStack(spacing: 5) {
                            Image(systemName: cardManager.isSaved(card) ? "heart.fill" : "heart")
                            Text(cardManager.isSaved(card) ? "Saved" : "Save")
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(cardManager.isSaved(card) ? .white : .pastelPink)
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(cardManager.isSaved(card) ? Color.pastelPink : Color.adaptiveWhite)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.pastelPink, lineWidth: cardManager.isSaved(card) ? 0 : 2))
                    }

                    Button(action: { cardManager.toggleMastered(card) }) {
                        HStack(spacing: 5) {
                            Image(systemName: cardManager.isMastered(card) ? "checkmark.circle.fill" : "checkmark.circle")
                            Text(cardManager.isMastered(card) ? "Mastered" : "Mark Mastered")
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(cardManager.isMastered(card) ? .white : .mintGreen)
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(cardManager.isMastered(card) ? Color.mintGreen : Color.adaptiveWhite)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.mintGreen, lineWidth: cardManager.isMastered(card) ? 0 : 2))
                    }
                }
                .padding(.horizontal)

                // Notes Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "note.text").foregroundColor(.softLavender)
                        Text("My Notes").font(.system(size: 15, weight: .semibold, design: .rounded))
                        Spacer()
                        Button(action: {
                            noteText = cardManager.getNote(for: card.id)?.note ?? ""
                            showNoteEditor = true
                        }) {
                            Text(cardManager.getNote(for: card.id) != nil ? "Edit" : "Add Note")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.softLavender)
                        }
                    }

                    if let note = cardManager.getNote(for: card.id) {
                        Text(note.note)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    } else {
                        Text("Tap 'Add Note' to save your own notes about this card.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.softLavender.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .background(Color.creamyBackground)
        .sheet(isPresented: $showNoteEditor) {
            CardNoteEditor(noteText: $noteText, onSave: {
                cardManager.saveNote(for: card.id, text: noteText)
            })
        }
    }
}

// MARK: - Card Note Editor

struct CardNoteEditor: View {
    @Binding var noteText: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextEditor(text: $noteText)
                    .font(.system(size: 16, design: .rounded))
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .padding()

                Spacer()
            }
            .background(Color.creamyBackground)
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Create Card View

struct CreateCardView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var cardManager: CardManager
    @State private var question = ""
    @State private var answer = ""
    @State private var wrongAnswer1 = ""
    @State private var wrongAnswer2 = ""
    @State private var wrongAnswer3 = ""
    @State private var rationale = ""
    @State private var selectedCategory: ContentCategory = .fundamentals
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    BackButton { appManager.currentScreen = .menu }
                    Spacer()
                    Text("Create Card").font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                    Color.clear.frame(width: 40)
                }
                .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Question").font(.system(size: 14, weight: .semibold, design: .rounded))
                    TextField("Enter your question...", text: $question, axis: .vertical)
                        .textFieldStyle(RoundedTextFieldStyle())
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Correct Answer").font(.system(size: 14, weight: .semibold, design: .rounded))
                    TextField("Enter the correct answer...", text: $answer, axis: .vertical)
                        .textFieldStyle(RoundedTextFieldStyle())
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Wrong Answers").font(.system(size: 14, weight: .semibold, design: .rounded))
                    TextField("Wrong answer 1", text: $wrongAnswer1).textFieldStyle(RoundedTextFieldStyle())
                    TextField("Wrong answer 2", text: $wrongAnswer2).textFieldStyle(RoundedTextFieldStyle())
                    TextField("Wrong answer 3", text: $wrongAnswer3).textFieldStyle(RoundedTextFieldStyle())
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Rationale (Optional)").font(.system(size: 14, weight: .semibold, design: .rounded))
                    TextField("Explain why this is correct...", text: $rationale, axis: .vertical)
                        .textFieldStyle(RoundedTextFieldStyle())
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Category").font(.system(size: 14, weight: .semibold, design: .rounded))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ContentCategory.allCases, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    Text(category.rawValue).font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(selectedCategory == category ? .white : .primary)
                                        .padding(.horizontal, 12).padding(.vertical, 8)
                                        .background(selectedCategory == category ? category.color : Color.adaptiveWhite)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty").font(.system(size: 14, weight: .semibold, design: .rounded))
                    HStack(spacing: 10) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Button(action: { selectedDifficulty = difficulty }) {
                                Text(difficulty.rawValue).font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(selectedDifficulty == difficulty ? .white : .primary)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(selectedDifficulty == difficulty ? difficulty.color : Color.adaptiveWhite)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Button(action: createCard) {
                    Text("Create Card")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canCreate ? Color.pastelPink : Color.gray)
                        .cornerRadius(14)
                }
                .disabled(!canCreate)
                .padding()
            }
        }
        .background(Color.creamyBackground)
        .alert("Card Created!", isPresented: $showAlert) {
            Button("Create Another") { clearForm() }
            Button("Done") { appManager.currentScreen = .cardBrowser; cardManager.currentFilter = .userCreated }
        }
    }

    var canCreate: Bool {
        !question.isEmpty && !answer.isEmpty && !wrongAnswer1.isEmpty && !wrongAnswer2.isEmpty && !wrongAnswer3.isEmpty
    }

    func createCard() {
        let card = Flashcard(
            question: question, answer: answer,
            wrongAnswers: [wrongAnswer1, wrongAnswer2, wrongAnswer3],
            rationale: rationale, contentCategory: selectedCategory,
            difficulty: selectedDifficulty, isUserCreated: true
        )
        cardManager.addUserCard(card)
        showAlert = true
    }

    func clearForm() {
        question = ""; answer = ""; wrongAnswer1 = ""; wrongAnswer2 = ""; wrongAnswer3 = ""; rationale = ""
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.adaptiveWhite)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3)
    }
}

// MARK: - Search View

struct SearchView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var searchText = ""
    @State private var selectedCard: Flashcard? = nil

    var searchResults: [Flashcard] {
        cardManager.searchCards(query: searchText, isSubscribed: subscriptionManager.hasPremiumAccess)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton { appManager.currentScreen = .menu }
                TextField("Search cards...", text: $searchText)
                    .textFieldStyle(RoundedTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                }
            }
            .padding()

            if searchText.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass").font(.system(size: 40)).foregroundColor(.gray)
                    Text("Search for questions or topics").font(.system(size: 15, design: .rounded)).foregroundColor(.secondary)
                }
                Spacer()
            } else if searchResults.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Text("🔍").font(.system(size: 40))
                    Text("No results found").font(.system(size: 16, weight: .semibold, design: .rounded))
                    Text("Try a different search term").font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        Text("\(searchResults.count) results").font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
                        ForEach(searchResults) { card in
                            CardListItem(card: card) { selectedCard = card }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.creamyBackground)
        .sheet(item: $selectedCard) { card in CardDetailSheet(card: card) }
    }
}

// MARK: - Stats View

struct StatsView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var statsManager: StatsManager
    @EnvironmentObject var cardManager: CardManager
    @StateObject private var achievementManager = AchievementManager()
    @State private var showAchievements = false
    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    BackButton { appManager.currentScreen = .menu }
                    Spacer()
                    Text("Your Stats").font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                // Main Stats
                HStack(spacing: 12) {
                    StatBox(title: "Cards Studied", value: "\(statsManager.stats.totalCardsStudied)", icon: "square.stack.fill", color: .softLavender)
                    StatBox(title: "Accuracy", value: String(format: "%.0f%%", statsManager.stats.overallAccuracy), icon: "target", color: .mintGreen)
                }
                .padding(.horizontal)

                // Achievements Button
                Button(action: { showAchievements = true }) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Achievements")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("\(achievementManager.unlockedAchievements.count)/\(AchievementType.allCases.count) unlocked")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                }
                .padding(.horizontal)

                // Weak Areas Section
                if !statsManager.getWeakCategories().isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.peachOrange)
                            Text("Areas to Improve")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        ForEach(statsManager.getWeakCategories().prefix(3), id: \.self) { category in
                            if let stats = statsManager.stats.categoryAccuracy[category] {
                                HStack {
                                    Text(category)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                    Spacer()
                                    Text(String(format: "%.0f%%", stats.accuracy))
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.coralPink)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.peachOrange.opacity(0.15))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                // Category Performance Chart
                if !statsManager.stats.categoryAccuracy.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category Performance")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))

                        Chart {
                            ForEach(Array(statsManager.stats.categoryAccuracy.keys.sorted()), id: \.self) { category in
                                if let stats = statsManager.stats.categoryAccuracy[category], stats.total >= 1 {
                                    BarMark(
                                        x: .value("Accuracy", stats.accuracy),
                                        y: .value("Category", category)
                                    )
                                    .foregroundStyle(stats.accuracy >= 70 ? Color.mintGreen : Color.coralPink)
                                    .cornerRadius(4)
                                }
                            }
                        }
                        .frame(height: CGFloat(statsManager.stats.categoryAccuracy.count * 35))
                        .chartXScale(domain: 0...100)
                        .chartXAxis {
                            AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                                AxisValueLabel {
                                    if let v = value.as(Int.self) {
                                        Text("\(v)%")
                                            .font(.system(size: 10))
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                // Time Studied
                VStack(alignment: .leading, spacing: 12) {
                    Text("Time Studied").font(.system(size: 15, weight: .semibold, design: .rounded))
                    let hours = statsManager.stats.totalTimeSpentSeconds / 3600
                    let minutes = (statsManager.stats.totalTimeSpentSeconds % 3600) / 60
                    Text("\(hours)h \(minutes)m total").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(.softLavender)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)

                // Recent Sessions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Sessions").font(.system(size: 15, weight: .semibold, design: .rounded))
                    if statsManager.stats.sessions.isEmpty {
                        Text("No sessions yet. Start studying!").font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
                    } else {
                        ForEach(statsManager.stats.sessions.suffix(5).reversed(), id: \.date) { session in
                            HStack {
                                Text(session.mode).font(.system(size: 13, weight: .medium, design: .rounded))
                                Spacer()
                                Text("\(session.correctAnswers)/\(session.cardsStudied) correct").font(.system(size: 12, design: .rounded)).foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)

                // Test History
                if !cardManager.testHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Test History").font(.system(size: 15, weight: .semibold, design: .rounded))
                        ForEach(cardManager.testHistory.prefix(5)) { test in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(test.questionCount) questions")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                    Text(test.date, style: .date)
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(String(format: "%.0f%%", test.accuracy))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(test.accuracy >= 70 ? .mintGreen : .coralPink)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                Spacer(minLength: 20)
            }
        }
        .background(Color.creamyBackground)
        .sheet(isPresented: $showAchievements) {
            AchievementsView(achievementManager: achievementManager)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            achievementManager.checkAchievements(
                stats: statsManager.stats,
                masteredCount: cardManager.validMasteredCount,
                categoriesStudied: Set(statsManager.stats.categoryAccuracy.keys)
            )
        }
    }
}

// MARK: - Achievements View

struct AchievementsView: View {
    @ObservedObject var achievementManager: AchievementManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(AchievementType.allCases, id: \.self) { type in
                        AchievementCard(
                            type: type,
                            isUnlocked: achievementManager.hasAchievement(type)
                        )
                    }
                }
                .padding()
            }
            .background(Color.creamyBackground)
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct AchievementCard: View {
    let type: AchievementType
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? type.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                Image(systemName: type.icon)
                    .font(.system(size: 26))
                    .foregroundColor(isUnlocked ? type.color : .gray.opacity(0.4))
            }
            Text(type.rawValue)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
            Text(type.description)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .opacity(isUnlocked ? 1 : 0.6)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var soundManager = SoundManager.shared
    @ObservedObject private var dailyGoalsManager = DailyGoalsManager.shared
    @StateObject private var appearanceManager = AppearanceManager.shared
    @State private var remindersEnabled = false
    @State private var selectedTime = Date()
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var hapticsEnabled = HapticManager.shared.isEnabled
    @State private var showResetConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    @State private var showDeleteAccountFinalConfirmation = false
    @State private var deleteConfirmationText = ""
    @State private var isDeletingAccount = false
    @StateObject private var authManager = AuthManager.shared

    private let privacyPolicyURL = "https://www.cozynclex.com/privacy.html"
    private let termsOfServiceURL = "https://www.cozynclex.com/terms"

    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Picker(selection: $appearanceManager.currentMode, label:
                        HStack {
                            Image(systemName: "circle.lefthalf.filled")
                                .foregroundColor(.softLavender)
                            Text("Theme")
                        }
                    ) {
                        ForEach(AppearanceManager.Mode.allCases, id: \.self) { mode in
                            HStack {
                                Image(systemName: mode.icon)
                                Text(mode.name)
                            }
                            .tag(mode)
                        }
                    }
                }

                Section("Study Reminders") {
                    Toggle("Daily Reminder", isOn: $remindersEnabled)
                        .onChange(of: remindersEnabled) { _, newValue in
                            if newValue {
                                notificationManager.requestAuthorization()
                            } else {
                                notificationManager.cancelReminders()
                            }
                        }

                    if remindersEnabled {
                        DatePicker("Reminder Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .onChange(of: selectedTime) { _, newValue in
                                notificationManager.reminderTime = newValue
                                notificationManager.scheduleStudyReminder()
                            }
                    }
                }

                Section("Feedback") {
                    Toggle(isOn: $hapticsEnabled) {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(.softLavender)
                            Text("Haptic Feedback")
                        }
                    }
                    .onChange(of: hapticsEnabled) { _, newValue in
                        HapticManager.shared.isEnabled = newValue
                        if newValue {
                            HapticManager.shared.light()
                        }
                    }

                    Toggle(isOn: $soundManager.isEnabled) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.mintGreen)
                            Text("Sound Effects")
                        }
                    }
                    .onChange(of: soundManager.isEnabled) { _, newValue in
                        if newValue {
                            SoundManager.shared.buttonTap()
                        }
                    }
                }

                Section("Subscription") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(subscriptionManager.hasPremiumAccess ? "Premium" : "Free")
                            .foregroundColor(subscriptionManager.hasPremiumAccess ? .mintGreen : .secondary)
                            .fontWeight(subscriptionManager.hasPremiumAccess ? .semibold : .regular)
                    }

                    Button(action: {
                        HapticManager.shared.buttonTap()
                        Task {
                            await subscriptionManager.restore()
                            restoreMessage = subscriptionManager.hasPremiumAccess ? "Subscription restored successfully!" : "No active subscription found."
                            showRestoreAlert = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Restore Purchases")
                        }
                    }
                }

                Section("Sync & Backup") {
                    NavigationLink {
                        SyncSettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(.blue)
                            Text("iCloud Sync")
                            Spacer()
                            SyncStatusBadge()
                        }
                    }
                }

                Section("Legal") {
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        if let url = URL(string: privacyPolicyURL) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.blue)
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: {
                        HapticManager.shared.buttonTap()
                        if let url = URL(string: termsOfServiceURL) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                            Text("Terms of Service")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("Disclaimer"), footer: Text("CozyNCLEX Prep is designed to supplement your NCLEX preparation. Always follow your nursing program's curriculum and consult official NCSBN resources for the most current exam information.")) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                        Text("This app is a study aid only and does not guarantee exam success. Content is for educational purposes and should not replace professional nursing education or clinical judgment.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Support") {
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        if let url = URL(string: "mailto:ethan@cozynclex.com?subject=CozyNCLEX%20Prep%20Support") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.mintGreen)
                            Text("Contact Support")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: {
                        HapticManager.shared.buttonTap()
                        requestReview()
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Rate This App")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Ethan Long")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Data") {
                    Button(action: {
                        HapticManager.shared.warning()
                        showResetConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            Text("Reset All Progress")
                                .foregroundColor(.red)
                        }
                    }
                }

                Section(header: Text("Account"), footer: Text("Deleting your account will permanently remove all your data and cannot be undone.")) {
                    Button(action: {
                        HapticManager.shared.warning()
                        showDeleteAccountConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.minus")
                                .foregroundColor(.red)
                            Text("Delete Account")
                                .foregroundColor(.red)
                            Spacer()
                            if isDeletingAccount {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isDeletingAccount)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        HapticManager.shared.buttonTap()
                        dismiss()
                    }
                }
            }
            .onAppear {
                remindersEnabled = notificationManager.isAuthorized
                selectedTime = notificationManager.reminderTime
                hapticsEnabled = HapticManager.shared.isEnabled
            }
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(restoreMessage)
            }
            .alert("Reset All Progress?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllProgress()
                }
            } message: {
                Text("This will delete all your study progress, mastered cards, saved cards, stats, XP, and achievements. This cannot be undone.")
            }
            .alert("Delete Account?", isPresented: $showDeleteAccountConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    showDeleteAccountFinalConfirmation = true
                }
            } message: {
                Text("This will permanently delete your account, all study progress, and personal data. This action cannot be undone.")
            }
            .sheet(isPresented: $showDeleteAccountFinalConfirmation) {
                DeleteAccountConfirmationView(
                    deleteConfirmationText: $deleteConfirmationText,
                    isDeletingAccount: $isDeletingAccount,
                    onDelete: deleteAccount
                )
            }
        }
    }

    private func deleteAccount() {
        isDeletingAccount = true
        Task {
            // Reset all local progress first
            resetAllProgress()

            // Clear cached content
            SupabaseContentProvider.shared.clearCache()

            // Clear sync data
            SyncManager.shared.resetSync()

            // Delete the account from Supabase
            do {
                try await authManager.deleteAccount()
            } catch {
                print("Error deleting account: \(error)")
            }

            isDeletingAccount = false
            showDeleteAccountFinalConfirmation = false
            dismiss()
        }
    }

    private func resetAllProgress() {
        // Reset CardManager
        cardManager.savedCardIDs.removeAll()
        cardManager.masteredCardIDs.removeAll()
        cardManager.consecutiveCorrect.removeAll()
        cardManager.userCreatedCards.removeAll()
        cardManager.studySets.removeAll()
        cardManager.spacedRepData.removeAll()
        cardManager.cardNotes.removeAll()
        cardManager.flaggedCardIDs.removeAll()
        cardManager.testHistory.removeAll()
        cardManager.saveAll()

        // Reset StatsManager
        statsManager.stats = UserStats()
        statsManager.save()

        // Reset DailyGoalsManager
        dailyGoalsManager.resetAllProgress()

        // Reset achievements
        UserDefaults.standard.removeObject(forKey: "unlockedAchievements")

        // Reset onboarding (optional - commented out)
        // UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")

        HapticManager.shared.success()
        SoundManager.shared.buttonTap()
    }

    private func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

// MARK: - Delete Account Confirmation View

struct DeleteAccountConfirmationView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var deleteConfirmationText: String
    @Binding var isDeletingAccount: Bool
    let onDelete: () -> Void

    private let confirmationWord = "DELETE"

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Warning Icon
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                }
                .padding(.top, 20)

                // Warning Text
                VStack(spacing: 12) {
                    Text("Permanently Delete Account")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.red)

                    Text("This action is irreversible. All your data will be permanently deleted including:")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Data that will be deleted
                VStack(alignment: .leading, spacing: 8) {
                    DeleteItemRow(icon: "chart.line.uptrend.xyaxis", text: "Study progress & statistics")
                    DeleteItemRow(icon: "star.fill", text: "XP, levels & achievements")
                    DeleteItemRow(icon: "bookmark.fill", text: "Saved & mastered cards")
                    DeleteItemRow(icon: "folder.fill", text: "Custom study sets & notes")
                    DeleteItemRow(icon: "icloud.fill", text: "iCloud synced data")
                    DeleteItemRow(icon: "person.fill", text: "Account & profile")
                }
                .padding()
                .background(Color.red.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)

                // Confirmation Input
                VStack(spacing: 8) {
                    Text("Type \"\(confirmationWord)\" to confirm")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)

                    TextField("", text: $deleteConfirmationText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        HapticManager.shared.error()
                        onDelete()
                    }) {
                        HStack {
                            if isDeletingAccount {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "trash.fill")
                                Text("Delete My Account")
                            }
                        }
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(deleteConfirmationText == confirmationWord ? Color.red : Color.red.opacity(0.4))
                        .cornerRadius(14)
                    }
                    .disabled(deleteConfirmationText != confirmationWord || isDeletingAccount)

                    Button("Cancel") {
                        deleteConfirmationText = ""
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct DeleteItemRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.red)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 22)).foregroundColor(color)
            Text(value).font(.system(size: 20, weight: .bold, design: .rounded))
            Text(title).font(.system(size: 11, design: .rounded)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.adaptiveWhite)
        .cornerRadius(16)
    }
}

// MARK: - Study Sets View

struct StudySetsView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var cardManager: CardManager

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton { appManager.currentScreen = .menu }
                Spacer()
                Text("Study Sets").font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Color.clear.frame(width: 40)
            }
            .padding()

            if cardManager.studySets.isEmpty {
                Spacer()
                VStack(spacing: 14) {
                    Text("📚").font(.system(size: 50))
                    Text("No study sets yet").font(.system(size: 18, weight: .semibold, design: .rounded))
                    Text("Create custom sets to organize your study").font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(cardManager.studySets) { set in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(set.name).font(.system(size: 15, weight: .semibold, design: .rounded))
                                    Text("\(set.cardIDs.count) cards").font(.system(size: 12, design: .rounded)).foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.adaptiveWhite)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.creamyBackground)
    }
}

// MARK: - Back Button

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(10)
                .background(Color.adaptiveWhite)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 3)
        }
        .buttonStyle(SoftBounceButtonStyle())
    }
}

// MARK: - Shared Session Complete View

struct SessionCompleteStat: Identifiable {
    let id = UUID()
    let value: String
    let label: String
    let color: Color
}

struct SessionCompleteView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var statsManager: StatsManager

    let performancePercent: Int
    let stats: [SessionCompleteStat]
    let summaryText: String
    let onPlayAgain: () -> Void
    let onHome: () -> Void
    var playAgainLabel: String = "Start Another Session"
    var extraContent: AnyView? = nil

    @State private var showSubscriptionSheet = false

    private var isPremium: Bool {
        subscriptionManager.hasPremiumAccess || (AuthManager.shared.userProfile?.isPremium ?? false)
    }

    private var celebrationIcon: String {
        switch performancePercent {
        case 90...100: return "star.fill"
        case 70..<90: return "flame.fill"
        case 50..<70: return "book.fill"
        default: return "heart.fill"
        }
    }

    private var celebrationIconColor: Color {
        switch performancePercent {
        case 90...100: return .yellow
        case 70..<90: return .orange
        case 50..<70: return .purple
        default: return .mintGreen
        }
    }

    private var celebrationTitle: String {
        switch performancePercent {
        case 100: return "Perfect Score!"
        case 90..<100: return "Session Crushed!"
        case 70..<90: return "Great Progress!"
        case 50..<70: return "Keep It Up!"
        case 30..<50: return "Building Foundations"
        default: return "Every Card Counts"
        }
    }

    private var celebrationSubtitle: String {
        switch performancePercent {
        case 90...100: return "You are one step closer to your RN license."
        case 70..<90: return "You're getting the hang of this — keep going!"
        case 50..<70: return "Solid effort. Review the tricky ones and try again."
        case 30..<50: return "Tough cards! A few more rounds and you'll own them."
        default: return "The hardest part is showing up — and you did. Try again!"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                // Header
                VStack(spacing: 8) {
                    Image(systemName: celebrationIcon)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(celebrationIconColor)
                    Text(celebrationTitle)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text(celebrationSubtitle)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Stats Grid
                HStack(spacing: 0) {
                    ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                        if index > 0 {
                            Divider().frame(height: 40)
                        }
                        VStack(spacing: 6) {
                            Text(stat.value)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(stat.color)
                            Text(stat.label)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.adaptiveWhite)
                .cornerRadius(16)
                .padding(.horizontal, 20)

                // Summary
                Text(summaryText)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                // Extra content (e.g. Review Answers button for tests)
                if let extraContent = extraContent {
                    extraContent
                }

                // Upsell (only for free users scoring 50% or below)
                if !isPremium && performancePercent <= 50 {
                    VStack(spacing: 14) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.yellow)

                        Text("Struggling with some cards? Unlock detailed rationales to understand the why behind every answer.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)

                        Button(action: {
                            showSubscriptionSheet = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill")
                                Text("Unlock Rationales & 1000+ Cards")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                        }

                        Button(action: { onHome() }) {
                            Text("Back to Home")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .underline()
                        }
                    }
                    .padding(20)
                    .background(Color.yellow.opacity(0.08))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                }

                // Action buttons (when no upsell showing)
                if isPremium || performancePercent > 50 {
                    VStack(spacing: 12) {
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            onPlayAgain()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text(playAgainLabel)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.mintGreen, .green], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                        }

                        Button(action: { onHome() }) {
                            Text("Back to Home")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.adaptiveWhite)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer().frame(height: 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.creamyBackground.ignoresSafeArea())
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet()
        }
    }
}

// MARK: - Study Flashcards View (Quizlet-Style)

struct StudyFlashcardsView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @ObservedObject private var dailyGoalsManager = DailyGoalsManager.shared

    // Card data
    @State private var allCards: [Flashcard] = []
    @State private var currentRoundCards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var knowCards: [Flashcard] = []
    @State private var stillLearningCards: [Flashcard] = []

    // UI state
    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var showStamp: String? = nil
    @State private var showRoundSummary = false
    @State private var roundNumber = 1
    @State private var showCelebration = false
    @State private var showConfetti = false
    @State private var startTime = Date()
    @State private var showKnowParticles = false
    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()

            if showCelebration {
                allKnownCelebrationView
            } else if currentRoundCards.isEmpty {
                AllMasteredView {
                    HapticManager.shared.buttonTap()
                    appManager.currentScreen = .cardBrowser
                    cardManager.currentFilter = .mastered
                }
            } else {
                studyContentView
            }

            if showConfetti {
                QuizConfettiOverlay()
                    .allowsHitTesting(false)
            }
        }
        .onAppear { setupSession() }
    }

    // MARK: - Study Content

    private var studyContentView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                BackButton {
                    HapticManager.shared.buttonTap()
                    saveSession()
                    appManager.currentScreen = .menu
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("Study Flashcards")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    if roundNumber > 1 {
                        Text("Round \(roundNumber)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                // Invisible spacer to balance back button
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal)
            .padding(.top, 4)

            // Progress bar
            ProgressBar(current: currentIndex, total: currentRoundCards.count)
                .padding(.horizontal)
                .padding(.top, 8)

            // Counters row
            HStack {
                // Still Learning counter
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                    Text("\(stillLearningCards.count)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Still Learning")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.orange.opacity(0.8))
                }

                Spacer()

                // Know counter
                HStack(spacing: 6) {
                    Text("Know")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.green.opacity(0.8))
                    Text("\(knowCards.count)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            // Card area
            if currentIndex < currentRoundCards.count {
                ZStack {
                    FlashcardView(
                        card: currentRoundCards[currentIndex],
                        isFlipped: $isFlipped,
                        isSaved: cardManager.isSaved(currentRoundCards[currentIndex])
                    ) {
                        HapticManager.shared.light()
                        cardManager.toggleSaved(currentRoundCards[currentIndex])
                    }
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onChanged { g in
                                isDragging = true
                                dragOffset = g.translation
                                let newStamp = g.translation.width > 50 ? "KNOW" : (g.translation.width < -50 ? "STILL LEARNING" : nil)
                                if newStamp != showStamp && newStamp != nil {
                                    if newStamp == "KNOW" {
                                        HapticManager.shared.light()
                                    } else {
                                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                    }
                                }
                                showStamp = newStamp
                            }
                            .onEnded { g in
                                isDragging = false
                                if g.translation.width > 100 {
                                    showKnowParticles = true
                                    markKnow()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { showKnowParticles = false }
                                }
                                else if g.translation.width < -100 { markStillLearning() }
                                else { withAnimation(.spring()) { dragOffset = .zero; showStamp = nil } }
                            }
                    )
                    .onTapGesture {
                        guard !isDragging else { return }
                        HapticManager.shared.cardFlip()
                        SoundManager.shared.cardFlip()
                        withAnimation(.spring(response: 0.5)) { isFlipped.toggle() }
                    }

                    if let stamp = showStamp {
                        StampOverlay(text: stamp, isPositive: stamp == "KNOW")
                    }

                    if showKnowParticles {
                        SwipeParticleEffect()
                            .allowsHitTesting(false)
                    }
                }
            }

            Spacer()

            // Bottom buttons
            if currentIndex < currentRoundCards.count {
                HStack(spacing: 16) {
                    Button(action: { markStillLearning() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                            Text("Still Learning")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange.opacity(0.12))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.orange.opacity(0.3), lineWidth: 1.5))
                    }

                    Button(action: {
                        showKnowParticles = true
                        markKnow()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { showKnowParticles = false }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                            Text("Know")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green.opacity(0.12))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.3), lineWidth: 1.5))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Round Summary

    private var roundSummaryView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🐻").font(.system(size: 60))

            Text("Round \(roundNumber) Complete!")
                .font(.system(size: 26, weight: .bold, design: .rounded))

            // Score display
            VStack(spacing: 8) {
                Text("You know \(knowCards.count) of \(allCards.count) cards")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                // Visual split bar
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        let knowFraction = allCards.isEmpty ? 0 : CGFloat(knowCards.count) / CGFloat(allCards.count)
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: geo.size.width * knowFraction)
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: geo.size.width * (1 - knowFraction))
                    }
                    .cornerRadius(6)
                }
                .frame(height: 12)
                .padding(.horizontal, 40)
            }

            // Legend
            HStack(spacing: 24) {
                HStack(spacing: 6) {
                    Circle().fill(Color.green).frame(width: 10, height: 10)
                    Text("Know: \(knowCards.count)")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 6) {
                    Circle().fill(Color.orange).frame(width: 10, height: 10)
                    Text("Still Learning: \(stillLearningCards.count)")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                if !stillLearningCards.isEmpty {
                    Button(action: { startNextRound() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Keep Studying (\(stillLearningCards.count) cards)")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [.orange, .orange.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                    }
                }

                Button(action: { finishSession() }) {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.adaptiveWhite)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color.creamyBackground)
    }

    // MARK: - Session Complete

    private var sessionAccuracy: Int {
        let total = knowCards.count + stillLearningCards.count
        guard total > 0 else { return 0 }
        return Int(Double(knowCards.count) / Double(total) * 100)
    }

    private var allKnownCelebrationView: some View {
        SessionCompleteView(
            performancePercent: sessionAccuracy,
            stats: [
                SessionCompleteStat(value: "\(sessionAccuracy)%", label: "Accuracy", color: .mintGreen),
                SessionCompleteStat(value: "\(statsManager.stats.currentStreak) Day\(statsManager.stats.currentStreak == 1 ? "" : "s")", label: "Streak", color: .orange),
                SessionCompleteStat(value: "+\(knowCards.count * 10) XP", label: "XP Earned", color: .softLavender)
            ],
            summaryText: "You studied \(allCards.count) cards — \(knowCards.count) known, \(stillLearningCards.count) still learning",
            onPlayAgain: { setupSession() },
            onHome: { finishSession() }
        )
    }

    // MARK: - Actions

    private func markKnow() {
        guard currentIndex < currentRoundCards.count else { return }
        let card = currentRoundCards[currentIndex]
        HapticManager.shared.correctAnswer()
        SoundManager.shared.correctAnswer()
        cardManager.recordCorrectAnswer(card)
        knowCards.append(card)
        advanceCard(positive: true)
    }

    private func markStillLearning() {
        guard currentIndex < currentRoundCards.count else { return }
        let card = currentRoundCards[currentIndex]
        HapticManager.shared.wrongAnswer()
        SoundManager.shared.wrongAnswer()
        cardManager.recordWrongAnswer(card)
        stillLearningCards.append(card)
        advanceCard(positive: false)
    }

    private func advanceCard(positive: Bool) {
        HapticManager.shared.swipe()
        SoundManager.shared.swipe()
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = CGSize(width: positive ? 500 : -500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dragOffset = .zero
            showStamp = nil
            isFlipped = false
            if currentIndex + 1 >= currentRoundCards.count {
                // Session complete — single round like Quizlet
                showCelebration = true
                showConfetti = true
                HapticManager.shared.achievement()
                SoundManager.shared.celebration()
            } else {
                currentIndex += 1
            }
        }
    }

    private func startNextRound() {
        HapticManager.shared.buttonTap()
        roundNumber += 1
        currentRoundCards = stillLearningCards.shuffled()
        stillLearningCards = []
        currentIndex = 0
        isFlipped = false
        showRoundSummary = false
    }

    private func finishSession() {
        HapticManager.shared.buttonTap()
        saveSession()
        SessionProgressManager.shared.clearProgress(for: .flashcards)
        appManager.currentScreen = .menu
    }

    // MARK: - Setup

    private func setupSession() {
        if let progress = cardManager.resumeProgress, progress.gameMode == GameMode.flashcards.rawValue {
            allCards = cardManager.sessionCards
            currentRoundCards = allCards
            cardManager.sessionCards = []
            currentIndex = progress.currentIndex
            // Restore know count from score
            knowCards = Array(allCards.prefix(progress.score))
            cardManager.resumeProgress = nil
        } else if !cardManager.sessionCards.isEmpty {
            allCards = cardManager.sessionCards
            currentRoundCards = allCards
            cardManager.sessionCards = []
            currentIndex = 0
        } else {
            allCards = cardManager.getGameCards(isSubscribed: subscriptionManager.hasPremiumAccess)
            currentRoundCards = allCards
            currentIndex = 0
        }
        knowCards = []
        stillLearningCards = []
        showCelebration = false
        showConfetti = false
        showRoundSummary = false
        roundNumber = 1
        startTime = Date()
    }

    // MARK: - Save

    private func saveSession() {
        let cardsStudied = knowCards.count + stillLearningCards.count
        let timeSpent = Int(Date().timeIntervalSince(startTime))
        if cardsStudied > 0 {
            statsManager.recordSession(cardsStudied: cardsStudied, correct: knowCards.count, timeSeconds: timeSpent, mode: "Flashcards")
            dailyGoalsManager.recordStudySession(cardsStudied: cardsStudied, correct: knowCards.count, timeSeconds: timeSpent)

            let categoriesStudied = Set((knowCards + stillLearningCards).map { $0.contentCategory })
            for category in categoriesStudied {
                dailyGoalsManager.recordCategoryStudied(category)
            }
        }

        // Save progress for resume if mid-session
        if !showCelebration && !showRoundSummary && currentIndex > 0 && currentIndex < currentRoundCards.count {
            SessionProgressManager.shared.saveProgress(
                gameMode: .flashcards,
                cardIDs: currentRoundCards.map { $0.id },
                currentIndex: currentIndex,
                score: knowCards.count
            )
        } else {
            SessionProgressManager.shared.clearProgress(for: .flashcards)
        }
    }
}

struct ProgressBar: View {
    let current: Int
    let total: Int

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gray.opacity(0.2)).frame(height: 6)
                Capsule().fill(LinearGradient(colors: [.mintGreen, .pastelPink], startPoint: .leading, endPoint: .trailing))
                    .frame(width: total > 0 ? geo.size.width * CGFloat(current) / CGFloat(total) : 0, height: 6)
            }
        }
        .frame(height: 6)
    }
}

struct FlashcardView: View {
    let card: Flashcard
    @Binding var isFlipped: Bool
    let isSaved: Bool
    let onSaveTap: () -> Void
    @StateObject private var speechManager = SpeechManager()

    private var spokenText: String {
        isFlipped ? card.answer : card.question
    }

    var body: some View {
        GeometryReader { geo in
            let cardWidth = min(geo.size.width - 32, 500)
            let cardHeight = min(geo.size.height * 0.85, 520)
            ZStack {
                CardFace(content: card.answer, category: card.contentCategory, isQuestion: false, rationale: card.rationale)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0)).opacity(isFlipped ? 1 : 0)
                CardFace(content: card.question, category: card.contentCategory, isQuestion: true, rationale: "")
                    .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0)).opacity(isFlipped ? 0 : 1)
            }
            .frame(width: cardWidth, height: cardHeight)
            .overlay(alignment: .topTrailing) {
                Button(action: onSaveTap) {
                    Image(systemName: isSaved ? "heart.fill" : "heart").font(.system(size: 22))
                        .foregroundColor(isSaved ? .red : .gray).padding(14)
                }
            }
            .overlay(alignment: .topLeading) {
                Button(action: {
                    HapticManager.shared.light()
                    speechManager.speak(spokenText)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .padding(14)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CardFace: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    let content: String
    let category: ContentCategory
    let isQuestion: Bool
    let rationale: String

    private let cardCream = Color(red: 1.0, green: 0.996, blue: 0.973) // #FFFEF8

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Category header (centered)
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: category.icon).foregroundColor(category.color)
                    Text(category.rawValue).font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                }
                Spacer()
            }

            if isQuestion {
                // Question side - left-aligned for clinical readability
                Spacer()
                Text(content)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                Spacer()
                Text("Tap to reveal")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                // Answer side - scrollable, left-aligned
                ScrollView(showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(content)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)

                        if !rationale.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 4) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.yellow)
                                    Text("Rationale")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(.secondary)
                                    if !subscriptionManager.hasPremiumAccess {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 9))
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Text(rationale)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .blur(radius: subscriptionManager.hasPremiumAccess ? 0 : 6)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 10)
                }

                Text("Answer")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(cardCream)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(category.color.opacity(0.2), lineWidth: 1.5)
        )
    }
}

struct StampOverlay: View {
    let text: String
    let isPositive: Bool

    var body: some View {
        Text(text).font(.system(size: 28, weight: .black, design: .rounded))
            .foregroundColor(isPositive ? .green : .red)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(isPositive ? Color.green : Color.red, lineWidth: 4))
            .rotationEffect(.degrees(isPositive ? -15 : 15))
    }
}

struct SwipeParticleEffect: View {
    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, opacity: Double, symbol: String)] = []
    private let symbols = ["star.fill", "heart.fill", "sparkle", "star.fill", "heart.fill"]

    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { p in
                Image(systemName: p.symbol)
                    .font(.system(size: CGFloat.random(in: 12...20)))
                    .foregroundColor(.green.opacity(p.opacity))
                    .offset(x: p.x, y: p.y)
            }
        }
        .onAppear {
            for i in 0..<12 {
                let startX = CGFloat.random(in: -60...60)
                let startY = CGFloat.random(in: -20...20)
                particles.append((id: i, x: startX, y: startY, opacity: 1.0, symbol: symbols[i % symbols.count]))
            }
            withAnimation(.easeOut(duration: 0.6)) {
                particles = particles.map { p in
                    (id: p.id, x: p.x + CGFloat.random(in: -40...40), y: p.y - CGFloat.random(in: 40...120), opacity: 0.0, symbol: p.symbol)
                }
            }
        }
    }
}

struct SwipeInstructions: View {
    var body: some View {
        HStack(spacing: 35) {
            VStack(spacing: 4) {
                Image(systemName: "arrow.left").font(.system(size: 22)).foregroundColor(.red.opacity(0.6))
                Text("Study More").font(.system(size: 11, design: .rounded)).foregroundColor(.secondary)
            }
            VStack(spacing: 4) {
                Image(systemName: "hand.tap").font(.system(size: 22)).foregroundColor(.blue.opacity(0.6))
                Text("Tap to Flip").font(.system(size: 11, design: .rounded)).foregroundColor(.secondary)
            }
            VStack(spacing: 4) {
                Image(systemName: "arrow.right").font(.system(size: 22)).foregroundColor(.green.opacity(0.6))
                Text("Got It!").font(.system(size: 11, design: .rounded)).foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 25)
    }
}

struct AllMasteredView: View {
    let onViewCards: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("🎉").font(.system(size: 55))
            Text("All cards mastered!").font(.system(size: 22, weight: .bold, design: .rounded))
            Text("Unmaster some cards to continue").font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
            Button(action: onViewCards) {
                Text("View Mastered Cards").font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white).padding(.horizontal, 22).padding(.vertical, 11)
                    .background(Color.pastelPink).cornerRadius(22)
            }
        }
    }
}

struct CelebrationView: View {
    let score: Int
    let total: Int
    let onRestart: () -> Void
    var onHome: (() -> Void)? = nil

    var percentage: Int { total > 0 ? Int(Double(score) / Double(total) * 100) : 0 }

    var body: some View {
        VStack(spacing: 20) {
            Text(percentage >= 80 ? "🏆" : percentage >= 60 ? "⭐" : "📚").font(.system(size: 65))
            Text(percentage >= 80 ? "Excellent!" : percentage >= 60 ? "Good Job!" : "Keep Studying!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text("Score: \(score)/\(total) (\(percentage)%)")
                .font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
            Button(action: onRestart) {
                Text("Study Again").font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white).padding(.horizontal, 35).padding(.vertical, 14)
                    .background(LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(22)
            }
            if let onHome {
                Button(action: onHome) {
                    HStack(spacing: 6) {
                        Image(systemName: "house.fill").font(.system(size: 14))
                        Text("Home").font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30).padding(.vertical, 12)
                }
            }
        }
    }
}

// MARK: - Bear Learn View (Adaptive Learning)

struct BearLearnView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @ObservedObject private var dailyGoalsManager = DailyGoalsManager.shared

    // Session card tracking
    @State private var sessionCards: [LearnSessionCard] = []
    @State private var cardQueue: [UUID] = []           // Order to show cards
    @State private var currentCardId: UUID? = nil
    @State private var learnedCount: Int = 0
    @State private var totalCards: Int = 0

    // UI state
    @State private var shuffledAnswers: [String] = []
    @State private var selectedAnswer: String? = nil
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showRationale = false
    @State private var showCelebration = false
    @State private var showConfetti = false
    @State private var streakCount = 0
    @State private var startTime = Date()
    @State private var cardScale: CGFloat = 1.0
    @State private var cardOpacity: Double = 1.0
    @State private var aboutToLearn = false  // Card is level 1, about to become learned

    var currentSessionCard: LearnSessionCard? {
        guard let id = currentCardId else { return nil }
        return sessionCards.first { $0.id == id }
    }

    var currentCard: Flashcard? { currentSessionCard?.card }

    var totalAttempts: Int {
        sessionCards.reduce(0) { $0 + $1.attempts }
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.creamyBackground, Color.softLavender.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                LearnHeader(
                    learnedCount: learnedCount,
                    totalCards: totalCards,
                    streakCount: streakCount,
                    onBack: {
                        HapticManager.shared.buttonTap()
                        saveSession()
                        appManager.currentScreen = .menu
                    }
                )

                if showCelebration {
                    SessionCompleteView(
                        performancePercent: totalAttempts > 0 ? Int(Double(totalCards) / Double(totalAttempts) * 100) : 0,
                        stats: [
                            SessionCompleteStat(value: "\(totalCards)", label: "Terms Learned", color: .mintGreen),
                            SessionCompleteStat(value: "\(totalAttempts > 0 ? Int(Double(totalCards) / Double(totalAttempts) * 100) : 0)%", label: "Efficiency", color: .softLavender),
                            SessionCompleteStat(value: "\(StatsManager.shared.stats.currentStreak) Day\(StatsManager.shared.stats.currentStreak == 1 ? "" : "s")", label: "Streak", color: .orange)
                        ],
                        summaryText: "Mastered \(totalCards) terms in \(totalAttempts) attempts",
                        onPlayAgain: {
                            HapticManager.shared.buttonTap()
                            resetLearn()
                        },
                        onHome: {
                            HapticManager.shared.buttonTap()
                            saveSession()
                            appManager.currentScreen = .menu
                        },
                        playAgainLabel: "Learn More"
                    )
                } else if sessionCards.isEmpty {
                    Spacer()
                    AllMasteredView {
                        HapticManager.shared.buttonTap()
                        appManager.currentScreen = .cardBrowser
                        cardManager.currentFilter = .mastered
                    }
                    Spacer()
                } else if let card = currentCard {
                    Spacer()
                        .frame(maxHeight: 20)

                    // About to learn indicator
                    if aboutToLearn {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Get this right to learn it!")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.yellow.opacity(0.15))
                        .cornerRadius(20)
                        .transition(.scale.combined(with: .opacity))
                    }

                    // Main Question Modal Card
                    LearnModalCard(
                        card: card,
                        shuffledAnswers: shuffledAnswers,
                        selectedAnswer: selectedAnswer,
                        showResult: showResult,
                        isCorrect: isCorrect,
                        showRationale: showRationale,
                        aboutToLearn: aboutToLearn,
                        onSelectAnswer: { answer in
                            selectAnswer(answer, correctAnswer: card.answer)
                        },
                        onNext: {
                            HapticManager.shared.buttonTap()
                            nextCard()
                        }
                    )
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)

                    Spacer()
                        .frame(maxHeight: 16)

                    // Remaining cards indicator
                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 12))
                        Text("\(cardQueue.count) cards remaining")
                            .font(.system(size: 13, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                } else {
                    // Fallback
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .onAppear {
                        if !sessionCards.isEmpty {
                            loadNextCard()
                        }
                    }
                    Spacer()
                }
            }

            // Confetti overlay
            if showConfetti {
                QuizConfettiOverlay()
                    .allowsHitTesting(false)
            }
        }
        .onAppear { setupLearnSession() }
    }

    func setupLearnSession() {
        // Check if resuming from saved progress
        if let progress = cardManager.resumeProgress, progress.gameMode == GameMode.learn.rawValue {
            // Resuming a previous session
            // progress.cardIDs contains the unlearned cards (remaining to study)
            // progress.currentIndex stores the learnedCount
            // progress.cardsReviewed stores the original totalCards
            // progress.streakCount stores the streak

            let allCards = cardManager.getAvailableCards(isSubscribed: subscriptionManager.hasPremiumAccess)
            let remainingCardIDs = Set(progress.cardIDs.compactMap { UUID(uuidString: $0) })
            // Filter out SATA questions - reserved for Practice Test only
            let remainingCards = allCards.filter { remainingCardIDs.contains($0.id) && $0.questionType != .sata }

            // Restore order from saved progress
            var orderedCards: [Flashcard] = []
            for idString in progress.cardIDs {
                if let uuid = UUID(uuidString: idString),
                   let card = remainingCards.first(where: { $0.id == uuid }) {
                    orderedCards.append(card)
                }
            }

            // Convert to LearnSessionCards (starting at level 0 for remaining cards)
            sessionCards = orderedCards.map { LearnSessionCard(id: $0.id, card: $0) }
            cardQueue = sessionCards.map { $0.id }  // Keep the saved order

            // Restore progress
            learnedCount = progress.currentIndex  // We stored learnedCount here
            totalCards = progress.cardsReviewed   // We stored totalCards here
            streakCount = progress.streakCount

            cardManager.resumeProgress = nil // Clear after use
            cardManager.sessionCards = []
        } else if !cardManager.sessionCards.isEmpty {
            // New session with selected cards (from setup screen)
            // Filter out SATA questions - reserved for Practice Test only
            let cards = cardManager.sessionCards.filter { $0.questionType != .sata }
            cardManager.sessionCards = []

            sessionCards = cards.map { LearnSessionCard(id: $0.id, card: $0) }
            totalCards = sessionCards.count
            cardQueue = sessionCards.map { $0.id }.shuffled()
            learnedCount = 0
            streakCount = 0
        } else {
            // New session with default cards
            // Filter out SATA questions - reserved for Practice Test only
            let cards = cardManager.getGameCards(isSubscribed: subscriptionManager.hasPremiumAccess)
                .filter { $0.questionType != .sata }

            sessionCards = cards.map { LearnSessionCard(id: $0.id, card: $0) }
            totalCards = sessionCards.count
            cardQueue = sessionCards.map { $0.id }.shuffled()
            learnedCount = 0
            streakCount = 0
        }

        startTime = Date()
        loadNextCard()
    }

    func loadNextCard() {
        guard !cardQueue.isEmpty else {
            showCelebration = true
            HapticManager.shared.achievement()
            SoundManager.shared.celebration()
            return
        }

        currentCardId = cardQueue.removeFirst()
        guard let sessionCard = currentSessionCard else { return }

        // Check if card is about to be learned
        aboutToLearn = sessionCard.sessionLevel == 1

        // Animate card in
        cardScale = 0.8
        cardOpacity = 0

        shuffledAnswers = sessionCard.card.shuffledAnswers()
        selectedAnswer = nil
        showResult = false
        isCorrect = false
        showRationale = false
        showConfetti = false

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
    }

    func selectAnswer(_ answer: String, correctAnswer: String) {
        guard !showResult, let cardId = currentCardId,
              let index = sessionCards.firstIndex(where: { $0.id == cardId }) else { return }

        // Haptic feedback
        HapticManager.shared.medium()

        selectedAnswer = answer
        isCorrect = answer == correctAnswer

        withAnimation(.easeInOut(duration: 0.3)) {
            showResult = true
        }

        // Update session card
        sessionCards[index].attempts += 1

        if isCorrect {
            sessionCards[index].correctStreak += 1
            sessionCards[index].sessionLevel += 1
            streakCount += 1

            if sessionCards[index].isLearned {
                learnedCount += 1
                // Card is learned - don't add back to queue
                // Show extra celebration for learning
                withAnimation(.easeOut(duration: 0.2)) {
                    showConfetti = true
                }
            } else {
                // Move card further back (5-8 positions)
                reinsertCard(cardId, positions: Int.random(in: 5...8))
                // Still show confetti for correct
                withAnimation(.easeOut(duration: 0.2)) {
                    showConfetti = true
                }
            }

            // Update spaced rep (quality 4 for correct)
            cardManager.recordSpacedRepResponse(card: sessionCards[index].card, quality: 4)
            cardManager.recordCorrectAnswer(sessionCards[index].card)

            // Success feedback
            HapticManager.shared.correctAnswer()
            SoundManager.shared.correctAnswer()
        } else {
            sessionCards[index].correctStreak = 0
            sessionCards[index].sessionLevel = 0  // Reset to beginning
            streakCount = 0

            // Card returns soon (3-5 positions)
            reinsertCard(cardId, positions: Int.random(in: 3...5))

            // Update spaced rep (quality 1 for wrong)
            cardManager.recordSpacedRepResponse(card: sessionCards[index].card, quality: 1)
            cardManager.recordWrongAnswer(sessionCards[index].card)

            // Error feedback
            HapticManager.shared.wrongAnswer()
            SoundManager.shared.wrongAnswer()

            // Shake animation
            withAnimation(.default) {
                cardScale = 0.98
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    cardScale = 1.0
                }
            }
        }

        statsManager.recordCategoryResult(category: sessionCards[index].card.contentCategory.rawValue, correct: isCorrect)

        // Check if session complete
        if learnedCount >= totalCards {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showCelebration = true
                HapticManager.shared.achievement()
                SoundManager.shared.celebration()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showRationale = true
                }
            }
        }
    }

    func reinsertCard(_ cardId: UUID, positions: Int) {
        let insertIndex = min(positions, cardQueue.count)
        cardQueue.insert(cardId, at: insertIndex)
    }

    func nextCard() {
        // Animate card out
        withAnimation(.easeInOut(duration: 0.2)) {
            cardScale = 0.9
            cardOpacity = 0
            aboutToLearn = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            loadNextCard()
        }
    }

    func resetLearn() {
        saveSession()
        // Navigate back to menu so user goes through setup flow again
        appManager.currentScreen = .menu
    }

    func saveSession() {
        let timeSpent = Int(Date().timeIntervalSince(startTime))
        let cardsStudied = sessionCards.filter { $0.attempts > 0 }.count

        if cardsStudied > 0 {
            let correctAnswers = sessionCards.filter { $0.isLearned }.count
            statsManager.recordSession(cardsStudied: cardsStudied, correct: correctAnswers, timeSeconds: timeSpent, mode: "Learn")
            dailyGoalsManager.recordStudySession(cardsStudied: cardsStudied, correct: correctAnswers, timeSeconds: timeSpent)

            // Track categories studied
            let categoriesStudied = Set(sessionCards.filter { $0.attempts > 0 }.map { $0.card.contentCategory })
            for category in categoriesStudied {
                dailyGoalsManager.recordCategoryStudied(category)
            }

            // Track correct streak
            dailyGoalsManager.recordCorrectStreak(streakCount: streakCount)

            // Check for perfect session (all learned with no mistakes)
            if showCelebration && totalAttempts == totalCards && totalCards >= 5 {
                dailyGoalsManager.recordPerfectQuiz()
            }
        }

        // Save progress for resume (only if not completed and user has made progress)
        let unlearnedCards = sessionCards.filter { !$0.isLearned }
        let hasStartedSession = cardsStudied > 0 || learnedCount > 0

        if !showCelebration && !unlearnedCards.isEmpty && hasStartedSession {
            // Build the remaining card queue: current card (if any) + queue + unlearned cards not in queue
            var remainingCardIDs: [UUID] = []

            // Add current card if exists
            if let currentId = currentCardId {
                remainingCardIDs.append(currentId)
            }

            // Add cards in queue
            remainingCardIDs.append(contentsOf: cardQueue)

            // Add any unlearned cards that might not be in queue yet
            let inQueueOrCurrent = Set(remainingCardIDs)
            for card in unlearnedCards {
                if !inQueueOrCurrent.contains(card.id) {
                    remainingCardIDs.append(card.id)
                }
            }

            // Use max(1, learnedCount) to ensure the guard in saveProgress passes
            // The actual learnedCount is stored in currentIndex, totalCards in cardsReviewed
            let indexToSave = max(1, learnedCount)

            // Save directly to UserDefaults to bypass the guard that requires currentIndex > 0
            let progress = SessionProgress(
                gameMode: GameMode.learn.rawValue,
                cardIDs: remainingCardIDs.map { $0.uuidString },
                currentIndex: learnedCount,
                score: cardsStudied,  // Store cardsStudied for display
                cardsReviewed: totalCards,
                streakCount: streakCount,
                savedAt: Date()
            )

            if let encoded = try? JSONEncoder().encode(progress) {
                UserDefaults.standard.set(encoded, forKey: "sessionProgress_\(GameMode.learn.rawValue)")
            }
        } else {
            // Clear progress if completed or no progress made
            SessionProgressManager.shared.clearProgress(for: .learn)
        }
    }
}

// MARK: - Learn Header

struct LearnHeader: View {
    let learnedCount: Int
    let totalCards: Int
    let streakCount: Int
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.softLavender)
                }

                Spacer()

                // Mascot and title
                HStack(spacing: 8) {
                    Image("NurseBear")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    Text("Bear Learn")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }

                Spacer()

                // Streak indicator
                if streakCount > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streakCount)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 4)
                } else {
                    // Placeholder for alignment
                    Color.clear.frame(width: 44, height: 1)
                }
            }
            .padding(.horizontal)

            // Progress section
            VStack(spacing: 6) {
                // Progress text
                Text("\(learnedCount) of \(totalCards) terms learned")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                // Progress bar
                GeometryReader { barGeo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(colors: [.mintGreen, .softLavender], startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(0, CGFloat(learnedCount) / CGFloat(max(1, totalCards))) * barGeo.size.width, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: learnedCount)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

// MARK: - Learn Modal Card

struct LearnModalCard: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    let card: Flashcard
    let shuffledAnswers: [String]
    let selectedAnswer: String?
    let showResult: Bool
    let isCorrect: Bool
    let showRationale: Bool
    let aboutToLearn: Bool
    let onSelectAnswer: (String) -> Void
    let onNext: () -> Void

    // Filter answers when showing result: only show selected + correct answer
    var visibleAnswers: [(index: Int, answer: String)] {
        if showResult {
            return shuffledAnswers.enumerated().filter { (_, answer) in
                answer == selectedAnswer || answer == card.answer
            }.map { (index: $0.offset, answer: $0.element) }
        } else {
            return shuffledAnswers.enumerated().map { (index: $0.offset, answer: $0.element) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Question Section
            VStack(spacing: 16) {
                // Category and difficulty badges
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: card.contentCategory.icon)
                            .font(.system(size: 12))
                            .foregroundColor(card.contentCategory.color)
                        Text(card.contentCategory.rawValue)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(card.contentCategory.color)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(card.contentCategory.color.opacity(0.15))
                    .cornerRadius(12)

                    Spacer()

                    Text(card.difficulty.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(card.difficulty.color)
                        .cornerRadius(12)
                }

                // Question text
                Text(card.question)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.vertical, 8)
            }
            .padding(20)
            .background(Color.cardBackground)

            Divider()

            // Answers Section (scrollable with constrained height)
            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 10) {
                        ForEach(visibleAnswers, id: \.answer) { item in
                            LearnAnswerOption(
                                answer: item.answer,
                                index: item.index,
                                isSelected: selectedAnswer == item.answer,
                                isCorrectAnswer: item.answer == card.answer,
                                showResult: showResult,
                                aboutToLearn: aboutToLearn && !showResult,
                                action: { onSelectAnswer(item.answer) }
                            )
                        }
                        .animation(.easeInOut(duration: 0.3), value: showResult)

                        // Rationale (inside scroll so it's viewable)
                        if showResult && showRationale && !card.rationale.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                    Text("Rationale")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    if !subscriptionManager.hasPremiumAccess {
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Image(systemName: "lock.fill").font(.system(size: 10))
                                            Text("Premium").font(.system(size: 11, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(.secondary)
                                    }
                                }
                                Text(card.rationale)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .blur(radius: subscriptionManager.hasPremiumAccess ? 0 : 6)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(12)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .id("rationale")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.45)
                .background(Color.cardBackground.opacity(0.5))
                .onChange(of: showRationale) { newValue in
                    if newValue {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scrollProxy.scrollTo("rationale", anchor: .bottom)
                        }
                    }
                }
            }

            // Continue button (fixed at bottom, outside scroll)
            if showResult {
                Button(action: onNext) {
                    HStack {
                        Text("Continue")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: isCorrect ? [.mintGreen, .green.opacity(0.8)] : [.softLavender, .pastelPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.cardBackground)
                .transition(.scale.combined(with: .opacity))
            }

            // Result Banner
            if showResult {
                LearnResultBanner(isCorrect: isCorrect)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showResult)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showRationale)
    }
}

// MARK: - Learn Answer Option

struct LearnAnswerOption: View {
    let answer: String
    let index: Int
    let isSelected: Bool
    let isCorrectAnswer: Bool
    let showResult: Bool
    let aboutToLearn: Bool
    let action: () -> Void

    var backgroundColor: Color {
        if showResult {
            if isCorrectAnswer { return .mintGreen.opacity(0.2) }
            if isSelected { return .coralPink.opacity(0.2) }
        }
        if isSelected { return .softLavender.opacity(0.3) }
        return Color.cardBackground
    }

    var borderColor: Color {
        if showResult {
            if isCorrectAnswer { return .mintGreen }
            if isSelected { return .coralPink }
        }
        if aboutToLearn { return .yellow.opacity(0.5) }
        if isSelected { return .softLavender }
        return Color.gray.opacity(0.2)
    }

    var letterLabels: [String] { ["A", "B", "C", "D"] }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Letter badge
                ZStack {
                    Circle()
                        .fill(showResult && isCorrectAnswer ? Color.mintGreen :
                                showResult && isSelected ? Color.coralPink :
                                aboutToLearn ? Color.yellow.opacity(0.3) :
                                Color.gray.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Text(index < letterLabels.count ? letterLabels[index] : "?")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(showResult && (isCorrectAnswer || isSelected) ? .white : .primary)
                }

                Text(answer)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)

                Spacer()

                if showResult {
                    if isCorrectAnswer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.mintGreen)
                            .font(.system(size: 22))
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.coralPink)
                            .font(.system(size: 22))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: aboutToLearn && !showResult ? 2 : 1.5)
            )
        }
        .disabled(showResult)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Learn Result Banner

struct LearnResultBanner: View {
    let isCorrect: Bool

    var body: some View {
        HStack {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 20))
            Text(isCorrect ? "Correct!" : "Not quite - keep practicing!")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(isCorrect ? Color.mintGreen : Color.coralPink)
    }
}

// MARK: - Quiz Modal Card (Legacy - used by other views)

struct QuizModalCard: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    let card: Flashcard
    let shuffledAnswers: [String]
    let selectedAnswer: String?
    let showResult: Bool
    let isCorrect: Bool
    let showRationale: Bool
    let onSelectAnswer: (String) -> Void
    let onNext: () -> Void

    // Filter answers when showing result: only show selected + correct answer
    var visibleAnswers: [(index: Int, answer: String)] {
        if showResult {
            return shuffledAnswers.enumerated().filter { (_, answer) in
                answer == selectedAnswer || answer == card.answer
            }.map { (index: $0.offset, answer: $0.element) }
        } else {
            return shuffledAnswers.enumerated().map { (index: $0.offset, answer: $0.element) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Question Section
            VStack(spacing: 16) {
                // Category and difficulty badges
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: card.contentCategory.icon)
                            .font(.system(size: 12))
                            .foregroundColor(card.contentCategory.color)
                        Text(card.contentCategory.rawValue)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(card.contentCategory.color)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(card.contentCategory.color.opacity(0.15))
                    .cornerRadius(12)

                    Spacer()

                    Text(card.difficulty.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(card.difficulty.color)
                        .cornerRadius(12)
                }

                // Question text
                Text(card.question)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.vertical, 8)
            }
            .padding(20)
            .background(Color.cardBackground)

            Divider()

            // Answers Section (scrollable with constrained height)
            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 10) {
                        ForEach(visibleAnswers, id: \.answer) { item in
                            QuizAnswerOption(
                                answer: item.answer,
                                index: item.index,
                                isSelected: selectedAnswer == item.answer,
                                isCorrectAnswer: item.answer == card.answer,
                                showResult: showResult,
                                action: { onSelectAnswer(item.answer) }
                            )
                        }
                        .animation(.easeInOut(duration: 0.3), value: showResult)

                        // Rationale (inside scroll so it's viewable)
                        if showResult && showRationale && !card.rationale.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                    Text("Rationale")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    if !subscriptionManager.hasPremiumAccess {
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Image(systemName: "lock.fill").font(.system(size: 10))
                                            Text("Premium").font(.system(size: 11, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(.secondary)
                                    }
                                }
                                Text(card.rationale)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .blur(radius: subscriptionManager.hasPremiumAccess ? 0 : 6)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(12)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .id("rationale")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.45)
                .background(Color.cardBackground.opacity(0.5))
                .onChange(of: showRationale) { newValue in
                    if newValue {
                        // Auto-scroll to show rationale when it appears
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scrollProxy.scrollTo("rationale", anchor: .bottom)
                        }
                    }
                }
            }

            // Continue button (fixed at bottom, outside scroll)
            if showResult {
                Button(action: onNext) {
                    HStack {
                        Text("Continue")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: isCorrect ? [.mintGreen, .green.opacity(0.8)] : [.pastelPink, .softLavender],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.cardBackground)
                .transition(.scale.combined(with: .opacity))
            }

            // Result Banner
            if showResult {
                ResultBanner(isCorrect: isCorrect)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showResult)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showRationale)
    }
}

// MARK: - Quiz Answer Option

struct QuizAnswerOption: View {
    let answer: String
    let index: Int
    let isSelected: Bool
    let isCorrectAnswer: Bool
    let showResult: Bool
    let action: () -> Void

    private let letters = ["A", "B", "C", "D", "E", "F"]

    var backgroundColor: Color {
        if showResult {
            if isCorrectAnswer { return Color.green.opacity(0.15) }
            if isSelected && !isCorrectAnswer { return Color.red.opacity(0.15) }
        }
        return isSelected ? Color.pastelPink.opacity(0.15) : Color.cardBackground
    }

    var borderColor: Color {
        if showResult {
            if isCorrectAnswer { return .green }
            if isSelected && !isCorrectAnswer { return .red }
        }
        return isSelected ? .pastelPink : Color.gray.opacity(0.2)
    }

    var letterBackgroundColor: Color {
        if showResult {
            if isCorrectAnswer { return .green }
            if isSelected && !isCorrectAnswer { return .red }
        }
        return isSelected ? .pastelPink : Color.gray.opacity(0.15)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Letter badge
                Text(index < letters.count ? letters[index] : "\(index + 1)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected || (showResult && isCorrectAnswer) ? .white : .secondary)
                    .frame(width: 32, height: 32)
                    .background(letterBackgroundColor)
                    .cornerRadius(10)

                // Answer text
                Text(answer)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                // Result icon
                if showResult {
                    if isCorrectAnswer {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.green)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(14)
            .background(backgroundColor)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: isSelected || (showResult && isCorrectAnswer) ? 2 : 1)
            )
        }
        .disabled(showResult)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: showResult)
    }
}

// MARK: - Result Banner

struct ResultBanner: View {
    let isCorrect: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 24))

            Text(isCorrect ? "Correct!" : "Not quite!")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            if isCorrect {
                Text("+1")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.adaptiveWhite.opacity(0.3))
                    .cornerRadius(8)
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: isCorrect ? [.green, .mintGreen] : [.red.opacity(0.8), .coralPink],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

// MARK: - Quiz Progress Dots

struct QuizProgressDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index == current ? Color.pastelPink : Color.gray.opacity(0.3))
                    .frame(width: index == current ? 10 : 8, height: index == current ? 10 : 8)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }
}

// MARK: - Quiz Confetti Overlay

struct QuizConfettiOverlay: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece, screenHeight: geo.size.height)
                }
            }
            .onAppear {
                createConfetti(width: geo.size.width)
            }
        }
    }

    func createConfetti(width: CGFloat) {
        let colors: [Color] = [.pastelPink, .mintGreen, .softLavender, .peachOrange, .skyBlue, .yellow, .red, .orange, .green, .blue, .purple]
        let shapes: [ConfettiShape] = [.rectangle, .circle, .triangle, .strip]

        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: i,
                x: CGFloat.random(in: 0...width),
                color: colors.randomElement() ?? .pastelPink,
                shape: shapes.randomElement() ?? .rectangle,
                size: CGFloat.random(in: 8...14),
                delay: Double.random(in: 0...0.5),
                horizontalMovement: CGFloat.random(in: -100...100),
                rotationSpeed: Double.random(in: 180...720)
            )
            confettiPieces.append(piece)
        }
    }
}

enum ConfettiShape {
    case rectangle, circle, triangle, strip
}

struct ConfettiPiece: Identifiable {
    let id: Int
    let x: CGFloat
    let color: Color
    let shape: ConfettiShape
    let size: CGFloat
    let delay: Double
    let horizontalMovement: CGFloat
    let rotationSpeed: Double
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    var screenHeight: CGFloat = 900
    @State private var yOffset: CGFloat = -50
    @State private var xOffset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    @State private var rotation3D: Double = 0

    var body: some View {
        confettiShape
            .frame(width: piece.shape == .strip ? piece.size * 0.4 : piece.size,
                   height: piece.shape == .strip ? piece.size * 2.5 : piece.size)
            .foregroundColor(piece.color)
            .position(x: piece.x + xOffset, y: yOffset)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .rotation3DEffect(.degrees(rotation3D), axis: (x: 1, y: 0, z: 0))
            .onAppear {
                withAnimation(.easeIn(duration: 2.5).delay(piece.delay)) {
                    yOffset = screenHeight + 100
                    xOffset = piece.horizontalMovement
                    rotation = piece.rotationSpeed
                    rotation3D = Double.random(in: 180...540)
                }
                withAnimation(.easeIn(duration: 2).delay(piece.delay + 0.5)) {
                    opacity = 0
                }
            }
    }

    @ViewBuilder
    var confettiShape: some View {
        switch piece.shape {
        case .rectangle:
            Rectangle()
        case .circle:
            Circle()
        case .triangle:
            TriangleShape()
        case .strip:
            RoundedRectangle(cornerRadius: 2)
        }
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Learn Celebration View

struct LearnCelebrationView: View {
    let totalCards: Int
    let totalAttempts: Int
    let onPlayAgain: () -> Void
    var onHome: (() -> Void)? = nil
    @State private var showContent = false

    var efficiency: Int {
        totalAttempts > 0 ? Int(Double(totalCards) / Double(totalAttempts) * 100) : 0
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Mascot
            Image("NurseBear")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)

            // Result text
            VStack(spacing: 8) {
                Text("All Terms Learned!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("Great job mastering these terms!")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)

            // Stats display
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(totalCards)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.mintGreen)
                    Text("Terms")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text("\(efficiency)%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.softLavender)
                    Text("Efficiency")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.08), radius: 10)
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)

            Spacer()

            // Learn more button
            Button(action: onPlayAgain) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Learn More")
                }
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)

            if let onHome {
                Button(action: onHome) {
                    HStack(spacing: 6) {
                        Image(systemName: "house.fill").font(.system(size: 14))
                        Text("Home").font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30).padding(.vertical, 12)
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                showContent = true
            }

            // Trigger review prompt for completing learn session
            ReviewManager.shared.recordPositiveExperience()
        }
    }
}

// MARK: - Quiz Celebration View (Legacy)

struct QuizCelebrationView: View {
    let score: Int
    let total: Int
    let onPlayAgain: () -> Void
    var onHome: (() -> Void)? = nil
    @State private var showContent = false

    var percentage: Int { total > 0 ? Int(Double(score) / Double(total) * 100) : 0 }
    var isPassing: Bool { percentage >= 70 }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Mascot
            Image("NurseBear")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)

            // Result text
            VStack(spacing: 8) {
                Text(isPassing ? "Amazing Job!" : "Keep Practicing!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text(isPassing ? "You're doing great!" : "You'll get there!")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)

            // Score display
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(score)/\(total)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.pastelPink)
                    Text("Correct")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text("\(percentage)%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(isPassing ? .mintGreen : .peachOrange)
                    Text("Score")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.08), radius: 10)
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)

            Spacer()

            // Play again button
            Button(action: onPlayAgain) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Play Again")
                }
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)

            if let onHome {
                Button(action: onHome) {
                    HStack(spacing: 6) {
                        Image(systemName: "house.fill").font(.system(size: 14))
                        Text("Home").font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30).padding(.vertical, 12)
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                showContent = true
            }

            // Trigger review prompt for good quiz results
            if isPassing {
                ReviewManager.shared.recordPositiveExperience()
            }
        }
    }
}

// MARK: - Legacy Question Card (for other views)

struct QuestionCard: View {
    let card: Flashcard

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: card.contentCategory.icon).foregroundColor(card.contentCategory.color)
                    Text(card.contentCategory.rawValue).font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                }
                Spacer()
                Text(card.difficulty.rawValue).font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 4)
                    .background(card.difficulty.color).cornerRadius(8)
            }
            Text(card.question).font(.system(size: 18, weight: .semibold, design: .rounded)).multilineTextAlignment(.center)
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 6)
    }
}

struct RationaleBox: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    let rationale: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill").foregroundColor(.yellow)
                Text("Rationale").font(.system(size: 14, weight: .semibold, design: .rounded))
                if !subscriptionManager.hasPremiumAccess {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill").font(.system(size: 10))
                        Text("Premium").font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                }
            }
            Text(rationale).font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
                .blur(radius: subscriptionManager.hasPremiumAccess ? 0 : 6)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.15))
        .cornerRadius(14)
    }
}

// MARK: - Write Mode View

struct WriteModeView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @State private var currentIndex = 0
    @State private var userAnswer = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var score = 0
    @State private var showCelebration = false
    @State private var startTime = Date()
    @State private var writeCards: [Flashcard] = []

    var currentCard: Flashcard? { currentIndex < writeCards.count ? writeCards[currentIndex] : nil }

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    BackButton { saveSession(); appManager.currentScreen = .menu }
                    Spacer()
                    Text("Write Mode ✏️").font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                    Text("Score: \(score)").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.skyBlue)
                }
                .padding(.horizontal)

                if showCelebration {
                    SessionCompleteView(
                        performancePercent: writeCards.count > 0 ? Int(Double(score) / Double(writeCards.count) * 100) : 0,
                        stats: [
                            SessionCompleteStat(value: "\(score)/\(writeCards.count)", label: "Score", color: .mintGreen),
                            SessionCompleteStat(value: "\(StatsManager.shared.stats.currentStreak) Day\(StatsManager.shared.stats.currentStreak == 1 ? "" : "s")", label: "Streak", color: .orange),
                            SessionCompleteStat(value: "+\(score * 10) XP", label: "XP Earned", color: .softLavender)
                        ],
                        summaryText: "You typed \(score) of \(writeCards.count) answers correctly",
                        onPlayAgain: { resetMode() },
                        onHome: { saveSession(); appManager.currentScreen = .menu },
                        playAgainLabel: "Study Again"
                    )
                } else if writeCards.isEmpty {
                    Spacer()
                    AllMasteredView { appManager.currentScreen = .cardBrowser; cardManager.currentFilter = .mastered }
                    Spacer()
                } else if let card = currentCard {
                    ScrollView {
                        VStack(spacing: 20) {
                            QuestionCard(card: card)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Answer").font(.system(size: 14, weight: .semibold, design: .rounded))
                                TextField("Type your answer...", text: $userAnswer, axis: .vertical)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                    .disabled(showResult)
                            }

                            if !showResult {
                                Button(action: checkAnswer) {
                                    Text("Check Answer").font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white).frame(maxWidth: .infinity).padding()
                                        .background(userAnswer.isEmpty ? Color.gray : Color.skyBlue).cornerRadius(14)
                                }
                                .disabled(userAnswer.isEmpty)
                            } else {
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(isCorrect ? .green : .red)
                                        Text(isCorrect ? "Correct!" : "Not quite").font(.system(size: 16, weight: .bold, design: .rounded))
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Correct Answer:").font(.system(size: 13, weight: .semibold, design: .rounded))
                                        Text(card.answer).font(.system(size: 14, design: .rounded)).foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.mintGreen.opacity(0.2))
                                    .cornerRadius(12)

                                    if !card.rationale.isEmpty { RationaleBox(rationale: card.rationale) }

                                    // Override button for when user had a typo but knew the answer
                                    if !isCorrect {
                                        Button(action: overrideAsCorrect) {
                                            HStack {
                                                Image(systemName: "checkmark.circle")
                                                Text("I Got This Right")
                                            }
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.mintGreen).frame(maxWidth: .infinity).padding()
                                            .background(Color.mintGreen.opacity(0.15))
                                            .cornerRadius(12)
                                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.mintGreen, lineWidth: 1))
                                        }
                                    }

                                    Button(action: nextCard) {
                                        Text("Next Question").font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white).frame(maxWidth: .infinity).padding()
                                            .background(Color.pastelPink).cornerRadius(14)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear { setupWriteMode() }
    }

    func setupWriteMode() {
        // Check if resuming from saved progress
        if let progress = cardManager.resumeProgress, progress.gameMode == GameMode.write.rawValue {
            // Use session cards (already restored by resumeGameMode)
            writeCards = cardManager.sessionCards
            cardManager.sessionCards = []
            currentIndex = progress.currentIndex
            score = progress.score
            cardManager.resumeProgress = nil // Clear after use
        } else if !cardManager.sessionCards.isEmpty {
            // Use session cards if available (from setup screen)
            writeCards = cardManager.sessionCards
            cardManager.sessionCards = [] // Clear after use
            currentIndex = 0
            score = 0
        } else {
            writeCards = cardManager.getGameCards(isSubscribed: subscriptionManager.hasPremiumAccess)
            currentIndex = 0
            score = 0
        }
        userAnswer = ""
        showResult = false
        isCorrect = false
        showCelebration = false
        startTime = Date()
    }

    func checkAnswer() {
        guard let card = currentCard else { return }
        HapticManager.shared.buttonTap()

        let normalizedUser = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedCorrect = card.answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        isCorrect = normalizedUser.contains(normalizedCorrect) || normalizedCorrect.contains(normalizedUser) ||
                   similarity(normalizedUser, normalizedCorrect) > 0.7
        showResult = true

        if isCorrect {
            score += 1
            cardManager.recordCorrectAnswer(card)
            HapticManager.shared.correctAnswer()
            SoundManager.shared.correctAnswer()
        } else {
            cardManager.recordWrongAnswer(card)
            HapticManager.shared.wrongAnswer()
            SoundManager.shared.wrongAnswer()
        }
        statsManager.recordCategoryResult(category: card.contentCategory.rawValue, correct: isCorrect)
    }

    func overrideAsCorrect() {
        guard let card = currentCard else { return }
        HapticManager.shared.success()
        SoundManager.shared.correctAnswer()
        // Reverse the wrong answer recording and record as correct instead
        score += 1
        isCorrect = true
        cardManager.recordCorrectAnswer(card)
        // Update stats - we already recorded a wrong, so this is a net correction
        statsManager.recordCategoryResult(category: card.contentCategory.rawValue, correct: true)
    }

    func similarity(_ s1: String, _ s2: String) -> Double {
        let longer = s1.count > s2.count ? s1 : s2
        let shorter = s1.count > s2.count ? s2 : s1
        if longer.isEmpty { return 1.0 }
        let matches = zip(longer, shorter).filter { $0 == $1 }.count
        return Double(matches) / Double(longer.count)
    }

    func nextCard() {
        HapticManager.shared.buttonTap()
        userAnswer = ""; showResult = false; isCorrect = false
        if currentIndex + 1 >= writeCards.count {
            showCelebration = true
            HapticManager.shared.achievement()
            SoundManager.shared.celebration()
        }
        else { currentIndex += 1 }
    }

    func resetMode() {
        HapticManager.shared.buttonTap()
        saveSession()
        setupWriteMode()
    }

    func saveSession() {
        let timeSpent = Int(Date().timeIntervalSince(startTime))
        if currentIndex > 0 {
            statsManager.recordSession(cardsStudied: currentIndex, correct: score, timeSeconds: timeSpent, mode: "Write")
            DailyGoalsManager.shared.recordStudySession(cardsStudied: currentIndex, correct: score, timeSeconds: timeSpent)

            // Track categories studied
            let categoriesStudied = Set(writeCards.prefix(currentIndex).map { $0.contentCategory })
            for category in categoriesStudied {
                DailyGoalsManager.shared.recordCategoryStudied(category)
            }

            // Check for perfect score
            if showCelebration && score == writeCards.count && writeCards.count >= 5 {
                DailyGoalsManager.shared.recordPerfectQuiz()
            }
        }

        // Save progress for resume (only if not completed)
        if !showCelebration && currentIndex > 0 && currentIndex < writeCards.count {
            SessionProgressManager.shared.saveProgress(
                gameMode: .write,
                cardIDs: writeCards.map { $0.id },
                currentIndex: currentIndex,
                score: score
            )
        } else {
            // Clear progress if completed
            SessionProgressManager.shared.clearProgress(for: .write)
        }
    }
}

// MARK: - Practice Test View

struct TestFormat: Identifiable {
    let id = UUID()
    let name: String
    let questionCount: Int
    let timeMinutes: Int

    var timeSeconds: Int { timeMinutes * 60 }
    var description: String { "\(questionCount) questions • \(timeMinutes) minutes" }
}

struct TestModeView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var testCards: [Flashcard] = []
    @State private var shuffledAnswers: [UUID: [String]] = [:] // Pre-shuffled answers
    @State private var currentIndex = 0
    @State private var answers: [UUID: String] = [:]
    @State private var showResults = false
    @State private var startTime = Date()
    @State private var timeRemaining = 7200 // 2 hours default
    @State private var timer: Timer?
    @State private var showExitConfirmation = false
    @State private var selectedFormat: TestFormat? = nil
    @State private var showReviewSheet = false

    // CAT (Computer Adaptive Testing) State
    @State private var isCATMode = true
    @State private var currentDifficulty: Difficulty = .medium
    @State private var competencyScore: Double = 0.0 // Running logit estimate
    @State private var usedCardIDs: Set<UUID> = []
    @State private var consecutiveCorrect = 0
    @State private var consecutiveWrong = 0
    @State private var catTerminated = false
    @State private var catPassed: Bool? = nil

    let testFormats = [
        TestFormat(name: "Quick Quiz", questionCount: 25, timeMinutes: 30),
        TestFormat(name: "Standard Test", questionCount: 50, timeMinutes: 60),
        TestFormat(name: "CAT Simulation", questionCount: 75, timeMinutes: 90)  // Variable length like real NCLEX
    ]

    var availableCards: [Flashcard] { cardManager.getGameCards(isSubscribed: subscriptionManager.hasPremiumAccess) }
    var currentCard: Flashcard? { currentIndex < testCards.count ? testCards[currentIndex] : nil }
    var correctCount: Int { testCards.filter { answers[$0.id] == $0.answer }.count }

    // Get cards by difficulty
    func getCardsByDifficulty(_ difficulty: Difficulty) -> [Flashcard] {
        availableCards.filter { $0.difficulty == difficulty && !usedCardIDs.contains($0.id) }
    }

    // Select next card based on CAT algorithm
    func selectNextCATCard(wasCorrect: Bool) -> Flashcard? {
        // Adjust competency score (simplified IRT model)
        if wasCorrect {
            competencyScore += 0.5
            consecutiveCorrect += 1
            consecutiveWrong = 0
        } else {
            competencyScore -= 0.5
            consecutiveWrong += 1
            consecutiveCorrect = 0
        }

        // Adjust difficulty based on performance
        if wasCorrect {
            switch currentDifficulty {
            case .easy: currentDifficulty = .medium
            case .medium: currentDifficulty = .hard
            case .hard: currentDifficulty = .hard
            }
        } else {
            switch currentDifficulty {
            case .easy: currentDifficulty = .easy
            case .medium: currentDifficulty = .easy
            case .hard: currentDifficulty = .medium
            }
        }

        // Check for early termination (95% confidence rule simulation)
        // If consistently above/below passing after minimum questions
        let minQuestions = 15
        if testCards.count >= minQuestions {
            // Passed: 3 consecutive correct at hard level with positive competency
            if consecutiveCorrect >= 3 && currentDifficulty == .hard && competencyScore > 1.0 {
                catTerminated = true
                catPassed = true
                return nil
            }
            // Failed: 3 consecutive wrong at easy level with negative competency
            if consecutiveWrong >= 3 && currentDifficulty == .easy && competencyScore < -1.0 {
                catTerminated = true
                catPassed = false
                return nil
            }
        }

        // Get cards at current difficulty, fall back to adjacent difficulties
        var candidates = getCardsByDifficulty(currentDifficulty)
        if candidates.isEmpty {
            // Try adjacent difficulties
            switch currentDifficulty {
            case .easy: candidates = getCardsByDifficulty(.medium)
            case .medium: candidates = getCardsByDifficulty(.easy) + getCardsByDifficulty(.hard)
            case .hard: candidates = getCardsByDifficulty(.medium)
            }
        }
        if candidates.isEmpty {
            // Use any remaining card
            candidates = availableCards.filter { !usedCardIDs.contains($0.id) }
        }

        return candidates.randomElement()
    }

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    Button(action: { if testCards.isEmpty { appManager.currentScreen = .menu } else { showExitConfirmation = true } }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                            Text("Back").font(.system(size: 14, weight: .semibold, design: .rounded))
                        }.foregroundColor(.pastelPink)
                    }
                    Spacer()
                    Text("Practice Test 📝").font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                    if !showResults && !testCards.isEmpty {
                        Text(timeString).font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(timeRemaining < 300 ? .red : .secondary)
                    }
                }
                .padding(.horizontal)

                if testCards.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("📋").font(.system(size: 50))
                        Text("Choose Your Test Format").font(.system(size: 20, weight: .bold, design: .rounded))
                        Text("Select how many questions and how much time you want").font(.system(size: 14, design: .rounded)).foregroundColor(.secondary).multilineTextAlignment(.center)

                        VStack(spacing: 12) {
                            ForEach(testFormats) { format in
                                Button(action: { selectedFormat = format }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(format.name).font(.system(size: 16, weight: .semibold, design: .rounded))
                                            Text(format.description).font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if selectedFormat?.id == format.id {
                                            Image(systemName: "checkmark.circle.fill").foregroundColor(.peachOrange).font(.system(size: 22))
                                        } else {
                                            Image(systemName: "circle").foregroundColor(.gray.opacity(0.4)).font(.system(size: 22))
                                        }
                                    }
                                    .padding()
                                    .background(selectedFormat?.id == format.id ? Color.peachOrange.opacity(0.15) : Color.adaptiveWhite)
                                    .cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(selectedFormat?.id == format.id ? Color.peachOrange : Color.gray.opacity(0.2), lineWidth: 2))
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal)

                        Button(action: startTest) {
                            Text("Start Test").font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white).padding(.horizontal, 40).padding(.vertical, 14)
                                .background(selectedFormat != nil ? Color.peachOrange : Color.gray)
                                .cornerRadius(22)
                        }
                        .disabled(selectedFormat == nil)
                    }
                    Spacer()
                } else if showResults {
                    SessionCompleteView(
                        performancePercent: testCards.count > 0 ? Int(Double(correctCount) / Double(testCards.count) * 100) : 0,
                        stats: [
                            SessionCompleteStat(value: "\(correctCount)/\(testCards.count)", label: "Score", color: .mintGreen),
                            SessionCompleteStat(value: "\(testCards.count > 0 ? Int(Double(correctCount) / Double(testCards.count) * 100) : 0)%", label: "Accuracy", color: (testCards.count > 0 && Double(correctCount) / Double(testCards.count) >= 0.7) ? .mintGreen : .peachOrange),
                            SessionCompleteStat(value: "\(StatsManager.shared.stats.currentStreak) Day\(StatsManager.shared.stats.currentStreak == 1 ? "" : "s")", label: "Streak", color: .orange)
                        ],
                        summaryText: (testCards.count > 0 && Double(correctCount) / Double(testCards.count) >= 0.7) ? "You passed! Great job — you're on track." : "You need 70% to pass. Review and try again!",
                        onPlayAgain: {
                            testCards = []; shuffledAnswers = [:]; showResults = false; selectedFormat = nil
                        },
                        onHome: {
                            saveSession()
                            appManager.currentScreen = .menu
                        },
                        playAgainLabel: "Take Another Test",
                        extraContent: AnyView(
                            Button(action: { showReviewSheet = true }) {
                                HStack {
                                    Image(systemName: "doc.text.magnifyingglass")
                                    Text("Review Answers")
                                }
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.pastelPink)
                                .padding(.horizontal, 30).padding(.vertical, 14)
                                .background(Color.pastelPink.opacity(0.15))
                                .cornerRadius(22)
                            }
                        )
                    )
                } else if let card = currentCard, let cardAnswers = shuffledAnswers[card.id] {
                    ProgressBar(current: currentIndex + 1, total: testCards.count).padding(.horizontal)
                    ScrollView {
                        VStack(spacing: 16) {
                            QuestionCard(card: card)
                            ForEach(cardAnswers, id: \.self) { answer in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        answers[card.id] = answer
                                    }
                                } label: {
                                    HStack {
                                        Text(answer)
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                        if answers[card.id] == answer {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.pastelPink)
                                                .font(.system(size: 20))
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray.opacity(0.4))
                                                .font(.system(size: 20))
                                        }
                                    }
                                    .padding()
                                    .background(answers[card.id] == answer ? Color.pastelPink.opacity(0.2) : Color.adaptiveWhite)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(answers[card.id] == answer ? Color.pastelPink : Color.gray.opacity(0.3), lineWidth: 2))
                                }
                                .buttonStyle(.plain)
                            }

                            HStack {
                                // In CAT mode, no going back (like real NCLEX)
                                if currentIndex > 0 && !isCATMode {
                                    Button(action: { currentIndex -= 1 }) {
                                        HStack { Image(systemName: "chevron.left"); Text("Previous") }
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary).padding().background(Color.adaptiveWhite).cornerRadius(12)
                                    }
                                }
                                Spacer()

                                if isCATMode {
                                    // CAT mode: Next adds a new adaptive question
                                    Button(action: nextCATQuestion) {
                                        HStack { Text("Next"); Image(systemName: "chevron.right") }
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white).padding().background(Color.pastelPink).cornerRadius(12)
                                    }
                                    .disabled(answers[card.id] == nil) // Must answer before proceeding
                                } else if currentIndex < testCards.count - 1 {
                                    Button(action: { currentIndex += 1 }) {
                                        HStack { Text("Next"); Image(systemName: "chevron.right") }
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white).padding().background(Color.pastelPink).cornerRadius(12)
                                    }
                                } else {
                                    Button(action: submitTest) {
                                        Text("Submit Test").font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white).padding().background(Color.mintGreen).cornerRadius(12)
                                    }
                                }
                            }

                            // CAT Mode indicator
                            if isCATMode {
                                HStack(spacing: 8) {
                                    Image(systemName: "brain.head.profile")
                                        .foregroundColor(.softLavender)
                                    Text("Adaptive Mode")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text("Difficulty: \(currentDifficulty.rawValue.capitalized)")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(difficultyColor)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding()
                        .frame(maxWidth: 700)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .onDisappear { timer?.invalidate() }
        .alert("Exit Test?", isPresented: $showExitConfirmation) {
            Button("Continue Test", role: .cancel) { }
            Button("Exit", role: .destructive) {
                timer?.invalidate()
                if testCards.count > 0 { saveSession() }
                testCards = []
                shuffledAnswers = [:]
                appManager.currentScreen = .menu
            }
        } message: {
            Text("Your progress will be saved but you'll need to start a new test.")
        }
        .sheet(isPresented: $showReviewSheet) {
            TestReviewView(answers: getTestAnswers())
        }
    }

    var timeString: String {
        let hours = timeRemaining / 3600
        let mins = (timeRemaining % 3600) / 60
        let secs = timeRemaining % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, mins, secs)
        }
        return String(format: "%02d:%02d", mins, secs)
    }

    func startTest() {
        guard let format = selectedFormat else { return }
        HapticManager.shared.buttonTap()
        SoundManager.shared.buttonTap()

        // Reset CAT state
        isCATMode = format.name == "CAT Simulation"
        currentDifficulty = .medium
        competencyScore = 0.0
        usedCardIDs = []
        consecutiveCorrect = 0
        consecutiveWrong = 0
        catTerminated = false
        catPassed = nil

        if isCATMode {
            // CAT mode: Start with one medium difficulty card
            testCards = []
            if let firstCard = getCardsByDifficulty(.medium).randomElement() ?? availableCards.randomElement() {
                testCards.append(firstCard)
                usedCardIDs.insert(firstCard.id)
                shuffledAnswers[firstCard.id] = firstCard.shuffledAnswers()
            }
        } else {
            // Standard mode: Load all questions at once
            let questionCount = min(format.questionCount, availableCards.count)
            testCards = Array(availableCards.shuffled().prefix(questionCount))
            shuffledAnswers = [:]
            for card in testCards {
                shuffledAnswers[card.id] = card.shuffledAnswers()
            }
        }

        currentIndex = 0
        answers = [:]
        startTime = Date()
        timeRemaining = format.timeSeconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 { timeRemaining -= 1 }
            else { submitTest() }
        }
    }

    func submitTest() {
        timer?.invalidate()
        HapticManager.shared.success()
        SoundManager.shared.celebration()

        var categoryBreakdown: [String: CategoryTestResult] = [:]
        var testAnswers: [TestAnswer] = []

        for card in testCards {
            let selectedAnswer = answers[card.id] ?? ""
            let isCorrect = selectedAnswer == card.answer

            if isCorrect { cardManager.recordCorrectAnswer(card) }
            else { cardManager.recordWrongAnswer(card) }
            statsManager.recordCategoryResult(category: card.contentCategory.rawValue, correct: isCorrect)

            // Track category breakdown
            let category = card.contentCategory.rawValue
            var catResult = categoryBreakdown[category] ?? CategoryTestResult()
            catResult.total += 1
            if isCorrect { catResult.correct += 1 }
            categoryBreakdown[category] = catResult

            // Track individual answers for review
            testAnswers.append(TestAnswer(card: card, selectedAnswer: selectedAnswer, isCorrect: isCorrect))
        }

        // Save test result
        let timeSpent = Int(Date().timeIntervalSince(startTime))
        let result = TestResult(
            questionCount: testCards.count,
            correctCount: correctCount,
            timeSpentSeconds: timeSpent,
            categoryBreakdown: categoryBreakdown,
            answers: testAnswers
        )
        cardManager.saveTestResult(result)

        saveSession()
        showResults = true
    }

    func saveSession() {
        let timeSpent = Int(Date().timeIntervalSince(startTime))
        statsManager.recordSession(cardsStudied: testCards.count, correct: correctCount, timeSeconds: timeSpent, mode: "Test")
        DailyGoalsManager.shared.recordStudySession(cardsStudied: testCards.count, correct: correctCount, timeSeconds: timeSpent)

        // Track categories studied
        let categoriesStudied = Set(testCards.map { $0.contentCategory })
        for category in categoriesStudied {
            DailyGoalsManager.shared.recordCategoryStudied(category)
        }

        // Check for perfect test
        if correctCount == testCards.count && testCards.count >= 5 {
            DailyGoalsManager.shared.recordPerfectQuiz()
        }
    }

    func getTestAnswers() -> [TestAnswer] {
        testCards.map { card in
            let selectedAnswer = answers[card.id] ?? ""
            return TestAnswer(card: card, selectedAnswer: selectedAnswer, isCorrect: selectedAnswer == card.answer)
        }
    }

    // CAT helper functions
    var difficultyColor: Color {
        switch currentDifficulty {
        case .easy: return .mintGreen
        case .medium: return .peachOrange
        case .hard: return .coralPink
        }
    }

    func nextCATQuestion() {
        guard let card = currentCard, let selectedAnswer = answers[card.id] else { return }

        let wasCorrect = selectedAnswer == card.answer

        // Check if we've reached max questions
        guard let format = selectedFormat else { return }
        if testCards.count >= format.questionCount {
            submitTest()
            return
        }

        // Select next card based on CAT algorithm
        if let nextCard = selectNextCATCard(wasCorrect: wasCorrect) {
            testCards.append(nextCard)
            usedCardIDs.insert(nextCard.id)
            shuffledAnswers[nextCard.id] = nextCard.shuffledAnswers()
            currentIndex += 1
        } else if catTerminated {
            // CAT algorithm determined pass/fail
            submitTest()
        } else {
            // No more cards available
            submitTest()
        }
    }
}

struct TestResultsView: View {
    let correct: Int
    let total: Int
    let onRetry: () -> Void
    var testAnswers: [TestAnswer] = []
    var onHome: (() -> Void)? = nil
    @State private var showReview = false

    var percentage: Int { total > 0 ? Int(Double(correct) / Double(total) * 100) : 0 }
    var passed: Bool { percentage >= 70 }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(passed ? "🎉" : "📚").font(.system(size: 60))
            Text(passed ? "You Passed!" : "Keep Studying").font(.system(size: 26, weight: .bold, design: .rounded))
            Text("\(correct)/\(total) correct (\(percentage)%)").font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
            Text(passed ? "Great job! You're on track." : "You need 70% to pass. Review and try again!")
                .font(.system(size: 14, design: .rounded)).foregroundColor(.secondary).multilineTextAlignment(.center)

            if !testAnswers.isEmpty {
                Button(action: { showReview = true }) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("Review Answers")
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.pastelPink)
                    .padding(.horizontal, 30).padding(.vertical, 14)
                    .background(Color.pastelPink.opacity(0.15))
                    .cornerRadius(22)
                }
            }

            Button(action: onRetry) {
                Text("Take Another Test").font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white).padding(.horizontal, 30).padding(.vertical, 14)
                    .background(LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(22)
            }
            if let onHome {
                Button(action: onHome) {
                    HStack(spacing: 6) {
                        Image(systemName: "house.fill").font(.system(size: 14))
                        Text("Home").font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30).padding(.vertical, 12)
                }
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showReview) {
            TestReviewView(answers: testAnswers)
        }
    }
}

// MARK: - Test Review View

struct TestReviewView: View {
    let answers: [TestAnswer]
    @Environment(\.dismiss) var dismiss
    @State private var showIncorrectOnly = false

    var filteredAnswers: [TestAnswer] {
        showIncorrectOnly ? answers.filter { !$0.isCorrect } : answers
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter toggle
                Picker("Filter", selection: $showIncorrectOnly) {
                    Text("All Questions").tag(false)
                    Text("Incorrect Only").tag(true)
                }
                .pickerStyle(.segmented)
                .padding()

                if filteredAnswers.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("🎉").font(.system(size: 50))
                        Text("All Correct!").font(.system(size: 20, weight: .bold, design: .rounded))
                        Text("You got every question right!").font(.system(size: 14, design: .rounded)).foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(filteredAnswers.enumerated()), id: \.element.id) { index, answer in
                                TestReviewCard(answer: answer, questionNumber: (answers.firstIndex(where: { $0.id == answer.id }) ?? index) + 1)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color.creamyBackground)
            .navigationTitle("Review Answers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct TestReviewCard: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    let answer: TestAnswer
    let questionNumber: Int
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(answer.isCorrect ? .mintGreen : .coralPink)
                    .font(.system(size: 20))
                Text("Question \(questionNumber)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Spacer()
                Text(answer.category)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }

            Text(answer.question)
                .font(.system(size: 15, weight: .medium, design: .rounded))

            if !answer.isCorrect {
                HStack(alignment: .top, spacing: 8) {
                    Text("Your answer:")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(answer.selectedAnswer.isEmpty ? "No answer" : answer.selectedAnswer)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.coralPink)
                }
            }

            HStack(alignment: .top, spacing: 8) {
                Text("Correct answer:")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                Text(answer.correctAnswer)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.mintGreen)
            }

            if isExpanded && !answer.rationale.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Rationale:")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        if !subscriptionManager.hasPremiumAccess {
                            Text("🔒 Premium")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    Text(answer.rationale)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                        .blur(radius: subscriptionManager.hasPremiumAccess ? 0 : 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !answer.rationale.isEmpty {
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack {
                        Text(isExpanded ? "Hide Rationale" : "Show Rationale")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.softLavender)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Cozy Match View

struct CozyMatchView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var tiles: [MatchTile] = []
    @State private var gameCards: [Flashcard] = []
    @State private var allSessionCards: [Flashcard] = [] // All cards for both rounds
    @State private var selectedTile: MatchTile? = nil
    @State private var matchedPairs = 0
    @State private var moves = 0
    @State private var totalMoves = 0 // Track moves across rounds
    @State private var showWin = false
    @State private var isProcessing = false
    @State private var startTime = Date()
    @State private var currentRound = 1
    @State private var showRoundTransition = false

    private let cardsPerRound = 5
    private let totalRounds = 2

    var availableCards: [Flashcard] { cardManager.getGameCards(isSubscribed: subscriptionManager.hasPremiumAccess) }

    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                // Header
                HStack {
                    BackButton { saveSession(); appManager.currentScreen = .menu }
                    Spacer()
                    Text("Cozy Match 🧩").font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                    Text("Moves: \(totalMoves + moves)").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.softLavender)
                }
                .padding(.horizontal)

                // Round indicator
                HStack(spacing: 8) {
                    ForEach(1...totalRounds, id: \.self) { round in
                        Circle()
                            .fill(round <= currentRound ? Color.softLavender : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                    Text("Round \(currentRound) of \(totalRounds)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Text("Match questions with answers!").font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)

                if showWin {
                    SessionCompleteView(
                        performancePercent: matchedPairs > 0 ? 100 : 0,
                        stats: [
                            SessionCompleteStat(value: "\(totalMoves)", label: "Moves", color: .mintGreen),
                            SessionCompleteStat(value: "\(StatsManager.shared.stats.currentStreak) Day\(StatsManager.shared.stats.currentStreak == 1 ? "" : "s")", label: "Streak", color: .orange),
                            SessionCompleteStat(value: "+\(matchedPairs * 10) XP", label: "XP Earned", color: .softLavender)
                        ],
                        summaryText: "Matched all pairs in \(totalMoves) moves across \(totalRounds) rounds",
                        onPlayAgain: { resetGame() },
                        onHome: { saveSession(); appManager.currentScreen = .menu },
                        playAgainLabel: "Play Again"
                    )
                } else if showRoundTransition {
                    // Round transition screen
                    Spacer()
                    VStack(spacing: 20) {
                        Text("🎉").font(.system(size: 60))
                        Text("Round \(currentRound - 1) Complete!").font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("Get ready for Round \(currentRound)").font(.system(size: 15, design: .rounded)).foregroundColor(.secondary)

                        Button(action: {
                            withAnimation { showRoundTransition = false }
                        }) {
                            Text("Continue")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                                .background(Color.softLavender)
                                .cornerRadius(25)
                        }
                        .padding(.top, 10)
                    }
                    Spacer()
                } else if tiles.isEmpty {
                    Spacer()
                    VStack(spacing: 14) {
                        Text("🎉").font(.system(size: 50))
                        Text("Need more cards").font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text("You need at least \(cardsPerRound * totalRounds) unmastered cards").font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    // Game grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(tiles) { tile in
                                MatchTileView(tile: tile, isSelected: selectedTile?.id == tile.id, isIPad: horizontalSizeClass == .regular) { handleTileTap(tile) }
                            }
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? 40 : 16)
                        .padding(.vertical, 8)
                        .frame(maxWidth: 700)
                        .frame(maxWidth: .infinity)
                    }

                    Button(action: resetGame) {
                        HStack { Image(systemName: "arrow.counterclockwise"); Text("New Game") }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white).padding(.horizontal, 22).padding(.vertical, 10)
                            .background(Color.softLavender).cornerRadius(22)
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .onAppear { setupGame() }
    }

    func setupGame() {
        // Use session cards if available (from setup screen), otherwise get all cards
        let cardsToUse: [Flashcard]
        if !cardManager.sessionCards.isEmpty {
            cardsToUse = cardManager.sessionCards
            cardManager.sessionCards = [] // Clear after use
        } else {
            cardsToUse = availableCards
        }

        let requiredCards = cardsPerRound * totalRounds
        guard cardsToUse.count >= requiredCards else { tiles = []; return }

        // Store all cards for both rounds
        allSessionCards = Array(cardsToUse.shuffled().prefix(requiredCards))
        currentRound = 1
        totalMoves = 0
        showRoundTransition = false
        setupRound()
    }

    func setupRound() {
        // Get cards for current round
        let startIndex = (currentRound - 1) * cardsPerRound
        let endIndex = min(startIndex + cardsPerRound, allSessionCards.count)
        let roundCards = Array(allSessionCards[startIndex..<endIndex])

        gameCards = roundCards
        var newTiles: [MatchTile] = []
        for card in roundCards {
            newTiles.append(MatchTile(cardId: card.id, content: card.question, isQuestion: true))
            newTiles.append(MatchTile(cardId: card.id, content: card.answer, isQuestion: false))
        }
        tiles = newTiles.shuffled()
        selectedTile = nil
        matchedPairs = 0
        moves = 0
        showWin = false
        isProcessing = false
        if currentRound == 1 { startTime = Date() }
    }

    func handleTileTap(_ tile: MatchTile) {
        guard !tile.isMatched && !isProcessing && selectedTile?.id != tile.id else {
            if selectedTile?.id == tile.id { selectedTile = nil }
            return
        }

        HapticManager.shared.selection()

        if let selected = selectedTile {
            isProcessing = true; moves += 1
            if selected.cardId == tile.cardId && selected.isQuestion != tile.isQuestion {
                // Match found!
                HapticManager.shared.correctAnswer()
                SoundManager.shared.correctAnswer()
                if let card = gameCards.first(where: { $0.id == tile.cardId }) { cardManager.recordCorrectAnswer(card) }
                withAnimation(.spring()) {
                    if let idx1 = tiles.firstIndex(where: { $0.id == selected.id }) { tiles[idx1].isMatched = true }
                    if let idx2 = tiles.firstIndex(where: { $0.id == tile.id }) { tiles[idx2].isMatched = true }
                }
                matchedPairs += 1; selectedTile = nil; isProcessing = false

                // Check if round is complete
                if matchedPairs == cardsPerRound {
                    totalMoves += moves
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if currentRound < totalRounds {
                            // Move to next round
                            currentRound += 1
                            withAnimation { showRoundTransition = true }
                            HapticManager.shared.achievement()
                            // Setup next round after transition
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                setupRound()
                            }
                        } else {
                            // Game complete!
                            showWin = true
                            HapticManager.shared.achievement()
                            SoundManager.shared.celebration()
                        }
                    }
                }
            } else {
                // No match
                HapticManager.shared.wrongAnswer()
                SoundManager.shared.wrongAnswer()
                if let idx1 = tiles.firstIndex(where: { $0.id == selected.id }) { tiles[idx1].showError = true }
                if let idx2 = tiles.firstIndex(where: { $0.id == tile.id }) { tiles[idx2].showError = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    for i in tiles.indices { tiles[i].showError = false }
                    selectedTile = nil; isProcessing = false
                }
            }
        } else { selectedTile = tile }
    }

    func resetGame() {
        HapticManager.shared.buttonTap()
        saveSession()
        setupGame()
    }

    func saveSession() {
        let timeSpent = Int(Date().timeIntervalSince(startTime))
        let totalPairs = (currentRound - 1) * cardsPerRound + matchedPairs // Pairs matched across all rounds
        if totalPairs > 0 {
            statsManager.recordSession(cardsStudied: totalPairs * 2, correct: totalPairs, timeSeconds: timeSpent, mode: "Match")
            DailyGoalsManager.shared.recordStudySession(cardsStudied: totalPairs * 2, correct: totalPairs, timeSeconds: timeSpent)

            // Track categories studied from all session cards
            let categoriesStudied = Set(allSessionCards.map { $0.contentCategory })
            for category in categoriesStudied {
                DailyGoalsManager.shared.recordCategoryStudied(category)
            }

            // Perfect match game (all pairs matched in both rounds)
            if showWin && currentRound == totalRounds && matchedPairs == cardsPerRound {
                DailyGoalsManager.shared.recordPerfectQuiz()
            }
        }
    }
}

struct MatchTileView: View {
    let tile: MatchTile
    let isSelected: Bool
    var isIPad: Bool = false
    let action: () -> Void

    var bgColor: Color {
        if tile.isMatched { return .green.opacity(0.3) }
        if tile.showError { return .red.opacity(0.3) }
        if isSelected { return .softLavender.opacity(0.3) }
        return .cardBackground
    }

    var borderColor: Color {
        if tile.isMatched { return .green }
        if tile.showError { return .red }
        if isSelected { return .softLavender }
        return .gray.opacity(0.2)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: isIPad ? 10 : 6) {
                // Badge showing Q or A
                Text(tile.isQuestion ? "Q" : "A")
                    .font(.system(size: isIPad ? 14 : 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, isIPad ? 12 : 8)
                    .padding(.vertical, isIPad ? 5 : 3)
                    .background(tile.isQuestion ? Color.mintGreen : Color.pastelPink)
                    .cornerRadius(8)

                // Content text - larger and more readable
                Text(tile.content)
                    .font(.system(size: isIPad ? 16 : 13, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .minimumScaleFactor(0.6)
            }
            .padding(isIPad ? 16 : 10)
            .frame(minHeight: isIPad ? 160 : 120)
            .frame(maxWidth: .infinity)
            .background(bgColor)
            .cornerRadius(isIPad ? 16 : 12)
            .overlay(RoundedRectangle(cornerRadius: isIPad ? 16 : 12).stroke(borderColor, lineWidth: 2))
            .shadow(color: isSelected ? borderColor.opacity(0.3) : .clear, radius: 4)
            .opacity(tile.isMatched ? 0 : 1)
            .scaleEffect(tile.isMatched ? 0.5 : 1)
        }
        .disabled(tile.isMatched)
    }
}

struct MatchWinView: View {
    let moves: Int
    let onPlayAgain: () -> Void
    var onHome: (() -> Void)? = nil
    var isPremium: Bool = true
    var onUpgrade: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Text("🎉").font(.system(size: 60))
            Text("You Win!").font(.system(size: 30, weight: .bold, design: .rounded))
            Text("Completed in \(moves) moves").font(.system(size: 16, design: .rounded)).foregroundColor(.secondary)

            if !isPremium {
                VStack(spacing: 10) {
                    Text("You've mastered the Demo Deck!")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("Unlock 20+ categories to keep playing.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button(action: { onUpgrade?() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 13))
                            Text("Upgrade to Premium")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(14)
            }

            Button(action: onPlayAgain) {
                Text("Play Again").font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white).padding(.horizontal, 35).padding(.vertical, 14)
                    .background(LinearGradient(colors: [.mintGreen, .softLavender], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(22)
            }
            if let onHome {
                Button(action: onHome) {
                    HStack(spacing: 6) {
                        Image(systemName: "house.fill").font(.system(size: 14))
                        Text("Home").font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30).padding(.vertical, 12)
                }
            }
            Spacer()
        }
    }
}

// MARK: - Category Filter Sheet

struct CategoryFilterSheet: View {
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showUpgradeSheet = false

    var isPremium: Bool {
        subscriptionManager.hasPremiumAccess || (authManager.userProfile?.isPremium ?? false)
    }

    var selectedCount: Int {
        cardManager.selectedCategories.count
    }

    var totalCount: Int {
        ContentCategory.allCases.count
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isPremium {
                    // Header with count
                    HStack {
                        Text("\(selectedCount) of \(totalCount) selected")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            if selectedCount == totalCount {
                                cardManager.deselectAllCategories()
                            } else {
                                cardManager.selectAllCategories()
                            }
                        }) {
                            Text(selectedCount == totalCount ? "Deselect All" : "Select All")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.pastelPink)
                        }
                    }
                    .padding()
                    .background(Color.creamyBackground)
                }

                // Category list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if !isPremium {
                            // Free sample row (always on)
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(Color.mintGreen)
                                    .frame(width: 12, height: 12)
                                Text("NCLEX Essentials (Free Sample)")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.mintGreen)
                                    .font(.system(size: 20))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.adaptiveWhite)
                            .cornerRadius(12)
                        }

                        ForEach(ContentCategory.allCases, id: \.self) { category in
                            if isPremium {
                                CategoryFilterRow(category: category, isSelected: cardManager.selectedCategories.contains(category)) {
                                    cardManager.toggleCategory(category)
                                }
                            } else {
                                // Locked category row
                                Button(action: { showUpgradeSheet = true }) {
                                    HStack(spacing: 14) {
                                        Circle()
                                            .fill(category.color)
                                            .frame(width: 12, height: 12)
                                        Text(category.rawValue)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 16))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color.adaptiveWhite)
                                    .cornerRadius(12)
                                    .opacity(0.6)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.creamyBackground)
            .navigationTitle("Filter Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.pastelPink)
                }
            }
            .sheet(isPresented: $showUpgradeSheet) {
                SubscriptionSheet()
            }
        }
    }
}

struct CategoryFilterRow: View {
    let category: ContentCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Color indicator
                Circle()
                    .fill(category.color)
                    .frame(width: 12, height: 12)

                Text(category.rawValue)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .mintGreen : .gray.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.adaptiveWhite)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.03), radius: 4)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
