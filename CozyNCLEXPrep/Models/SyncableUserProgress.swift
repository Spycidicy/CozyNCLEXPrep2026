//
//  SyncableUserProgress.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation
import CloudKit

/// Wrapper for user progress data with sync metadata
struct SyncableUserProgress: Codable {
    var masteredCardIDs: Set<UUID>
    var savedCardIDs: Set<UUID>
    var flaggedCardIDs: Set<UUID>
    var consecutiveCorrect: [UUID: Int]
    var spacedRepData: [UUID: SpacedRepetitionData]
    var lastModified: Date

    init(
        masteredCardIDs: Set<UUID> = [],
        savedCardIDs: Set<UUID> = [],
        flaggedCardIDs: Set<UUID> = [],
        consecutiveCorrect: [UUID: Int] = [:],
        spacedRepData: [UUID: SpacedRepetitionData] = [:],
        lastModified: Date = Date()
    ) {
        self.masteredCardIDs = masteredCardIDs
        self.savedCardIDs = savedCardIDs
        self.flaggedCardIDs = flaggedCardIDs
        self.consecutiveCorrect = consecutiveCorrect
        self.spacedRepData = spacedRepData
        self.lastModified = lastModified
    }

    // MARK: - CloudKit Conversion

    func toCKRecord(recordID: CKRecord.ID) -> CKRecord {
        let record = CKRecord(recordType: CloudKitConfig.RecordType.userProgress, recordID: recordID)

        record[CloudKitConfig.Fields.masteredCardIDs] = masteredCardIDs.map { $0.uuidString } as [String]
        record[CloudKitConfig.Fields.savedCardIDs] = savedCardIDs.map { $0.uuidString } as [String]
        record[CloudKitConfig.Fields.flaggedCardIDs] = flaggedCardIDs.map { $0.uuidString } as [String]

        if let consecutiveData = try? JSONEncoder().encode(consecutiveCorrect) {
            record[CloudKitConfig.Fields.consecutiveCorrect] = consecutiveData
        }

        if let spacedData = try? JSONEncoder().encode(spacedRepData) {
            record[CloudKitConfig.Fields.spacedRepData] = spacedData
        }

        record[CloudKitConfig.Fields.lastModified] = lastModified

        return record
    }

    static func from(record: CKRecord) -> SyncableUserProgress? {
        let masteredStrings = record[CloudKitConfig.Fields.masteredCardIDs] as? [String] ?? []
        let savedStrings = record[CloudKitConfig.Fields.savedCardIDs] as? [String] ?? []
        let flaggedStrings = record[CloudKitConfig.Fields.flaggedCardIDs] as? [String] ?? []

        let masteredIDs = Set(masteredStrings.compactMap { UUID(uuidString: $0) })
        let savedIDs = Set(savedStrings.compactMap { UUID(uuidString: $0) })
        let flaggedIDs = Set(flaggedStrings.compactMap { UUID(uuidString: $0) })

        var consecutiveCorrect: [UUID: Int] = [:]
        if let data = record[CloudKitConfig.Fields.consecutiveCorrect] as? Data {
            consecutiveCorrect = (try? JSONDecoder().decode([UUID: Int].self, from: data)) ?? [:]
        }

        var spacedRepData: [UUID: SpacedRepetitionData] = [:]
        if let data = record[CloudKitConfig.Fields.spacedRepData] as? Data {
            spacedRepData = (try? JSONDecoder().decode([UUID: SpacedRepetitionData].self, from: data)) ?? [:]
        }

        let lastModified = record[CloudKitConfig.Fields.lastModified] as? Date ?? Date()

        return SyncableUserProgress(
            masteredCardIDs: masteredIDs,
            savedCardIDs: savedIDs,
            flaggedCardIDs: flaggedIDs,
            consecutiveCorrect: consecutiveCorrect,
            spacedRepData: spacedRepData,
            lastModified: lastModified
        )
    }

    // MARK: - Merge Strategy

    /// Merge with another progress using union for sets, max for counters
    func merged(with other: SyncableUserProgress) -> SyncableUserProgress {
        // Union for card ID sets (don't lose any mastered/saved/flagged cards)
        let mergedMastered = masteredCardIDs.union(other.masteredCardIDs)
        let mergedSaved = savedCardIDs.union(other.savedCardIDs)
        let mergedFlagged = flaggedCardIDs.union(other.flaggedCardIDs)

        // For consecutive correct, take the higher value
        var mergedConsecutive = consecutiveCorrect
        for (id, count) in other.consecutiveCorrect {
            mergedConsecutive[id] = max(mergedConsecutive[id] ?? 0, count)
        }

        // For spaced rep data, use the one with the higher repetition count
        var mergedSpacedRep = spacedRepData
        for (id, data) in other.spacedRepData {
            if let existing = mergedSpacedRep[id] {
                if data.repetitions > existing.repetitions {
                    mergedSpacedRep[id] = data
                }
            } else {
                mergedSpacedRep[id] = data
            }
        }

        return SyncableUserProgress(
            masteredCardIDs: mergedMastered,
            savedCardIDs: mergedSaved,
            flaggedCardIDs: mergedFlagged,
            consecutiveCorrect: mergedConsecutive,
            spacedRepData: mergedSpacedRep,
            lastModified: max(lastModified, other.lastModified)
        )
    }
}
