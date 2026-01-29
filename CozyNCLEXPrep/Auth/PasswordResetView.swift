//
//  PasswordResetView.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import SwiftUI

struct PasswordResetView: View {
    @ObservedObject var authManager = AuthManager.shared
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var isUpdating = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    var passwordIsValid: Bool {
        newPassword.count >= 6
    }

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()

            if showSuccess {
                // Success State
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.mintGreen.opacity(0.2))
                            .frame(width: 100, height: 100)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.mintGreen)
                    }

                    Text("Password Updated!")
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Text("Your password has been successfully changed.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button(action: {
                        authManager.showPasswordReset = false
                    }) {
                        Text("Continue to App")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mintGreen)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
            } else {
                // Password Reset Form
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.pastelPink.opacity(0.3), Color.softLavender.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)

                                Image(systemName: "key.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.pastelPink)
                            }

                            Text("Set New Password")
                                .font(.system(size: 26, weight: .bold, design: .rounded))

                            Text("Enter your new password below")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)

                        // Form
                        VStack(spacing: 16) {
                            // New Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("New Password")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)

                                HStack {
                                    if showPassword {
                                        TextField("Enter new password", text: $newPassword)
                                            .foregroundColor(.primary)
                                    } else {
                                        SecureField("Enter new password", text: $newPassword)
                                            .foregroundColor(.primary)
                                    }

                                    Button(action: { showPassword.toggle() }) {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color.adaptiveWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )

                                // Password strength indicator
                                if !newPassword.isEmpty {
                                    HStack(spacing: 8) {
                                        Image(systemName: passwordIsValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(passwordIsValid ? .green : .red)
                                            .font(.system(size: 12))
                                        Text("At least 6 characters")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(passwordIsValid ? .green : .red)
                                    }
                                }
                            }

                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)

                                SecureField("Confirm new password", text: $confirmPassword)
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background(Color.adaptiveWhite)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                !confirmPassword.isEmpty && !passwordsMatch ? Color.red.opacity(0.5) : Color.gray.opacity(0.2),
                                                lineWidth: 1
                                            )
                                    )

                                // Match indicator
                                if !confirmPassword.isEmpty {
                                    HStack(spacing: 8) {
                                        Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(passwordsMatch ? .green : .red)
                                            .font(.system(size: 12))
                                        Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(passwordsMatch ? .green : .red)
                                    }
                                }
                            }

                            // Error Message
                            if let error = errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(error)
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                            }

                            // Update Button
                            Button(action: updatePassword) {
                                HStack {
                                    if isUpdating {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Update Password")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    (passwordsMatch && passwordIsValid) ?
                                    LinearGradient(colors: [.pastelPink, .softLavender], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(14)
                            }
                            .disabled(!passwordsMatch || !passwordIsValid || isUpdating)
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 24)

                        // Cancel button
                        Button(action: {
                            authManager.showPasswordReset = false
                        }) {
                            Text("Cancel")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)

                        Spacer()
                    }
                }
            }
        }
    }

    private func updatePassword() {
        isUpdating = true
        errorMessage = nil

        Task {
            do {
                try await authManager.updatePassword(newPassword: newPassword)
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isUpdating = false
        }
    }
}

#Preview {
    PasswordResetView()
}
