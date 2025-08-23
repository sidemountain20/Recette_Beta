//
//  RecipeViewModel.swift
//  Recette
//
//  Created by 横山哲也 on 2025/08/11.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var likedRecipes: [Recipe] = []
    
    private var db: Firestore?
    
    init() {
        // プレビュー環境ではFirebaseを初期化しない
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            print("プレビュー環境のため、RecipeViewModelのFirebase初期化をスキップします")
            isLoading = false
            errorMessage = ""
            recipes = []
            likedRecipes = []
            return
        }
        #endif
        
        // 実際の環境でのみFirebaseを初期化
        if FirebaseApp.app() != nil {
            db = Firestore.firestore()
            loadRecipes()
            loadLikedRecipes()
        } else {
            print("Firebaseが初期化されていません")
            self.errorMessage = "Firebaseが初期化されていません。アプリを再起動してください。"
        }
    }
    
    func loadRecipes() {
        isLoading = true
        errorMessage = ""
        
        // プレビュー環境ではデモ用のデータ
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.recipes = self.getDemoRecipes()
                self.isLoading = false
            }
            return
        }
        #endif
        
        guard let db = db else {
            self.errorMessage = "Firestoreが利用できません。"
            self.isLoading = false
            return
        }
        
        db.collection("recipes").order(by: "createdAt", descending: true).addSnapshotListener { querySnapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "レシピの読み込みに失敗しました: \(error.localizedDescription)"
                    print("Error getting recipes: \(error.localizedDescription)")
                    return
                }
                
                self.recipes = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Recipe.self)
                } ?? []
                print("Recipes loaded: \(self.recipes.count)")
            }
        }
    }
    
    func loadLikedRecipes() {
        // プレビュー環境ではデモ用のデータ
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.likedRecipes = self.getDemoLikedRecipes()
            }
            return
        }
        #endif
        
        guard let db = db else { return }
        
        // お気に入りレシピを取得（例：いいね数が5以上のレシピ）
        db.collection("recipes")
            .whereField("likes", isGreaterThan: 4)
            .order(by: "likes", descending: true)
            .limit(to: 10)
            .addSnapshotListener { querySnapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error getting liked recipes: \(error.localizedDescription)")
                        return
                    }
                    
                    self.likedRecipes = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Recipe.self)
                    } ?? []
                    print("Liked recipes loaded: \(self.likedRecipes.count)")
                }
            }
    }
    
    private func loadDemoRecipes() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.recipes = self.getDemoRecipes()
            self.isLoading = false
        }
    }
    
    private func loadDemoLikedRecipes() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.likedRecipes = self.getDemoLikedRecipes()
        }
    }
    
    private func getDemoRecipes() -> [Recipe] {
        return [
            Recipe(id: UUID().uuidString, title: "デモレシピ1", description: "これはデモ用のレシピです。", ingredients: [Ingredient(name: "材料A", amount: "1個")], instructions: ["手順1", "手順2"], cookingTime: "30分", servings: "2人分", difficulty: "簡単", tags: ["和食", "時短"], estimatedBudget: "500円", estimatedCalories: "300kcal", authorId: "demoUser1", authorName: "デモユーザー1", createdAt: Date().addingTimeInterval(-3600), likes: 5, isPublic: true),
            Recipe(id: UUID().uuidString, title: "デモレシピ2", description: "もう一つのデモレシピ。", ingredients: [Ingredient(name: "材料B", amount: "2個")], instructions: ["手順A", "手順B"], cookingTime: "45分", servings: "4人分", difficulty: "普通", tags: ["洋食", "ヘルシー"], estimatedBudget: "800円", estimatedCalories: "450kcal", authorId: "demoUser2", authorName: "デモユーザー2", createdAt: Date().addingTimeInterval(-7200), likes: 10, isPublic: true)
        ]
    }
    
    private func getDemoLikedRecipes() -> [Recipe] {
        return [
            Recipe(id: UUID().uuidString, title: "嫁カレー", description: "お気に入りのカレーレシピ", ingredients: [Ingredient(name: "ごはん", amount: "4杯"), Ingredient(name: "赤パプリカ", amount: "1/2個"), Ingredient(name: "ズッキーニ", amount: "1/2本")], instructions: ["手順1", "手順2"], cookingTime: "30分", servings: "4人分", difficulty: "簡単", tags: ["和食", "カレー"], estimatedBudget: "2500円", estimatedCalories: "4000kcal", authorId: "demoUser1", authorName: "しゅうとのよめ", createdAt: Date().addingTimeInterval(-3600), likes: 15, isPublic: true),
            Recipe(id: UUID().uuidString, title: "簡単パスタ", description: "時短パスタレシピ", ingredients: [Ingredient(name: "スパゲッティ", amount: "200g"), Ingredient(name: "トマト", amount: "2個")], instructions: ["手順A", "手順B"], cookingTime: "15分", servings: "2人分", difficulty: "簡単", tags: ["洋食", "パスタ"], estimatedBudget: "800円", estimatedCalories: "600kcal", authorId: "demoUser2", authorName: "料理好き", createdAt: Date().addingTimeInterval(-7200), likes: 8, isPublic: true)
        ]
    }
    
    func toggleLike(recipe: Recipe) {
        // プレビュー環境ではデモ用の処理
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
                recipes[index].likes += 1
            }
            return
        }
        #endif
        
        guard let db = db else { return }
        let recipeRef = db.collection("recipes").document(recipe.id)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let recipeDocument: DocumentSnapshot
            do {
                recipeDocument = try transaction.getDocument(recipeRef)
            } catch let fetchError as NSError {
                self.errorMessage = "いいねの更新に失敗しました: \(fetchError.localizedDescription)"
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldLikes = recipeDocument.data()?["likes"] as? Int else {
                let error = NSError(domain: "AppError", code: 0, userInfo: [NSLocalizedDescriptionKey: "いいね数が無効です。"])
                errorPointer?.pointee = error
                return nil
            }
            
            transaction.updateData(["likes": oldLikes + 1], forDocument: recipeRef)
            return nil
        }) { (object, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "いいねの更新に失敗しました: \(error.localizedDescription)"
                }
            } else {
                print("Recipe liked successfully!")
            }
        }
    }
    
    func deleteRecipe(recipe: Recipe) {
        // プレビュー環境ではデモ用の処理
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            recipes.removeAll { $0.id == recipe.id }
            return
        }
        #endif
        
        guard let db = db else { return }
        db.collection("recipes").document(recipe.id).delete { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "レシピの削除に失敗しました: \(error.localizedDescription)"
                } else {
                    self.recipes.removeAll { $0.id == recipe.id }
                    print("Recipe deleted successfully!")
                }
            }
        }
    }
}
