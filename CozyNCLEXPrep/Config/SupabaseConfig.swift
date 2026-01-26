//
//  SupabaseConfig.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation
import Supabase

struct SupabaseConfig {
    // MARK: - Configuration
    static let url = URL(string: "https://cmhchwjuwhvtbvwrfrle.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNtaGNod2p1d2h2dGJ2d3JmcmxlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkyMjg0MTIsImV4cCI6MjA4NDgwNDQxMn0.SvEKYUh9daH-wFxU08lEJqNw33fXFgQQaazaXf_L-SM"

    // MARK: - Client
    static let client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)

    // MARK: - Table Names
    struct Tables {
        static let nclexQuestions = "nclex_questions"
        static let contentVersions = "content_versions"
    }

    // MARK: - Validation
    static var isConfigured: Bool {
        return !url.absoluteString.contains("YOUR_PROJECT_ID") &&
               !anonKey.contains("YOUR_ANON_KEY")
    }
}
