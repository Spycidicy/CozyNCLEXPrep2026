//
//  LocalStorageManager.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation

/// Wraps UserDefaults with sync metadata tracking
class LocalStorageManager {
    static let shared = LocalStorageManager()

    private let defaults = UserDefaults.standard

    // MARK: - Sync Metadata Keys
    private let dirtyRecordsKey = "syncDirtyRecords"
    private let lastSyncTimestampKey = "lastSyncTimestamp"
    private let modificationTimestampsKey = "modificationTimestamps"
    private let pendingUploadsKey = "pendingUploads"
    private let syncEnabledKey = "iCloudSyncEnabled"

    private init() {}

    // MARK: - Sync Enabled

    var isSyncEnabled: Bool {
        get { defaults.bool(forKey: syncEnabledKey) }
        set { defaults.set(newValue, forKey: syncEnabledKey) }
    }

    // MARK: - Dirty Record Tracking

    /// Mark a record as needing sync
    func markDirty(_ recordType: String, id: String) {
        var dirty = getDirtyRecords()
        var ids = dirty[recordType] ?? []
        if !ids.contains(id) {
            ids.append(id)
            dirty[recordType] = ids
            saveDirtyRecords(dirty)
        }
    }

    /// Clear dirty flag for a record
    func clearDirty(_ recordType: String, id: String) {
        var dirty = getDirtyRecords()
        if var ids = dirty[recordType] {
            ids.removeAll { $0 == id }
            dirty[recordType] = ids
            saveDirtyRecords(dirty)
        }
    }

    /// Clear all dirty flags for a record type
    func clearAllDirty(_ recordType: String) {
        var dirty = getDirtyRecords()
        dirty.removeValue(forKey: recordType)
        saveDirtyRecords(dirty)
    }

    /// Get all dirty records by type
    func getDirtyRecords() -> [String: [String]] {
        guard let data = defaults.data(forKey: dirtyRecordsKey),
              let dirty = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return [:]
        }
        return dirty
    }

    /// Check if there are any pending sync operations
    var hasPendingSync: Bool {
        let dirty = getDirtyRecords()
        return dirty.values.contains { !$0.isEmpty }
    }

    private func saveDirtyRecords(_ dirty: [String: [String]]) {
        if let data = try? JSONEncoder().encode(dirty) {
            defaults.set(data, forKey: dirtyRecordsKey)
        }
    }

    // MARK: - Modification Timestamps

    /// Record modification time for a record
    func recordModification(_ recordType: String, id: String, date: Date = Date()) {
        var timestamps = getModificationTimestamps()
        let key = "\(recordType):\(id)"
        timestamps[key] = date
        saveModificationTimestamps(timestamps)
    }

    /// Get modification time for a record
    func getModificationDate(_ recordType: String, id: String) -> Date? {
        let key = "\(recordType):\(id)"
        return getModificationTimestamps()[key]
    }

    private func getModificationTimestamps() -> [String: Date] {
        guard let data = defaults.data(forKey: modificationTimestampsKey),
              let timestamps = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return [:]
        }
        return timestamps
    }

    private func saveModificationTimestamps(_ timestamps: [String: Date]) {
        if let data = try? JSONEncoder().encode(timestamps) {
            defaults.set(data, forKey: modificationTimestampsKey)
        }
    }

    // MARK: - Last Sync Timestamp

    var lastSyncTimestamp: Date? {
        get {
            guard let timestamp = defaults.object(forKey: lastSyncTimestampKey) as? TimeInterval else {
                return nil
            }
            return Date(timeIntervalSince1970: timestamp)
        }
        set {
            if let date = newValue {
                defaults.set(date.timeIntervalSince1970, forKey: lastSyncTimestampKey)
            } else {
                defaults.removeObject(forKey: lastSyncTimestampKey)
            }
        }
    }

    // MARK: - Pending Uploads Queue

    /// Add a pending upload operation
    func queueUpload(_ operation: PendingUpload) {
        var pending = getPendingUploads()
        pending.append(operation)
        savePendingUploads(pending)
    }

    /// Remove a pending upload operation
    func dequeueUpload(_ id: String) {
        var pending = getPendingUploads()
        pending.removeAll { $0.id == id }
        savePendingUploads(pending)
    }

    /// Get all pending uploads
    func getPendingUploads() -> [PendingUpload] {
        guard let data = defaults.data(forKey: pendingUploadsKey),
              let pending = try? JSONDecoder().decode([PendingUpload].self, from: data) else {
            return []
        }
        return pending
    }

    private func savePendingUploads(_ pending: [PendingUpload]) {
        if let data = try? JSONEncoder().encode(pending) {
            defaults.set(data, forKey: pendingUploadsKey)
        }
    }

    // MARK: - Reset

    /// Clear all sync metadata
    func clearSyncMetadata() {
        defaults.removeObject(forKey: dirtyRecordsKey)
        defaults.removeObject(forKey: lastSyncTimestampKey)
        defaults.removeObject(forKey: modificationTimestampsKey)
        defaults.removeObject(forKey: pendingUploadsKey)
    }
}

// MARK: - Supporting Types

struct PendingUpload: Codable, Identifiable {
    let id: String
    let recordType: String
    let recordID: String
    let operation: UploadOperation
    let data: Data
    let queuedAt: Date

    init(recordType: String, recordID: String, operation: UploadOperation, data: Data) {
        self.id = UUID().uuidString
        self.recordType = recordType
        self.recordID = recordID
        self.operation = operation
        self.data = data
        self.queuedAt = Date()
    }
}

enum UploadOperation: String, Codable {
    case create
    case update
    case delete
}
