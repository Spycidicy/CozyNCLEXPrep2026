//
//  CloudKitConfig.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation
import CloudKit

struct CloudKitConfig {
    // MARK: - Container
    static let containerIdentifier = "iCloud.com.cozynclex.prep"

    // Lazy initialization to avoid crashes when entitlements aren't configured
    private static let _container = CKContainer(identifier: containerIdentifier)
    static var container: CKContainer {
        _container
    }

    static var privateDatabase: CKDatabase {
        container.privateCloudDatabase
    }

    // MARK: - Zone
    static let zoneName = "CozyNCLEXZone"
    static var zoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
    }

    // MARK: - Record Types
    struct RecordType {
        static let userProgress = "UserProgress"
        static let userCard = "UserCard"
        static let studySet = "StudySet"
        static let userStats = "UserStats"
        static let cardNote = "CardNote"
        static let testResult = "TestResult"
        static let userXP = "UserXP"
    }

    // MARK: - Subscription IDs
    struct SubscriptionID {
        static let userProgress = "userProgress-changes"
        static let userCard = "userCard-changes"
        static let studySet = "studySet-changes"
        static let userStats = "userStats-changes"
        static let cardNote = "cardNote-changes"
        static let testResult = "testResult-changes"
    }

    // MARK: - Field Names
    struct Fields {
        // UserProgress
        static let masteredCardIDs = "masteredCardIDs"
        static let savedCardIDs = "savedCardIDs"
        static let flaggedCardIDs = "flaggedCardIDs"
        static let consecutiveCorrect = "consecutiveCorrect"
        static let spacedRepData = "spacedRepData"

        // UserCard
        static let question = "question"
        static let answer = "answer"
        static let wrongAnswers = "wrongAnswers"
        static let rationale = "rationale"
        static let contentCategory = "contentCategory"
        static let nclexCategory = "nclexCategory"
        static let difficulty = "difficulty"
        static let questionType = "questionType"
        static let isDeleted = "isDeleted"

        // StudySet
        static let name = "name"
        static let cardIDs = "cardIDs"
        static let color = "color"
        static let createdDate = "createdDate"

        // UserStats
        static let totalCardsStudied = "totalCardsStudied"
        static let totalCorrectAnswers = "totalCorrectAnswers"
        static let totalTimeSpentSeconds = "totalTimeSpentSeconds"
        static let currentStreak = "currentStreak"
        static let longestStreak = "longestStreak"
        static let lastStudyDate = "lastStudyDate"
        static let categoryAccuracy = "categoryAccuracy"

        // CardNote
        static let cardID = "cardID"
        static let note = "note"
        static let modifiedDate = "modifiedDate"

        // TestResult
        static let date = "date"
        static let questionCount = "questionCount"
        static let correctCount = "correctCount"
        static let timeSpentSeconds = "timeSpentSeconds"
        static let categoryBreakdown = "categoryBreakdown"
        static let answers = "answers"

        // UserXP
        static let totalXP = "totalXP"
        static let dailyGoals = "dailyGoals"
        static let lastGoalDate = "lastGoalDate"

        // Common
        static let lastModified = "lastModified"
    }
}
