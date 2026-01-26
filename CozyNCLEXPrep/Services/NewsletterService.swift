//
//  NewsletterService.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation
import Combine
import Supabase

/// Handles newsletter subscriptions via Supabase
@MainActor
class NewsletterService: ObservableObject {
    static let shared = NewsletterService()

    @Published var isSubscribing = false
    @Published var subscriptionError: String?

    private let client = SupabaseConfig.client

    private init() {}

    /// Subscribe an email to the newsletter
    func subscribe(email: String, source: String = "app_signup") async -> Bool {
        guard !email.isEmpty else { return false }

        isSubscribing = true
        subscriptionError = nil

        do {
            try await client
                .from("newsletter_subscribers")
                .insert([
                    "email": email,
                    "source": source
                ])
                .execute()

            isSubscribing = false
            return true
        } catch {
            // If already subscribed, that's fine
            if error.localizedDescription.contains("duplicate") ||
               error.localizedDescription.contains("unique") {
                isSubscribing = false
                return true
            }

            subscriptionError = error.localizedDescription
            isSubscribing = false
            return false
        }
    }

    /// Check if an email is already subscribed
    func isSubscribed(email: String) async -> Bool {
        do {
            let result: [NewsletterSubscriber] = try await client
                .from("newsletter_subscribers")
                .select()
                .eq("email", value: email)
                .execute()
                .value

            return !result.isEmpty
        } catch {
            return false
        }
    }
}

// MARK: - Newsletter Subscriber Model

struct NewsletterSubscriber: Codable {
    let id: UUID
    let email: String
    let subscribedAt: Date
    let source: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case subscribedAt = "subscribed_at"
        case source
    }
}
