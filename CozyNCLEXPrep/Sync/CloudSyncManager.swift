//
//  CloudSyncManager.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation
import Combine
import Supabase

// MARK: - Sync Models

struct CloudCardProgress: Codable {
    let id: UUID?
    let userId: UUID
    let cardId: UUID
    var consecutiveCorrect: Int
    var isMastered: Bool
    var isSaved: Bool
    var isFlagged: Bool
    var timesStudied: Int
    var timesCorrect: Int
    var lastStudiedAt: Date?
    let createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case cardId = "card_id"
        case consecutiveCorrect = "consecutive_correct"
        case isMastered = "is_mastered"
        case isSaved = "is_saved"
        case isFlagged = "is_flagged"
        case timesStudied = "times_studied"
        case timesCorrect = "times_correct"
        case lastStudiedAt = "last_studied_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CloudUserStats: Codable {
    let id: UUID?
    let userId: UUID
    var totalCardsStudied: Int
    var totalCorrect: Int
    var totalIncorrect: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastStudyDate: String?
    var totalXp: Int
    var currentLevel: Int
    var studySessionsCompleted: Int
    var testsCompleted: Int
    var perfectSessions: Int
    let createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case totalCardsStudied = "total_cards_studied"
        case totalCorrect = "total_correct"
        case totalIncorrect = "total_incorrect"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case lastStudyDate = "last_study_date"
        case totalXp = "total_xp"
        case currentLevel = "current_level"
        case studySessionsCompleted = "study_sessions_completed"
        case testsCompleted = "tests_completed"
        case perfectSessions = "perfect_sessions"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CloudUserCard: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var question: String
    var answer: String
    var wrongAnswers: [String]
    var rationale: String
    var contentCategory: String
    var nclexCategory: String
    var difficulty: String
    var isDeleted: Bool
    let createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case question
        case answer
        case wrongAnswers = "wrong_answers"
        case rationale
        case contentCategory = "content_category"
        case nclexCategory = "nclex_category"
        case difficulty
        case isDeleted = "is_deleted"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CloudStudySet: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var name: String
    var cardIds: [String]
    var color: String
    var isDeleted: Bool
    let createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case cardIds = "card_ids"
        case color
        case isDeleted = "is_deleted"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CloudDailyActivity: Codable {
    let id: UUID?
    let userId: UUID
    let activityDate: String
    var cardsStudied: Int
    var correctAnswers: Int
    var xpEarned: Int
    var minutesStudied: Int
    var goalsCompleted: [String]
    let createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case activityDate = "activity_date"
        case cardsStudied = "cards_studied"
        case correctAnswers = "correct_answers"
        case xpEarned = "xp_earned"
        case minutesStudied = "minutes_studied"
        case goalsCompleted = "goals_completed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CloudTestResult: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let testDate: Date
    let questionCount: Int
    let correctCount: Int
    let timeTakenSeconds: Int?
    let categoryBreakdown: [String: Int]
    let difficulty: String
    let testType: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case testDate = "test_date"
        case questionCount = "question_count"
        case correctCount = "correct_count"
        case timeTakenSeconds = "time_taken_seconds"
        case categoryBreakdown = "category_breakdown"
        case difficulty
        case testType = "test_type"
        case createdAt = "created_at"
    }
}

// MARK: - Cloud Sync Manager

@MainActor
class CloudSyncManager: ObservableObject {
    static let shared = CloudSyncManager()

    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    @Published var isSyncEnabled = true

    private let client = SupabaseConfig.client
    private var cancellables = Set<AnyCancellable>()

    private let lastSyncKey = "lastCloudSyncDate"

    private init() {
        lastSyncDate = UserDefaults.standard.object(forKey: lastSyncKey) as? Date

        // Listen for auth changes to trigger sync
        AuthManager.shared.$isAuthenticated
            .dropFirst()
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    Task { await self?.syncAll() }
                }
            }
            .store(in: &cancellables)

        // Also sync on startup if already authenticated
        Task {
            // Wait a moment for auth to initialize
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            if AuthManager.shared.isAuthenticated {
                await syncAll()
            }
        }
    }

    // MARK: - Main Sync Methods

    func syncAll() async {
        guard isSyncEnabled else { return }
        guard AuthManager.shared.isAuthenticated else { return }

        // Verify we have a valid session with the Supabase client
        do {
            let session = try await client.auth.session
            let userId = session.user.id

            // IMPORTANT: Check if user changed BEFORE syncing to prevent data leakage
            let userChanged = PersistenceManager.shared.handleUserChange(newUserId: userId.uuidString)
            if userChanged {
                print("☁️ User changed - clearing local data before sync")
                await MainActor.run {
                    DailyGoalsManager.shared.resetForNewUser()
                    StatsManager.shared.resetForNewUser()
                    CardManager.shared.resetForNewUser()
                }
            }

            // Always ensure daily goals exist after sync (they may have been reset or never generated)
            await MainActor.run {
                DailyGoalsManager.shared.checkAndResetDailyGoals()
            }

            print("☁️ Starting cloud sync for user: \(userId)")
            print("☁️ Session valid, user email: \(session.user.email ?? "unknown")")

            isSyncing = true
            syncError = nil

            // Ensure user_stats row exists first (required for foreign key constraints)
            try await ensureUserStatsExists(userId: userId)

            // Sync in order of dependency
            try await syncCardProgress(userId: userId)
            try await syncUserStats(userId: userId)
            try await syncUserCards(userId: userId)
            try await syncStudySets(userId: userId)

            // Reload all managers with the synced data
            await MainActor.run {
                CardManager.shared.loadData()
                StatsManager.shared.loadData()
                print("☁️ Reloaded CardManager and StatsManager with synced data")
                print("☁️ Mastered cards count after sync: \(CardManager.shared.masteredCardIDs.count)")
            }

            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: lastSyncKey)
            print("☁️ Cloud sync completed successfully")
        } catch {
            syncError = error.localizedDescription
            print("☁️ Cloud sync error: \(error)")
        }

        isSyncing = false
    }

    /// Ensure user_stats row exists before other syncs (trigger may not have run yet)
    private func ensureUserStatsExists(userId: UUID) async throws {
        let existing: [CloudUserStats] = try await client
            .from("user_stats")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        if existing.isEmpty {
            print("☁️ Creating initial user_stats row for user: \(userId)")

            // Create initial stats row with explicit ID
            let initialStats = CloudUserStats(
                id: UUID(), // Generate ID on client side
                userId: userId,
                totalCardsStudied: 0,
                totalCorrect: 0,
                totalIncorrect: 0,
                currentStreak: 0,
                longestStreak: 0,
                lastStudyDate: nil,
                totalXp: 0,
                currentLevel: 1,
                studySessionsCompleted: 0,
                testsCompleted: 0,
                perfectSessions: 0,
                createdAt: nil,
                updatedAt: nil
            )

            try await client
                .from("user_stats")
                .insert(initialStats)
                .execute()

            print("☁️ Created initial user_stats row")
        } else {
            print("☁️ user_stats row already exists")
        }
    }

    // MARK: - Card Progress Sync

    func syncCardProgress(userId: UUID) async throws {
        // Fetch cloud data
        let cloudProgress: [CloudCardProgress] = try await client
            .from("user_card_progress")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        print("☁️ Found \(cloudProgress.count) card progress records in cloud")

        // Convert to dictionaries for easy lookup
        var cloudMastered = Set<UUID>()
        var cloudSaved = Set<UUID>()
        var cloudFlagged = Set<UUID>()
        var cloudConsecutive: [UUID: Int] = [:]

        for progress in cloudProgress {
            if progress.isMastered { cloudMastered.insert(progress.cardId) }
            if progress.isSaved { cloudSaved.insert(progress.cardId) }
            if progress.isFlagged { cloudFlagged.insert(progress.cardId) }
            cloudConsecutive[progress.cardId] = progress.consecutiveCorrect
        }

        // Get local data from PersistenceManager
        let persistence = PersistenceManager.shared
        let localMastered = persistence.loadMasteredCards()
        let localSaved = persistence.loadSavedCards()
        let localFlagged = persistence.loadFlaggedCards()
        let localConsecutive = persistence.loadConsecutiveCorrect()

        print("☁️ Local data - Mastered: \(localMastered.count), Saved: \(localSaved.count)")

        // Merge: Union for mastered/saved/flagged, max for consecutive correct
        let mergedMastered = localMastered.union(cloudMastered)
        let mergedSaved = localSaved.union(cloudSaved)
        let mergedFlagged = localFlagged.union(cloudFlagged)

        var mergedConsecutive: [UUID: Int] = [:]
        for (cardId, count) in localConsecutive {
            mergedConsecutive[cardId] = max(count, cloudConsecutive[cardId] ?? 0)
        }
        for (cardId, count) in cloudConsecutive {
            if mergedConsecutive[cardId] == nil {
                mergedConsecutive[cardId] = count
            }
        }

        // Save merged data locally
        persistence.saveMasteredCards(mergedMastered)
        persistence.saveSavedCards(mergedSaved)
        persistence.saveFlaggedCards(mergedFlagged)
        persistence.saveConsecutiveCorrect(mergedConsecutive)

        // Upload merged data to cloud in batches
        let allCardIds = Array(mergedMastered.union(mergedSaved).union(mergedFlagged).union(Set(mergedConsecutive.keys)))

        if allCardIds.isEmpty {
            print("☁️ No card progress to sync")
            return
        }

        print("☁️ Syncing \(allCardIds.count) card progress records to cloud")

        // Build a map of existing card progress IDs from cloud
        var existingProgressIds: [UUID: UUID] = [:] // cardId -> progressId
        for progress in cloudProgress {
            if let progressId = progress.id {
                existingProgressIds[progress.cardId] = progressId
            }
        }

        // Build all progress records
        var progressRecords: [CloudCardProgress] = []
        for cardId in allCardIds {
            // Use existing ID if we have one, otherwise generate new
            let progressId = existingProgressIds[cardId] ?? UUID()

            let progress = CloudCardProgress(
                id: progressId,
                userId: userId,
                cardId: cardId,
                consecutiveCorrect: mergedConsecutive[cardId] ?? 0,
                isMastered: mergedMastered.contains(cardId),
                isSaved: mergedSaved.contains(cardId),
                isFlagged: mergedFlagged.contains(cardId),
                timesStudied: 0,
                timesCorrect: 0,
                lastStudiedAt: Date(),
                createdAt: nil,
                updatedAt: nil
            )
            progressRecords.append(progress)
        }

        // Batch upsert (up to 100 at a time to avoid timeouts)
        let batchSize = 100
        for i in stride(from: 0, to: progressRecords.count, by: batchSize) {
            let batch = Array(progressRecords[i..<min(i + batchSize, progressRecords.count)])
            do {
                try await client
                    .from("user_card_progress")
                    .upsert(batch, onConflict: "user_id,card_id")
                    .execute()
                print("☁️ Uploaded batch \(i/batchSize + 1) of \((progressRecords.count + batchSize - 1)/batchSize)")
            } catch {
                print("☁️ Error uploading batch: \(error)")
                throw error
            }
        }
    }

    // MARK: - User Stats Sync

    func syncUserStats(userId: UUID) async throws {
        // Fetch cloud stats
        let cloudStats: [CloudUserStats] = try await client
            .from("user_stats")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        let cloudStat = cloudStats.first

        // Get local stats
        let persistence = PersistenceManager.shared
        let localStats = persistence.loadUserStats()
        let localXP = DailyGoalsManager.shared.totalXP
        let localStreak = DailyGoalsManager.shared.currentStreak
        let localLongestStreak = DailyGoalsManager.shared.longestStreak

        // Merge: Take maximum values
        var mergedStats = localStats
        mergedStats.totalCardsStudied = max(localStats.totalCardsStudied, cloudStat?.totalCardsStudied ?? 0)
        mergedStats.totalCorrectAnswers = max(localStats.totalCorrectAnswers, cloudStat?.totalCorrect ?? 0)
        mergedStats.currentStreak = max(localStats.currentStreak, cloudStat?.currentStreak ?? 0)
        mergedStats.longestStreak = max(localStats.longestStreak, cloudStat?.longestStreak ?? 0)

        // Merge XP - take the maximum
        let mergedXP = max(localXP, cloudStat?.totalXp ?? 0)
        let mergedStreak = max(localStreak, cloudStat?.currentStreak ?? 0)
        let mergedLongestStreak = max(localLongestStreak, cloudStat?.longestStreak ?? 0)

        // Save locally
        persistence.saveUserStats(mergedStats)

        // Update DailyGoalsManager with merged XP (if cloud has more)
        if mergedXP > localXP {
            DailyGoalsManager.shared.setXPFromSync(mergedXP)
        }
        if mergedStreak > localStreak {
            DailyGoalsManager.shared.setStreakFromSync(current: mergedStreak, longest: mergedLongestStreak)
        }

        // Upload to cloud
        let dateFormatter = ISO8601DateFormatter()
        let uploadStats = CloudUserStats(
            id: nil,
            userId: userId,
            totalCardsStudied: mergedStats.totalCardsStudied,
            totalCorrect: mergedStats.totalCorrectAnswers,
            totalIncorrect: mergedStats.totalCardsStudied - mergedStats.totalCorrectAnswers,
            currentStreak: mergedStreak,
            longestStreak: mergedLongestStreak,
            lastStudyDate: mergedStats.lastStudyDate.map { dateFormatter.string(from: $0) },
            totalXp: mergedXP,
            currentLevel: DailyGoalsManager.shared.currentLevel,
            studySessionsCompleted: mergedStats.sessions.count,
            testsCompleted: 0,
            perfectSessions: 0,
            createdAt: nil,
            updatedAt: nil
        )

        try await client
            .from("user_stats")
            .upsert(uploadStats, onConflict: "user_id")
            .execute()

        print("☁️ Synced XP: local=\(localXP), cloud=\(cloudStat?.totalXp ?? 0), merged=\(mergedXP)")
    }

    // MARK: - User Cards Sync

    func syncUserCards(userId: UUID) async throws {
        // Fetch cloud cards
        let cloudCards: [CloudUserCard] = try await client
            .from("user_cards")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_deleted", value: false)
            .execute()
            .value

        // Get local user-created cards
        let persistence = PersistenceManager.shared
        let localCards = persistence.loadUserCards()

        // Merge: Union by ID
        var mergedCards: [UUID: Flashcard] = [:]

        // Add local cards
        for card in localCards {
            mergedCards[card.id] = card
        }

        // Add/update from cloud
        for cloudCard in cloudCards {
            if mergedCards[cloudCard.id] == nil {
                // Convert cloud card to Flashcard
                let flashcard = Flashcard(
                    id: cloudCard.id,
                    question: cloudCard.question,
                    answer: cloudCard.answer,
                    wrongAnswers: cloudCard.wrongAnswers,
                    rationale: cloudCard.rationale,
                    contentCategory: ContentCategory(rawValue: cloudCard.contentCategory) ?? .fundamentals,
                    nclexCategory: NCLEXCategory(rawValue: cloudCard.nclexCategory) ?? .physiological,
                    difficulty: Difficulty(rawValue: cloudCard.difficulty) ?? .medium,
                    questionType: .standard,
                    isPremium: false,
                    isUserCreated: true
                )
                mergedCards[cloudCard.id] = flashcard
            }
        }

        // Save merged cards locally
        persistence.saveUserCards(Array(mergedCards.values))

        // Upload local cards to cloud
        for card in localCards {
            let cloudCard = CloudUserCard(
                id: card.id,
                userId: userId,
                question: card.question,
                answer: card.answer,
                wrongAnswers: card.wrongAnswers,
                rationale: card.rationale,
                contentCategory: card.contentCategory.rawValue,
                nclexCategory: card.nclexCategory.rawValue,
                difficulty: card.difficulty.rawValue,
                isDeleted: false,
                createdAt: nil,
                updatedAt: nil
            )

            try await client
                .from("user_cards")
                .upsert(cloudCard, onConflict: "id")
                .execute()
        }
    }

    // MARK: - Study Sets Sync

    func syncStudySets(userId: UUID) async throws {
        // Fetch cloud study sets
        let cloudSets: [CloudStudySet] = try await client
            .from("study_sets")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_deleted", value: false)
            .execute()
            .value

        // Get local study sets
        let persistence = PersistenceManager.shared
        let localSets = persistence.loadStudySets()

        // Merge: Union by ID
        var mergedSets: [UUID: StudySet] = [:]

        // Add local sets
        for set in localSets {
            mergedSets[set.id] = set
        }

        // Add from cloud
        for cloudSet in cloudSets {
            if mergedSets[cloudSet.id] == nil {
                let cardUUIDs = cloudSet.cardIds.compactMap { UUID(uuidString: $0) }
                let studySet = StudySet(
                    id: cloudSet.id,
                    name: cloudSet.name,
                    cardIDs: cardUUIDs,
                    color: cloudSet.color
                )
                mergedSets[cloudSet.id] = studySet
            }
        }

        // Save merged sets locally
        persistence.saveStudySets(Array(mergedSets.values))

        // Upload local sets to cloud
        for set in localSets {
            let cloudSet = CloudStudySet(
                id: set.id,
                userId: userId,
                name: set.name,
                cardIds: set.cardIDs.map { $0.uuidString },
                color: set.color,
                isDeleted: false,
                createdAt: nil,
                updatedAt: nil
            )

            try await client
                .from("study_sets")
                .upsert(cloudSet, onConflict: "id")
                .execute()
        }
    }

    // MARK: - Individual Update Methods (call these when data changes)

    func updateCardProgress(cardId: UUID, isMastered: Bool? = nil, isSaved: Bool? = nil, consecutiveCorrect: Int? = nil) async {
        guard isSyncEnabled else { return }

        do {
            // Verify we have a valid session
            let session = try await client.auth.session
            let userId = session.user.id

            // First get existing progress
            let existing: [CloudCardProgress] = try await client
                .from("user_card_progress")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("card_id", value: cardId.uuidString)
                .execute()
                .value

            var progress = existing.first ?? CloudCardProgress(
                id: UUID(), // Generate ID on client side
                userId: userId,
                cardId: cardId,
                consecutiveCorrect: 0,
                isMastered: false,
                isSaved: false,
                isFlagged: false,
                timesStudied: 0,
                timesCorrect: 0,
                lastStudiedAt: nil,
                createdAt: nil,
                updatedAt: nil
            )

            // Update fields
            if let isMastered = isMastered { progress.isMastered = isMastered }
            if let isSaved = isSaved { progress.isSaved = isSaved }
            if let consecutiveCorrect = consecutiveCorrect { progress.consecutiveCorrect = consecutiveCorrect }
            progress.lastStudiedAt = Date()

            try await client
                .from("user_card_progress")
                .upsert(progress, onConflict: "user_id,card_id")
                .execute()

            print("☁️ Updated card progress for \(cardId)")
        } catch {
            print("☁️ Error updating card progress: \(error)")
        }
    }

    func saveTestResult(questionCount: Int, correctCount: Int, timeTaken: Int?, categoryBreakdown: [String: Int]) async {
        guard isSyncEnabled else { return }

        do {
            let session = try await client.auth.session
            let userId = session.user.id

            let result = CloudTestResult(
                id: UUID(),
                userId: userId,
                testDate: Date(),
                questionCount: questionCount,
                correctCount: correctCount,
                timeTakenSeconds: timeTaken,
                categoryBreakdown: categoryBreakdown,
                difficulty: "mixed",
                testType: "practice",
                createdAt: nil
            )

            try await client
                .from("test_results")
                .insert(result)
                .execute()

            print("☁️ Saved test result")
        } catch {
            print("☁️ Error saving test result: \(error)")
        }
    }

    func syncXPToCloud(totalXP: Int) async {
        guard isSyncEnabled else { return }

        do {
            let session = try await client.auth.session
            let userId = session.user.id

            // Update just the XP field
            try await client
                .from("user_stats")
                .update(["total_xp": totalXP, "current_level": DailyGoalsManager.shared.currentLevel])
                .eq("user_id", value: userId.uuidString)
                .execute()

            print("☁️ Synced XP to cloud: \(totalXP)")
        } catch {
            print("☁️ Error syncing XP: \(error)")
        }
    }

    func updateDailyActivity(cardsStudied: Int, correctAnswers: Int, xpEarned: Int) async {
        guard isSyncEnabled else { return }

        do {
            let session = try await client.auth.session
            let userId = session.user.id

            let today = ISO8601DateFormatter().string(from: Date()).prefix(10) // YYYY-MM-DD

            // Get existing activity for today
            let existing: [CloudDailyActivity] = try await client
                .from("daily_activity")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("activity_date", value: String(today))
                .execute()
                .value

            var activity = existing.first ?? CloudDailyActivity(
                id: nil,
                userId: userId,
                activityDate: String(today),
                cardsStudied: 0,
                correctAnswers: 0,
                xpEarned: 0,
                minutesStudied: 0,
                goalsCompleted: [],
                createdAt: nil,
                updatedAt: nil
            )

            // Accumulate values
            activity.cardsStudied += cardsStudied
            activity.correctAnswers += correctAnswers
            activity.xpEarned += xpEarned

            try await client
                .from("daily_activity")
                .upsert(activity, onConflict: "user_id,activity_date")
                .execute()

            print("☁️ Updated daily activity")
        } catch {
            print("☁️ Error updating daily activity: \(error)")
        }
    }
}
