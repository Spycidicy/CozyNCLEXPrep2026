//
//  CozyNCLEXPrepApp.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/22/26.
//

import SwiftUI
import os.log

@main
struct CozyNCLEXPrepApp: App {

    init() {
        // Run pending data migrations BEFORE any UI or manager loads data.
        // This is critical: managers read from UserDefaults in their init(),
        // so migrations must complete first.
        do {
            if MigrationManager.shared.needsMigration {
                try MigrationManager.shared.runMigrations()
                Logger(subsystem: Bundle.main.bundleIdentifier ?? "CozyNCLEXPrep", category: "Migration")
                    .info("✅ Migrations complete (now at v\(MigrationManager.shared.lastMigrationVersion))")
            }
        } catch {
            Logger(subsystem: Bundle.main.bundleIdentifier ?? "CozyNCLEXPrep", category: "Migration")
                .error("❌ Migration failed: \(error.localizedDescription) — app will continue with existing data")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
