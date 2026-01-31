//
//  JSONHelper.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/30/26.
//

import Foundation
import os.log

// MARK: - Logger

private let jsonLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CozyNCLEXPrep", category: "JSONHelper")

// MARK: - Versioned Wrapper

/// Wraps any Codable payload with a schema version tag.
/// Use this when persisting data so future migrations can detect the format.
///
///     let wrapped = VersionedWrapper(version: 1, payload: myStats)
///     let data = try JSONEncoder().encode(wrapped)
///
struct VersionedWrapper<T: Codable>: Codable {
    let version: Int
    let payload: T
}

// MARK: - Safe Decode

/// Attempts to decode `T` from `Data` with resilience against schema changes.
///
/// Strategy:
/// 1. Try normal decode — fast path, works when schema matches.
/// 2. If that fails, try decoding a `VersionedWrapper<T>` (in case data was saved wrapped).
/// 3. If that also fails, log the *specific* error for debugging and return `nil`
///    so the caller can decide how to handle it (e.g. keep raw data, use a fallback).
///
/// - Parameters:
///   - type: The Codable type to decode.
///   - data: The raw JSON data from persistence.
///   - context: A human-readable label for log messages (e.g. "UserStats").
/// - Returns: The decoded value, or `nil` if all strategies failed.
///
func safeDecode<T: Codable>(_ type: T.Type, from data: Data, context: String = String(describing: T.self)) -> T? {
    let decoder = JSONDecoder()

    // Strategy 1: Direct decode
    do {
        return try decoder.decode(T.self, from: data)
    } catch {
        jsonLogger.warning("⚠️ [\(context)] Direct decode failed: \(error.localizedDescription)")
    }

    // Strategy 2: Maybe it was stored inside a VersionedWrapper
    do {
        let wrapped = try decoder.decode(VersionedWrapper<T>.self, from: data)
        jsonLogger.info("✅ [\(context)] Recovered from VersionedWrapper (v\(wrapped.version))")
        return wrapped.payload
    } catch {
        jsonLogger.debug("[\(context)] Not a VersionedWrapper either — expected if data predates versioning.")
    }

    // Strategy 3: Log the detailed error for debugging
    do {
        // Re-attempt to get the *precise* DecodingError details
        _ = try decoder.decode(T.self, from: data)
    } catch let DecodingError.keyNotFound(key, ctx) {
        jsonLogger.error("❌ [\(context)] Missing key '\(key.stringValue)' at \(ctx.codingPath.map(\.stringValue).joined(separator: ".")) — add a default value for this field")
    } catch let DecodingError.typeMismatch(expectedType, ctx) {
        jsonLogger.error("❌ [\(context)] Type mismatch: expected \(String(describing: expectedType)) at \(ctx.codingPath.map(\.stringValue).joined(separator: "."))")
    } catch let DecodingError.valueNotFound(valueType, ctx) {
        jsonLogger.error("❌ [\(context)] Null value for \(String(describing: valueType)) at \(ctx.codingPath.map(\.stringValue).joined(separator: "."))")
    } catch let DecodingError.dataCorrupted(ctx) {
        jsonLogger.error("❌ [\(context)] Data corrupted at \(ctx.codingPath.map(\.stringValue).joined(separator: ".")): \(ctx.debugDescription)")
    } catch {
        jsonLogger.error("❌ [\(context)] Unknown decode error: \(error.localizedDescription)")
    }

    // Preserve the raw data so it is NOT lost
    preserveRawData(data, context: context)

    return nil
}

/// Attempts to decode a `VersionedWrapper<T>`, returning both the version and the payload.
/// Useful when you need to branch migration logic based on the stored version.
func safeDecodeVersioned<T: Codable>(_ type: T.Type, from data: Data, context: String = String(describing: T.self)) -> (version: Int, payload: T)? {
    let decoder = JSONDecoder()

    // Try versioned first
    if let wrapped = try? decoder.decode(VersionedWrapper<T>.self, from: data) {
        return (wrapped.version, wrapped.payload)
    }

    // Fall back to un-versioned (treat as version 0)
    if let plain = safeDecode(type, from: data, context: context) {
        return (0, plain)
    }

    return nil
}

// MARK: - Safe Encode

/// Encodes a value wrapped with a schema version tag.
/// Returns nil (instead of crashing) on failure and logs the error.
func safeEncode<T: Codable>(_ value: T, version: Int = 1, context: String = String(describing: T.self)) -> Data? {
    let wrapped = VersionedWrapper(version: version, payload: value)
    do {
        return try JSONEncoder().encode(wrapped)
    } catch {
        jsonLogger.error("❌ [\(context)] Encode failed: \(error.localizedDescription)")
        return nil
    }
}

// MARK: - Raw Data Preservation

/// Saves raw data that failed to decode into a recovery key so it is never silently lost.
/// This allows a future app update to attempt recovery with a corrected model.
private func preserveRawData(_ data: Data, context: String) {
    let recoveryKey = "recovery_\(context)_\(Int(Date().timeIntervalSince1970))"
    UserDefaults.standard.set(data, forKey: recoveryKey)
    jsonLogger.warning("🛟 [\(context)] Raw data preserved under key '\(recoveryKey)' for future recovery")
}
