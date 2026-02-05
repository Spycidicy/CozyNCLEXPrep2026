//
//  ProfileView.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var dailyGoalsManager = DailyGoalsManager.shared
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var isEditingName = false
    @State private var newDisplayName = ""
    @State private var showCreateAccount = false

    var onSignOut: (() -> Void)?
    var onCreateAccount: (() -> Void)?

    private var isGuest: Bool {
        !authManager.isAuthenticated
    }

    var body: some View {
        NavigationView {
            List {
                // Profile Header
                Section {
                    HStack(spacing: 16) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: isGuest ? [.gray, .gray.opacity(0.7)] : [.mintGreen, .green.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 70, height: 70)

                            if isGuest {
                                Image(systemName: "person.fill.questionmark")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text(initials)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(isGuest ? "Guest User" : (authManager.userProfile?.displayName ?? "Student"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))

                            if isGuest {
                                Text("Progress saved locally")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.secondary)
                            } else {
                                Text(authManager.currentUser?.email ?? "")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                // Guest: Create Account CTA
                if isGuest {
                    Section {
                        Button(action: { showCreateAccount = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        LinearGradient(colors: [.mintGreen, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Create Free Account")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Sync & keep your progress forever")
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        Text("Unlock Full Features")
                    } footer: {
                        Text("Your current progress will be saved to your new account.")
                    }
                }

                // Account Settings (only for signed-in users)
                if !isGuest {
                    Section("Account") {
                        Button(action: { isEditingName = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                Text("Edit Display Name")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(authManager.userProfile?.displayName ?? "")
                                    .foregroundColor(.secondary)
                            }
                        }

                        if authManager.userProfile?.isPremium == true {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("Premium Member")
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }

                    // Sync Section
                    Section("Data & Sync") {
                        NavigationLink {
                            SyncSettingsView()
                        } label: {
                            HStack {
                                Image(systemName: "icloud")
                                    .foregroundColor(.blue)
                                Text("iCloud Sync")
                                Spacer()
                                SyncStatusBadge()
                            }
                        }
                    }

                    // Sign Out
                    Section {
                        Button(action: { showSignOutAlert = true }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.orange)
                                Text("Sign Out")
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    // Danger Zone
                    Section {
                        Button(action: { showDeleteAccountAlert = true }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                Text("Delete Account")
                                    .foregroundColor(.red)
                            }
                        }
                    } footer: {
                        Text("Deleting your account will permanently remove all your data. This action cannot be undone.")
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authManager.signOut()
                        dismiss()
                        onSignOut?()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        try? await authManager.deleteAccount()
                        dismiss()
                    }
                }
            } message: {
                Text("This will permanently delete your account and all associated data. This cannot be undone.")
            }
            .sheet(isPresented: $isEditingName) {
                EditNameView(displayName: $newDisplayName)
            }
            .sheet(isPresented: $showCreateAccount) {
                AuthView(startInSignUpMode: true, onAuthenticated: {
                    showCreateAccount = false
                    // Progress is preserved - local data syncs to Supabase on sign in
                    Task {
                        await CloudSyncManager.shared.syncAll()
                    }
                })
            }
            .onAppear {
                newDisplayName = authManager.userProfile?.displayName ?? ""
            }
        }
    }

    private var initials: String {
        let name = authManager.userProfile?.displayName ?? "S"
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Edit Name View

struct EditNameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthManager.shared
    @Binding var displayName: String
    @State private var isSaving = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Edit Display Name")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .padding(.top, 40)

                AuthTextField(
                    icon: "person.fill",
                    placeholder: "Display Name",
                    text: $displayName
                )
                .padding(.horizontal, 24)

                Button(action: saveName) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Save")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.mintGreen)
                    .cornerRadius(14)
                }
                .disabled(displayName.isEmpty || isSaving)
                .opacity(displayName.isEmpty ? 0.6 : 1)
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveName() {
        isSaving = true
        Task {
            try? await authManager.updateDisplayName(displayName)
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
