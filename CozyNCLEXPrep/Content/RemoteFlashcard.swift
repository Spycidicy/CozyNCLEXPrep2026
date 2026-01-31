//
//  RemoteFlashcard.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation

/// Model for flashcards fetched from Supabase
struct RemoteFlashcard: Codable, Identifiable {
    let id: UUID
    let question: String
    let answer: String
    let wrongAnswers: [String]
    let rationale: String?
    let contentCategory: String
    let nclexCategory: String
    let difficulty: String
    let questionType: String
    let isPremium: Bool
    let isActive: Bool
    let version: String
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case question
        case answer
        case wrongAnswers = "wrong_answers"
        case rationale
        case contentCategory = "content_category"
        case nclexCategory = "nclex_category"
        case difficulty
        case questionType = "question_type"
        case isPremium = "is_premium"
        case isActive = "is_active"
        case version
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// Convert to local Flashcard model
    func toFlashcard() -> Flashcard? {
        // Try to convert each enum with flexible matching
        guard let contentCat = ContentCategory.fromDatabaseValue(contentCategory) else {
            #if DEBUG
            print("❌ Failed to convert contentCategory: '\(contentCategory)'")
            #endif
            return nil
        }

        guard let nclexCat = NCLEXCategory.fromDatabaseValue(nclexCategory) else {
            #if DEBUG
            print("❌ Failed to convert nclexCategory: '\(nclexCategory)'")
            #endif
            return nil
        }

        guard let diff = Difficulty.fromDatabaseValue(difficulty) else {
            #if DEBUG
            print("❌ Failed to convert difficulty: '\(difficulty)'")
            #endif
            return nil
        }

        guard let qType = QuestionType.fromDatabaseValue(questionType) else {
            #if DEBUG
            print("❌ Failed to convert questionType: '\(questionType)'")
            #endif
            return nil
        }

        return Flashcard(
            id: id,
            question: question,
            answer: answer,
            wrongAnswers: wrongAnswers,
            rationale: rationale ?? "",
            contentCategory: contentCat,
            nclexCategory: nclexCat,
            difficulty: diff,
            questionType: qType,
            isPremium: isPremium,
            isUserCreated: false
        )
    }
}

/// Model for content version tracking
struct ContentVersion: Codable, Identifiable {
    let id: UUID
    let version: String
    let publishedAt: Date?
    let isCurrent: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case version
        case publishedAt = "published_at"
        case isCurrent = "is_current"
    }
}
