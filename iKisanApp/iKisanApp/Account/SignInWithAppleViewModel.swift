//
//  SignInWithAppleViewModel.swift
//  iKisanApp
//
//  Created by harsh chauhan on 13/06/25.
//

import Foundation
import AuthenticationServices
import CryptoKit
import Supabase
import SwiftUI

class SignInWithAppleViewModel: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var navigateToHome = false
    @Published var showNameEntry = false
    @Published var errorMessage: String?
    @Published var lastSupabaseSession: Session?
    
    private var currentNonce: String?
    private let supabase = SupabaseManager.shared
    private var pendingSession: Session?
    var pendingEmail: String = ""
    
    private enum UserDefaultsKeys {
        static let sessionKey = "supabase_session"
        static let userIdKey = "user_id"
        static let userEmailKey = "user_email"
    }
    
    override init() {
        super.init()
        Task {
            await checkAndRestoreSession()
        }
    }
    
    private func checkAndRestoreSession() async {
        guard let sessionString = UserDefaults.standard.string(forKey: UserDefaultsKeys.sessionKey),
              let sessionData = sessionString.data(using: .utf8) else {
            print("❌ No saved session found")
            return
        }
        
        do {
            let sessionDict = try JSONDecoder().decode([String: String].self, from: sessionData)
            guard let accessToken = sessionDict["accessToken"],
                  let refreshToken = sessionDict["refreshToken"],
                  !accessToken.isEmpty,
                  !refreshToken.isEmpty else {
                print("❌ Invalid session data found")
                await clearSession()
                return
            }
            
            do {
                try await supabase.client.auth.setSession(accessToken: accessToken, refreshToken: refreshToken)
                await MainActor.run {
                    self.isAuthenticated = true
                    self.navigateToHome = true
                    print("✅ Session restored")
                }
            } catch {
                print("❌ Failed to set session: \(error)")
                await clearSession()
            }
        } catch {
            print("❌ Failed to restore session: \(error)")
            await clearSession()
        }
    }
    
    private func saveSession(_ session: Session) async {
        do {
            let sessionDict = [
                "accessToken": session.accessToken,
                "refreshToken": session.refreshToken
            ]
            let sessionData = try JSONEncoder().encode(sessionDict)
            if let sessionString = String(data: sessionData, encoding: .utf8) {
                UserDefaults.standard.set(sessionString, forKey: UserDefaultsKeys.sessionKey)
                UserDefaults.standard.set(session.user.id.uuidString, forKey: UserDefaultsKeys.userIdKey)
                UserDefaults.standard.set(session.user.email, forKey: UserDefaultsKeys.userEmailKey)
                
                do {
                    try await supabase.client.auth.setSession(accessToken: session.accessToken, refreshToken: session.refreshToken)
                    await MainActor.run {
                        self.isAuthenticated = true
                        self.navigateToHome = true
                    }
                    print("✅ Session saved and set")
                } catch {
                    print("❌ Failed to set session: \(error)")
                    await clearSession()
                }
            }
        } catch {
            print("❌ Failed to save session: \(error)")
        }
    }
    
    private func clearSession() async {
        await MainActor.run {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.sessionKey)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userIdKey)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userEmailKey)
            self.isAuthenticated = false
            self.navigateToHome = false
            self.showNameEntry = false
        }
    }

    func signIn() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func handleAppleSignIn(credential: ASAuthorizationAppleIDCredential) async {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8),
              let currentNonce = currentNonce else {
            await MainActor.run {
                self.errorMessage = "Failed to get Apple credentials or nonce"
                self.isLoading = false
            }
            return
        }

        let rawName = [credential.fullName?.givenName, credential.fullName?.familyName].compactMap { $0 }.joined(separator: " ")
        let finalName = rawName.isEmpty ? "iKisan User" : rawName
        
        print("📱 Apple Sign In - Constructed Name:", finalName)
        
        // Email might be nil after first sign in
        let rawEmail = credential.email ?? ""
        print("📱 Apple Sign In - Raw Apple Email:", rawEmail)
        print("📱 Apple Sign In - User ID:", credential.user)

        do {
            await MainActor.run { self.isLoading = true }
            
            print("🔄 Attempting Supabase Auth sign in...")
            let session = try await supabase.client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: tokenString,
                    nonce: currentNonce
                )
            )
            self.lastSupabaseSession = session

            print("✅ Supabase Auth Success:")
            print("   - User ID: \(session.user.id)")
            print("   - Email: \(session.user.email ?? "No email")")

            // Always use email from Supabase session if Apple didn't provide it
            let finalEmail = rawEmail.isEmpty ? (session.user.email ?? "") : rawEmail

            // Ensure we have a valid email before proceeding
            guard !finalEmail.isEmpty else {
                await MainActor.run {
                    self.errorMessage = "No email available from Apple or session"
                    self.isLoading = false
                }
                return
            }

            // Check if Apple provided a name
            let appleProvidedName = !rawName.isEmpty
            
            if appleProvidedName {
                // Apple provided a name, check if user exists and has a name
                let userHasName = await checkUserHasName(session)
                
                if userHasName {
                    // User exists and has a name, proceed normally
                    do {
                        print("🔄 Handling Apple Sign In session with AuthManager...")
                        let authUser = try await AuthManager.shared.handleAppleSignInSession(
                            session,
                            name: finalName,
                            email: finalEmail
                        )
                        print("✅ Successfully handled Apple Sign In session")
                        
                        // Save the session
                        await saveSession(session)
                        
                        // Set authentication state
                        await MainActor.run {
                            self.isAuthenticated = true
                            self.navigateToHome = true
                            self.errorMessage = nil
                        }
                    } catch {
                        print("❌ Error handling Apple Sign In session: \(error)")
                        await MainActor.run {
                            self.errorMessage = "Failed to complete sign in: \(error.localizedDescription)"
                        }
                    }
                } else {
                    // User exists but doesn't have a name, show name entry screen
                    print("📝 User exists but name is missing, showing name entry screen")
                    await MainActor.run {
                        self.pendingSession = session
                        self.pendingEmail = finalEmail
                        self.showNameEntry = true
                        self.isLoading = false
                    }
                    return
                }
            } else {
                // Apple didn't provide a name, show name entry screen
                print("📝 Apple didn't provide a name, showing name entry screen")
                await MainActor.run {
                    self.pendingSession = session
                    self.pendingEmail = finalEmail
                    self.showNameEntry = true
                    self.isLoading = false
                }
                return
            }
            
        } catch {
            print("❌ Sign-in error: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "Sign-in failed: \(error.localizedDescription)"
                self.isAuthenticated = false
                self.navigateToHome = false
            }
            await clearSession()
        }
        
        await MainActor.run { self.isLoading = false }
    }

    // MARK: - Nonce Utilities

    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
            for random in randoms {
                if remainingLength == 0 { return result }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Name Validation
    
    private func checkUserHasName(_ session: Session) async -> Bool {
        do {
            // Fetch user details from users table
            let result = try await supabase.client
                .from("users")
                .select("name")
                .eq("userID", value: session.user.id.uuidString)
                .single()
                .execute()
            
            // Try to cast result.data to [String: Any] and extract name
            if let dict = result.data as? [String: Any],
               let nameString = dict["name"] as? String {
                return !nameString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
            }
            // Fallback: Try to decode as Data and parse JSON
            if let data = try? JSONSerialization.data(withJSONObject: result.data, options: []),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let nameString = dict["name"] as? String {
                return !nameString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
            }
            return false
        } catch {
            print("❌ Error checking user name: \(error)")
            return false
        }
    }
    
    // MARK: - Helper Structures
    
    private struct UserUpdateRequest: Encodable {
        let name: String
        let phone: String
    }
    
    func completeSignInWithName(_ name: String, phone: String) async {
        guard let session = pendingSession else {
            await MainActor.run {
                self.errorMessage = "No pending session found"
                self.isLoading = false
            }
            return
        }
        
        // Validate input parameters to prevent crashes
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                self.errorMessage = "Name cannot be empty"
                self.isLoading = false
            }
            return
        }
        
        await MainActor.run { self.isLoading = true }
        
        do {
            // Check if user exists in the database with timeout protection
            let userExists = await checkUserExists(session)
            
            if userExists {
                // User exists, update the name and phone with proper error handling
                let updateData = UserUpdateRequest(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    phone: phone.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                try await supabase.client
                    .from("users")
                    .update(updateData)
                    .eq("userID", value: session.user.id.uuidString)
                    .execute()
                print("✅ Updated existing user's name and phone")
            } else {
                // User doesn't exist, create new user with the provided name and phone
                let newUser = NewUserRequest(
                    userID: session.user.id.uuidString,
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: pendingEmail,
                    phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                    latitude: 0.0,
                    longitude: 0.0,
                    fieldArea: 0.0
                )
                try await supabase.client
                    .from("users")
                    .insert(newUser)
                    .execute()
                print("✅ Created new user with provided name and phone")
            }
            
            // Now handle the Apple Sign In session with proper error handling
            let authUser = try await AuthManager.shared.handleAppleSignInSession(
                session,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: pendingEmail
            )
            
            // Save the session only if everything succeeded
            await saveSession(session)
            
            // Set authentication state
            await MainActor.run {
                self.isAuthenticated = true
                self.navigateToHome = true
                self.showNameEntry = false
                self.errorMessage = nil
                self.pendingSession = nil
                self.pendingEmail = ""
            }
            print("✅ Successfully completed sign in with name and phone: \(name), \(phone)")
        } catch {
            print("❌ Error completing sign in with name and phone: \(error)")
            await MainActor.run {
                // Provide more specific error messages
                let errorMessage: String
                if error.localizedDescription.contains("network") || error.localizedDescription.contains("connection") {
                    errorMessage = "Network error. Please check your connection and try again."
                } else if error.localizedDescription.contains("timeout") {
                    errorMessage = "Request timed out. Please try again."
                } else {
                    errorMessage = "Failed to complete sign in. Please try again."
                }
                
                self.errorMessage = errorMessage
                self.showNameEntry = false
                self.pendingSession = nil
                self.pendingEmail = ""
            }
        }
        await MainActor.run { self.isLoading = false }
    }
    
    private func checkUserExists(_ session: Session) async -> Bool {
        do {
            let result = try await supabase.client
                .from("users")
                .select("userID")
                .eq("userID", value: session.user.id.uuidString)
                .single()
                .execute()
            return true
        } catch {
            return false
        }
    }

    func cancelNameEntry() {
        Task {
            await MainActor.run {
                self.showNameEntry = false
                self.pendingSession = nil
                self.pendingEmail = ""
                self.isLoading = false
                self.errorMessage = nil
            }
        }
    }
}

// MARK: - Apple Sign-In Delegates

extension SignInWithAppleViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            self.errorMessage = "Failed to get Apple credentials"
            return
        }

        Task {
            await handleAppleSignIn(credential: appleIDCredential)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ Apple Sign-In failed: \(error.localizedDescription)")
        
        // Handle specific Apple Sign-In errors to prevent crashes
        let nsError = error as NSError
        let errorMessage: String
        
        switch nsError.code {
        case 1000: // ASAuthorizationErrorCanceled
            errorMessage = "Sign in was canceled"
        case 1001: // ASAuthorizationErrorFailed
            errorMessage = "Sign in failed. Please try again"
        case 1002: // ASAuthorizationErrorInvalidResponse
            errorMessage = "Invalid response from Apple. Please try again"
        case 1003: // ASAuthorizationErrorNotHandled
            errorMessage = "Sign in not handled. Please try again"
        case 1004: // ASAuthorizationErrorUnknown
            errorMessage = "Unknown error occurred. Please try again"
        default:
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
        
        // Ensure UI updates happen on main thread
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = errorMessage
            self?.isLoading = false
            self?.isAuthenticated = false
        }
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // More robust window finding to prevent crashes
        if let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            return keyWindow
        }
        
        // Fallback to first available window
        if let firstWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return firstWindow
        }
        
        // Last resort fallback
        return ASPresentationAnchor()
    }
}
