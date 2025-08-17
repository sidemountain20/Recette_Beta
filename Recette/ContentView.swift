//
//  ContentView.swift
//  Recette
//
//  Created by 横山哲也 on 2025/08/11.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainAppView()
                    .environmentObject(authViewModel)
            } else {
                SignUpView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

// メインアプリビュー
struct MainAppView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecipeView()
                .tabItem {
                    Image(systemName: "carrot")
                    Text("レシピ")
                }
                .tag(0)
            
            ShoppingListView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("買い物リスト")
                }
                .tag(1)
            
            CalorieView()
                .tabItem {
                    Image(systemName: "scalemass")
                    Text("カロリー")
                }
                .tag(2)
            
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("ホーム")
                }
                .tag(3)
        }
        .accentColor(Color(red: 0.9, green: 0.2, blue: 0.2))
        .navigationBarBackButtonHidden(true)
    }
}

// レシピ画面
struct RecipeView: View {
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダーセクション（赤）
            headerSection
            
            // メインコンテンツエリア（白）
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<10, id: \.self) { index in
                        recipeCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            .background(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .statusBar(hidden: false)
    }
    
    // ヘッダーセクション
    private var headerSection: some View {
        VStack(spacing: 12) {
            // 検索バー
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                Text("キーワードを追加")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // フィルタータグ
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterTag(text: "和食")
                    FilterTag(text: "簡単")
                    FilterTag(text: "4人前")
                }
                .padding(.horizontal, 16)
            }
            
            Spacer(minLength: 8)
        }
        .background(Color(red: 0.9, green: 0.2, blue: 0.2))
        .frame(height: 140)
    }
    
    // レシピカード
    private var recipeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ユーザー情報とアクションアイコン
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                    
                    Text("しゅうとのよめ")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        // 編集アクション
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                    
                    Button(action: {
                        // お気に入りアクション
                    }) {
                        Image(systemName: "star")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                }
            }
            
            // レシピ画像
            Rectangle()
                .fill(Color(red: 0.8, green: 0.6, blue: 0.4))
                .frame(height: 200)
                .cornerRadius(12)
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            // ご飯の部分
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 80, height: 60)
                                .cornerRadius(8)
                                .overlay(
                                    Text("ご飯")
                                        .font(.system(size: 12))
                                        .foregroundColor(.black)
                                )
                            
                            Spacer()
                            
                            // カレーの部分
                            VStack(spacing: 4) {
                                ForEach(0..<3) { _ in
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                )
            
            // レシピタイトル
            Text("嫁カレー")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            // レシピタグ
            HStack {
                Text("#和食 #時短 #簡単 #4人前")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("推定予算 : ¥2,500-")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
            }
            
            // 材料リスト
            VStack(alignment: .leading, spacing: 4) {
                Text("ごはん お茶碗 4杯(600g)")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                Text("赤パプリカ 1/2個")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                Text("ズッキーニ 1/2本")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                Text("なす 2本")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                Text("かぼちゃ [スライス] 4枚(60g)")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                Text("オクラ 4本")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                Text("サラダ油 適量")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                Text("...")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// 買い物リスト画面
struct ShoppingListView: View {
    @State private var selectedPage = 1
    @State private var checkedItems: Set<String> = []
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダーセクション（赤）
            shoppingListHeader
            
            // メインコンテンツエリア
            ScrollView {
                VStack(spacing: 16) {
                    if selectedPage == 1 {
                        shoppingListPage1
                    } else if selectedPage == 2 {
                        shoppingListPage2
                    } else {
                        shoppingListPage3
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            .background(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .statusBar(hidden: false)
    }
    
    // 買い物リストヘッダー
    private var shoppingListHeader: some View {
        VStack(spacing: 12) {
            // アプリタイトル
            HStack {
                Text("Recette")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("買い物リスト")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // ページ選択ボタン
            HStack(spacing: 40) {
                ForEach(1...3, id: \.self) { page in
                    Button(action: {
                        selectedPage = page
                    }) {
                        Text("\(page)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(selectedPage == page ? Color.white.opacity(0.3) : Color.clear)
                            )
                    }
                }
            }
            
            // 選択ボタン
            Button(action: {
                // レシピ選択アクション
            }) {
                Text(selectedPage == 1 ? "レシピを選択する" : 
                     selectedPage == 2 ? "冷蔵庫にある食材を選択" : "今日の買い物リスト")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(8)
            }
            
            Spacer(minLength: 8)
        }
        .background(Color(red: 0.9, green: 0.2, blue: 0.2))
        .frame(height: 160)
    }
    
    // 買い物リストページ1
    private var shoppingListPage1: some View {
        LazyVStack(spacing: 16) {
            ForEach(0..<10, id: \.self) { _ in
                shoppingListCard
            }
        }
    }
    
    // 買い物リストページ2
    private var shoppingListPage2: some View {
        VStack(spacing: 12) {
            ForEach(shoppingItems, id: \.self) { item in
                HStack {
                    Button(action: {
                        if checkedItems.contains(item.name) {
                            checkedItems.remove(item.name)
                        } else {
                            checkedItems.insert(item.name)
                        }
                    }) {
                        Circle()
                            .fill(checkedItems.contains(item.name) ? Color(red: 0.9, green: 0.2, blue: 0.2) : Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .overlay(
                                checkedItems.contains(item.name) ? 
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12)) : nil
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text(item.name)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text(item.quantity)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // 買い物リストページ3
    private var shoppingListPage3: some View {
        VStack(spacing: 12) {
            ForEach(shoppingItems.filter { !checkedItems.contains($0.name) }, id: \.self) { item in
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 24, height: 24)
                    
                    Text(item.name)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text(item.quantity)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
            
            // 予算とカロリー情報
            VStack(spacing: 8) {
                HStack {
                    Text("推定予算")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("¥2,500-")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                }
                
                HStack {
                    Text("平均推定カロリー")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("4,000kcal/1人前")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(12)
            .background(Color(red: 1.0, green: 0.95, blue: 0.95))
            .cornerRadius(8)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // 買い物リストカード
    private var shoppingListCard: some View {
        HStack(spacing: 16) {
            // レシピ画像
            Rectangle()
                .fill(Color(red: 0.8, green: 0.6, blue: 0.4))
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                // 材料リスト
                VStack(alignment: .leading, spacing: 2) {
                    Text("ごはん お茶碗 4杯(600g)")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    Text("赤パプリカ 1/2個")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    Text("ズッキーニ 1/2本")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    Text("...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                // レシピ情報
                HStack {
                    Text("嫁カレー")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // 数量選択
                    HStack(spacing: 8) {
                        Button("-") {
                            // 数量減少
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                        
                        Text("1")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        Button("+") {
                            // 数量増加
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                    }
                }
                
                // 予算とカロリー
                HStack {
                    Text("推定予算: ¥2,500-")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("推定カロリー: 2,500kcal")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// カロリー画面
struct CalorieView: View {
    @State private var selectedTab = 0
    @State private var stepCount: Int = 0
    @State private var healthStore: HKHealthStore?
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダーセクション（赤）
            calorieHeader
            
            // メインコンテンツエリア
            ScrollView {
                VStack(spacing: 16) {
                    if selectedTab == 0 {
                        calorieHomeView
                    } else if selectedTab == 1 {
                        calorieMealDataView
                    } else {
                        calorieTrendView
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .onAppear {
                requestHealthKitPermission()
            }
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .statusBar(hidden: false)
    }
    
    // カロリーヘッダー
    private var calorieHeader: some View {
        VStack(spacing: 12) {
            // アプリタイトル
            HStack {
                Text("Recette")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("健康管理")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // タブ選択
            HStack(spacing: 0) {
                ForEach(["ホーム", "食事データ", "今月の推移"], id: \.self) { tab in
                    Button(action: {
                        selectedTab = ["ホーム", "食事データ", "今月の推移"].firstIndex(of: tab) ?? 0
                    }) {
                        Text(tab)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedTab == ["ホーム", "食事データ", "今月の推移"].firstIndex(of: tab) ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedTab == ["ホーム", "食事データ", "今月の推移"].firstIndex(of: tab) ? Color.white : Color.clear
                            )
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer(minLength: 8)
        }
        .background(Color(red: 0.9, green: 0.2, blue: 0.2))
        .frame(height: 160)
    }
    
    // カロリーホームビュー
    private var calorieHomeView: some View {
        VStack(spacing: 16) {
            // 栄養データカード
            VStack(alignment: .leading, spacing: 16) {
                Text("2025年8月10日の栄養データ")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                HStack(spacing: 20) {
                    // 円グラフ
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        VStack {
                            Text("目標まで")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            Text("4,000kcal")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    
                    // カロリー情報
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("目標")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Spacer()
                            Text("1,000kcal")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        HStack {
                            Text("フード")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Spacer()
                            Text("1,000kcal")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        HStack {
                            Text("エクササイズ")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Spacer()
                            Text("1,000kcal")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                }
                
                // 栄養素バー
                VStack(spacing: 8) {
                    ForEach(["炭水化物", "脂質", "タンパク質", "ビタミン", "ミネラル"], id: \.self) { nutrient in
                        HStack {
                            Text(nutrient)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            
            // 活動と体重
            HStack(spacing: 16) {
                VStack {
                    Text("歩数 \(stepCount)歩")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                
                VStack {
                    Text("体重 75.5kg")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
            }
            
            // アクションボタン
            HStack(spacing: 16) {
                Button("食事データを登録する") {
                    // 食事データ登録
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(16)
                
                Button("今月の推移を見る") {
                    // 推移表示
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(16)
            }
        }
    }
    
    // カロリー食事データビュー
    private var calorieMealDataView: some View {
        VStack(spacing: 16) {
            // 日付バナー
            HStack {
                Text("2025年8月10日の食事")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color(red: 0.9, green: 0.2, blue: 0.2))
            .cornerRadius(8)
            
            // データカード
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("平均摂取カロリー")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 100)
                        .cornerRadius(8)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("体重")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 100)
                        .cornerRadius(8)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
            }
            
            // アクションボタン
            HStack(spacing: 16) {
                Button("ホームにもどる") {
                    selectedTab = 0
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(16)
                
                Button("食事データを登録する") {
                    // 食事データ登録
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(16)
            }
        }
    }
    
    // カロリートレンドビュー
    private var calorieTrendView: some View {
        VStack(spacing: 16) {
            Text("今月の推移")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Rectangle()
                .fill(Color.white)
                .frame(height: 200)
                .cornerRadius(16)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // HealthKit権限リクエスト
    private func requestHealthKitPermission() {
        // プレビュー環境ではHealthKitを使用しない
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            stepCount = 8500 // プレビュー用のダミーデータ
            return
        }
        #endif
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            stepCount = 0
            return
        }
        
        healthStore = HKHealthStore()
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        healthStore?.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            if success {
                fetchTodayStepCount()
            } else {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.stepCount = 0
                }
            }
        }
    }
    
    // 今日の歩数を取得
    private func fetchTodayStepCount() {
        guard let healthStore = healthStore else { return }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch step count: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
}

// ホーム画面
struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダーセクション（赤）
            homeHeader
            
            // メインコンテンツエリア（白）
            ScrollView {
                VStack(spacing: 16) {
                    myPageContent
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color.white)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .statusBar(hidden: false)
    }
    
    // ホームヘッダー
    private var homeHeader: some View {
        VStack(spacing: 12) {
            // ユーザー情報
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TETSUYA YOKOYAMAさんの")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Recette")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            Spacer(minLength: 8)
        }
        .background(Color(red: 0.9, green: 0.2, blue: 0.2))
        .frame(height: 140)
    }
    
    // マイページコンテンツ
    private var myPageContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("マイページ")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            VStack(spacing: 0) {
                ForEach(myPageItems, id: \.self) { item in
                    Button(action: {
                        // 各項目のアクション
                    }) {
                        HStack {
                            Text(item)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if item != myPageItems.last {
                        Divider()
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            
            // レシピ投稿ボタン
            Button(action: {
                // レシピ投稿アクション
            }) {
                Text("レシピを投稿する")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(red: 1.0, green: 0.95, blue: 0.95))
                    .cornerRadius(16)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
}

// フィルタータグ
struct FilterTag: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
            
            Button(action: {
                // タグ削除アクション
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .font(.system(size: 10))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(8)
    }
    }
    
    // データモデル
struct ShoppingItem: Hashable {
    let name: String
    let quantity: String
    let isChecked: Bool
}

let shoppingItems = [
    ShoppingItem(name: "ごはん", quantity: "4杯", isChecked: true),
    ShoppingItem(name: "チーズ", quantity: "適量", isChecked: true),
    ShoppingItem(name: "赤パプリカ", quantity: "1個", isChecked: false),
    ShoppingItem(name: "ズッキーニ", quantity: "1本", isChecked: false),
    ShoppingItem(name: "なす", quantity: "4本", isChecked: false),
    ShoppingItem(name: "かぼちゃ", quantity: "1/4個", isChecked: false),
    ShoppingItem(name: "オクラ", quantity: "8本", isChecked: false),
    ShoppingItem(name: "サラダ油", quantity: "適量", isChecked: true),
    ShoppingItem(name: "カレールウ", quantity: "4人分", isChecked: false),
    ShoppingItem(name: "合いびき肉", quantity: "600g", isChecked: false),
    ShoppingItem(name: "玉ねぎ", quantity: "2個", isChecked: true),
    ShoppingItem(name: "おろししょうが", quantity: "小さじ1", isChecked: true)
]

let myPageItems = [
    "アカウント情報",
    "お気に入りレシピ",
    "投稿したレシピ",
    "閲覧履歴",
    "利用規約",
    "ヘルプ",
    "お問い合わせ",
    "ログアウト"
]

#Preview {
    ContentView()
        .environment(\.healthKit, MockHealthKit())
}

// プレビュー用の簡単なテストビュー
struct SimplePreviewView: View {
    var body: some View {
        VStack {
            Text("Recette")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("レシピアプリ")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview("Simple") {
    SimplePreviewView()
}

// プレビュー用のモックHealthKit
struct MockHealthKit {
    func isHealthDataAvailable() -> Bool {
        return false
    }
}

private struct HealthKitKey: EnvironmentKey {
    static let defaultValue = MockHealthKit()
}

extension EnvironmentValues {
    var healthKit: MockHealthKit {
        get { self[HealthKitKey.self] }
        set { self[HealthKitKey.self] = newValue }
    }
}
