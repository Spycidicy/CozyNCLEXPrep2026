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

                #if DEBUG
                print("🔐 Auth event: \(event)")
                #endif

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
                    #if DEBUG
                    print("🔐 Password recovery detected - showing reset UI")
                    #endif
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
            let mapped = AuthError.from(error)
            authError = mapped
            throw mapped
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
            let mapped = AuthError.from(error)
            authError = mapped
            throw mapped
        }
    }

    func resetPassword(email: String) async throws {
        isLoading = true
        authError = nil
        defer { isLoading = false }

        do {
            try await client.auth.resetPasswordForEmail(
                email,
                redirectTo: URL(string: "https://www.cozynclex.com/auth-redirect/")
            )
        } catch {
            let mapped = AuthError.from(error)
            authError = mapped
            throw mapped
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
            let mapped = AuthError.from(error)
            authError = mapped
            throw mapped
        }
    }

    func handlePasswordResetURL(_ url: URL) async {
        #if DEBUG
        print("🔐 Handling auth URL: \(url)")
        #endif

        // Check if this is a recovery/password reset URL
        let urlString = url.absoluteString
        let isRecovery = urlString.contains("type=recovery") ||
                         urlString.contains("recovery") ||
                         url.path.contains("recovery")

        do {
            let session = try await client.auth.session(from: url)
            #if DEBUG
            print("🔐 Session created for user: \(session.user.email ?? "unknown")")
            #endif
            currentUser = session.user
            isAuthenticated = true

            // Only show password reset AFTER session is successfully created
            if isRecovery {
                #if DEBUG
                print("🔐 Recovery URL with valid session, showing password reset")
                #endif
                showPasswordReset = true
            }
        } catch {
            #if DEBUG
            print("🔐 Error handling auth URL: \(error)")
            #endif

            // If session(from:) fails but we have a recovery URL, check for existing session
            if isRecovery {
                if let existingSession = try? await client.auth.session {
                    #if DEBUG
                    print("🔐 Existing session found with recovery URL, showing password reset")
                    #endif
                    currentUser = existingSession.user
                    isAuthenticated = true
                    showPasswordReset = true
                } else {
                    #if DEBUG
                    print("🔐 No session available for password reset")
                    #endif
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
            let mapped = AuthError.from(error)
            authError = mapped
            throw mapped
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
            let mapped = AuthError.from(error)
            authError = mapped
            throw mapped
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
            #if DEBUG
            print("🔐 Loaded profile: \(profile.displayName), isPremium: \(profile.isPremium)")
            #endif
        } catch {
            #if DEBUG
            print("🔐 Error loading profile: \(error)")
            #endif
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
            #if DEBUG
            print("Failed to create profile: \(error)")
            #endif
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
        var deletionErrors: [Error] = []

        // 1. Delete all user data from each table, collecting errors but continuing
        let tablesToDelete: [(table: String, column: String)] = [
            ("card_reports", "user_id"),
            ("card_progress", "user_id"),
            ("daily_activity", "user_id"),
            ("user_stats", "user_id"),
            ("daily_goals", "user_id"),
            ("achievements", "user_id"),
            ("user_profiles", "id"),
        ]

        for entry in tablesToDelete {
            do {
                try await client
                    .from(entry.table)
                    .delete()
                    .eq(entry.column, value: userId.uuidString)
                    .execute()
                #if DEBUG
                print("🗑️ Deleted user data from \(entry.table)")
                #endif
            } catch {
                #if DEBUG
                print("🗑️ Error deleting from \(entry.table): \(error)")
                #endif
                deletionErrors.append(error)
            }
        }

        // 2. Delete auth user via Edge Function (requires admin privileges)
        do {
            try await client.functions.invoke("delete-user")
            #if DEBUG
            print("🗑️ Auth user deleted via Edge Function")
            #endif
        } catch {
            #if DEBUG
            print("🗑️ Error deleting auth user: \(error)")
            #endif
            deletionErrors.append(error)
        }

        // 3. Clear all local data and sign out regardless of server errors
        await MainActor.run {
            PersistenceManager.shared.clearAllUserData()
            DailyGoalsManager.shared.resetForNewUser()
            StatsManager.shared.resetForNewUser()
            CardManager.shared.resetForNewUser()
        }

        do {
            try await client.auth.signOut()
        } catch {
            #if DEBUG
            print("🗑️ Error signing out: \(error)")
            #endif
        }

        currentUser = nil
        userProfile = nil
        isAuthenticated = false
        isLoading = false

        // If any server deletions failed, report the first error
        if let firstError = deletionErrors.first {
            let mapped = AuthError.from(firstError)
            authError = mapped
            throw mapped
        }
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
        // Check error description for both localized and debug representations
        // to handle all locales correctly
        let message = error.localizedDescription.lowercased()
        let debugDescription = String(describing: error).lowercased()
        let combined = message + " " + debugDescription

        if combined.contains("invalid") && combined.contains("email") {
            return .invalidEmail
        } else if combined.contains("password") && (combined.contains("weak") || combined.contains("too short")) {
            return .weakPassword
        } else if combined.contains("already") || combined.contains("exists") || combined.contains("user_already_exists") {
            return .emailInUse
        } else if combined.contains("not found") || combined.contains("no user") || combined.contains("user_not_found") {
            return .userNotFound
        } else if combined.contains("invalid_credentials") || combined.contains("wrong") || combined.contains("incorrect") {
            return .wrongPassword
        } else if combined.contains("network") || combined.contains("connection") || error is URLError {
            return .networkError
        }

        return .unknown(error.localizedDescription)
    }
}
