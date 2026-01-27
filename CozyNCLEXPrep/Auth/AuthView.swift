//
//  AuthView.swift
//  CozyNCLEX Prep 2026
//
//  Created by Ethan Long on 1/24/26.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import Supabase

struct AuthView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var isSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showResetPassword = false
    @State private var subscribeToNewsletter = true

    var onAuthenticated: (() -> Void)?

    init(startInSignUpMode: Bool = false, onAuthenticated: (() -> Void)? = nil) {
        _isSignUp = State(initialValue: startInSignUpMode)
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.mintGreen.opacity(0.3), Color.creamyBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Logo and Title
                    VStack(spacing: 12) {
                        Image("NurseBear")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

                        Text("CozyNCLEX Prep")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.2, green: 0.2, blue: 0.25), Color(red: 0.3, green: 0.3, blue: 0.35)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text(isSignUp ? "Create your account" : "Welcome back!")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    // Social Sign In - FIRST
                    VStack(spacing: 12) {
                        // Sign in with Apple
                        SignInWithAppleButton(isSignUp ? .signUp : .signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(14)

                        // Sign in with Google
                        Button(action: signInWithGoogle) {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20))
                                Text(isSignUp ? "Sign up with Google" : "Sign in with Google")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.adaptiveWhite)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text("or with email")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)

                    // Email/Password Form - SECOND
                    VStack(spacing: 16) {
                        // Email Field
                        AuthTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        // Password Field
                        AuthSecureField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $password
                        )

                        if isSignUp {
                            // Confirm Password Field
                            AuthSecureField(
                                icon: "lock.fill",
                                placeholder: "Confirm Password",
                                text: $confirmPassword
                            )

                            // Newsletter Signup
                            NewsletterToggle(isOn: $subscribeToNewsletter)
                        }

                        // Forgot Password
                        if !isSignUp {
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    showResetPassword = true
                                }
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.blue)
                            }
                        }

                        // Submit Button
                        Button(action: submitForm) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.mintGreen, .green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                        }
                        .disabled(authManager.isLoading || !isFormValid)
                        .opacity(isFormValid ? 1 : 0.6)
                    }
                    .padding(.horizontal, 24)

                    // Toggle Sign Up / Sign In
                    HStack(spacing: 4) {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.secondary)
                        Button(isSignUp ? "Sign In" : "Sign Up") {
                            withAnimation(.spring(response: 0.3)) {
                                isSignUp.toggle()
                                clearForm()
                            }
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.mintGreen)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showResetPassword) {
            ResetPasswordSheet()
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                onAuthenticated?()
            }
        }
    }

    // MARK: - Form Validation

    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty &&
                   !password.isEmpty &&
                   password == confirmPassword &&
                   password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }

    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
    }

    /// Generate display name from email (everything before @)
    private func displayNameFromEmail(_ email: String) -> String {
        if let atIndex = email.firstIndex(of: "@") {
            return String(email[..<atIndex])
        }
        return email
    }

    // MARK: - Actions

    private func submitForm() {
        Task {
            do {
                if isSignUp {
                    let generatedDisplayName = displayNameFromEmail(email)
                    try await authManager.signUp(email: email, password: password, displayName: generatedDisplayName)

                    // Subscribe to newsletter if opted in
                    if subscribeToNewsletter {
                        _ = await NewsletterService.shared.subscribe(email: email, source: "app_signup")
                    }
                } else {
                    try await authManager.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    do {
                        try await authManager.signInWithApple(credential: credential)
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func signInWithGoogle() {
        print("DEBUG: signInWithGoogle called")

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to find root view controller"
            showError = true
            print("DEBUG: No root view controller")
            return
        }

        print("DEBUG: Got root view controller")

        // Configure with iOS client ID and Web (server) client ID
        // The serverClientID ensures the ID token is valid for Supabase
        let config = GIDConfiguration(
            clientID: "40859403275-9o180g17crnm3fliqul26tsuqqd95dce.apps.googleusercontent.com",
            serverClientID: "40859403275-rjjma3n9r3go374bmgnm7piir7ljniiv.apps.googleusercontent.com"
        )

        GIDSignIn.sharedInstance.configuration = config

        print("DEBUG: Starting Google Sign-In...")

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            print("DEBUG: Google Sign-In callback received")

            if let error = error {
                print("DEBUG: Google error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                showError = true
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("DEBUG: No ID token received")
                errorMessage = "Failed to get Google credentials"
                showError = true
                return
            }

            print("DEBUG: Got ID token, calling Supabase...")
            let accessToken = user.accessToken.tokenString

            Task {
                do {
                    try await authManager.signInWithGoogle(idToken: idToken, accessToken: accessToken)
                    print("DEBUG: Supabase sign-in successful")
                } catch {
                    print("DEBUG: Supabase error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Reset Password Sheet

struct ResetPasswordSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showNotFound = false

    var body: some View {
        ZStack {
            Color.creamyBackground.ignoresSafeArea()

            if showSuccess {
                successView
            } else if showNotFound {
                notFoundView
            } else {
                inputView
            }

            // Cancel button overlay
            if !showSuccess && !showNotFound && !isLoading {
                VStack {
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .padding()
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .interactiveDismissDisabled(isLoading || showSuccess || showNotFound)
    }

    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.mintGreen.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.mintGreen)
            }

            VStack(spacing: 12) {
                Text("Check Your Email")
                    .font(.system(size: 26, weight: .bold, design: .rounded))

                Text("If an account exists for")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.secondary)

                Text(email)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.mintGreen)

                Text("you'll receive password reset instructions shortly.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 16) {
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.mintGreen)
                        .cornerRadius(14)
                }

                Text("Didn't receive it? Check spam or try a different email.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Not Found View
    private var notFoundView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
            }

            VStack(spacing: 12) {
                Text("No Account Found")
                    .font(.system(size: 26, weight: .bold, design: .rounded))

                Text("We couldn't find an account with:")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.secondary)

                Text(email)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.orange)

                Text("This email may not be registered, or you might have signed up with Apple or Google.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("Create New Account")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.mintGreen, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                }

                Button(action: {
                    showNotFound = false
                    email = ""
                }) {
                    Text("Try Another Email")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.mintGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.mintGreen.opacity(0.1))
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Input View
    private var inputView: some View {
        VStack(spacing: 24) {
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 60))
                .foregroundColor(.mintGreen)
                .padding(.top, 40)

            Text("Reset Password")
                .font(.system(size: 24, weight: .bold, design: .rounded))

            Text("Enter your email and we'll send you a link to reset your password.")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            AuthTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            .padding(.horizontal, 24)

            Button {
                sendResetEmail()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Send Reset Link")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.mintGreen)
                .cornerRadius(14)
            }
            .disabled(email.isEmpty || isLoading)
            .opacity(email.isEmpty ? 0.6 : 1)
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func sendResetEmail() {
        guard !email.isEmpty else { return }
        isLoading = true

        Task {
            do {
                try await SupabaseConfig.client.auth.resetPasswordForEmail(
                    email,
                    redirectTo: URL(string: "https://spycidicy.github.io/cozynclex-auth-redirect/")
                )
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                let errorMessage = error.localizedDescription.lowercased()
                await MainActor.run {
                    isLoading = false
                    if errorMessage.contains("not found") ||
                       errorMessage.contains("no user") ||
                       errorMessage.contains("invalid") ||
                       errorMessage.contains("unable to validate") {
                        showNotFound = true
                    } else {
                        // For security, show success even on other errors
                        showSuccess = true
                    }
                }
            }
        }
    }
}

// MARK: - Custom Text Fields

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
        }
        .padding()
        .background(Color.adaptiveWhite)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct AuthSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)

            if isVisible {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } else {
                SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Button(action: { isVisible.toggle() }) {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.adaptiveWhite)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Newsletter Toggle

struct NewsletterToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack(spacing: 12) {
                // Custom checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isOn ? Color.mintGreen : Color.gray.opacity(0.4), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isOn {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.mintGreen)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Get study tips & updates")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)

                    Text("Join 10,000+ nursing students")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "envelope.badge.fill")
                    .foregroundColor(isOn ? .mintGreen : .gray.opacity(0.4))
                    .font(.system(size: 18))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(Color.adaptiveWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isOn ? Color.mintGreen.opacity(0.3) : Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    AuthView()
}
