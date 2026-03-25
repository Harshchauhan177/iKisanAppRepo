//
//  RazorpayPaymentViewController.swift
//  iKisanApp
//
//  Created for CoEquip group payments
//  Provides a proper UIKit context for Razorpay SDK to avoid CheckoutBridge issues
//

import UIKit
import Razorpay

/// A dedicated UIKit ViewController for handling Razorpay payments
/// This solves the CheckoutBridge error that occurs when Razorpay is opened from SwiftUI context
class RazorpayPaymentViewController: UIViewController, RazorpayPaymentCompletionProtocol {

    // MARK: - Properties

    private var razorpay: RazorpayCheckout!
    private let razorpayKey = "rzp_test_A9W91a51kUjKmX"

    private var paymentOptions: [String: Any]?
    private var onPaymentComplete: ((Bool, String?) -> Void)?

    // Activity indicator while loading
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0) // iKisan green
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Initializing payment..."
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    /// Initialize with payment options and completion handler
    /// - Parameters:
    ///   - options: Razorpay payment options dictionary
    ///   - completion: Called with (success, paymentId) when payment completes
    init(options: [String: Any], completion: @escaping (Bool, String?) -> Void) {
        self.paymentOptions = options
        self.onPaymentComplete = completion
        super.init(nibName: nil, bundle: nil)

        // Configure modal presentation
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        print("📱 [RazorpayPaymentVC] viewDidLoad - UIKit context established")

        // CRITICAL: Initialize Razorpay SDK immediately in viewDidLoad
        // This gives WKWebView maximum time to inject JavaScript message handlers
        // before the UI is presented, preventing CheckoutBridge Code 1 race condition
        print("🔧 [RazorpayPaymentVC] Initializing Razorpay SDK early (viewDidLoad)")
        razorpay = RazorpayCheckout.initWithKey(razorpayKey, andDelegate: self)
        print("✅ [RazorpayPaymentVC] Razorpay SDK initialized - WKWebView preparing JS bridge")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("📱 [RazorpayPaymentVC] viewDidAppear - View is now visible on screen")
        statusLabel.text = "Preparing secure payment..."

        // CRITICAL: Massive delay to allow WKWebView's JavaScript bridge to fully initialize
        // The CheckoutBridge crash occurs when .open() is called before WebKit
        // finishes compiling and injecting its message handlers
        // 1.5 seconds ensures the bridge is definitively ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            print("💳 [RazorpayPaymentVC] Opening checkout after WKWebView stabilization delay")
            self?.openRazorpayCheckout()
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        // Semi-transparent background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        // Add activity indicator and label
        view.addSubview(activityIndicator)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        activityIndicator.startAnimating()
    }

    // MARK: - Razorpay

    private func openRazorpayCheckout() {
        guard let options = paymentOptions else {
            print("❌ [RazorpayPaymentVC] No payment options provided")
            completePayment(success: false, paymentId: nil)
            return
        }

        print("💳 [RazorpayPaymentVC] Opening Razorpay checkout from UIKit context...")
        statusLabel.text = "Opening payment gateway..."

        // Open Razorpay with explicit display controller to prevent presentation collision
        // This ensures Razorpay presents on top of this VC instead of the root TabBarController
        razorpay.open(options, displayController: self)
    }

    private func completePayment(success: Bool, paymentId: String?) {
        print("🏁 [RazorpayPaymentVC] Completing payment - success: \(success), paymentId: \(paymentId ?? "nil")")

        // Dismiss this VC first, then call completion
        dismiss(animated: false) { [weak self] in
            self?.onPaymentComplete?(success, paymentId)
        }
    }

    // MARK: - RazorpayPaymentCompletionProtocol

    func onPaymentSuccess(_ payment_id: String) {
        print("✅ [RazorpayPaymentVC] Payment successful: \(payment_id)")
        completePayment(success: true, paymentId: payment_id)
    }

    func onPaymentError(_ code: Int32, description str: String) {
        print("❌ [RazorpayPaymentVC] Payment error: \(str) (Code: \(code))")
        completePayment(success: false, paymentId: nil)
    }
}

// MARK: - Presentation Helper

extension RazorpayPaymentViewController {

    /// Present the payment view controller from a specific view controller
    /// - Parameters:
    ///   - presentingVC: The view controller to present from
    ///   - options: Razorpay payment options
    ///   - completion: Called when payment completes
    static func presentOnViewController(
        _ presentingVC: UIViewController,
        with options: [String: Any],
        completion: @escaping (Bool, String?) -> Void
    ) {
        print("📱 [RazorpayPaymentVC] Presenting from specific VC: \(type(of: presentingVC))")

        let paymentVC = RazorpayPaymentViewController(options: options, completion: completion)
        presentingVC.present(paymentVC, animated: false)
    }

    /// Present the payment view controller from the current context
    /// - Parameters:
    ///   - options: Razorpay payment options
    ///   - completion: Called when payment completes
    static func present(with options: [String: Any], completion: @escaping (Bool, String?) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            print("❌ [RazorpayPaymentVC] Could not find root view controller")
            completion(false, nil)
            return
        }

        // Find the topmost presented VC
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        print("📱 [RazorpayPaymentVC] Presenting from: \(type(of: topVC))")

        let paymentVC = RazorpayPaymentViewController(options: options, completion: completion)
        topVC.present(paymentVC, animated: false)
    }
}
