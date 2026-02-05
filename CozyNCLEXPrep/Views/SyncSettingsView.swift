//
//  SyncSettingsView.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import SwiftUI
import CloudKit

struct SyncSettingsView: View {
    @StateObject private var syncManager = SyncManager.shared
    @StateObject private var iCloudManager = iCloudSyncManager.shared
    @StateObject private var contentProvider = SupabaseContentProvider.shared
    @StateObject private var cloudSyncManager = CloudSyncManager.shared

    @State private var showingResetAlert = false
    @State private var showingMigrationAlert = false
    @State private var migrationError: Error?

    var body: some View {
        List {
            // MARK: - Cloud Sync Section (Supabase)
            Section {
                // Cloud Sync Status
                HStack {
                    Image(systemName: "cloud")
                        .foregroundColor(.purple)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cloud Sync")
                        if cloudSyncManager.isSyncing {
                            Text("Syncing...")
                                .font(.caption)
                                .foregroundColor(.blue)
                        } else if let lastSync = cloudSyncManager.lastSyncDate {
                            Text("Last synced: \(lastSync, formatter: Self.relativeDateFormatter)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Not synced yet")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    if cloudSyncManager.isSyncing {
                        ProgressView()
                    } else if cloudSyncManager.lastSyncDate != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }

                // Cloud Sync Error
                if let error = cloudSyncManager.syncError {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Sync Error")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                        Text(error)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(3)

                        if error.contains("row-level security") {
                            Text("Database policies may need to be refreshed. Try logging out and back in.")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }

                // Manual Cloud Sync Button
                Button {
                    Task {
                        await cloudSyncManager.syncAll()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sync Now")
                    }
                }
                .disabled(cloudSyncManager.isSyncing || !AuthManager.shared.isAuthenticated)

                // XP Display
                HStack {
                    Text("Total XP")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(DailyGoalsManager.shared.totalXP)")
                        .font(.system(.body, design: .rounded).bold())
                        .foregroundColor(.orange)
                }

                HStack {
                    Text("Level")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(DailyGoalsManager.shared.currentLevel)")
                        .font(.system(.body, design: .rounded).bold())
                        .foregroundColor(.purple)
                }
            } header: {
                Text("Cloud Sync")
            } footer: {
                Text("Syncs your XP, level, mastered cards, and progress across devices. Requires a CozyNCLEX account.")
            }

            // MARK: - iCloud Sync Section
            Section {
                // Sync Toggle
                Toggle(isOn: $syncManager.isSyncEnabled) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("iCloud Sync")
                            Text("Sync progress across devices")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "icloud")
                            .foregroundColor(.blue)
                    }
                }
                .disabled(!iCloudManager.isAvailable)

                // iCloud Status
                if !iCloudManager.isAvailable {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Sign in to iCloud in Settings to enable sync")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Sync Status
                if syncManager.isSyncEnabled {
                    HStack {
                        Image(systemName: syncManager.syncState.icon)
                            .foregroundColor(syncStateColor)
                            .symbolEffect(.pulse, isActive: syncManager.syncState == .syncing)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(syncManager.syncState.description)
                                .font(.subheadline)

                            if let lastSync = syncManager.lastSyncDate {
                                Text("Last synced: \(lastSync, formatter: Self.relativeDateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        if syncManager.pendingChangesCount > 0 {
                            Text("\(syncManager.pendingChangesCount) pending")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }

                    // Manual Sync Button
                    Button {
                        Task {
                            await syncManager.performSync()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Sync Now")
                        }
                    }
                    .disabled(syncManager.syncState == .syncing)
                }

                // Sync Error
                if let error = syncManager.syncError {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            } header: {
                Text("iCloud Sync")
            } footer: {
                Text("Your study progress, cards, and statistics will sync across all your devices signed into the same iCloud account.")
            }

            // MARK: - Content Updates Section
            Section {
                // Content Status
                HStack {
                    Image(systemName: "square.stack.3d.up")
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Question Database")
                        if let version = contentProvider.currentVersion {
                            Text("Version: \(version)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    if contentProvider.isLoading {
                        ProgressView()
                    } else if contentProvider.hasOfflineContent {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }

                // Last Content Sync
                if let lastSync = contentProvider.lastSyncDate {
                    HStack {
                        Text("Last updated")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(lastSync, formatter: Self.relativeDateFormatter)
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }

                // Refresh Content Button
                Button {
                    Task {
                        await contentProvider.forceRefresh()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Check for Updates")
                    }
                }
                .disabled(contentProvider.isLoading)

                // Cache Size
                HStack {
                    Text("Cache Size")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(contentProvider.cacheSizeString)
                        .foregroundColor(.secondary)
                }
                .font(.caption)

                // Clear Cache Button
                Button(role: .destructive) {
                    contentProvider.clearCache()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear Cache")
                    }
                }
            } header: {
                Text("Content")
            } footer: {
                Text("Questions are downloaded from the cloud so you always have the latest content. Cached content is available offline.")
            }

            // MARK: - Advanced Section
            Section {
                // Reset Sync
                Button(role: .destructive) {
                    showingResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Sync Data")
                    }
                }
            } header: {
                Text("Advanced")
            } footer: {
                Text("Resetting sync data will clear all sync metadata. Your local data will remain, but will be re-uploaded on the next sync.")
            }

            // MARK: - Debug Section (for testing)
            #if DEBUG
            Section {
                Button {
                    CoachMarkManager.shared.resetAll()
                    HapticManager.shared.success()
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Reset Tooltips (Test First-Time Experience)")
                    }
                }

                Button {
                    UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                    HapticManager.shared.success()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle")
                        Text("Reset Onboarding (Restart App to Test)")
                    }
                }
            } header: {
                Text("Debug")
            } footer: {
                Text("Reset tooltips to test the coach mark system. Reset onboarding and restart the app to test the intro slides.")
            }
            #endif
        }
        .navigationTitle("Sync Settings")
        .alert("Reset Sync Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                syncManager.resetSync()
            }
        } message: {
            Text("This will reset all sync metadata. Your data will remain, but will need to be re-synced.")
        }
        .alert("Migration Error", isPresented: $showingMigrationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = migrationError {
                Text(error.localizedDescription)
            }
        }
        .onAppear {
            Task {
                await iCloudManager.checkAccountStatus()
            }
        }
    }

    // MARK: - Helpers

    private var syncStateColor: Color {
        switch syncManager.syncState {
        case .idle: return .green
        case .syncing: return .blue
        case .error: return .red
        }
    }

    private static let relativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Sync Status Badge View

struct SyncStatusBadge: View {
    @ObservedObject var syncManager = SyncManager.shared

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: syncManager.syncState.icon)
                .font(.caption)
                .symbolEffect(.pulse, isActive: syncManager.syncState == .syncing)

            if syncManager.pendingChangesCount > 0 {
                Text("\(syncManager.pendingChangesCount)")
                    .font(.caption2)
            }
        }
        .foregroundColor(badgeColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(badgeColor.opacity(0.15))
        .cornerRadius(8)
    }

    private var badgeColor: Color {
        switch syncManager.syncState {
        case .idle: return .green
        case .syncing: return .blue
        case .error: return .red
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SyncSettingsView()
    }
}
