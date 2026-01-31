//
//  iCloudSyncManager.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation
import CloudKit
import Combine

/// Manages CloudKit operations for iCloud sync
@MainActor
class iCloudSyncManager: ObservableObject {
    static let shared = iCloudSyncManager()

    @Published private(set) var iCloudStatus: CKAccountStatus = .couldNotDetermine
    @Published private(set) var isAvailable = false
    @Published private(set) var isSyncing = false
    @Published private(set) var lastError: Error?
    @Published private(set) var entitlementsConfigured = false

    private var container: CKContainer { CloudKitConfig.container }
    private var database: CKDatabase { CloudKitConfig.privateDatabase }
    private var zoneID: CKRecordZone.ID { CloudKitConfig.zoneID }

    private var zoneCreated = false
    private var subscriptionsCreated = false

    private init() {
        // Don't automatically check - wait until explicitly requested
        // This prevents crashes when entitlements aren't configured
    }

    /// Call this to initialize CloudKit (only when entitlements are properly set up)
    func initializeIfNeeded() async {
        guard !entitlementsConfigured else { return }
        await checkAccountStatus()
    }

    // MARK: - Account Status

    func checkAccountStatus() async {
        do {
            let status = try await container.accountStatus()
            iCloudStatus = status
            isAvailable = status == .available
            entitlementsConfigured = true

            if isAvailable && !zoneCreated {
                await setupZone()
            }
        } catch {
            iCloudStatus = .couldNotDetermine
            isAvailable = false
            lastError = error

            // Check if this is an entitlements error
            let errorString = error.localizedDescription.lowercased()
            if errorString.contains("entitlement") || errorString.contains("icloud-services") {
                entitlementsConfigured = false
                #if DEBUG
                print("⚠️ CloudKit entitlements not configured. iCloud sync disabled.")
                #endif
            }
        }
    }

    // MARK: - Zone Setup

    private func setupZone() async {
        guard !zoneCreated else { return }

        let zone = CKRecordZone(zoneID: zoneID)
        do {
            _ = try await database.modifyRecordZones(saving: [zone], deleting: [])
            zoneCreated = true

            if !subscriptionsCreated {
                await setupSubscriptions()
            }
        } catch {
            // Zone might already exist
            if let ckError = error as? CKError, ckError.code == .serverRecordChanged {
                zoneCreated = true
            } else {
                lastError = error
            }
        }
    }

    // MARK: - Subscriptions

    private func setupSubscriptions() async {
        guard !subscriptionsCreated else { return }

        let recordTypes = [
            CloudKitConfig.RecordType.userProgress,
            CloudKitConfig.RecordType.userCard,
            CloudKitConfig.RecordType.studySet,
            CloudKitConfig.RecordType.userStats,
            CloudKitConfig.RecordType.cardNote,
            CloudKitConfig.RecordType.testResult
        ]

        for recordType in recordTypes {
            let subscriptionID = "subscription-\(recordType)"
            let subscription = CKRecordZoneSubscription(zoneID: zoneID, subscriptionID: subscriptionID)

            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo

            do {
                _ = try await database.modifySubscriptions(saving: [subscription], deleting: [])
            } catch {
                // Subscription might already exist, that's okay
                #if DEBUG
                print("Subscription setup error for \(recordType): \(error)")
                #endif
            }
        }

        subscriptionsCreated = true
    }

    // MARK: - Save Records

    func saveRecord(_ record: CKRecord) async throws {
        guard isAvailable else {
            throw SyncError.iCloudNotAvailable
        }

        isSyncing = true
        defer { isSyncing = false }

        do {
            _ = try await database.save(record)
        } catch let error as CKError {
            if error.code == .serverRecordChanged {
                // Handle conflict - server record was modified
                throw SyncError.conflictDetected(serverRecord: error.serverRecord)
            }
            throw error
        }
    }

    func saveRecords(_ records: [CKRecord]) async throws {
        guard isAvailable else {
            throw SyncError.iCloudNotAvailable
        }

        guard !records.isEmpty else { return }

        isSyncing = true
        defer { isSyncing = false }

        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInitiated

        return try await withCheckedThrowingContinuation { continuation in
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            database.add(operation)
        }
    }

    // MARK: - Fetch Records

    func fetchRecord(recordType: String, recordID: String) async throws -> CKRecord? {
        guard isAvailable else {
            throw SyncError.iCloudNotAvailable
        }

        let ckRecordID = CKRecord.ID(recordName: recordID, zoneID: zoneID)

        do {
            return try await database.record(for: ckRecordID)
        } catch let error as CKError {
            if error.code == .unknownItem {
                return nil
            }
            throw error
        }
    }

    func fetchAllRecords(recordType: String) async throws -> [CKRecord] {
        guard isAvailable else {
            throw SyncError.iCloudNotAvailable
        }

        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))

        var allRecords: [CKRecord] = []
        var cursor: CKQueryOperation.Cursor?

        repeat {
            let (results, nextCursor) = try await fetchBatch(query: query, cursor: cursor)
            allRecords.append(contentsOf: results)
            cursor = nextCursor
        } while cursor != nil

        return allRecords
    }

    private func fetchBatch(query: CKQuery, cursor: CKQueryOperation.Cursor?) async throws -> ([CKRecord], CKQueryOperation.Cursor?) {
        return try await withCheckedThrowingContinuation { continuation in
            var records: [CKRecord] = []
            var nextCursor: CKQueryOperation.Cursor?

            let operation: CKQueryOperation
            if let cursor = cursor {
                operation = CKQueryOperation(cursor: cursor)
            } else {
                operation = CKQueryOperation(query: query)
            }

            operation.zoneID = zoneID
            operation.resultsLimit = 100

            operation.recordMatchedBlock = { _, result in
                if case .success(let record) = result {
                    records.append(record)
                }
            }

            operation.queryResultBlock = { result in
                switch result {
                case .success(let cursor):
                    nextCursor = cursor
                    continuation.resume(returning: (records, nextCursor))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            database.add(operation)
        }
    }

    // MARK: - Fetch Changes

    func fetchChanges(since token: CKServerChangeToken?) async throws -> (records: [CKRecord], deletedRecordIDs: [CKRecord.ID], newToken: CKServerChangeToken?) {
        guard isAvailable else {
            throw SyncError.iCloudNotAvailable
        }

        var changedRecords: [CKRecord] = []
        var deletedRecordIDs: [CKRecord.ID] = []
        var newToken: CKServerChangeToken?

        let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        configuration.previousServerChangeToken = token

        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], configurationsByRecordZoneID: [zoneID: configuration])

        operation.recordWasChangedBlock = { _, result in
            if case .success(let record) = result {
                changedRecords.append(record)
            }
        }

        operation.recordWithIDWasDeletedBlock = { recordID, _ in
            deletedRecordIDs.append(recordID)
        }

        operation.recordZoneChangeTokensUpdatedBlock = { _, token, _ in
            newToken = token
        }

        operation.recordZoneFetchResultBlock = { (_: CKRecordZone.ID, result: Result<(serverChangeToken: CKServerChangeToken, clientChangeTokenData: Data?, moreComing: Bool), Error>) in
            if case .success(let data) = result {
                newToken = data.serverChangeToken
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            operation.fetchRecordZoneChangesResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume(returning: (changedRecords, deletedRecordIDs, newToken))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            database.add(operation)
        }
    }

    // MARK: - Delete Records

    func deleteRecord(recordID: CKRecord.ID) async throws {
        guard isAvailable else {
            throw SyncError.iCloudNotAvailable
        }

        isSyncing = true
        defer { isSyncing = false }

        try await database.deleteRecord(withID: recordID)
    }

    func deleteRecords(_ recordIDs: [CKRecord.ID]) async throws {
        guard isAvailable else {
            throw SyncError.iCloudNotAvailable
        }

        guard !recordIDs.isEmpty else { return }

        isSyncing = true
        defer { isSyncing = false }

        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        operation.qualityOfService = .userInitiated

        return try await withCheckedThrowingContinuation { continuation in
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            database.add(operation)
        }
    }

    // MARK: - Record Creation Helpers

    func createRecord(type: String, id: String) -> CKRecord {
        let recordID = CKRecord.ID(recordName: id, zoneID: zoneID)
        return CKRecord(recordType: type, recordID: recordID)
    }
}

// MARK: - Error Types

enum SyncError: Error, LocalizedError {
    case iCloudNotAvailable
    case conflictDetected(serverRecord: CKRecord?)
    case encodingFailed
    case decodingFailed
    case recordNotFound
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .iCloudNotAvailable:
            return "iCloud is not available. Please sign in to iCloud in Settings."
        case .conflictDetected:
            return "A sync conflict was detected. The most recent changes will be kept."
        case .encodingFailed:
            return "Failed to encode data for sync."
        case .decodingFailed:
            return "Failed to decode synced data."
        case .recordNotFound:
            return "The requested record was not found."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
