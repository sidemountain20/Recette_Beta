//
//  RecetteApp.swift
//  Recette
//
//  Created by 横山哲也 on 2025/08/11.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct RecetteApp: App {
    // Firebase初期化用のAppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// プレビュー用のアプリ
#if DEBUG
struct RecetteApp_Previews: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.healthKit, MockHealthKit())
        }
    }
}
#endif

// Firebase初期化用のAppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // プレビュー環境ではFirebase初期化をスキップ
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            print("プレビュー環境のため、Firebase初期化をスキップします")
            return true
        }
        #endif
        
        // Firebase初期化
        do {
            FirebaseApp.configure()
            print("Firebase初期化完了")
        } catch {
            print("Firebase初期化エラー: \(error)")
        }
        
        // GoogleSignIn設定
        configureGoogleSignIn()
        
        return true
    }
    
    private func configureGoogleSignIn() {
        // GoogleSignInの設定
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            print("GoogleService-Info.plistが見つからないか、CLIENT_IDが設定されていません")
            print("GoogleSignInは無効化されます")
            return
        }
        
        // シミュレーター環境での安全な設定
        #if targetEnvironment(simulator)
        print("シミュレーター環境でGoogleSignInを設定中...")
        #endif
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        print("GoogleSignIn設定完了: \(clientId)")
    }
}
