//
//  SyncManager.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation
import CloudKit
import Combine

/// Orchestrates sync operations between local storage and iCloud
@MainActor
class SyncManager: ObservableObject {
    static let shared = SyncManager()

    @Published private(set) var syncState: SyncState = .idle
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var pendingChangesCount: Int = 0
    @Published private(set) var syncError: Error?
    @Published var isSyncEnabled: Bool {
        didSet {
            LocalStorageManager.shared.isSyncEnabled = isSyncEnabled
            if isSyncEnabled {
                Task { await performSync() }
            }
        }
    }

    private let iCloudManager = iCloudSyncManager.shared
    private let localStorage = LocalStorageManager.shared

    private var changeTokenKey = "cloudKitChangeToken"
    private var syncTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        isSyncEnabled = localStorage.isSyncEnabled
        lastSyncDate = localStorage.lastSyncTimestamp
        updatePendingCount()

        // Don't auto-initialize CloudKit - wait until user enables sync
        // This prevents crashes when entitlements aren't configured
    }

    /// Initialize CloudKit sync (call when user enables sync or after checking entitlements)
    func initializeCloudKit() async {
        await iCloudManager.initializeIfNeeded()

        // Observe iCloud availability changes
        iCloudManager.$isAvailable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAvailable in
                if isAvailable && self?.isSyncEnabled == true {
                    Task { await self?.performSync() }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Sync Control

    /// Perform a full sync operation
    func performSync() async {
        guard isSyncEnabled else { return }
        guard iCloudManager.isAvailable else {
            syncError = SyncError.iCloudNotAvailable
            return
        }
        guard syncState != .syncing else { return }

        syncState = .syncing
        syncError = nil

        do {
            // 1. Push local changes to iCloud
            try await pushLocalChanges()

            // 2. Pull remote changes from iCloud
            try await pullRemoteChanges()

            // 3. Update sync metadata
            lastSyncDate = Date()
            localStorage.lastSyncTimestamp = lastSyncDate
            updatePendingCount()

            syncState = .idle
        } catch {
            syncError = error
            syncState = .error
        }
    }

    /// Trigger sync for a specific record type
    func syncRecordType(_ recordType: String) async {
        guard isSyncEnabled && iCloudManager.isAvailable else { return }

        do {
            try await pushChangesForType(recordType)
        } catch {
            syncError = error
        }
    }

    /// Handle remote notification
    func handleRemoteNotification() async {
        guard isSyncEnabled else { return }
        await performSync()
    }

    // MARK: - Push Changes

    private func pushLocalChanges() async throws {
        let dirtyRecords = localStorage.getDirtyRecords()

        for (recordType, ids) in dirtyRecords {
            for id in ids {
                try await pushRecord(type: recordType, id: id)
                localStorage.clearDirty(recordType, id: id)
            }
        }

        // Process pending uploads (queued when offline)
        let pendingUploads = localStorage.getPendingUploads()
        for upload in pendingUploads {
            try await processPendingUpload(upload)
            localStorage.dequeueUpload(upload.id)
        }
    }

    private func pushChangesForType(_ recordType: String) async throws {
        let dirtyRecords = localStorage.getDirtyRecords()
        guard let ids = dirtyRecords[recordType] else { return }

        for id in ids {
            try await pushRecord(type: recordType, id: id)
            localStorage.clearDirty(recordType, id: id)
        }
    }

    private func pushRecord(type: String, id: String) async throws {
        // This will be overridden to convert local data to CKRecord
        // For now, we'll create a simple implementation

        let record = iCloudManager.createRecord(type: type, id: id)
        record[CloudKitConfig.Fields.lastModified] = Date()

        try await iCloudManager.saveRecord(record)
    }

    private func processPendingUpload(_ upload: PendingUpload) async throws {
        switch upload.operation {
        case .create, .update:
            let record = iCloudManager.createRecord(type: upload.recordType, id: upload.recordID)
            // Decode and apply data to record
            try await iCloudManager.saveRecord(record)
        case .delete:
            let recordID = CKRecord.ID(recordName: upload.recordID, zoneID: CloudKitConfig.zoneID)
            try await iCloudManager.deleteRecord(recordID: recordID)
        }
    }

    // MARK: - Pull Changes

    private func pullRemoteChanges() async throws {
        let token = loadChangeToken()

        let (records, deletedIDs, newToken) = try await iCloudManager.fetchChanges(since: token)

        // Process changed records
        for record in records {
            await processRemoteRecord(record)
        }

        // Process deletions
        for recordID in deletedIDs {
            await processRemoteDeletion(recordID)
        }

        // Save new token
        if let newToken = newToken {
            saveChangeToken(newToken)
        }
    }

    private func processRemoteRecord(_ record: CKRecord) async {
        // Convert CKRecord to local model and merge
        // Implementation depends on record type
        let recordType = record.recordType

        switch recordType {
        case CloudKitConfig.RecordType.userProgress:
            await mergeUserProgress(from: record)
        case CloudKitConfig.RecordType.userCard:
            await mergeUserCard(from: record)
        case CloudKitConfig.RecordType.studySet:
            await mergeStudySet(from: record)
        case CloudKitConfig.RecordType.userStats:
            await mergeUserStats(from: record)
        case CloudKitConfig.RecordType.cardNote:
            await mergeCardNote(from: record)
        case CloudKitConfig.RecordType.testResult:
            await mergeTestResult(from: record)
        case CloudKitConfig.RecordType.userXP:
            await mergeUserXP(from: record)
        default:
            break
        }
    }

    private func processRemoteDeletion(_ recordID: CKRecord.ID) async {
        // Handle remote deletion
        // This needs to be implemented based on record type
    }

    // MARK: - Merge Operations (Last-Write-Wins + Union for sets)

    private func mergeUserProgress(from record: CKRecord) async {
        // Merge mastered, saved, flagged card IDs using union strategy
        // Later implementation will integrate with CardManager
    }

    private func mergeUserCard(from record: CKRecord) async {
        // Merge user-created cards using last-write-wins
    }

    private func mergeStudySet(from record: CKRecord) async {
        // Merge study sets using last-write-wins
    }

    private func mergeUserStats(from record: CKRecord) async {
        // Merge user stats - take max for counters, union for sessions
    }

    private func mergeCardNote(from record: CKRecord) async {
        // Merge card notes using last-write-wins
    }

    private func mergeTestResult(from record: CKRecord) async {
        // Merge test results - union (add any missing results)
    }

    private func mergeUserXP(from record: CKRecord) async {
        // Merge XP - take the higher value (user can only gain XP, not lose it)
        guard let remoteXP = record[CloudKitConfig.Fields.totalXP] as? Int else { return }

        let localXP = UserDefaults.standard.integer(forKey: "totalXP")

        if remoteXP > localXP {
            UserDefaults.standard.set(remoteXP, forKey: "totalXP")
            // Notify DailyGoalsManager to recalculate level
            await MainActor.run {
                DailyGoalsManager.shared.totalXP = remoteXP
                DailyGoalsManager.shared.calculateLevel()
            }
        }
    }

    // MARK: - Change Token Management

    private func loadChangeToken() -> CKServerChangeToken? {
        guard let data = UserDefaults.standard.data(forKey: changeTokenKey) else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
    }

    private func saveChangeToken(_ token: CKServerChangeToken) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) {
            UserDefaults.standard.set(data, forKey: changeTokenKey)
        }
    }

    // MARK: - Helpers

    private func updatePendingCount() {
        let dirty = localStorage.getDirtyRecords()
        pendingChangesCount = dirty.values.reduce(0) { $0 + $1.count }
        pendingChangesCount += localStorage.getPendingUploads().count
    }

    /// Mark local data as changed (call this when user makes changes)
    func markChanged(_ recordType: String, id: String) {
        localStorage.markDirty(recordType, id: id)
        localStorage.recordModification(recordType, id: id)
        updatePendingCount()

        // Debounce sync
        syncTask?.cancel()
        syncTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second debounce
            if !Task.isCancelled {
                await performSync()
            }
        }
    }

    /// Queue an upload for when we're back online
    func queueForLater(_ recordType: String, id: String, operation: UploadOperation, data: Data) {
        let upload = PendingUpload(recordType: recordType, recordID: id, operation: operation, data: data)
        localStorage.queueUpload(upload)
        updatePendingCount()
    }

    /// Reset all sync data
    func resetSync() {
        localStorage.clearSyncMetadata()
        UserDefaults.standard.removeObject(forKey: changeTokenKey)
        lastSyncDate = nil
        pendingChangesCount = 0
        syncState = .idle
        syncError = nil
    }
}

// MARK: - Sync State

enum SyncState: Equatable {
    case idle
    case syncing
    case error

    var description: String {
        switch self {
        case .idle: return "Synced"
        case .syncing: return "Syncing..."
        case .error: return "Sync Error"
        }
    }

    var icon: String {
        switch self {
        case .idle: return "checkmark.icloud"
        case .syncing: return "arrow.triangle.2.circlepath.icloud"
        case .error: return "exclamationmark.icloud"
        }
    }
}
