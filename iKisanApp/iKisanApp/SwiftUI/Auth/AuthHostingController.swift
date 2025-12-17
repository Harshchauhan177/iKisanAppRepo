//
//  AuthHostingController.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  UIHostingController bridge for SwiftUI Authentication Views
//

import UIKit
import SwiftUI

/// Hosting controller for Login View
final class LoginHostingController: UIHostingController<LoginView> {
    
    init() {
        super.init(rootView: LoginView())
        setupHostingController()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: LoginView())
        setupHostingController()
    }
    
    private func setupHostingController() {
        // Hide navigation bar for custom design
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

/// Hosting controller for Signup View
final class SignupHostingController: UIHostingController<SignupView> {
    
    init() {
        super.init(rootView: SignupView())
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SignupView())
    }
}

/// Hosting controller for OTP Verification View
final class OTPVerificationHostingController: UIHostingController<OTPVerificationView> {
    
    init(email: String) {
        super.init(rootView: OTPVerificationView(email: email))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(email:)")
    }
}

/// Hosting controller for Forgot Password View
final class ForgotPasswordHostingController: UIHostingController<ImprovedForgotPasswordView> {
    
    init() {
        super.init(rootView: ImprovedForgotPasswordView())
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ImprovedForgotPasswordView())
    }
}

/// Hosting controller for Reset Password View
final class ResetPasswordHostingController: UIHostingController<ImprovedResetPasswordView> {
    
    init(email: String) {
        super.init(rootView: ImprovedResetPasswordView(email: email))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(email:)")
    }
}
