//
//  SignUpView.swift
//  Recette
//
//  Created by 横山哲也 on 2025/08/11.
//

import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = true
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.2, blue: 0.2),
                        Color(red: 0.8, green: 0.1, blue: 0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // ロゴとタイトル
                        VStack(spacing: 20) {
                            Image(systemName: "carrot.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text("Recette")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("美味しいレシピを発見しよう")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 50)
                        
                        // メインフォーム
                        VStack(spacing: 20) {
                            // メールアドレス入力
                            VStack(alignment: .leading, spacing: 8) {
                                Text("メールアドレス")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("example@email.com", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            
                            // パスワード入力
                            VStack(alignment: .leading, spacing: 8) {
                                Text("パスワード")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    if showPassword {
                                        TextField("パスワードを入力", text: $password)
                                    } else {
                                        SecureField("パスワードを入力", text: $password)
                                    }
                                    
                                    Button(action: {
                                        showPassword.toggle()
                                    }) {
                                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // 確認パスワード（サインアップ時のみ）
                            if isSignUp {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("パスワード確認")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    HStack {
                                        if showConfirmPassword {
                                            TextField("パスワードを再入力", text: $confirmPassword)
                                        } else {
                                            SecureField("パスワードを再入力", text: $confirmPassword)
                                        }
                                        
                                        Button(action: {
                                            showConfirmPassword.toggle()
                                        }) {
                                            Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            
                            // エラーメッセージ
                            if !authViewModel.errorMessage.isEmpty {
                                Text(authViewModel.errorMessage)
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // メインアクションボタン
                            Button(action: {
                                if isSignUp {
                                    authViewModel.signUpWithEmail(email: email, password: password)
                                } else {
                                    authViewModel.signInWithEmail(email: email, password: password)
                                }
                            }) {
                                HStack {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    
                                    Text(isSignUp ? "アカウント作成" : "ログイン")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            .disabled(authViewModel.isLoading)
                            
                            // ソーシャルログインボタン
                            VStack(spacing: 15) {
                                // 区切り線
                                HStack {
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.white.opacity(0.3))
                                    
                                    Text("または")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 10)
                                    
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                
                                // Appleサインイン
                                #if DEBUG
                                // プレビュー用のモックボタン
                                Button(action: {
                                    print("Apple Sign In tapped (Preview)")
                                }) {
                                    HStack {
                                        Image(systemName: "applelogo")
                                            .font(.title2)
                                        Text("Appleでサインイン")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(10)
                                }
                                .disabled(authViewModel.isLoading)
                                #else
                                // 実際のAppleサインインボタン
                                SignInWithAppleButton(
                                    onRequest: { request in
                                        request.requestedScopes = [.fullName, .email]
                                    },
                                    onCompletion: { result in
                                        switch result {
                                        case .success(let authResults):
                                            print("Apple Sign In success: \(authResults)")
                                        case .failure(let error):
                                            print("Apple Sign In failed: \(error)")
                                        }
                                    }
                                )
                                .signInWithAppleButtonStyle(.white)
                                .frame(height: 50)
                                .cornerRadius(10)
                                #endif
                                
                                // Googleサインイン
                                Button(action: {
                                    authViewModel.signInWithGoogle()
                                }) {
                                    HStack {
                                        Image(systemName: "globe")
                                            .font(.title2)
                                        Text("Googleでサインイン")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                }
                                .disabled(authViewModel.isLoading)
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // サインアップ/サインイン切り替え
                        HStack {
                            Text(isSignUp ? "すでにアカウントをお持ちですか？" : "アカウントをお持ちでないですか？")
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button(action: {
                                isSignUp.toggle()
                                email = ""
                                password = ""
                                confirmPassword = ""
                                authViewModel.errorMessage = ""
                            }) {
                                Text(isSignUp ? "ログイン" : "アカウント作成")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    SignUpView()
}
