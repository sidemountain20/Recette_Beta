//
//  AuthViewModel.swift
//  Recette
//
//  Created by 横山哲也 on 2025/08/11.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: String = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var appleSignInDelegate: AppleSignInDelegate?
    private var appleSignInPresentationContextProvider: AppleSignInPresentationContextProvider?
    
    init() {
        // プレビュー環境での初期化
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            print("プレビュー環境でAuthViewModelを初期化中")
            isAuthenticated = false
            currentUser = ""
            isLoading = false
            errorMessage = ""
            return
        }
        #endif
        
        // デモ用の初期化
        isAuthenticated = false
        currentUser = ""
        isLoading = false
        errorMessage = ""
    }
    
    // メールアドレスとパスワードでサインアップ
    func signUpWithEmail(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        // 基本的なバリデーション
        guard !email.isEmpty, !password.isEmpty else {
            isLoading = false
            errorMessage = "メールアドレスとパスワードを入力してください"
            return
        }
        
        guard password.count >= 6 else {
            isLoading = false
            errorMessage = "パスワードは6文字以上で入力してください"
            return
        }
        
        // デモ用の処理（実際のFirebase認証は後で実装）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.currentUser = email
            self.isAuthenticated = true
        }
    }
    
    // メールアドレスとパスワードでサインイン
    func signInWithEmail(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        // 基本的なバリデーション
        guard !email.isEmpty, !password.isEmpty else {
            isLoading = false
            errorMessage = "メールアドレスとパスワードを入力してください"
            return
        }
        
        // デモ用の処理（実際のFirebase認証は後で実装）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.currentUser = email
            self.isAuthenticated = true
        }
    }
    
    // Appleサインイン
    func signInWithApple() {
        isLoading = true
        errorMessage = ""
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        appleSignInDelegate = AppleSignInDelegate { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let credential):
                    self?.handleAppleSignIn(credential: credential)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        
        appleSignInPresentationContextProvider = AppleSignInPresentationContextProvider()
        
        authorizationController.delegate = appleSignInDelegate
        authorizationController.presentationContextProvider = appleSignInPresentationContextProvider
        authorizationController.performRequests()
    }
    
    // Googleサインイン
    func signInWithGoogle() {
        isLoading = true
        errorMessage = ""
        
        // GoogleSignInの設定が完了しているかチェック
        guard GIDSignIn.sharedInstance.configuration != nil else {
            isLoading = false
            errorMessage = "GoogleSignInの設定が完了していません"
            return
        }
        
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            isLoading = false
            errorMessage = "ビューコントローラーが見つかりません"
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    // エラーの詳細をログに出力
                    print("GoogleSignIn error: \(error.localizedDescription)")
                    
                    // ユーザーがキャンセルした場合はエラーメッセージを表示しない
                    if let signInError = error as? GIDSignInError {
                        switch signInError.code {
                        case .canceled:
                            // ユーザーがキャンセルした場合は何もしない
                            return
                        default:
                            self?.errorMessage = "Googleサインインに失敗しました: \(error.localizedDescription)"
                        }
                    } else {
                        self?.errorMessage = "Googleサインインに失敗しました: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let user = result?.user else {
                    self?.errorMessage = "Googleサインインに失敗しました"
                    return
                }
                
                self?.handleGoogleSignIn(user: user)
            }
        }
    }
    
    // Appleサインインの処理
    private func handleAppleSignIn(credential: ASAuthorizationAppleIDCredential) {
        // デモ用の処理（実際のFirebase認証は後で実装）
        currentUser = credential.email ?? "Apple User"
        isAuthenticated = true
    }
    
    // Googleサインインの処理
    private func handleGoogleSignIn(user: GIDGoogleUser) {
        // デモ用の処理（実際のFirebase認証は後で実装）
        currentUser = user.profile?.email ?? "Google User"
        isAuthenticated = true
    }
    
    // サインアウト
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isAuthenticated = false
        currentUser = ""
        errorMessage = ""
    }
}

// Appleサインイン用のデリゲート
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let completion: (Result<ASAuthorizationAppleIDCredential, Error>) -> Void
    
    init(completion: @escaping (Result<ASAuthorizationAppleIDCredential, Error>) -> Void) {
        self.completion = completion
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            completion(.success(appleIDCredential))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
}

// Appleサインイン用のプレゼンテーションコンテキストプロバイダー
class AppleSignInPresentationContextProvider: NSObject, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
