//
//  SyncableUserCard.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation
import CloudKit

/// Wrapper for user-created cards with sync metadata
struct SyncableUserCard: Codable, Identifiable {
    let id: UUID
    var question: String
    var answer: String
    var wrongAnswers: [String]
    var rationale: String
    var contentCategory: String
    var nclexCategory: String
    var difficulty: String
    var questionType: String
    var isDeleted: Bool
    var createdAt: Date
    var lastModified: Date

    init(from flashcard: Flashcard, isDeleted: Bool = false) {
        self.id = flashcard.id
        self.question = flashcard.question
        self.answer = flashcard.answer
        self.wrongAnswers = flashcard.wrongAnswers
        self.rationale = flashcard.rationale
        self.contentCategory = flashcard.contentCategory.rawValue
        self.nclexCategory = flashcard.nclexCategory.rawValue
        self.difficulty = flashcard.difficulty.rawValue
        self.questionType = flashcard.questionType.rawValue
        self.isDeleted = isDeleted
        self.createdAt = Date()
        self.lastModified = Date()
    }

    init(
        id: UUID,
        question: String,
        answer: String,
        wrongAnswers: [String],
        rationale: String,
        contentCategory: String,
        nclexCategory: String,
        difficulty: String,
        questionType: String,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        lastModified: Date = Date()
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.wrongAnswers = wrongAnswers
        self.rationale = rationale
        self.contentCategory = contentCategory
        self.nclexCategory = nclexCategory
        self.difficulty = difficulty
        self.questionType = questionType
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.lastModified = lastModified
    }

    // MARK: - Conversion

    func toFlashcard() -> Flashcard? {
        guard !isDeleted else { return nil }

        guard let category = ContentCategory(rawValue: contentCategory),
              let nclex = NCLEXCategory(rawValue: nclexCategory),
              let diff = Difficulty(rawValue: difficulty),
              let type = QuestionType(rawValue: questionType) else {
            return nil
        }

        return Flashcard(
            id: id,
            question: question,
            answer: answer,
            wrongAnswers: wrongAnswers,
            rationale: rationale,
            contentCategory: category,
            nclexCategory: nclex,
            difficulty: diff,
            questionType: type,
            isPremium: false,
            isUserCreated: true
        )
    }

    // MARK: - CloudKit Conversion

    func toCKRecord(recordID: CKRecord.ID) -> CKRecord {
        let record = CKRecord(recordType: CloudKitConfig.RecordType.userCard, recordID: recordID)

        record[CloudKitConfig.Fields.question] = question
        record[CloudKitConfig.Fields.answer] = answer
        record[CloudKitConfig.Fields.wrongAnswers] = wrongAnswers as [String]
        record[CloudKitConfig.Fields.rationale] = rationale
        record[CloudKitConfig.Fields.contentCategory] = contentCategory
        record[CloudKitConfig.Fields.nclexCategory] = nclexCategory
        record[CloudKitConfig.Fields.difficulty] = difficulty
        record[CloudKitConfig.Fields.questionType] = questionType
        record[CloudKitConfig.Fields.isDeleted] = isDeleted ? 1 : 0
        record[CloudKitConfig.Fields.createdDate] = createdAt
        record[CloudKitConfig.Fields.lastModified] = lastModified

        return record
    }

    static func from(record: CKRecord) -> SyncableUserCard? {
        guard let id = UUID(uuidString: record.recordID.recordName),
              let question = record[CloudKitConfig.Fields.question] as? String,
              let answer = record[CloudKitConfig.Fields.answer] as? String else {
            return nil
        }

        let wrongAnswers = record[CloudKitConfig.Fields.wrongAnswers] as? [String] ?? []
        let rationale = record[CloudKitConfig.Fields.rationale] as? String ?? ""
        let contentCategory = record[CloudKitConfig.Fields.contentCategory] as? String ?? "Fundamentals"
        let nclexCategory = record[CloudKitConfig.Fields.nclexCategory] as? String ?? "Physiological Integrity"
        let difficulty = record[CloudKitConfig.Fields.difficulty] as? String ?? "Medium"
        let questionType = record[CloudKitConfig.Fields.questionType] as? String ?? "Multiple Choice"
        let isDeleted = (record[CloudKitConfig.Fields.isDeleted] as? Int ?? 0) == 1
        let createdAt = record[CloudKitConfig.Fields.createdDate] as? Date ?? Date()
        let lastModified = record[CloudKitConfig.Fields.lastModified] as? Date ?? Date()

        return SyncableUserCard(
            id: id,
            question: question,
            answer: answer,
            wrongAnswers: wrongAnswers,
            rationale: rationale,
            contentCategory: contentCategory,
            nclexCategory: nclexCategory,
            difficulty: difficulty,
            questionType: questionType,
            isDeleted: isDeleted,
            createdAt: createdAt,
            lastModified: lastModified
        )
    }

    // MARK: - Merge Strategy (Last Write Wins)

    func merged(with other: SyncableUserCard) -> SyncableUserCard {
        // Last write wins - return the one with the later modification date
        if lastModified >= other.lastModified {
            return self
        } else {
            return other
        }
    }
}
