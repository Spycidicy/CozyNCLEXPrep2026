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
    @Published var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()

    private let reminderTimeKey = "studyReminderTime"
    private let remindersEnabledKey = "studyRemindersEnabled"

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
                }
            }
        }
    }

    func scheduleStudyReminder() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Time to Study! 📚"
        content.body = "Your NCLEX prep is waiting. Keep your streak going!"
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "studyReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
        saveSettings()
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

enum DailyGoalType: String, Codable {
    case studyCards = "Study Cards"
    case correctAnswers = "Get Correct"
    case studyMinutes = "Study Time"
    case masterCards = "Master Cards"

    var icon: String {
        switch self {
        case .studyCards: return "square.stack.fill"
        case .correctAnswers: return "checkmark.circle.fill"
        case .studyMinutes: return "clock.fill"
        case .masterCards: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .studyCards: return .softLavender
        case .correctAnswers: return .mintGreen
        case .studyMinutes: return .skyBlue
        case .masterCards: return .pastelPink
        }
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

    private let dailyGoalsKey = "dailyGoals"
    private let totalXPKey = "totalXP"
    private let lastGoalDateKey = "lastGoalDate"
    private let cardOfTheDayIDKey = "cardOfTheDayID"
    private let cardOfTheDayDateKey = "cardOfTheDayDate"
    private let cardOfTheDayCompletedKey = "cardOfTheDayCompleted"

    init() {
        loadData()
        checkAndResetDailyGoals()
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
    }

    func saveData() {
        UserDefaults.standard.set(totalXP, forKey: totalXPKey)
        if let data = try? JSONEncoder().encode(dailyGoals) {
            UserDefaults.standard.set(data, forKey: dailyGoalsKey)
        }
        UserDefaults.standard.set(lastGoalDate, forKey: lastGoalDateKey)
        UserDefaults.standard.set(hasCompletedCardOfTheDay, forKey: cardOfTheDayCompletedKey)
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

        if let lastDate = lastGoalDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            if today > lastDay {
                // New day - reset goals
                generateDailyGoals()
                hasCompletedCardOfTheDay = false
            }
        } else {
            // First time - generate goals
            generateDailyGoals()
        }

        lastGoalDate = today
        saveData()
    }

    func generateDailyGoals() {
        dailyGoals = [
            DailyGoal(type: .studyCards, target: 20, xpReward: 50),
            DailyGoal(type: .correctAnswers, target: 15, xpReward: 40),
            DailyGoal(type: .studyMinutes, target: 10, xpReward: 30)
        ]
        saveData()
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
        case 5: return "NCLEX Warrior"
        case 6: return "Knowledge Seeker"
        case 7: return "Study Champion"
        case 8: return "Expert in Training"
        case 9: return "Nearly There"
        case 10: return "NCLEX Master"
        default: return "NCLEX Legend \(currentLevel - 9)"
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
    case menu
    case swipeGame
    case quizGame
    case smartReview
    case matchGame
    case cardBrowser
    case createCard
    case studySets
    case testMode
    case writeMode
    case stats
    case search
}

enum GameMode: String, CaseIterable {
    case swipe = "Cozy Swipe"
    case quiz = "Bear Quiz"
    case smartReview = "Smart Review"
    case match = "Cozy Match"
    case write = "Write Mode"
    case test = "Practice Test"

    var icon: String {
        switch self {
        case .swipe: return "hand.draw"
        case .quiz: return "questionmark.circle"
        case .smartReview: return "brain.head.profile"
        case .match: return "square.grid.2x2"
        case .write: return "pencil.line"
        case .test: return "doc.text"
        }
    }

    var subtitle: String {
        switch self {
        case .swipe: return "Tinder-style study"
        case .quiz: return "Multiple choice"
        case .smartReview: return "Spaced repetition"
        case .match: return "Memory match"
        case .write: return "Type answers"
        case .test: return "Practice exam"
        }
    }

    var isPaid: Bool {
        switch self {
        case .swipe, .quiz: return false
        case .match, .write, .test, .smartReview: return true
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

enum ContentCategory: String, Codable, CaseIterable {
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
        return Double(correct) / Double(total) * 100
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
        return Double(totalCorrectAnswers) / Double(totalCardsStudied) * 100
    }
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
        // FUNDAMENTALS - FREE (10)
        Flashcard(
            question: "What is the FIRST action a nurse should take when a patient falls?",
            answer: "Assess the patient for injuries",
            wrongAnswers: ["Call the physician", "Complete an incident report", "Help the patient back to bed"],
            rationale: "Patient safety is the priority. Before any other action, the nurse must assess for injuries to determine the severity and appropriate interventions. Documentation and notification come after ensuring patient safety.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .priority,
            isPremium: false
        ),
        Flashcard(
            question: "Which vital sign change indicates a patient may be developing shock?",
            answer: "Decreased blood pressure with increased heart rate",
            wrongAnswers: ["Increased blood pressure with decreased heart rate", "Normal blood pressure with normal heart rate", "Decreased blood pressure with decreased heart rate"],
            rationale: "In early compensatory shock, the body attempts to maintain perfusion by increasing heart rate (tachycardia) as blood pressure drops. This compensatory mechanism is a key early warning sign.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A nurse is preparing to administer medications. Which action demonstrates proper patient identification?",
            answer: "Check two patient identifiers and compare with the MAR",
            wrongAnswers: ["Ask the patient their name only", "Check the room number", "Verify with the patient's family member"],
            rationale: "The Joint Commission requires two patient identifiers (name and DOB, or name and medical record number) before medication administration. Room numbers should never be used as identifiers.",
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
            rationale: "The correct sequence is Inspection (visual), Palpation (touch), Percussion (tapping), Auscultation (listening). Exception: For abdominal assessment, auscultate before palpation to avoid altering bowel sounds.",
            contentCategory: .fundamentals,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient has a blood pressure of 88/56 mmHg. Which position should the nurse place the patient in?",
            answer: "Supine with legs elevated (modified Trendelenburg)",
            wrongAnswers: ["High Fowler's position", "Prone position", "Left lateral position"],
            rationale: "For hypotensive patients, elevating the legs helps return blood to the central circulation, improving cardiac output and blood pressure. High Fowler's would worsen hypotension by pooling blood in the lower extremities.",
            contentCategory: .fundamentals,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which nursing intervention is MOST important for preventing hospital-acquired infections?",
            answer: "Performing hand hygiene before and after patient contact",
            wrongAnswers: ["Wearing gloves for all patient interactions", "Isolating all patients with infections", "Administering prophylactic antibiotics"],
            rationale: "Hand hygiene is the single most effective way to prevent the spread of infections in healthcare settings. The CDC and WHO emphasize hand hygiene as the cornerstone of infection prevention.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient is NPO for surgery. Which action by the nurse is appropriate?",
            answer: "Remove the water pitcher and post NPO sign",
            wrongAnswers: ["Allow ice chips only", "Give medications with a full glass of water", "Permit clear liquids until 2 hours before surgery"],
            rationale: "NPO means nothing by mouth. Removing access to fluids and posting clear signage prevents accidental intake. Specific pre-operative guidelines should be followed per facility protocol and surgeon orders.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Select ALL interventions that are appropriate for fall prevention:",
            answer: "Keep bed in lowest position, Ensure call light is within reach, Use non-slip footwear, Keep environment well-lit",
            wrongAnswers: ["Restrain all high-risk patients"],
            rationale: "Fall prevention is multifaceted: low bed position reduces injury from falls, accessible call light allows patients to ask for help, non-slip footwear prevents slipping, and good lighting helps patients see obstacles. Restraints are a last resort and can increase fall risk.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .sata,
            isPremium: false
        ),
        Flashcard(
            question: "What does the acronym RACE stand for in fire safety?",
            answer: "Rescue, Alarm, Contain, Extinguish",
            wrongAnswers: ["Run, Alert, Call, Evacuate", "Rescue, Alert, Cover, Exit", "Remove, Alarm, Close, Escape"],
            rationale: "RACE is the fire response protocol: Rescue patients in immediate danger, Activate the Alarm, Contain the fire by closing doors, Extinguish if small and safe to do so. This sequence prioritizes patient safety.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A nurse is documenting in the medical record. Which entry is MOST appropriate?",
            answer: "Patient states 'I feel dizzy when I stand up.' VS: BP 100/60 sitting, 82/50 standing.",
            wrongAnswers: ["Patient is dizzy, probably dehydrated", "Patient seems to have orthostatic hypotension", "Patient is a poor historian and is confused about symptoms"],
            rationale: "Documentation should be objective, factual, and include direct patient quotes when relevant. Avoid assumptions, diagnoses (unless within scope), and judgmental language. Include measurable data.",
            contentCategory: .fundamentals,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),

        // MED-SURG - FREE (10)
        Flashcard(
            question: "A patient with heart failure has gained 3 pounds overnight. What is the nurse's PRIORITY action?",
            answer: "Assess for edema and lung sounds, then notify the provider",
            wrongAnswers: ["Restrict fluids immediately", "Administer an extra dose of diuretic", "Encourage increased activity"],
            rationale: "Rapid weight gain (>2-3 lbs in 24 hours) indicates fluid retention, a sign of worsening heart failure. Assessment confirms the finding, and the provider needs notification for medication adjustments. Nurses cannot independently change medication doses.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: false
        ),
        Flashcard(
            question: "Which finding in a patient with diabetes requires IMMEDIATE intervention?",
            answer: "Blood glucose of 45 mg/dL with diaphoresis",
            wrongAnswers: ["Blood glucose of 180 mg/dL before lunch", "Blood glucose of 95 mg/dL fasting", "HbA1c of 7.2%"],
            rationale: "Hypoglycemia (<70 mg/dL) with symptoms (diaphoresis, confusion, tremors) is a medical emergency requiring immediate treatment with fast-acting glucose. Untreated severe hypoglycemia can lead to seizures, coma, and death.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient post-thyroidectomy reports tingling around the mouth. What should the nurse assess for?",
            answer: "Hypocalcemia (check Chvostek's and Trousseau's signs)",
            wrongAnswers: ["Hyperkalemia", "Thyroid storm", "Allergic reaction to anesthesia"],
            rationale: "Parathyroid glands may be damaged during thyroidectomy, causing hypocalcemia. Perioral tingling is an early sign. Chvostek's sign (facial twitch when tapping cheek) and Trousseau's sign (carpopedal spasm with BP cuff) confirm hypocalcemia.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What is the PRIORITY nursing diagnosis for a patient experiencing an acute asthma attack?",
            answer: "Impaired gas exchange",
            wrongAnswers: ["Anxiety", "Activity intolerance", "Deficient knowledge"],
            rationale: "During an acute asthma attack, bronchospasm and inflammation severely impair oxygen and carbon dioxide exchange. This life-threatening physiological problem takes priority over psychological or educational needs using Maslow's hierarchy.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with COPD has an oxygen saturation of 88%. What is the appropriate oxygen flow rate?",
            answer: "1-2 L/min via nasal cannula, titrate to SpO2 88-92%",
            wrongAnswers: ["High-flow oxygen at 15 L/min", "100% oxygen via non-rebreather mask", "No oxygen needed, 88% is acceptable for COPD"],
            rationale: "COPD patients have chronic CO2 retention and rely on hypoxic drive for breathing. High-flow oxygen can suppress this drive and cause respiratory failure. Target SpO2 of 88-92% balances oxygenation with maintaining respiratory drive.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which assessment finding indicates a patient may be experiencing a stroke?",
            answer: "Sudden onset of facial drooping, arm weakness, and slurred speech",
            wrongAnswers: ["Gradual onset of bilateral leg weakness over 2 weeks", "Chronic headaches with normal neurological exam", "Intermittent dizziness when changing positions"],
            rationale: "FAST (Face drooping, Arm weakness, Speech difficulty, Time to call 911) identifies stroke symptoms. Sudden onset of unilateral neurological deficits is characteristic. Stroke is time-sensitive - 'time is brain.'",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with cirrhosis has a distended abdomen. Which position is BEST for comfort and breathing?",
            answer: "Semi-Fowler's or high Fowler's position",
            wrongAnswers: ["Supine flat position", "Trendelenburg position", "Prone position"],
            rationale: "Ascites (fluid accumulation) in cirrhosis causes abdominal distension that pushes on the diaphragm, making breathing difficult. Elevating the head of bed allows gravity to pull fluid down and gives the diaphragm more room to expand.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "After a cardiac catheterization via femoral artery, which assessment is PRIORITY?",
            answer: "Check the puncture site for bleeding and assess distal pulses",
            wrongAnswers: ["Encourage the patient to ambulate immediately", "Assess for pain at the catheter insertion site", "Check blood glucose levels"],
            rationale: "Femoral artery access creates bleeding risk and potential for hematoma or arterial occlusion. Checking the site for bleeding/hematoma and assessing pedal pulses ensures adequate circulation. The patient must remain on bedrest with the leg straight.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with renal failure has a potassium level of 6.8 mEq/L. Which ECG change should the nurse expect?",
            answer: "Tall, peaked T waves",
            wrongAnswers: ["Flat T waves", "Prolonged QT interval", "ST segment elevation"],
            rationale: "Hyperkalemia causes characteristic ECG changes: tall peaked T waves (early), widened QRS, and eventually sine wave pattern and cardiac arrest. K+ >6.0 mEq/L is dangerous and requires immediate treatment.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Select ALL signs and symptoms of left-sided heart failure:",
            answer: "Dyspnea, Orthopnea, Crackles in lungs, Pink frothy sputum",
            wrongAnswers: ["Jugular vein distension"],
            rationale: "Left-sided heart failure causes pulmonary congestion because the left ventricle cannot effectively pump blood forward. Fluid backs up into the lungs causing dyspnea, orthopnea, crackles, and in severe cases, pink frothy sputum (pulmonary edema). JVD is a sign of right-sided failure.",
            contentCategory: .medSurg,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .sata,
            isPremium: false
        ),

        // PHARMACOLOGY - FREE (10)
        Flashcard(
            question: "A patient is prescribed warfarin. Which lab value should the nurse monitor?",
            answer: "INR (International Normalized Ratio)",
            wrongAnswers: ["aPTT (activated Partial Thromboplastin Time)", "Platelet count only", "Hemoglobin and hematocrit only"],
            rationale: "Warfarin affects vitamin K-dependent clotting factors (II, VII, IX, X). INR monitors warfarin effectiveness. Therapeutic range is usually 2-3 (2.5-3.5 for mechanical heart valves). aPTT monitors heparin, not warfarin.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What is the antidote for heparin overdose?",
            answer: "Protamine sulfate",
            wrongAnswers: ["Vitamin K", "Naloxone", "Flumazenil"],
            rationale: "Protamine sulfate is a positively charged molecule that binds to negatively charged heparin, neutralizing its anticoagulant effect. Vitamin K reverses warfarin. Naloxone reverses opioids. Flumazenil reverses benzodiazepines.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which medication class ending in '-pril' is used for hypertension and heart failure?",
            answer: "ACE inhibitors (e.g., lisinopril, enalapril)",
            wrongAnswers: ["Beta blockers", "Calcium channel blockers", "ARBs"],
            rationale: "ACE inhibitors end in '-pril' and work by blocking angiotensin-converting enzyme, reducing angiotensin II production. This causes vasodilation and decreased aldosterone, lowering BP. Common side effect is dry cough.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient on digoxin has a heart rate of 52 bpm. What should the nurse do?",
            answer: "Hold the medication and notify the provider",
            wrongAnswers: ["Give the medication as prescribed", "Give half the prescribed dose", "Wait 30 minutes and recheck the heart rate"],
            rationale: "Digoxin slows heart rate. Hold digoxin if HR <60 bpm (adults) or <70 bpm (children) as this may indicate toxicity. Always check apical pulse for full minute before administration. Notify provider for HR below threshold.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which electrolyte imbalance increases the risk of digoxin toxicity?",
            answer: "Hypokalemia (low potassium)",
            wrongAnswers: ["Hyperkalemia", "Hypernatremia", "Hypercalcemia"],
            rationale: "Digoxin and potassium compete for the same binding sites on the sodium-potassium ATPase pump. Low potassium means more digoxin binds, increasing toxicity risk. Always monitor K+ levels in patients on digoxin.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What is the antidote for acetaminophen (Tylenol) overdose?",
            answer: "Acetylcysteine (Mucomyst)",
            wrongAnswers: ["Naloxone", "Flumazenil", "Protamine sulfate"],
            rationale: "Acetylcysteine replenishes glutathione stores in the liver, which is depleted by the toxic metabolite of acetaminophen (NAPQI). Most effective within 8 hours of overdose but can be given up to 24 hours.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient is starting metformin for type 2 diabetes. Which teaching is ESSENTIAL?",
            answer: "Hold the medication before procedures using IV contrast dye",
            wrongAnswers: ["Take on an empty stomach for best absorption", "This medication will cause significant weight gain", "Blood glucose monitoring is not necessary"],
            rationale: "Metformin combined with IV contrast dye can cause lactic acidosis, a life-threatening condition. Hold metformin 48 hours before and after contrast procedures. Metformin should be taken with food to reduce GI upset and typically causes weight loss or neutrality.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which medication requires the patient to avoid grapefruit juice?",
            answer: "Statins (e.g., atorvastatin, simvastatin)",
            wrongAnswers: ["Acetaminophen", "Amoxicillin", "Omeprazole"],
            rationale: "Grapefruit juice inhibits CYP3A4 enzyme in the intestine, which normally metabolizes statins. This leads to increased statin levels and risk of muscle damage (rhabdomyolysis). Some statins are more affected than others.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Select ALL symptoms of opioid overdose:",
            answer: "Respiratory depression, Pinpoint pupils, Decreased level of consciousness, Bradycardia",
            wrongAnswers: ["Dilated pupils"],
            rationale: "Opioid overdose causes CNS depression: slow/shallow breathing (respiratory depression is the killer), pinpoint (miotic) pupils, decreased LOC/unresponsive, and bradycardia. Dilated pupils suggest stimulant overdose or anticholinergic toxicity.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .sata,
            isPremium: false
        ),
        Flashcard(
            question: "Which antibiotic class should be avoided during pregnancy due to effects on fetal teeth and bones?",
            answer: "Tetracyclines",
            wrongAnswers: ["Penicillins", "Cephalosporins", "Macrolides"],
            rationale: "Tetracyclines cross the placenta and deposit in developing teeth and bones, causing permanent tooth discoloration and potential bone growth problems. Contraindicated in pregnancy and children under 8 years.",
            contentCategory: .pharmacology,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),

        // PEDIATRICS - FREE (5)
        Flashcard(
            question: "A 2-year-old is admitted with suspected epiglottitis. Which action should the nurse AVOID?",
            answer: "Inspecting the throat with a tongue depressor",
            wrongAnswers: ["Keeping the child calm", "Having emergency intubation equipment nearby", "Allowing the child to sit in a position of comfort"],
            rationale: "In epiglottitis, the airway is severely compromised. Using a tongue depressor can trigger complete airway obstruction and respiratory arrest. Visualize the throat only in a controlled setting with emergency airway equipment ready.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "What is the normal respiratory rate for a newborn?",
            answer: "30-60 breaths per minute",
            wrongAnswers: ["12-20 breaths per minute", "20-30 breaths per minute", "60-80 breaths per minute"],
            rationale: "Newborns have faster respiratory rates than adults due to higher metabolic demands and smaller lung capacity. Normal newborn RR is 30-60/min. Rates >60/min (tachypnea) may indicate respiratory distress.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A child is diagnosed with Kawasaki disease. Which assessment finding is MOST concerning?",
            answer: "Coronary artery abnormalities on echocardiogram",
            wrongAnswers: ["Strawberry tongue", "Peeling skin on fingers", "High fever for 5 days"],
            rationale: "Kawasaki disease causes systemic vasculitis with the most serious complication being coronary artery aneurysms, which can lead to MI, heart failure, and death. IVIG treatment reduces this risk when given within 10 days of fever onset.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "At what age should an infant double their birth weight?",
            answer: "4-6 months",
            wrongAnswers: ["1-2 months", "8-10 months", "12 months"],
            rationale: "Infants typically double birth weight by 4-6 months and triple it by 12 months. This is an important milestone for assessing adequate nutrition and growth. Failure to meet this may indicate feeding problems or underlying illness.",
            contentCategory: .pediatrics,
            nclexCategory: .healthPromotion,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which finding is expected in a child with pyloric stenosis?",
            answer: "Projectile vomiting after feeding with an olive-shaped mass in the abdomen",
            wrongAnswers: ["Bile-stained vomiting", "Diarrhea with blood in stool", "Gradual onset of vomiting over several weeks"],
            rationale: "Pyloric stenosis causes hypertrophy of the pyloric sphincter, obstructing gastric outflow. Classic presentation: non-bilious projectile vomiting, visible peristalsis, palpable 'olive' mass in RUQ, and hungry baby. Usually presents at 2-8 weeks of age.",
            contentCategory: .pediatrics,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),

        // MATERNITY - FREE (5)
        Flashcard(
            question: "A laboring patient's fetal heart rate shows late decelerations. What is the nurse's PRIORITY action?",
            answer: "Reposition the patient to left lateral side and administer oxygen",
            wrongAnswers: ["Continue to monitor without intervention", "Increase the rate of Pitocin", "Prepare for immediate cesarean section"],
            rationale: "Late decelerations indicate uteroplacental insufficiency (decreased oxygen to fetus). Immediate nursing actions: left lateral position (improves uterine blood flow), oxygen (increases available O2), stop Pitocin if running, IV fluid bolus. Notify provider immediately.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .priority,
            isPremium: false
        ),
        Flashcard(
            question: "What is the normal fetal heart rate range?",
            answer: "110-160 beats per minute",
            wrongAnswers: ["60-100 beats per minute", "100-150 beats per minute", "160-200 beats per minute"],
            rationale: "Normal fetal heart rate (FHR) baseline is 110-160 bpm. Below 110 (bradycardia) or above 160 (tachycardia) for >10 minutes requires evaluation. Variability and accelerations are signs of fetal well-being.",
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
            rationale: "Uterine atony (boggy uterus) is the most common cause of postpartum hemorrhage. First action is fundal massage to stimulate uterine contraction. Also empty the bladder (full bladder prevents contraction), administer uterotonics as ordered.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .priority,
            isPremium: false
        ),
        Flashcard(
            question: "Which symptom is a warning sign of preeclampsia?",
            answer: "Severe headache with visual changes and BP of 160/110",
            wrongAnswers: ["Mild ankle swelling at end of day", "Occasional Braxton Hicks contractions", "Increased urinary frequency"],
            rationale: "Preeclampsia warning signs: BP ≥140/90, severe headache, visual disturbances (blurring, spots), epigastric pain, sudden edema. Severe preeclampsia (BP ≥160/110) can progress to eclampsia (seizures) and is life-threatening.",
            contentCategory: .maternity,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "When should a pregnant patient feel fetal movement (quickening)?",
            answer: "Primigravida: 18-20 weeks; Multigravida: 16-18 weeks",
            wrongAnswers: ["8-10 weeks in all pregnancies", "25-28 weeks in all pregnancies", "Only after 30 weeks"],
            rationale: "Quickening (first maternal perception of fetal movement) occurs earlier in multiparous women who recognize the sensation. It's an important milestone. Decreased fetal movement later in pregnancy warrants evaluation.",
            contentCategory: .maternity,
            nclexCategory: .healthPromotion,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),

        // MENTAL HEALTH - FREE (5)
        Flashcard(
            question: "A patient expresses suicidal thoughts. What is the nurse's PRIORITY assessment?",
            answer: "Ask directly if the patient has a plan and access to means",
            wrongAnswers: ["Avoid discussing suicide to prevent giving ideas", "Immediately place in physical restraints", "Call family members before talking to patient"],
            rationale: "Direct questioning about suicide does NOT increase risk - it shows concern and allows intervention. Assess: ideation, plan, means, timeline, and protective factors. A specific plan with accessible means = HIGH RISK requiring immediate intervention.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .priority,
            isPremium: false
        ),
        Flashcard(
            question: "Which therapeutic communication technique involves restating the patient's message?",
            answer: "Reflection",
            wrongAnswers: ["Clarification", "Confrontation", "Summarizing"],
            rationale: "Reflection mirrors back the patient's feelings or content, showing understanding and encouraging elaboration. Example: Patient: 'I'm so angry at my family.' Nurse: 'You're feeling angry at your family.' This validates feelings.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with schizophrenia reports hearing voices telling them to hurt themselves. What type of hallucination is this?",
            answer: "Command auditory hallucination",
            wrongAnswers: ["Visual hallucination", "Tactile hallucination", "Olfactory hallucination"],
            rationale: "Command hallucinations are auditory hallucinations that tell the person to do something, often harmful. These require immediate assessment and safety intervention as patients may act on commands. This is a psychiatric emergency.",
            contentCategory: .mentalHealth,
            nclexCategory: .psychosocial,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Select ALL symptoms of serotonin syndrome:",
            answer: "Hyperthermia, Agitation, Hyperreflexia, Tremor, Diaphoresis",
            wrongAnswers: ["Hypothermia"],
            rationale: "Serotonin syndrome occurs with excessive serotonergic activity, often from drug interactions (SSRIs + MAOIs, SSRIs + triptans). Symptoms: hyperthermia, altered mental status, autonomic instability, neuromuscular abnormalities. Life-threatening emergency.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .hard,
            questionType: .sata,
            isPremium: false
        ),
        Flashcard(
            question: "A patient with alcohol use disorder is admitted. When should the nurse expect withdrawal symptoms to begin?",
            answer: "6-24 hours after last drink",
            wrongAnswers: ["Immediately upon admission", "3-5 days after last drink", "1-2 weeks after last drink"],
            rationale: "Alcohol withdrawal timeline: 6-24 hours - tremors, anxiety, tachycardia; 24-48 hours - hallucinations; 48-72 hours - seizures; 3-5 days - delirium tremens (DTs). DTs have 5-15% mortality if untreated.",
            contentCategory: .mentalHealth,
            nclexCategory: .physiological,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        ),

        // LEADERSHIP - FREE (5)
        Flashcard(
            question: "Which task is appropriate to delegate to a UAP (unlicensed assistive personnel)?",
            answer: "Taking vital signs on a stable patient",
            wrongAnswers: ["Assessing a new patient's pain level", "Administering oral medications", "Teaching a patient about new medications"],
            rationale: "UAPs can perform tasks that are routine, standard, and do not require nursing judgment: vital signs, ADLs, ambulation, I&O, feeding stable patients. Assessment, teaching, and medication administration require RN/LPN licensure.",
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
            rationale: "Using ABCs and prioritization: the post-op patient with restlessness and dropping BP may be hemorrhaging (shock). This is life-threatening and requires immediate assessment. The other patients are important but stable.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: false
        ),
        Flashcard(
            question: "A nurse makes a medication error. What is the FIRST action?",
            answer: "Assess the patient for adverse effects",
            wrongAnswers: ["Complete an incident report before telling anyone", "Notify the nurse manager", "Call the pharmacy"],
            rationale: "Patient safety is always first. Assess for adverse effects and intervene as needed. Then notify the provider, document objectively in the chart, and complete an incident report. Never delay patient assessment for administrative tasks.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .priority,
            isPremium: false
        ),
        Flashcard(
            question: "What is the purpose of an incident report?",
            answer: "To identify patterns and improve systems to prevent future occurrences",
            wrongAnswers: ["To punish the nurse who made the error", "To document in the patient's medical record", "To report the nurse to the state board"],
            rationale: "Incident reports are quality improvement tools, not punitive. They identify system issues and patterns to prevent future errors. They are NOT part of the medical record and should not be referenced in charting.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .easy,
            questionType: .standard,
            isPremium: false
        ),
        Flashcard(
            question: "Which patient can the RN safely assign to an LPN/LVN?",
            answer: "Stable patient with a chronic condition requiring routine care",
            wrongAnswers: ["New admission requiring comprehensive assessment", "Patient requiring blood transfusion", "Unstable patient requiring frequent reassessment"],
            rationale: "LPN/LVNs work under RN supervision and can care for stable, predictable patients. They can administer most medications (varies by state), perform treatments, and reinforce teaching. New admissions, unstable patients, and blood transfusions require RN assessment skills.",
            contentCategory: .leadership,
            nclexCategory: .safeEffectiveCare,
            difficulty: .medium,
            questionType: .standard,
            isPremium: false
        )
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
        if PersistenceManager.shared.hasSeenOnboarding() {
            currentScreen = .menu
        } else {
            currentScreen = .onboarding
        }
    }

    func completeOnboarding() {
        PersistenceManager.shared.setOnboardingComplete()
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreen = .menu
        }
    }
}

class SubscriptionManager: ObservableObject {
    @Published var isSubscribed: Bool = false
    @Published var products: [Product] = []
    @Published var lifetimeProduct: Product?
    @Published var purchaseError: String?
    @Published var isLoading: Bool = false

    private let subscriptionIDs = ["com.cozynclex.premium.weekly", "com.cozynclex.premium.monthly", "com.cozynclex.premium.yearly"]
    private let lifetimeProductID = "com.cozynclex.lifetime"
    private var updateListenerTask: Task<Void, Error>?

    init() {
        // Load cached subscription status
        isSubscribed = PersistenceManager.shared.loadSubscriptionStatus()

        // Start listening for transactions
        updateListenerTask = listenForTransactions()

        // Load products and check subscription status
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
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
        var hasAccess = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                // Check for active subscription OR lifetime purchase
                if transaction.productType == .autoRenewable || transaction.productType == .nonConsumable {
                    hasAccess = true
                    break
                }
            } catch {
                continue
            }
        }

        isSubscribed = hasAccess
        PersistenceManager.shared.saveSubscriptionStatus(hasAccess)
    }

    @MainActor
    func updateSubscriptionStatus() async {
        await checkSubscriptionStatus()
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
}

enum StoreError: Error {
    case failedVerification
}

class CardManager: ObservableObject {
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

    let masteryThreshold = 3
    private let persistence = PersistenceManager.shared

    init() {
        loadData()
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
    }

    var allCards: [Flashcard] {
        Flashcard.freeCards + (SubscriptionManager().isSubscribed ? Flashcard.premiumCards : []) + userCreatedCards
    }

    func getAvailableCards(isSubscribed: Bool) -> [Flashcard] {
        let baseCards = isSubscribed ? Flashcard.allCards : Flashcard.freeCards
        return baseCards + userCreatedCards
    }

    func getFilteredCards(isSubscribed: Bool) -> [Flashcard] {
        var available = getAvailableCards(isSubscribed: isSubscribed)

        // Apply category filter
        if selectedCategories.count < ContentCategory.allCases.count {
            available = available.filter { selectedCategories.contains($0.contentCategory) }
        }

        switch currentFilter {
        case .all:
            return available
        case .mastered:
            // Show ALL mastered cards regardless of subscription or category filters
            let allCards = Flashcard.allCards + userCreatedCards
            return allCards.filter { masteredCardIDs.contains($0.id) }
        case .saved:
            // Show ALL saved cards regardless of subscription or category filters
            let allCards = Flashcard.allCards + userCreatedCards
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
        if savedCardIDs.contains(card.id) {
            savedCardIDs.remove(card.id)
        } else {
            savedCardIDs.insert(card.id)
        }
        persistence.saveSavedCards(savedCardIDs)
    }

    func recordCorrectAnswer(_ card: Flashcard) {
        let current = consecutiveCorrect[card.id] ?? 0
        let newCount = current + 1
        consecutiveCorrect[card.id] = newCount
        if newCount >= masteryThreshold {
            masteredCardIDs.insert(card.id)
            persistence.saveMasteredCards(masteredCardIDs)
        }
        persistence.saveConsecutiveCorrect(consecutiveCorrect)

        // Also update spaced repetition (quality 4 = correct with hesitation)
        recordSpacedRepResponse(card: card, quality: 4)
    }

    func recordWrongAnswer(_ card: Flashcard) {
        consecutiveCorrect[card.id] = 0
        persistence.saveConsecutiveCorrect(consecutiveCorrect)

        // Also update spaced repetition (quality 1 = wrong)
        recordSpacedRepResponse(card: card, quality: 1)
    }

    func recordEasyAnswer(_ card: Flashcard) {
        // Perfect recall - update spaced repetition with quality 5
        recordCorrectAnswer(card)
        recordSpacedRepResponse(card: card, quality: 5)
    }

    func toggleMastered(_ card: Flashcard) {
        if masteredCardIDs.contains(card.id) {
            masteredCardIDs.remove(card.id)
            consecutiveCorrect[card.id] = 0
        } else {
            masteredCardIDs.insert(card.id)
        }
        persistence.saveMasteredCards(masteredCardIDs)
        persistence.saveConsecutiveCorrect(consecutiveCorrect)
    }

    func isSaved(_ card: Flashcard) -> Bool { savedCardIDs.contains(card.id) }
    func isMastered(_ card: Flashcard) -> Bool { masteredCardIDs.contains(card.id) }
    func progressTowardsMastery(_ card: Flashcard) -> Int { consecutiveCorrect[card.id] ?? 0 }

    // Count of mastered cards that actually exist in the database
    var validMasteredCount: Int {
        let allCards = Flashcard.allCards + userCreatedCards
        let allCardIDs = Set(allCards.map { $0.id })
        return masteredCardIDs.filter { allCardIDs.contains($0) }.count
    }

    // Count of saved cards that actually exist in the database
    var validSavedCount: Int {
        let allCards = Flashcard.allCards + userCreatedCards
        let allCardIDs = Set(allCards.map { $0.id })
        return savedCardIDs.filter { allCardIDs.contains($0) }.count
    }

    // MARK: - User Cards

    func addUserCard(_ card: Flashcard) {
        userCreatedCards.append(card)
        persistence.saveUserCards(userCreatedCards)
    }

    func deleteUserCard(_ card: Flashcard) {
        userCreatedCards.removeAll { $0.id == card.id }
        persistence.saveUserCards(userCreatedCards)
    }

    // MARK: - Study Sets

    func addStudySet(_ set: StudySet) {
        studySets.append(set)
        persistence.saveStudySets(studySets)
    }

    func updateStudySet(_ set: StudySet) {
        if let index = studySets.firstIndex(where: { $0.id == set.id }) {
            studySets[index] = set
            persistence.saveStudySets(studySets)
        }
    }

    func deleteStudySet(_ set: StudySet) {
        studySets.removeAll { $0.id == set.id }
        persistence.saveStudySets(studySets)
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
    @Published var stats: UserStats = UserStats()

    private let persistence = PersistenceManager.shared

    init() {
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
            save()
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

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @StateObject private var appManager = AppManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var cardManager = CardManager()
    @StateObject private var statsManager = StatsManager()
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var appearanceManager = AppearanceManager.shared

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()

            switch appManager.currentScreen {
            case .onboarding: OnboardingView()
            case .menu: MainMenuView()
            case .swipeGame: SwipeGameView()
            case .quizGame: BearQuizView()
            case .smartReview: SmartReviewView()
            case .matchGame: CozyMatchView()
            case .cardBrowser: CardBrowserView()
            case .createCard: CreateCardView()
            case .studySets: StudySetsView()
            case .testMode: TestModeView()
            case .writeMode: WriteModeView()
            case .stats: StatsView()
            case .search: SearchView()
            }
        }
        .environmentObject(appManager)
        .environmentObject(subscriptionManager)
        .environmentObject(cardManager)
        .environmentObject(statsManager)
        .environmentObject(speechManager)
        .preferredColorScheme(appearanceManager.currentMode.colorScheme)
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @EnvironmentObject var appManager: AppManager
    @State private var currentPage = 0
    @State private var showContent = false
    @State private var mascotOffset: CGFloat = 50
    @State private var mascotOpacity: Double = 0

    private let pages: [(title: String, subtitle: String, icon: String, color: Color, isSourcesPage: Bool)] = [
        ("Welcome to CozyNCLEX!", "Your cozy companion for NCLEX success", "heart.fill", .pastelPink, false),
        ("Trusted Sources", "Content compiled from leading NCLEX prep resources", "checkmark.seal.fill", .mintGreen, true),
        ("Study Your Way", "Multiple study modes to fit your learning style", "books.vertical.fill", .skyBlue, false),
        ("Track Progress", "Watch yourself grow with detailed stats", "chart.line.uptrend.xyaxis", .peachOrange, false),
        ("Let's Get Started!", "Your nursing journey begins now", "star.fill", .softLavender, false)
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

            VStack(spacing: 0) {
                // Fixed top spacing for consistent bear position
                Spacer().frame(height: 60)

                // Mascot - fixed position
                Image("NurseBear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .offset(y: mascotOffset)
                    .opacity(mascotOpacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                            mascotOffset = 0
                            mascotOpacity = 1
                        }
                    }

                Spacer().frame(height: 24)

                // Page content - fixed height container for consistency
                VStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(pages[currentPage].color.opacity(0.2))
                            .frame(width: 70, height: 70)

                        Image(systemName: pages[currentPage].icon)
                            .font(.system(size: 32))
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

                    // Sources list for credentials page - scrollable if needed
                    if pages[currentPage].isSourcesPage {
                        ScrollView {
                            VStack(spacing: 10) {
                                SourceBadge(name: "Kaplan", color: .blue)
                                SourceBadge(name: "Archer Review", color: .green)
                                SourceBadge(name: "UWorld", color: .orange)
                                SourceBadge(name: "NCSBN", color: .purple)
                                SourceBadge(name: "CAT Methodology", color: .pink)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation { showContent = true }
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
                .padding(.bottom, 30)

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

                        Button(action: { appManager.completeOnboarding() }) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    } else {
                        Button(action: { appManager.completeOnboarding() }) {
                            HStack {
                                Text("Start Studying")
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
                .padding(.bottom, 50)
            }
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
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage -= 1
                        }
                    }
                }
        )
    }

    func nextPage() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentPage += 1
        }
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
    @StateObject private var dailyGoalsManager = DailyGoalsManager.shared
    @State private var showSubscriptionSheet = false
    @State private var showCategoryFilter = false
    @State private var showCardOfTheDay = false
    @State private var cardOfTheDayFlipped = false
    @State private var selectedTab = 0 // 0 = Study, 1 = Progress

    var body: some View {
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
            .onChange(of: selectedTab) { _, _ in
                HapticManager.shared.selection()
            }

            // Tab Content
            TabView(selection: $selectedTab) {
                // STUDY TAB
                ScrollView {
                    VStack(spacing: 16) {
                        CategoryFilterBadge(showCategoryFilter: $showCategoryFilter)
                        GameModesGridSection(showSubscriptionSheet: $showSubscriptionSheet)
                        QuickActionsSection()
                        if !subscriptionManager.isSubscribed {
                            SubscribeButton(showSheet: $showSubscriptionSheet)
                        }
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
                        CardOfTheDaySection(showCard: $showCardOfTheDay, isFlipped: $cardOfTheDayFlipped)
                        QuickStatsSection()
                    }
                    .padding()
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.creamyBackground)
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionSheet()
        }
        .sheet(isPresented: $showCategoryFilter) {
            CategoryFilterSheet()
        }
        .sheet(isPresented: $dailyGoalsManager.showLevelUpCelebration) {
            LevelUpCelebrationView()
        }
        .onAppear {
            let cards = cardManager.getAvailableCards(isSubscribed: subscriptionManager.isSubscribed)
            dailyGoalsManager.selectCardOfTheDay(from: cards)
            dailyGoalsManager.checkAndResetDailyGoals()
        }
    }
}

// MARK: - Compact Header View

struct CompactHeaderView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @StateObject private var dailyGoalsManager = DailyGoalsManager.shared
    @Binding var showCategoryFilter: Bool

    var isFiltered: Bool {
        cardManager.selectedCategories.count < ContentCategory.allCases.count
    }

    var body: some View {
        HStack(spacing: 12) {
            // Bear + Title
            Image("NurseBear")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 1) {
                Text("CozyNCLEX")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                HStack(spacing: 8) {
                    // Level badge
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.pastelPink)
                        Text("Lv.\(dailyGoalsManager.currentLevel)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    // Streak
                    if statsManager.stats.currentStreak > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                            Text("\(statsManager.stats.currentStreak)")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    // XP
                    Text("\(dailyGoalsManager.totalXP) XP")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.softLavender)
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
        }
    }
}

// MARK: - Game Modes Grid Section (More Prominent)

struct GameModesGridSection: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Binding var showSubscriptionSheet: Bool

    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Study Modes")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    GameModeGridCard(mode: mode, showSubscriptionSheet: $showSubscriptionSheet)
                }
            }
        }
    }
}

struct GameModeGridCard: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    let mode: GameMode
    @Binding var showSubscriptionSheet: Bool

    var isLocked: Bool {
        mode.isPaid && !subscriptionManager.isSubscribed
    }

    var cardColor: Color {
        switch mode {
        case .swipe: return .mintGreen
        case .quiz: return .pastelPink
        case .smartReview: return .softLavender
        case .match: return .peachOrange
        case .write: return .skyBlue
        case .test: return .coralPink
        }
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            SoundManager.shared.buttonTap()
            if isLocked {
                showSubscriptionSheet = true
            } else {
                switch mode {
                case .swipe: appManager.currentScreen = .swipeGame
                case .quiz: appManager.currentScreen = .quizGame
                case .smartReview: appManager.currentScreen = .smartReview
                case .match: appManager.currentScreen = .matchGame
                case .write: appManager.currentScreen = .writeMode
                case .test: appManager.currentScreen = .testMode
                }
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
                } else if !mode.isPaid {
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
    }
}

// MARK: - Level Progress Section

struct LevelProgressSection: View {
    @StateObject private var dailyGoalsManager = DailyGoalsManager.shared

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
    }
}

// MARK: - Daily Goals Section

struct DailyGoalsSection: View {
    @StateObject private var dailyGoalsManager = DailyGoalsManager.shared

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
    @StateObject private var dailyGoalsManager = DailyGoalsManager.shared
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
    @StateObject private var dailyGoalsManager = DailyGoalsManager.shared
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
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
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
        }
        .onAppear {
            generateConfetti()
        }
    }

    func generateConfetti() {
        let colors: [Color] = [.pastelPink, .mintGreen, .softLavender, .peachOrange, .skyBlue, .yellow]
        confettiPieces = (0..<60).map { _ in
            LevelUpConfettiPiece(
                color: colors.randomElement() ?? .pastelPink,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
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
    @Binding var showCategoryFilter: Bool

    var selectedCount: Int { cardManager.selectedCategories.count }
    var totalCount: Int { ContentCategory.allCases.count }
    var isFiltered: Bool { selectedCount < totalCount }

    var body: some View {
        if isFiltered {
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
        }
    }
}

struct QuickStatsSection: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var totalCards: Int {
        cardManager.getAvailableCards(isSubscribed: subscriptionManager.isSubscribed).count
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

struct QuickActionsSection: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        HStack(spacing: 12) {
            QuickActionButton(icon: "plus.circle.fill", label: "Create Card", color: .mintGreen) {
                appManager.currentScreen = .createCard
            }
            QuickActionButton(icon: "folder.fill", label: "Study Sets", color: .peachOrange) {
                appManager.currentScreen = .studySets
            }
            QuickActionButton(icon: "chart.bar.fill", label: "Stats", color: .softLavender) {
                appManager.currentScreen = .stats
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
            if !subscriptionManager.isSubscribed {
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
        if mode.isPaid && !subscriptionManager.isSubscribed {
            showSubscriptionSheet = true
        } else {
            switch mode {
            case .swipe: appManager.currentScreen = .swipeGame
            case .quiz: appManager.currentScreen = .quizGame
            case .smartReview: appManager.currentScreen = .smartReview
            case .match: appManager.currentScreen = .matchGame
            case .write: appManager.currentScreen = .writeMode
            case .test: appManager.currentScreen = .testMode
            }
        }
    }
}

struct CompactModeCard: View {
    let mode: GameMode
    let action: () -> Void

    var modeColor: Color {
        switch mode {
        case .swipe: return .mintGreen
        case .quiz: return .pastelPink
        case .smartReview: return .softLavender
        case .match: return .softLavender
        case .write: return .skyBlue
        case .test: return .peachOrange
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
        case .swipe: return .mintGreen
        case .quiz: return .pastelPink
        case .smartReview: return .softLavender
        case .match: return .softLavender
        case .write: return .skyBlue
        case .test: return .peachOrange
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

struct SubscribeButton: View {
    @Binding var showSheet: Bool

    var body: some View {
        Button(action: { showSheet = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Text("Unlock 500+ Cards").font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    Text("$4.99/week • All Study Modes").font(.system(size: 13, design: .rounded)).opacity(0.9)
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
    @Environment(\.dismiss) var dismiss
    @State private var selectedProduct: Product?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("NurseBear")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            Text("Unlock Everything!").font(.system(size: 26, weight: .bold, design: .rounded))

            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(icon: "square.stack.3d.up.fill", text: "500+ NCLEX Questions")
                FeatureRow(icon: "brain.head.profile", text: "Smart Review (Spaced Repetition)")
                FeatureRow(icon: "gamecontroller.fill", text: "All Study Modes")
                FeatureRow(icon: "doc.text.fill", text: "Practice Tests")
            }
            .padding()
            .background(Color.adaptiveWhite)
            .cornerRadius(16)

            // Product options
            if subscriptionManager.products.isEmpty && subscriptionManager.lifetimeProduct == nil {
                // Loading state when products not yet loaded
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading subscription options...")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                // Subscription products
                VStack(spacing: 10) {
                    ForEach(subscriptionManager.products, id: \.id) { product in
                        SubscriptionProductRow(
                            product: product,
                            isSelected: selectedProduct?.id == product.id,
                            isLifetime: false,
                            action: { selectedProduct = product }
                        )
                    }

                    // Lifetime option
                    if let lifetime = subscriptionManager.lifetimeProduct {
                        SubscriptionProductRow(
                            product: lifetime,
                            isSelected: selectedProduct?.id == lifetime.id,
                            isLifetime: true,
                            action: { selectedProduct = lifetime }
                        )
                    }
                }

                if let product = selectedProduct ?? subscriptionManager.products.first {
                    Button(action: {
                        Task {
                            await subscriptionManager.purchase(product)
                            if subscriptionManager.isSubscribed {
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            if subscriptionManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                let isLifetime = product.type == .nonConsumable
                                Text(isLifetime ? "Buy Lifetime - \(product.displayPrice)" : "Subscribe - \(product.displayPrice)")
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
                }

                if let error = subscriptionManager.purchaseError {
                    Text(error)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }

            Button(action: {
                Task {
                    await subscriptionManager.restore()
                    if subscriptionManager.isSubscribed {
                        dismiss()
                    }
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

            Spacer()
        }
        .padding()
        .background(Color.creamyBackground)
        .onAppear {
            selectedProduct = subscriptionManager.products.first
        }
    }
}

struct SubscriptionProductRow: View {
    let product: Product
    let isSelected: Bool
    let isLifetime: Bool
    let action: () -> Void

    var periodText: String {
        // Use product ID to determine period (most reliable)
        let id = product.id.lowercased()
        if id.contains("weekly") { return "week" }
        if id.contains("monthly") { return "month" }
        if id.contains("yearly") { return "year" }

        // Fallback to StoreKit subscription period
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
                        if isLifetime {
                            Text("BEST VALUE")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(4)
                        }
                    }
                    Text(isLifetime ? "\(product.displayPrice) one-time" : "\(product.displayPrice)/\(periodText)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
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
    @State private var selectedCard: Flashcard? = nil
    @State private var showCategoryFilter = false

    var filteredCards: [Flashcard] {
        cardManager.getFilteredCards(isSubscribed: subscriptionManager.isSubscribed)
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
                    HStack(spacing: 4) {
                        Image(systemName: card.contentCategory.icon).foregroundColor(card.contentCategory.color)
                        Text(card.contentCategory.rawValue).font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                    }
                    Spacer()
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
                        }
                        Text(card.rationale).font(.system(size: 14, design: .rounded)).foregroundColor(.secondary)
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
        cardManager.searchCards(query: searchText, isSubscribed: subscriptionManager.isSubscribed)
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

                HStack(spacing: 12) {
                    StatBox(title: "Current Streak", value: "\(statsManager.stats.currentStreak) days", icon: "flame.fill", color: .orange)
                    StatBox(title: "Cards Mastered", value: "\(cardManager.validMasteredCount)", icon: "checkmark.seal.fill", color: .pastelPink)
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
    @StateObject private var dailyGoalsManager = DailyGoalsManager.shared
    @StateObject private var appearanceManager = AppearanceManager.shared
    @State private var remindersEnabled = false
    @State private var selectedTime = Date()
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var hapticsEnabled = HapticManager.shared.isEnabled
    @State private var showResetConfirmation = false

    private let privacyPolicyURL = "https://spycidicy.github.io/CozyNCLEXPrep2026/privacy.html"
    private let termsOfServiceURL = "https://spycidicy.github.io/CozyNCLEXPrep2026/terms.html"

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
                        Text(subscriptionManager.isSubscribed ? "Premium" : "Free")
                            .foregroundColor(subscriptionManager.isSubscribed ? .mintGreen : .secondary)
                            .fontWeight(subscriptionManager.isSubscribed ? .semibold : .regular)
                    }

                    Button(action: {
                        HapticManager.shared.buttonTap()
                        Task {
                            await subscriptionManager.restore()
                            restoreMessage = subscriptionManager.isSubscribed ? "Subscription restored successfully!" : "No active subscription found."
                            showRestoreAlert = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Restore Purchases")
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
                        if let url = URL(string: "mailto:longxethan@gmail.com?subject=CozyNCLEX%20Prep%20Support") {
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

// MARK: - Swipe Game View

struct SwipeGameView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @StateObject private var dailyGoalsManager = DailyGoalsManager.shared
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var isFlipped = false
    @State private var showStamp: String? = nil
    @State private var showCelebration = false
    @State private var correctCount = 0
    @State private var startTime = Date()
    @State private var swipeCards: [Flashcard] = []
    @State private var isDragging = false

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    BackButton {
                        HapticManager.shared.buttonTap()
                        saveSession()
                        appManager.currentScreen = .menu
                    }
                    Spacer()
                    Text("Cozy Swipe").font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                    Text("\(currentIndex + 1)/\(swipeCards.count)")
                        .font(.system(size: 14, weight: .medium, design: .rounded)).foregroundColor(.secondary)
                }
                .padding(.horizontal)

                ProgressBar(current: currentIndex + 1, total: swipeCards.count)
                    .padding(.horizontal)

                Spacer()

                if showCelebration {
                    CelebrationView(score: correctCount, total: swipeCards.count) {
                        HapticManager.shared.buttonTap()
                        saveSession()
                        setupSwipeCards()
                    }
                } else if swipeCards.isEmpty {
                    AllMasteredView {
                        HapticManager.shared.buttonTap()
                        appManager.currentScreen = .cardBrowser
                        cardManager.currentFilter = .mastered
                    }
                } else if currentIndex < swipeCards.count {
                    ZStack {
                        FlashcardView(card: swipeCards[currentIndex], isFlipped: $isFlipped,
                                     isSaved: cardManager.isSaved(swipeCards[currentIndex])) {
                            HapticManager.shared.light()
                            cardManager.toggleSaved(swipeCards[currentIndex])
                        }
                        .offset(offset)
                        .rotationEffect(.degrees(Double(offset.width / 20)))
                        .gesture(
                            DragGesture(minimumDistance: 10)
                                .onChanged { g in
                                    isDragging = true
                                    offset = g.translation
                                    let newStamp = g.translation.width > 50 ? "GOT IT!" : (g.translation.width < -50 ? "STUDY MORE" : nil)
                                    if newStamp != showStamp && newStamp != nil {
                                        HapticManager.shared.selection()
                                    }
                                    showStamp = newStamp
                                }
                                .onEnded { g in
                                    isDragging = false
                                    if g.translation.width > 100 { swipeRight() }
                                    else if g.translation.width < -100 { swipeLeft() }
                                    else { withAnimation(.spring()) { offset = .zero; showStamp = nil } }
                                }
                        )
                        .onTapGesture {
                            guard !isDragging else { return }
                            HapticManager.shared.cardFlip()
                            SoundManager.shared.cardFlip()
                            withAnimation(.spring(response: 0.5)) { isFlipped.toggle() }
                        }

                        if let stamp = showStamp {
                            StampOverlay(text: stamp, isPositive: stamp == "GOT IT!")
                        }
                    }
                }
                Spacer()

                if !showCelebration && !swipeCards.isEmpty && currentIndex < swipeCards.count {
                    SwipeInstructions()
                }
            }
        }
        .onAppear { setupSwipeCards() }
    }

    func setupSwipeCards() {
        swipeCards = cardManager.getGameCards(isSubscribed: subscriptionManager.isSubscribed)
        currentIndex = 0
        correctCount = 0
        showCelebration = false
        startTime = Date()
    }

    func swipeRight() {
        guard currentIndex < swipeCards.count else { return }
        HapticManager.shared.correctAnswer()
        SoundManager.shared.correctAnswer()
        cardManager.recordCorrectAnswer(swipeCards[currentIndex])
        correctCount += 1
        nextCard(positive: true)
    }

    func swipeLeft() {
        guard currentIndex < swipeCards.count else { return }
        HapticManager.shared.wrongAnswer()
        SoundManager.shared.wrongAnswer()
        cardManager.recordWrongAnswer(swipeCards[currentIndex])
        nextCard(positive: false)
    }

    func nextCard(positive: Bool) {
        HapticManager.shared.swipe()
        SoundManager.shared.swipe()
        withAnimation(.easeOut(duration: 0.3)) { offset = CGSize(width: positive ? 500 : -500, height: 0) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            offset = .zero; showStamp = nil; isFlipped = false
            if currentIndex + 1 >= swipeCards.count {
                showCelebration = true
                HapticManager.shared.achievement()
                SoundManager.shared.celebration()
            }
            else { currentIndex += 1 }
        }
    }

    func saveSession() {
        let timeSpent = Int(Date().timeIntervalSince(startTime))
        if currentIndex > 0 {
            statsManager.recordSession(cardsStudied: currentIndex, correct: correctCount, timeSeconds: timeSpent, mode: "Swipe")
            dailyGoalsManager.recordStudySession(cardsStudied: currentIndex, correct: correctCount, timeSeconds: timeSpent)
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

    var body: some View {
        ZStack {
            CardFace(content: card.answer, category: card.contentCategory, isQuestion: false, rationale: card.rationale)
                .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0)).opacity(isFlipped ? 1 : 0)
            CardFace(content: card.question, category: card.contentCategory, isQuestion: true, rationale: "")
                .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0)).opacity(isFlipped ? 0 : 1)
        }
        .frame(width: 300, height: 400)
        .overlay(alignment: .topTrailing) {
            Button(action: onSaveTap) {
                Image(systemName: isSaved ? "heart.fill" : "heart").font(.system(size: 22))
                    .foregroundColor(isSaved ? .red : .gray).padding(14)
            }
        }
    }
}

struct CardFace: View {
    let content: String
    let category: ContentCategory
    let isQuestion: Bool
    let rationale: String

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: category.icon).foregroundColor(category.color)
                Text(category.rawValue).font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
            }
            Spacer()
            Text(content).font(.system(size: 20, weight: .medium, design: .rounded)).multilineTextAlignment(.center).padding(.horizontal)
            Spacer()
            if !isQuestion && !rationale.isEmpty {
                Text(rationale).font(.system(size: 12, design: .rounded)).foregroundColor(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal).lineLimit(4)
            }
            Text(isQuestion ? "Tap to reveal" : "Answer").font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color.adaptiveWhite).shadow(color: .black.opacity(0.1), radius: 8))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(category.color.opacity(0.3), lineWidth: 2))
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
        }
    }
}

// MARK: - Bear Quiz View

struct BearQuizView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @StateObject private var dailyGoalsManager = DailyGoalsManager.shared
    @State private var currentIndex = 0
    @State private var shuffledAnswers: [String] = []
    @State private var selectedAnswer: String? = nil
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var score = 0
    @State private var showCelebration = false
    @State private var startTime = Date()
    @State private var showRationale = false
    @State private var cardScale: CGFloat = 1.0
    @State private var cardOpacity: Double = 1.0
    @State private var showConfetti = false
    @State private var streakCount = 0
    @State private var quizCards: [Flashcard] = []

    private let maxQuestions = 10

    var currentCard: Flashcard? { currentIndex < quizCards.count ? quizCards[currentIndex] : nil }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.creamyBackground, Color.pastelPink.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                QuizHeader(
                    score: score,
                    currentIndex: currentIndex,
                    total: quizCards.count,
                    streakCount: streakCount,
                    onBack: {
                        HapticManager.shared.buttonTap()
                        saveSession()
                        appManager.currentScreen = .menu
                    }
                )

                if showCelebration {
                    QuizCelebrationView(score: score, total: quizCards.count, onPlayAgain: {
                        HapticManager.shared.buttonTap()
                        resetQuiz()
                    })
                } else if quizCards.isEmpty {
                    Spacer()
                    AllMasteredView {
                        HapticManager.shared.buttonTap()
                        appManager.currentScreen = .cardBrowser
                        cardManager.currentFilter = .mastered
                    }
                    Spacer()
                } else if let card = currentCard {
                    Spacer()

                    // Main Question Modal Card
                    QuizModalCard(
                        card: card,
                        shuffledAnswers: shuffledAnswers,
                        selectedAnswer: selectedAnswer,
                        showResult: showResult,
                        isCorrect: isCorrect,
                        showRationale: showRationale,
                        onSelectAnswer: { answer in
                            selectAnswer(answer, correctAnswer: card.answer)
                        },
                        onNext: {
                            HapticManager.shared.buttonTap()
                            nextQuestion()
                        }
                    )
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)

                    Spacer()

                    // Progress dots
                    QuizProgressDots(current: currentIndex, total: quizCards.count)
                        .padding(.bottom, 20)
                }
            }

            // Confetti overlay
            if showConfetti {
                QuizConfettiOverlay()
                    .allowsHitTesting(false)
            }
        }
        .onAppear { setupQuiz() }
    }

    func setupQuiz() {
        let allCards = cardManager.getGameCards(isSubscribed: subscriptionManager.isSubscribed)
        quizCards = Array(allCards.prefix(maxQuestions))
        currentIndex = 0
        score = 0
        streakCount = 0
        startTime = Date()
        loadQuestion()
    }

    func loadQuestion() {
        guard let card = currentCard else { return }

        // Animate card in
        cardScale = 0.8
        cardOpacity = 0

        shuffledAnswers = card.shuffledAnswers()
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
        guard !showResult, let card = currentCard else { return }

        // Haptic feedback
        HapticManager.shared.medium()

        selectedAnswer = answer
        isCorrect = answer == correctAnswer

        withAnimation(.easeInOut(duration: 0.3)) {
            showResult = true
        }

        if isCorrect {
            score += 1
            streakCount += 1
            cardManager.recordCorrectAnswer(card)

            // Show confetti for correct answer
            withAnimation(.easeOut(duration: 0.2)) {
                showConfetti = true
            }

            // Success feedback
            HapticManager.shared.correctAnswer()
            SoundManager.shared.correctAnswer()
        } else {
            streakCount = 0
            cardManager.recordWrongAnswer(card)

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

        statsManager.recordCategoryResult(category: card.contentCategory.rawValue, correct: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showRationale = true
            }
        }
    }

    func nextQuestion() {
        // Animate card out
        withAnimation(.easeInOut(duration: 0.2)) {
            cardScale = 0.9
            cardOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if currentIndex + 1 >= quizCards.count {
                showCelebration = true
                HapticManager.shared.achievement()
                SoundManager.shared.celebration()
            } else {
                currentIndex += 1
                loadQuestion()
            }
        }
    }

    func resetQuiz() {
        saveSession()
        showCelebration = false
        setupQuiz()
    }

    func saveSession() {
        let timeSpent = Int(Date().timeIntervalSince(startTime))
        if currentIndex > 0 {
            statsManager.recordSession(cardsStudied: currentIndex, correct: score, timeSeconds: timeSpent, mode: "Quiz")
            dailyGoalsManager.recordStudySession(cardsStudied: currentIndex, correct: score, timeSeconds: timeSpent)
        }
    }
}

// MARK: - Quiz Header

struct QuizHeader: View {
    let score: Int
    let currentIndex: Int
    let total: Int
    let streakCount: Int
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.pastelPink)
                }

                Spacer()

                // Mascot and title
                HStack(spacing: 8) {
                    Image("NurseBear")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    Text("Bear Quiz")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }

                Spacer()

                // Score badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    Text("\(score)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.cardBackground)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4)
            }
            .padding(.horizontal)

            // Progress and streak
            HStack {
                Text("Question \(currentIndex + 1) of \(total)")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)

                Spacer()

                if streakCount > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streakCount) streak!")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

// MARK: - Quiz Modal Card

struct QuizModalCard: View {
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

            // Answers Section (scrollable)
            ScrollView {
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
                            }
                            Text(card.rationale)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                                .lineSpacing(3)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
            }
            .background(Color.cardBackground.opacity(0.5))

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
        ZStack {
            ForEach(confettiPieces) { piece in
                ConfettiPieceView(piece: piece)
            }
        }
        .onAppear {
            createConfetti()
        }
    }

    func createConfetti() {
        let colors: [Color] = [.pastelPink, .mintGreen, .softLavender, .peachOrange, .skyBlue, .yellow, .red, .orange, .green, .blue, .purple]
        let shapes: [ConfettiShape] = [.rectangle, .circle, .triangle, .strip]

        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: i,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
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
                    yOffset = UIScreen.main.bounds.height + 100
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

// MARK: - Quiz Celebration View

struct QuizCelebrationView: View {
    let score: Int
    let total: Int
    let onPlayAgain: () -> Void
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
    let rationale: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack { Image(systemName: "lightbulb.fill").foregroundColor(.yellow); Text("Rationale").font(.system(size: 14, weight: .semibold, design: .rounded)) }
            Text(rationale).font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
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
                    CelebrationView(score: score, total: writeCards.count) { resetMode() }
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
        writeCards = cardManager.getGameCards(isSubscribed: subscriptionManager.isSubscribed)
        currentIndex = 0
        score = 0
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

    var availableCards: [Flashcard] { cardManager.getGameCards(isSubscribed: subscriptionManager.isSubscribed) }
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
                    TestResultsView(correct: correctCount, total: testCards.count, onRetry: {
                        testCards = []; shuffledAnswers = [:]; showResults = false; selectedFormat = nil
                    }, testAnswers: getTestAnswers())
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
                Text("Rationale:")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                Text(answer.rationale)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
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

// MARK: - Smart Review View (Spaced Repetition)

struct SmartReviewView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @State private var reviewCards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var score = 0
    @State private var cardsReviewed = 0
    @State private var startTime = Date()
    @State private var showCelebration = false

    var currentCard: Flashcard? {
        currentIndex < reviewCards.count ? reviewCards[currentIndex] : nil
    }

    var dueCount: Int {
        cardManager.getDueCardCount(isSubscribed: subscriptionManager.isSubscribed)
    }

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    BackButton { saveSession(); appManager.currentScreen = .menu }
                    Spacer()
                    Text("Smart Review 🧠").font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(score)/\(cardsReviewed)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.mintGreen)
                        Text("\(dueCount) due")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                if showCelebration {
                    SmartReviewCelebration(cardsReviewed: cardsReviewed, score: score) {
                        resetReview()
                    }
                } else if reviewCards.isEmpty {
                    Spacer()
                    NoCardsDueView {
                        appManager.currentScreen = .menu
                    }
                    Spacer()
                } else if let card = currentCard {
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(colors: [.mintGreen, .softLavender], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * CGFloat(currentIndex) / CGFloat(max(1, reviewCards.count)), height: 8)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)

                    // Spaced Rep Info
                    if let srData = cardManager.getSpacedRepInfo(card: card) {
                        HStack {
                            Label("Interval: \(srData.interval) days", systemImage: "calendar")
                            Spacer()
                            Label("Reviews: \(srData.repetitions)", systemImage: "arrow.counterclockwise")
                        }
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    }

                    ScrollView {
                        VStack(spacing: 20) {
                            // Question Card
                            VStack(spacing: 12) {
                                HStack {
                                    HStack(spacing: 4) {
                                        Image(systemName: card.contentCategory.icon)
                                            .foregroundColor(card.contentCategory.color)
                                        Text(card.contentCategory.rawValue)
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(card.difficulty.rawValue)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(card.difficulty.color)
                                        .cornerRadius(8)
                                }

                                Text(card.question)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 10)
                            }
                            .padding(20)
                            .background(Color.adaptiveWhite)
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.08), radius: 6)

                            if showAnswer {
                                // Answer Card
                                VStack(spacing: 12) {
                                    Text("Answer")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(.secondary)

                                    Text(card.answer)
                                        .font(.system(size: 17, weight: .medium, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.mintGreen)

                                    if !card.rationale.isEmpty {
                                        Divider().padding(.vertical, 8)
                                        Text(card.rationale)
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .padding(20)
                                .background(Color.mintGreen.opacity(0.1))
                                .cornerRadius(18)

                                // Rating Buttons
                                VStack(spacing: 10) {
                                    Text("How well did you know this?")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)

                                    HStack(spacing: 12) {
                                        RatingButton(title: "Again", subtitle: "1 day", color: .coralPink) {
                                            rateCard(quality: 1)
                                        }
                                        RatingButton(title: "Hard", subtitle: "3 days", color: .peachOrange) {
                                            rateCard(quality: 3)
                                        }
                                        RatingButton(title: "Good", subtitle: "1 week", color: .mintGreen) {
                                            rateCard(quality: 4)
                                        }
                                        RatingButton(title: "Easy", subtitle: "2 weeks", color: .skyBlue) {
                                            rateCard(quality: 5)
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            } else {
                                // Show Answer Button
                                Button(action: { withAnimation { showAnswer = true } }) {
                                    Text("Show Answer")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing))
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear { loadReviewCards() }
    }

    func loadReviewCards() {
        reviewCards = cardManager.getCardsForSpacedReview(isSubscribed: subscriptionManager.isSubscribed).shuffled()
        currentIndex = 0
        showAnswer = false
    }

    func rateCard(quality: Int) {
        guard let card = currentCard else { return }

        // Haptic feedback based on rating
        if quality >= 4 {
            HapticManager.shared.correctAnswer()
            SoundManager.shared.correctAnswer()
        } else if quality >= 3 {
            HapticManager.shared.light()
        } else {
            HapticManager.shared.wrongAnswer()
            SoundManager.shared.wrongAnswer()
        }

        cardsReviewed += 1
        if quality >= 3 {
            score += 1
            cardManager.recordCorrectAnswer(card)
        } else {
            cardManager.recordWrongAnswer(card)
        }

        // Record spaced rep response
        cardManager.recordSpacedRepResponse(card: card, quality: quality)
        statsManager.recordCategoryResult(category: card.contentCategory.rawValue, correct: quality >= 3)

        // Move to next card
        if currentIndex + 1 >= reviewCards.count {
            showCelebration = true
            HapticManager.shared.achievement()
            SoundManager.shared.celebration()
        } else {
            currentIndex += 1
            showAnswer = false
        }
    }

    func resetReview() {
        HapticManager.shared.buttonTap()
        saveSession()
        score = 0
        cardsReviewed = 0
        currentIndex = 0
        showCelebration = false
        startTime = Date()
        loadReviewCards()
    }

    func saveSession() {
        let timeSpent = Int(Date().timeIntervalSince(startTime))
        if cardsReviewed > 0 {
            statsManager.recordSession(cardsStudied: cardsReviewed, correct: score, timeSeconds: timeSpent, mode: "Smart Review")
            DailyGoalsManager.shared.recordStudySession(cardsStudied: cardsReviewed, correct: score, timeSeconds: timeSpent)
        }
    }
}

struct RatingButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(12)
        }
    }
}

struct NoCardsDueView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("🎉").font(.system(size: 60))
            Text("All Caught Up!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text("No cards due for review.\nCome back later or try another study mode!")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button(action: action) {
                Text("Back to Menu")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(LinearGradient(colors: [.mintGreen, .softLavender], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(22)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

struct SmartReviewCelebration: View {
    let cardsReviewed: Int
    let score: Int
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🧠").font(.system(size: 70))
            Text("Review Complete!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text("You reviewed \(cardsReviewed) cards")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)

            HStack(spacing: 30) {
                VStack {
                    Text("\(score)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.mintGreen)
                    Text("Correct")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }
                VStack {
                    Text("\(cardsReviewed > 0 ? Int(Double(score) / Double(cardsReviewed) * 100) : 0)%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.softLavender)
                    Text("Accuracy")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical)

            Button(action: onContinue) {
                Text("Continue Studying")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 14)
                    .background(LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(22)
            }
            Spacer()
        }
    }
}

// MARK: - Cozy Match View

struct CozyMatchView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var cardManager: CardManager
    @EnvironmentObject var statsManager: StatsManager
    @State private var tiles: [MatchTile] = []
    @State private var gameCards: [Flashcard] = []
    @State private var selectedTile: MatchTile? = nil
    @State private var matchedPairs = 0
    @State private var moves = 0
    @State private var showWin = false
    @State private var isProcessing = false
    @State private var startTime = Date()

    var availableCards: [Flashcard] { cardManager.getGameCards(isSubscribed: subscriptionManager.isSubscribed) }

    let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    BackButton { saveSession(); appManager.currentScreen = .menu }
                    Spacer()
                    Text("Cozy Match 🧩").font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                    Text("Moves: \(moves)").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.softLavender)
                }
                .padding(.horizontal)

                Text("Match questions with answers!").font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)

                if showWin {
                    MatchWinView(moves: moves) { resetGame() }
                } else if tiles.isEmpty {
                    Spacer()
                    VStack(spacing: 14) {
                        Text("🎉").font(.system(size: 50))
                        Text("Need more cards").font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text("You need at least 6 unmastered cards").font(.system(size: 13, design: .rounded)).foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(tiles) { tile in
                                MatchTileView(tile: tile, isSelected: selectedTile?.id == tile.id) { handleTileTap(tile) }
                            }
                        }
                        .padding()
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
        guard availableCards.count >= 6 else { tiles = []; return }
        let selected = Array(availableCards.shuffled().prefix(6))
        gameCards = selected
        var newTiles: [MatchTile] = []
        for card in selected {
            newTiles.append(MatchTile(cardId: card.id, content: card.question, isQuestion: true))
            newTiles.append(MatchTile(cardId: card.id, content: card.answer, isQuestion: false))
        }
        tiles = newTiles.shuffled()
        selectedTile = nil; matchedPairs = 0; moves = 0; showWin = false; isProcessing = false; startTime = Date()
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
                if matchedPairs == 6 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showWin = true
                        HapticManager.shared.achievement()
                        SoundManager.shared.celebration()
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
        if matchedPairs > 0 {
            statsManager.recordSession(cardsStudied: matchedPairs * 2, correct: matchedPairs, timeSeconds: timeSpent, mode: "Match")
            DailyGoalsManager.shared.recordStudySession(cardsStudied: matchedPairs * 2, correct: matchedPairs, timeSeconds: timeSpent)
        }
    }
}

struct MatchTileView: View {
    let tile: MatchTile
    let isSelected: Bool
    let action: () -> Void

    var bgColor: Color {
        if tile.isMatched { return .green.opacity(0.3) }
        if tile.showError { return .red.opacity(0.3) }
        if isSelected { return .softLavender.opacity(0.3) }
        return .white
    }

    var borderColor: Color {
        if tile.isMatched { return .green }
        if tile.showError { return .red }
        if isSelected { return .softLavender }
        return .gray.opacity(0.2)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Badge showing Q or A
                Text(tile.isQuestion ? "Q" : "A")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(tile.isQuestion ? Color.mintGreen : Color.pastelPink)
                    .cornerRadius(8)

                // Content text - larger and more readable
                Text(tile.content)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(5)
                    .minimumScaleFactor(0.6)
            }
            .padding(10)
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(bgColor)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 2))
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

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Text("🎉").font(.system(size: 60))
            Text("You Win!").font(.system(size: 30, weight: .bold, design: .rounded))
            Text("Completed in \(moves) moves").font(.system(size: 16, design: .rounded)).foregroundColor(.secondary)
            Button(action: onPlayAgain) {
                Text("Play Again").font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white).padding(.horizontal, 35).padding(.vertical, 14)
                    .background(LinearGradient(colors: [.mintGreen, .softLavender], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(22)
            }
            Spacer()
        }
    }
}

// MARK: - Category Filter Sheet

struct CategoryFilterSheet: View {
    @EnvironmentObject var cardManager: CardManager
    @Environment(\.dismiss) var dismiss

    var selectedCount: Int {
        cardManager.selectedCategories.count
    }

    var totalCount: Int {
        ContentCategory.allCases.count
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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

                // Category list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(ContentCategory.allCases, id: \.self) { category in
                            CategoryFilterRow(category: category, isSelected: cardManager.selectedCategories.contains(category)) {
                                cardManager.toggleCategory(category)
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
