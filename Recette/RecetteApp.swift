//
//  RecetteApp.swift
//  Recette
//
//  Created by 横山哲也 on 2025/08/11.
//

import SwiftUI
import Firebase

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
            return true
        }
        #endif
        
        // Firebase初期化
        FirebaseApp.configure()
        return true
    }
}
