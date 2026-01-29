//
//  LocalContentCache.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation

/// Manages local caching of remote flashcard content for offline use
class LocalContentCache {
    static let shared = LocalContentCache()

    private let fileManager = FileManager.default
    private let cacheFileName = "cached_flashcards.json"
    private let versionFileName = "cached_version.json"

    private var cacheURL: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("CozyNCLEXContent")
    }

    private init() {
        createCacheDirectoryIfNeeded()
    }

    // MARK: - Directory Management

    private func createCacheDirectoryIfNeeded() {
        guard let cacheURL = cacheURL else { return }
        if !fileManager.fileExists(atPath: cacheURL.path) {
            try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        }
    }

    // MARK: - Flashcard Caching

    /// Save flashcards to local cache
    func cacheFlashcards(_ cards: [RemoteFlashcard]) throws {
        guard let cacheURL = cacheURL else {
            throw CacheError.directoryNotFound
        }

        let fileURL = cacheURL.appendingPathComponent(cacheFileName)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(cards)
        try data.write(to: fileURL)
    }

    /// Load flashcards from local cache
    func loadCachedFlashcards() -> [RemoteFlashcard]? {
        guard let cacheURL = cacheURL else { return nil }

        let fileURL = cacheURL.appendingPathComponent(cacheFileName)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([RemoteFlashcard].self, from: data)
        } catch {
            print("Failed to load cached flashcards: \(error)")
            return nil
        }
    }

    /// Convert cached remote flashcards to local Flashcard models
    func loadCachedAsFlashcards() -> [Flashcard] {
        guard let remoteCards = loadCachedFlashcards() else { return [] }
        return remoteCards.compactMap { $0.toFlashcard() }
    }

    // MARK: - Version Tracking

    /// Save the current content version
    func cacheVersion(_ version: String) throws {
        guard let cacheURL = cacheURL else {
            throw CacheError.directoryNotFound
        }

        let fileURL = cacheURL.appendingPathComponent(versionFileName)
        let versionData = CachedVersion(version: version, cachedAt: Date())
        let data = try JSONEncoder().encode(versionData)
        try data.write(to: fileURL)
    }

    /// Get the cached content version
    func getCachedVersion() -> String? {
        guard let cacheURL = cacheURL else { return nil }

        let fileURL = cacheURL.appendingPathComponent(versionFileName)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }

        do {
            let data = try Data(contentsOf: fileURL)
            let versionData = try JSONDecoder().decode(CachedVersion.self, from: data)
            return versionData.version
        } catch {
            return nil
        }
    }

    /// Check if cache needs update based on version
    func needsUpdate(currentVersion: String) -> Bool {
        guard let cachedVersion = getCachedVersion() else {
            return true // No cache exists
        }
        return cachedVersion != currentVersion
    }

    // MARK: - Cache Management

    /// Clear all cached content
    func clearCache() throws {
        guard let cacheURL = cacheURL else { return }

        let fileURLs = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
        for fileURL in fileURLs {
            try fileManager.removeItem(at: fileURL)
        }
    }

    /// Get cache size in bytes
    func cacheSize() -> Int64 {
        guard let cacheURL = cacheURL else { return 0 }

        var totalSize: Int64 = 0
        if let files = try? fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: [.fileSizeKey]) {
            for file in files {
                if let size = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(size)
                }
            }
        }
        return totalSize
    }

    /// Check if cache exists and has content
    var hasCachedContent: Bool {
        loadCachedFlashcards() != nil
    }
}

// MARK: - Supporting Types

private struct CachedVersion: Codable {
    let version: String
    let cachedAt: Date
}

enum CacheError: Error, LocalizedError {
    case directoryNotFound
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .directoryNotFound:
            return "Cache directory not found"
        case .encodingFailed:
            return "Failed to encode data for caching"
        case .decodingFailed:
            return "Failed to decode cached data"
        }
    }
}
