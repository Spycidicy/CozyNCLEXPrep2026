//
//  MigrationManager.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation

/// Handles data migration for existing users when enabling sync
class MigrationManager {
    static let shared = MigrationManager()

    private let migrationVersionKey = "dataMigrationVersion"
    private let backupPrefix = "backup_v"
    private let currentMigrationVersion = 1

    private init() {}

    // MARK: - Migration Check

    /// Check if migration is needed
    var needsMigration: Bool {
        let currentVersion = UserDefaults.standard.integer(forKey: migrationVersionKey)
        return currentVersion < currentMigrationVersion
    }

    /// Get the last completed migration version
    var lastMigrationVersion: Int {
        return UserDefaults.standard.integer(forKey: migrationVersionKey)
    }

    // MARK: - Migration Execution

    /// Run all pending migrations
    func runMigrations() throws {
        let startVersion = lastMigrationVersion

        for version in (startVersion + 1)...currentMigrationVersion {
            try runMigration(version: version)
            UserDefaults.standard.set(version, forKey: migrationVersionKey)
        }
    }

    private func runMigration(version: Int) throws {
        switch version {
        case 1:
            try migrateToSyncableFormat()
        default:
            break
        }
    }

    // MARK: - Version 1: Convert to Syncable Format

    private func migrateToSyncableFormat() throws {
        // Create backup first
        try createBackup(version: 0)

        let persistence = PersistenceManager.shared
        let localStorage = LocalStorageManager.shared

        // Load existing data
        let savedCards = persistence.loadSavedCards()
        let masteredCards = persistence.loadMasteredCards()
        let flaggedCards = persistence.loadFlaggedCards()
        let consecutiveCorrect = persistence.loadConsecutiveCorrect()
        let spacedRepData = persistence.loadSpacedRepData()
        let userCards = persistence.loadUserCards()
        let studySets = persistence.loadStudySets()
        let userStats = persistence.loadUserStats()
        let cardNotes = persistence.loadCardNotes()
        let testHistory = persistence.loadTestHistory()

        // Mark all existing data as needing sync
        // This will cause first sync to upload everything to iCloud

        // Mark user progress
        localStorage.markDirty(CloudKitConfig.RecordType.userProgress, id: "main")
        localStorage.recordModification(CloudKitConfig.RecordType.userProgress, id: "main")

        // Mark each user card
        for card in userCards {
            localStorage.markDirty(CloudKitConfig.RecordType.userCard, id: card.id.uuidString)
            localStorage.recordModification(CloudKitConfig.RecordType.userCard, id: card.id.uuidString)
        }

        // Mark each study set
        for set in studySets {
            localStorage.markDirty(CloudKitConfig.RecordType.studySet, id: set.id.uuidString)
            localStorage.recordModification(CloudKitConfig.RecordType.studySet, id: set.id.uuidString)
        }

        // Mark user stats
        localStorage.markDirty(CloudKitConfig.RecordType.userStats, id: "main")
        localStorage.recordModification(CloudKitConfig.RecordType.userStats, id: "main")

        // Mark each card note
        for (cardID, _) in cardNotes {
            localStorage.markDirty(CloudKitConfig.RecordType.cardNote, id: cardID.uuidString)
            localStorage.recordModification(CloudKitConfig.RecordType.cardNote, id: cardID.uuidString)
        }

        // Mark each test result
        for result in testHistory {
            localStorage.markDirty(CloudKitConfig.RecordType.testResult, id: result.id.uuidString)
            localStorage.recordModification(CloudKitConfig.RecordType.testResult, id: result.id.uuidString)
        }

        print("Migration v1 complete: Marked \(userCards.count) cards, \(studySets.count) sets, \(cardNotes.count) notes, \(testHistory.count) test results for sync")
    }

    // MARK: - Backup

    /// Create a backup of current data
    func createBackup(version: Int) throws {
        let persistence = PersistenceManager.shared
        let backupKey = "\(backupPrefix)\(version)"

        // Create a backup dictionary with all data (JSON-compatible types only)
        var backup: [String: Any] = [:]

        backup["savedCards"] = persistence.loadSavedCards().map { $0.uuidString }
        backup["masteredCards"] = persistence.loadMasteredCards().map { $0.uuidString }
        backup["flaggedCards"] = persistence.loadFlaggedCards().map { $0.uuidString }

        // Convert Data to Base64 strings for JSON compatibility
        if let consecutiveData = try? JSONEncoder().encode(persistence.loadConsecutiveCorrect()) {
            backup["consecutiveCorrect"] = consecutiveData.base64EncodedString()
        }

        if let spacedData = try? JSONEncoder().encode(persistence.loadSpacedRepData()) {
            backup["spacedRepData"] = spacedData.base64EncodedString()
        }

        if let userCardsData = try? JSONEncoder().encode(persistence.loadUserCards()) {
            backup["userCards"] = userCardsData.base64EncodedString()
        }

        if let studySetsData = try? JSONEncoder().encode(persistence.loadStudySets()) {
            backup["studySets"] = studySetsData.base64EncodedString()
        }

        if let statsData = try? JSONEncoder().encode(persistence.loadUserStats()) {
            backup["userStats"] = statsData.base64EncodedString()
        }

        if let notesData = try? JSONEncoder().encode(persistence.loadCardNotes()) {
            backup["cardNotes"] = notesData.base64EncodedString()
        }

        if let historyData = try? JSONEncoder().encode(persistence.loadTestHistory()) {
            backup["testHistory"] = historyData.base64EncodedString()
        }

        // Convert Date to timestamp for JSON compatibility
        backup["timestamp"] = Date().timeIntervalSince1970

        // Save backup
        if let backupData = try? JSONSerialization.data(withJSONObject: backup) {
            UserDefaults.standard.set(backupData, forKey: backupKey)
        }
    }

    /// Restore from a backup
    func restoreFromBackup(version: Int) throws {
        let backupKey = "\(backupPrefix)\(version)"

        guard let backupData = UserDefaults.standard.data(forKey: backupKey),
              let backup = try? JSONSerialization.jsonObject(with: backupData) as? [String: Any] else {
            throw MigrationError.backupNotFound
        }

        let persistence = PersistenceManager.shared

        // Restore saved cards
        if let savedStrings = backup["savedCards"] as? [String] {
            let savedIDs = Set(savedStrings.compactMap { UUID(uuidString: $0) })
            persistence.saveSavedCards(savedIDs)
        }

        // Restore mastered cards
        if let masteredStrings = backup["masteredCards"] as? [String] {
            let masteredIDs = Set(masteredStrings.compactMap { UUID(uuidString: $0) })
            persistence.saveMasteredCards(masteredIDs)
        }

        // Restore flagged cards
        if let flaggedStrings = backup["flaggedCards"] as? [String] {
            let flaggedIDs = Set(flaggedStrings.compactMap { UUID(uuidString: $0) })
            persistence.saveFlaggedCards(flaggedIDs)
        }

        // Restore consecutive correct (decode from Base64)
        if let base64String = backup["consecutiveCorrect"] as? String,
           let data = Data(base64Encoded: base64String),
           let consecutive = try? JSONDecoder().decode([UUID: Int].self, from: data) {
            persistence.saveConsecutiveCorrect(consecutive)
        }

        // Restore spaced rep data
        if let base64String = backup["spacedRepData"] as? String,
           let data = Data(base64Encoded: base64String),
           let spacedRep = try? JSONDecoder().decode([UUID: SpacedRepetitionData].self, from: data) {
            persistence.saveSpacedRepData(spacedRep)
        }

        // Restore user cards
        if let base64String = backup["userCards"] as? String,
           let data = Data(base64Encoded: base64String),
           let cards = try? JSONDecoder().decode([Flashcard].self, from: data) {
            persistence.saveUserCards(cards)
        }

        // Restore study sets
        if let base64String = backup["studySets"] as? String,
           let data = Data(base64Encoded: base64String),
           let sets = try? JSONDecoder().decode([StudySet].self, from: data) {
            persistence.saveStudySets(sets)
        }

        // Restore user stats
        if let base64String = backup["userStats"] as? String,
           let data = Data(base64Encoded: base64String),
           let stats = try? JSONDecoder().decode(UserStats.self, from: data) {
            persistence.saveUserStats(stats)
        }

        // Restore card notes
        if let base64String = backup["cardNotes"] as? String,
           let data = Data(base64Encoded: base64String),
           let notes = try? JSONDecoder().decode([UUID: CardNote].self, from: data) {
            persistence.saveCardNotes(notes)
        }

        // Restore test history
        if let base64String = backup["testHistory"] as? String,
           let data = Data(base64Encoded: base64String),
           let history = try? JSONDecoder().decode([TestResult].self, from: data) {
            persistence.saveTestHistory(history)
        }
    }

    /// Check if a backup exists
    func hasBackup(version: Int) -> Bool {
        let backupKey = "\(backupPrefix)\(version)"
        return UserDefaults.standard.data(forKey: backupKey) != nil
    }

    /// Delete a backup
    func deleteBackup(version: Int) {
        let backupKey = "\(backupPrefix)\(version)"
        UserDefaults.standard.removeObject(forKey: backupKey)
    }
}

// MARK: - Migration Errors

enum MigrationError: Error, LocalizedError {
    case backupNotFound
    case migrationFailed(String)
    case restoreFailed(String)

    var errorDescription: String? {
        switch self {
        case .backupNotFound:
            return "Backup not found"
        case .migrationFailed(let reason):
            return "Migration failed: \(reason)"
        case .restoreFailed(let reason):
            return "Restore failed: \(reason)"
        }
    }
}
