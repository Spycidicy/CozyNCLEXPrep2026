//
//  SupabaseContentProvider.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation
import Combine
import Supabase

/// Provides flashcard content from Supabase with local caching
@MainActor
class SupabaseContentProvider: ObservableObject {
    static let shared = SupabaseContentProvider()

    @Published private(set) var remoteCards: [Flashcard] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var error: ContentProviderError?
    @Published private(set) var currentVersion: String?

    private let cache = LocalContentCache.shared
    private let lastSyncKey = "lastContentSyncDate"

    private init() {
        // DEBUG: Clear cache to force fresh fetch
        #if DEBUG
        try? cache.clearCache()
        print("🗑️ Cache cleared for debugging")
        #endif

        loadFromCache()
        loadLastSyncDate()
    }

    // MARK: - Public Interface

    /// Load content - tries remote first, falls back to cache
    func loadContent() async {
        guard SupabaseConfig.isConfigured else {
            // Supabase not configured, use bundled cards only
            #if DEBUG
            print("⚠️ Supabase not configured, using bundled cards only")
            #endif
            return
        }

        #if DEBUG
        print("📡 Loading content from Supabase...")
        #endif
        isLoading = true
        error = nil

        do {
            // Check for updates
            let latestVersion = try await fetchCurrentVersion()
            #if DEBUG
            print("✅ Current version: \(latestVersion)")
            #endif

            if cache.needsUpdate(currentVersion: latestVersion) || remoteCards.isEmpty {
                // Fetch new content
                #if DEBUG
                print("📥 Fetching remote cards...")
                #endif
                let cards = try await fetchRemoteCards()
                #if DEBUG
                print("📥 Fetched \(cards.count) cards from Supabase")
                #endif

                let converted = cards.compactMap { $0.toFlashcard() }
                #if DEBUG
                print("✅ Converted \(converted.count) cards successfully")

                if converted.count < cards.count {
                    print("⚠️ \(cards.count - converted.count) cards failed to convert - check category values")
                    // Log unique failed categories for debugging
                    let failedCategories = Set(cards.compactMap { card -> String? in
                        if ContentCategory.fromDatabaseValue(card.contentCategory) == nil {
                            return card.contentCategory
                        }
                        return nil
                    })
                    if !failedCategories.isEmpty {
                        print("❌ Failed category values: \(failedCategories.sorted().joined(separator: ", "))")
                    }
                }

                // Log card distribution by category
                var categoryCount: [String: Int] = [:]
                for card in converted {
                    categoryCount[card.contentCategory.rawValue, default: 0] += 1
                }
                print("📊 Cards by category: \(categoryCount.sorted(by: { $0.key < $1.key }).map { "\($0.key): \($0.value)" }.joined(separator: ", "))")
                #endif

                remoteCards = converted

                // Cache the new content
                try cache.cacheFlashcards(cards)
                try cache.cacheVersion(latestVersion)

                currentVersion = latestVersion
            } else {
                #if DEBUG
                print("📦 Using cached content, version: \(currentVersion ?? "unknown")")
                #endif
            }

            lastSyncDate = Date()
            saveLastSyncDate()
            #if DEBUG
            print("✅ Content load complete. Total remote cards: \(remoteCards.count)")
            #endif

        } catch {
            #if DEBUG
            print("❌ Error loading content: \(error)")
            #endif
            self.error = ContentProviderError.from(error)
            // Content still available from cache if previously loaded
        }

        isLoading = false
    }

    /// Force refresh content from remote
    func forceRefresh() async {
        guard SupabaseConfig.isConfigured else { return }

        isLoading = true
        error = nil

        do {
            let cards = try await fetchRemoteCards()
            remoteCards = cards.compactMap { $0.toFlashcard() }

            let version = try await fetchCurrentVersion()
            try cache.cacheFlashcards(cards)
            try cache.cacheVersion(version)

            currentVersion = version
            lastSyncDate = Date()
            saveLastSyncDate()

        } catch {
            self.error = ContentProviderError.from(error)
        }

        isLoading = false
    }

    /// Check if there's an update available without downloading
    func checkForUpdate() async -> Bool {
        guard SupabaseConfig.isConfigured else { return false }

        do {
            let latestVersion = try await fetchCurrentVersion()
            return cache.needsUpdate(currentVersion: latestVersion)
        } catch {
            return false
        }
    }

    // MARK: - Private Methods

    private func loadFromCache() {
        remoteCards = cache.loadCachedAsFlashcards()
        currentVersion = cache.getCachedVersion()
    }

    private func fetchRemoteCards() async throws -> [RemoteFlashcard] {
        do {
            let response: [RemoteFlashcard] = try await SupabaseConfig.client
                .from(SupabaseConfig.Tables.nclexQuestions)
                .select()
                .eq("is_active", value: true)
                .order("created_at", ascending: true)
                .limit(1000)
                .execute()
                .value

            return response
        } catch let error as DecodingError {
            // Log specific decoding error details
            #if DEBUG
            switch error {
            case .typeMismatch(let type, let context):
                print("❌ Decoding typeMismatch: \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            case .valueNotFound(let type, let context):
                print("❌ Decoding valueNotFound: \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            case .keyNotFound(let key, let context):
                print("❌ Decoding keyNotFound: \(key.stringValue), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            case .dataCorrupted(let context):
                print("❌ Decoding dataCorrupted: \(context.debugDescription)")
            @unknown default:
                print("❌ Decoding unknown error: \(error)")
            }
            #endif
            throw error
        }
    }

    private func fetchCurrentVersion() async throws -> String {
        let versions: [ContentVersion] = try await SupabaseConfig.client
            .from(SupabaseConfig.Tables.contentVersions)
            .select()
            .eq("is_current", value: true)
            .limit(1)
            .execute()
            .value

        guard let current = versions.first else {
            throw ContentProviderError.noVersionFound
        }

        return current.version
    }

    private func loadLastSyncDate() {
        if let timestamp = UserDefaults.standard.object(forKey: lastSyncKey) as? TimeInterval {
            lastSyncDate = Date(timeIntervalSince1970: timestamp)
        }
    }

    private func saveLastSyncDate() {
        if let date = lastSyncDate {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: lastSyncKey)
        }
    }

    // MARK: - Content Access

    /// Get all remote cards (premium and free)
    var allRemoteCards: [Flashcard] {
        remoteCards
    }

    /// Get only free remote cards
    var freeRemoteCards: [Flashcard] {
        remoteCards.filter { !$0.isPremium }
    }

    /// Get only premium remote cards
    var premiumRemoteCards: [Flashcard] {
        remoteCards.filter { $0.isPremium }
    }

    /// Check if we have any cached content available
    var hasOfflineContent: Bool {
        cache.hasCachedContent || !remoteCards.isEmpty
    }

    /// Get cache size for display
    var cacheSizeString: String {
        let bytes = cache.cacheSize()
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    /// Clear the content cache
    func clearCache() {
        try? cache.clearCache()
        remoteCards = []
        currentVersion = nil
    }
}

// MARK: - Error Types

enum ContentProviderError: Error, LocalizedError {
    case networkError(Error)
    case noVersionFound
    case decodingError(Error)
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noVersionFound:
            return "No content version found on server"
        case .decodingError(let error):
            return "Failed to decode content: \(error.localizedDescription)"
        case .notConfigured:
            return "Supabase is not configured"
        }
    }

    static func from(_ error: Error) -> ContentProviderError {
        if let providerError = error as? ContentProviderError {
            return providerError
        }
        return .networkError(error)
    }
}
