//
//  AuthManager.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import Foundation
import Combine
import Supabase
import AuthenticationServices
import CryptoKit

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    @Published var authError: AuthError?
    @Published var showPasswordReset = false

    private let client = SupabaseConfig.client
    private var authStateTask: Task<Void, Never>?

    private init() {
        // Check for existing session on init
        Task {
            await checkSession()
            await listenToAuthChanges()
        }
    }

    // MARK: - Session Management

    func checkSession() async {
        isLoading = true
        do {
            let session = try await client.auth.session
            currentUser = session.user
            isAuthenticated = true
            await loadUserProfile()
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
        isLoading = false
    }

    private func listenToAuthChanges() async {
        authStateTask?.cancel()
        authStateTask = Task {
            for await (event, session) in client.auth.authStateChanges {
                guard !Task.isCancelled else { break }

                print("🔐 Auth event: \(event)")

                switch event {
                case .signedIn:
                    currentUser = session?.user
                    isAuthenticated = true
                    await loadUserProfile()
                case .signedOut:
                    currentUser = nil
                    userProfile = nil
                    isAuthenticated = false
                case .userUpdated:
                    currentUser = session?.user
                    await loadUserProfile()
                case .passwordRecovery:
                    // User clicked password reset link - show reset UI
                    currentUser = session?.user
                    isAuthenticated = true
                    showPasswordReset = true
                    print("🔐 Password recovery detected - showing reset UI")
                default:
                    break
                }
            }
        }
    }

    // MARK: - Email/Password Auth

    func signUp(email: String, password: String, displayName: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }

        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["display_name": .string(displayName)]
            )

            currentUser = response.user
            isAuthenticated = response.user != nil
            if response.user != nil {
                await createUserProfile(displayName: displayName)
            }
        } catch {
            authError = AuthError.from(error)
            throw authError!
        }
    }

    func signIn(email: String, password: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }

        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )

            currentUser = session.user
            isAuthenticated = true
            await loadUserProfile()
        } catch {
            authError = AuthError.from(error)
            throw authError!
        }
    }

    func resetPassword(email: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }

        do {
            try await client.auth.resetPasswordForEmail(
                email,
                redirectTo: URL(string: "https://spycidicy.github.io/cozynclex-auth-redirect/")
            )
        } catch {
            authError = AuthError.from(error)
            throw authError!
        }
    }

    func updatePassword(newPassword: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }

        do {
            try await client.auth.update(user: UserAttributes(password: newPassword))
            showPasswordReset = false
        } catch {
            authError = AuthError.from(error)
            throw authError!
        }
    }

    func handlePasswordResetURL(_ url: URL) async {
        print("🔐 Handling auth URL: \(url)")

        // Check if this is a recovery/password reset URL
        let urlString = url.absoluteString
        let isRecovery = urlString.contains("type=recovery") ||
                         urlString.contains("recovery") ||
                         url.path.contains("recovery")

        do {
            let session = try await client.auth.session(from: url)
            print("🔐 Session created for user: \(session.user.email ?? "unknown")")
            currentUser = session.user
            isAuthenticated = true

            // Only show password reset AFTER session is successfully created
            if isRecovery {
                print("🔐 Recovery URL with valid session, showing password reset")
                showPasswordReset = true
            }
        } catch {
            print("🔐 Error handling auth URL: \(error)")

            // If session(from:) fails but we have a recovery URL, check for existing session
            if isRecovery {
                if let existingSession = try? await client.auth.session {
                    print("🔐 Existing session found with recovery URL, showing password reset")
                    currentUser = existingSession.user
                    isAuthenticated = true
                    showPasswordReset = true
                } else {
                    print("🔐 No session available for password reset")
                }
            }
        }
    }

    // MARK: - Sign in with Apple

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }

        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            authError = .invalidCredential
            throw AuthError.invalidCredential
        }

        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: tokenString
                )
            )

            currentUser = session.user
            isAuthenticated = true

            // Create/update profile with Apple data
            let displayName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")

            if !displayName.isEmpty {
                await createUserProfile(displayName: displayName)
            } else {
                await loadUserProfile()
            }
        } catch {
            authError = AuthError.from(error)
            throw authError!
        }
    }

    // MARK: - Sign in with Google

    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        isLoading = true
        authError = nil

        defer { isLoading = false }

        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken
                )
            )

            currentUser = session.user
            isAuthenticated = true
            await loadUserProfile()
        } catch {
            authError = AuthError.from(error)
            throw authError!
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        isLoading = true
        do {
            try await client.auth.signOut()

            // Clear all local user data to prevent data leakage between accounts
            await MainActor.run {
                PersistenceManager.shared.clearAllUserData()

                // Reset singleton managers to their initial state
                DailyGoalsManager.shared.resetForNewUser()
                StatsManager.shared.resetForNewUser()
                CardManager.shared.resetForNewUser()
            }

            currentUser = nil
            userProfile = nil
            isAuthenticated = false
        } catch {
            authError = AuthError.from(error)
        }
        isLoading = false
    }

    // MARK: - User Profile

    private func loadUserProfile() async {
        guard let userId = currentUser?.id else { return }

        do {
            let profile: UserProfile = try await client
                .from("user_profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value

            userProfile = profile
            print("🔐 Loaded profile: \(profile.displayName), isPremium: \(profile.isPremium)")
        } catch {
            print("🔐 Error loading profile: \(error)")
            // Profile doesn't exist, create one with email prefix as display name
            let email = currentUser?.email ?? "Student"
            let displayName = displayNameFromEmail(email)
            await createUserProfile(displayName: displayName)
        }
    }

    /// Generate display name from email (everything before @)
    private func displayNameFromEmail(_ email: String) -> String {
        if let atIndex = email.firstIndex(of: "@") {
            return String(email[..<atIndex])
        }
        return email
    }

    private func createUserProfile(displayName: String) async {
        guard let userId = currentUser?.id else { return }

        let profile = UserProfile(
            id: userId,
            displayName: displayName,
            createdAt: Date(),
            updatedAt: Date()
        )

        do {
            try await client
                .from("user_profiles")
                .upsert(profile)
                .execute()

            userProfile = profile
        } catch {
            print("Failed to create profile: \(error)")
        }
    }

    func updateDisplayName(_ name: String) async throws {
        guard var profile = userProfile else { return }

        profile.displayName = name
        profile.updatedAt = Date()

        try await client
            .from("user_profiles")
            .update(profile)
            .eq("id", value: profile.id.uuidString)
            .execute()

        userProfile = profile
    }

    // MARK: - Delete Account

    func deleteAccount() async throws {
        guard let userId = currentUser?.id else { return }

        isLoading = true

        do {
            // Delete user profile
            try await client
                .from("user_profiles")
                .delete()
                .eq("id", value: userId.uuidString)
                .execute()

            // Sign out (account deletion requires admin API)
            await signOut()
        } catch {
            authError = AuthError.from(error)
            throw authError!
        }

        isLoading = false
    }
}

// MARK: - User Profile Model

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var displayName: String
    var avatarUrl: String?
    var isPremium: Bool
    var totalXP: Int
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID, displayName: String, avatarUrl: String? = nil, isPremium: Bool = false, totalXP: Int = 0, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.isPremium = isPremium
        self.totalXP = totalXP
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case isPremium = "is_premium"
        case totalXP = "total_xp"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Auth Errors

enum AuthError: Error, LocalizedError {
    case invalidCredential
    case invalidEmail
    case weakPassword
    case emailInUse
    case userNotFound
    case wrongPassword
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid credentials provided"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .emailInUse:
            return "This email is already registered"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown(let message):
            return message
        }
    }

    static func from(_ error: Error) -> AuthError {
        let message = error.localizedDescription.lowercased()

        if message.contains("invalid") && message.contains("email") {
            return .invalidEmail
        } else if message.contains("password") && message.contains("weak") {
            return .weakPassword
        } else if message.contains("already") || message.contains("exists") {
            return .emailInUse
        } else if message.contains("not found") || message.contains("no user") {
            return .userNotFound
        } else if message.contains("wrong") || message.contains("incorrect") {
            return .wrongPassword
        } else if message.contains("network") || message.contains("connection") {
            return .networkError
        }

        return .unknown(error.localizedDescription)
    }
}
