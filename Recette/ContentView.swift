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
    @StateObject private var recipeViewModel = RecipeViewModel()
    @State private var searchText = ""
    @State private var selectedTags: Set<String> = []
    
    var filteredRecipes: [Recipe] {
        var recipes = recipeViewModel.recipes
        
        // 検索フィルター
        if !searchText.isEmpty {
            recipes = recipes.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.description.localizedCaseInsensitiveContains(searchText) ||
                recipe.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // タグフィルター
        if !selectedTags.isEmpty {
            recipes = recipes.filter { recipe in
                !Set(recipe.tags).isDisjoint(with: selectedTags)
            }
        }
        
        return recipes
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダーセクション（赤）
            headerSection
            
            // メインコンテンツエリア（白）
            if recipeViewModel.isLoading {
                loadingView
            } else if filteredRecipes.isEmpty {
                emptyStateView
            } else {
                recipeListView
            }
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .statusBar(hidden: false)
        .refreshable {
            recipeViewModel.loadRecipes()
        }
    }
    
    // ヘッダーセクション
    private var headerSection: some View {
        VStack(spacing: 12) {
            // 検索バー
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                TextField("キーワードを検索", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                }
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
                    ForEach(getAllTags(), id: \.self) { tag in
                        FilterTag(
                            text: tag,
                            isSelected: selectedTags.contains(tag),
                            onTap: {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            
            Spacer(minLength: 8)
        }
        .background(Color(red: 0.9, green: 0.2, blue: 0.2))
        .frame(height: 140)
    }
    
    // ローディングビュー
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("レシピを読み込み中...")
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // 空の状態ビュー
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("レシピが見つかりません")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            
            if !searchText.isEmpty || !selectedTags.isEmpty {
                Text("検索条件を変更してみてください")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            } else {
                Text("レシピを投稿してみましょう！")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // レシピリストビュー
    private var recipeListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredRecipes) { recipe in
                    RecipeCardView(recipe: recipe, recipeViewModel: recipeViewModel)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // すべてのタグを取得
    private func getAllTags() -> [String] {
        let allTags = Set(recipeViewModel.recipes.flatMap { $0.tags })
        return Array(allTags).sorted()
    }
}

// レシピカードビュー
struct RecipeCardView: View {
    let recipe: Recipe
    let recipeViewModel: RecipeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ユーザー情報とアクションアイコン
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                    
                    Text(recipe.authorName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        // 編集アクション（将来的に実装）
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                    
                    Button(action: {
                        recipeViewModel.toggleLike(recipe: recipe)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart")
                                .foregroundColor(.red)
                                .font(.system(size: 18))
                            
                            Text("\(recipe.likes)")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            // レシピ画像（プレースホルダー）
            Rectangle()
                .fill(Color(red: 0.8, green: 0.6, blue: 0.4))
                .frame(height: 200)
                .cornerRadius(12)
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            // 材料のプレビュー
                            VStack(spacing: 4) {
                                ForEach(recipe.ingredients.prefix(3), id: \.id) { ingredient in
                                    Text(ingredient.name)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(4)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                )
            
            // レシピタイトル
            Text(recipe.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            // レシピ説明
            if !recipe.description.isEmpty {
                Text(recipe.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            // レシピタグ
            HStack {
                Text(recipe.tags.map { "#\($0)" }.joined(separator: " "))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("推定予算 : ¥\(recipe.estimatedBudget)-")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
            }
            
            // 材料リスト（最初の3つまで表示）
            VStack(alignment: .leading, spacing: 4) {
                ForEach(recipe.ingredients.prefix(3), id: \.id) { ingredient in
                    Text("\(ingredient.name) \(ingredient.amount)")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                
                if recipe.ingredients.count > 3 {
                    Text("...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            // 基本情報
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("調理時間: \(recipe.cookingTime)分")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                    
                    Text("\(recipe.servings)人前")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(recipe.difficulty)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var difficultyColor: Color {
        switch recipe.difficulty {
        case "簡単":
            return .green
        case "普通":
            return .orange
        case "難しい":
            return .red
        default:
            return .gray
        }
    }
}

// 買い物リスト画面
struct ShoppingListView: View {
    @State private var selectedPage = 1
    @State private var checkedItems: Set<String> = []
    @StateObject private var recipeViewModel = RecipeViewModel()
    @State private var selectedRecipes: [Recipe] = []
    @State private var shoppingItems: [ShoppingItem] = []
    
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
        .onChange(of: selectedRecipes) { _ in
            updateShoppingItems()
        }
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
    
    // 買い物リストページ1（レシピ選択）
    private var shoppingListPage1: some View {
        LazyVStack(spacing: 16) {
            if recipeViewModel.isLoading {
                ProgressView("お気に入りレシピを読み込み中...")
                    .padding()
            } else if recipeViewModel.likedRecipes.isEmpty {
                Text("お気に入りレシピがありません")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(recipeViewModel.likedRecipes) { recipe in
                    shoppingListCard(for: recipe)
                }
            }
        }
    }
    
    // 買い物リストページ2（冷蔵庫にある食材を選択）
    private var shoppingListPage2: some View {
        VStack(spacing: 12) {
            if shoppingItems.isEmpty {
                Text("レシピを選択してください")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(shoppingItems, id: \.id) { item in
                    HStack {
                        Button(action: {
                            if checkedItems.contains(item.id) {
                                checkedItems.remove(item.id)
                            } else {
                                checkedItems.insert(item.id)
                            }
                        }) {
                            Circle()
                                .fill(checkedItems.contains(item.id) ? Color(red: 0.9, green: 0.2, blue: 0.2) : Color.gray.opacity(0.3))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    checkedItems.contains(item.id) ? 
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
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // 買い物リストページ3（今日の買い物リスト）
    private var shoppingListPage3: some View {
        VStack(spacing: 12) {
            let uncheckedItems = shoppingItems.filter { !checkedItems.contains($0.id) }
            
            if uncheckedItems.isEmpty {
                Text("買い物リストは空です")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(uncheckedItems, id: \.id) { item in
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
            }
            
            // 予算とカロリー情報
            if !selectedRecipes.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("推定予算")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("¥\(calculateTotalBudget())-")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        Text("平均推定カロリー")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("\(calculateTotalCalories())kcal/1人前")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(12)
                .background(Color(red: 1.0, green: 0.95, blue: 0.95))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // 買い物リストカード（レシピ用）
    private func shoppingListCard(for recipe: Recipe) -> some View {
        let isSelected = selectedRecipes.contains { $0.id == recipe.id }
        
        return HStack(spacing: 16) {
            // レシピ画像
            Rectangle()
                .fill(Color(red: 0.8, green: 0.6, blue: 0.4))
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                // 材料リスト
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(recipe.ingredients.prefix(3), id: \.id) { ingredient in
                        Text("\(ingredient.name) \(ingredient.amount)")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    if recipe.ingredients.count > 3 {
                        Text("...")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                // レシピ情報
                HStack {
                    Text(recipe.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // 選択ボタン
                    Button(action: {
                        if isSelected {
                            selectedRecipes.removeAll { $0.id == recipe.id }
                        } else {
                            selectedRecipes.append(recipe)
                        }
                    }) {
                        Text(isSelected ? "選択中" : "選択")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isSelected ? Color(red: 0.9, green: 0.2, blue: 0.2) : Color.gray)
                            .cornerRadius(6)
                    }
                }
                
                // 予算とカロリー
                HStack {
                    Text("推定予算: ¥\(recipe.estimatedBudget)-")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("推定カロリー: \(recipe.estimatedCalories)")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color(red: 0.9, green: 0.2, blue: 0.2) : Color.clear, lineWidth: 2)
        )
    }
    
    // 選択されたレシピから買い物アイテムを更新
    private func updateShoppingItems() {
        var allIngredients: [String: (name: String, quantity: String)] = [:]
        
        for recipe in selectedRecipes {
            for ingredient in recipe.ingredients {
                let key = ingredient.name
                if let existing = allIngredients[key] {
                    // 同じ材料がある場合は数量を合計
                    allIngredients[key] = (name: ingredient.name, quantity: "\(existing.quantity) + \(ingredient.amount)")
                } else {
                    allIngredients[key] = (name: ingredient.name, quantity: ingredient.amount)
                }
            }
        }
        
        shoppingItems = allIngredients.map { key, value in
            ShoppingItem(id: key, name: value.name, quantity: value.quantity)
        }.sorted { $0.name < $1.name }
    }
    
    // 総予算を計算
    private func calculateTotalBudget() -> String {
        let total = selectedRecipes.reduce(0) { sum, recipe in
            let budget = Int(recipe.estimatedBudget.replacingOccurrences(of: "円", with: "").replacingOccurrences(of: "¥", with: "")) ?? 0
            return sum + budget
        }
        return "\(total)"
    }
    
    // 総カロリーを計算
    private func calculateTotalCalories() -> String {
        let total = selectedRecipes.reduce(0) { sum, recipe in
            let calories = Int(recipe.estimatedCalories.replacingOccurrences(of: "kcal", with: "").replacingOccurrences(of: ",", with: "")) ?? 0
            return sum + calories
        }
        return "\(total)"
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
    @State private var showRecipePost = false
    
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
        .sheet(isPresented: $showRecipePost) {
            RecipePostView()
        }
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
                showRecipePost = true
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
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(text)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .black : .gray)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 10))
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.white : Color.white.opacity(0.7))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
    
    // データモデル
struct ShoppingItem: Hashable {
    let id: String
    let name: String
    let quantity: String
}

let shoppingItems = [
    ShoppingItem(id: "ごはん", name: "ごはん", quantity: "4杯"),
    ShoppingItem(id: "チーズ", name: "チーズ", quantity: "適量"),
    ShoppingItem(id: "赤パプリカ", name: "赤パプリカ", quantity: "1個"),
    ShoppingItem(id: "ズッキーニ", name: "ズッキーニ", quantity: "1本"),
    ShoppingItem(id: "なす", name: "なす", quantity: "4本"),
    ShoppingItem(id: "かぼちゃ", name: "かぼちゃ", quantity: "1/4個"),
    ShoppingItem(id: "オクラ", name: "オクラ", quantity: "8本"),
    ShoppingItem(id: "サラダ油", name: "サラダ油", quantity: "適量"),
    ShoppingItem(id: "カレールウ", name: "カレールウ", quantity: "4人分"),
    ShoppingItem(id: "合いびき肉", name: "合いびき肉", quantity: "600g"),
    ShoppingItem(id: "玉ねぎ", name: "玉ねぎ", quantity: "2個"),
    ShoppingItem(id: "おろししょうが", name: "おろししょうが", quantity: "小さじ1")
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
        .environmentObject(AuthViewModel())
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
