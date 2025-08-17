//
//  RecipePostView.swift
//  Recette
//
//  Created by 横山哲也 on 2025/08/11.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct RecipePostView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var recipeTitle = ""
    @State private var recipeDescription = ""
    @State private var ingredients: [Ingredient] = [Ingredient(name: "", amount: "")]
    @State private var instructions: [String] = [""]
    @State private var cookingTime = ""
    @State private var servings = ""
    @State private var difficulty = "簡単"
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var estimatedBudget = ""
    @State private var estimatedCalories = ""
    @State private var isPosting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let difficultyOptions = ["簡単", "普通", "難しい"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // レシピタイトル
                    VStack(alignment: .leading, spacing: 8) {
                        Text("レシピタイトル")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        TextField("例：嫁カレー", text: $recipeTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // レシピ説明
                    VStack(alignment: .leading, spacing: 8) {
                        Text("レシピ説明")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        TextField("レシピの説明を入力してください", text: $recipeDescription, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    // 材料
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("材料")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button("追加") {
                                ingredients.append(Ingredient(name: "", amount: ""))
                            }
                            .foregroundColor(.blue)
                        }
                        
                        ForEach(ingredients.indices, id: \.self) { index in
                            HStack {
                                TextField("材料名", text: $ingredients[index].name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("分量", text: $ingredients[index].amount)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                if ingredients.count > 1 {
                                    Button("削除") {
                                        ingredients.remove(at: index)
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    // 作り方
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("作り方")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button("追加") {
                                instructions.append("")
                            }
                            .foregroundColor(.blue)
                        }
                        
                        ForEach(instructions.indices, id: \.self) { index in
                            HStack {
                                Text("\(index + 1).")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, alignment: .leading)
                                
                                TextField("手順を入力", text: $instructions[index], axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(2...4)
                                
                                if instructions.count > 1 {
                                    Button("削除") {
                                        instructions.remove(at: index)
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    // 基本情報
                    VStack(alignment: .leading, spacing: 12) {
                        Text("基本情報")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("調理時間")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                TextField("分", text: $cookingTime)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("人数")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                TextField("人前", text: $servings)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("難易度")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            Picker("難易度", selection: $difficulty) {
                                ForEach(difficultyOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("推定予算")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                TextField("円", text: $estimatedBudget)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("推定カロリー")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                TextField("kcal", text: $estimatedCalories)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                    
                    // タグ
                    VStack(alignment: .leading, spacing: 8) {
                        Text("タグ")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        HStack {
                            TextField("新しいタグ", text: $newTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("追加") {
                                if !newTag.isEmpty && !tags.contains(newTag) {
                                    tags.append(newTag)
                                    newTag = ""
                                }
                            }
                            .foregroundColor(.blue)
                        }
                        
                        if !tags.isEmpty {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text("#\(tag)")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        
                                        Button("×") {
                                            tags.removeAll { $0 == tag }
                                        }
                                        .foregroundColor(.red)
                                        .font(.caption)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // 投稿ボタン
                    Button(action: postRecipe) {
                        HStack {
                            if isPosting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isPosting ? "投稿中..." : "レシピを投稿する")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.9, green: 0.2, blue: 0.2))
                        .cornerRadius(12)
                        .disabled(isPosting)
                    }
                }
                .padding()
            }
            .navigationTitle("レシピ投稿")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .alert("投稿結果", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("成功") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func postRecipe() {
        guard !recipeTitle.isEmpty else {
            alertMessage = "レシピタイトルを入力してください"
            showAlert = true
            return
        }
        
        guard !ingredients.isEmpty && ingredients.allSatisfy({ !$0.name.isEmpty && !$0.amount.isEmpty }) else {
            alertMessage = "材料を正しく入力してください"
            showAlert = true
            return
        }
        
        guard !instructions.isEmpty && instructions.allSatisfy({ !$0.isEmpty }) else {
            alertMessage = "作り方を入力してください"
            showAlert = true
            return
        }
        
        isPosting = true
        
        // プレビュー環境ではデモ用の処理
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isPosting = false
                self.alertMessage = "レシピの投稿に成功しました！（デモ用）"
                self.showAlert = true
            }
            return
        }
        #endif
        
        // Firebaseの初期化をチェック
        guard FirebaseApp.app() != nil else {
            DispatchQueue.main.async {
                self.isPosting = false
                self.alertMessage = "Firebaseが初期化されていません"
                self.showAlert = true
            }
            return
        }
        
        let recipe = Recipe(
            id: UUID().uuidString,
            title: recipeTitle,
            description: recipeDescription,
            ingredients: ingredients,
            instructions: instructions,
            cookingTime: cookingTime,
            servings: servings,
            difficulty: difficulty,
            tags: tags,
            estimatedBudget: estimatedBudget,
            estimatedCalories: estimatedCalories,
            authorId: authViewModel.currentUser,
            authorName: authViewModel.currentUser,
            createdAt: Date(),
            likes: 0,
            isPublic: true
        )
        
        // Cloud Firestoreに投稿
        let db = Firestore.firestore()
        db.collection("recipes").document(recipe.id).setData(recipe.toDictionary()) { error in
            DispatchQueue.main.async {
                self.isPosting = false
                
                if let error = error {
                    self.alertMessage = "投稿に失敗しました: \(error.localizedDescription)"
                } else {
                    self.alertMessage = "レシピの投稿に成功しました！"
                }
                self.showAlert = true
            }
        }
    }
}

// 材料モデル
struct Ingredient: Codable, Identifiable, Equatable {
    let id = UUID()
    var name: String
    var amount: String
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "amount": amount
        ]
    }
}

// レシピモデル
struct Recipe: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let cookingTime: String
    let servings: String
    let difficulty: String
    let tags: [String]
    let estimatedBudget: String
    let estimatedCalories: String
    let authorId: String
    let authorName: String
    let createdAt: Date
    var likes: Int
    let isPublic: Bool
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "description": description,
            "ingredients": ingredients.map { $0.toDictionary() },
            "instructions": instructions,
            "cookingTime": cookingTime,
            "servings": servings,
            "difficulty": difficulty,
            "tags": tags,
            "estimatedBudget": estimatedBudget,
            "estimatedCalories": estimatedCalories,
            "authorId": authorId,
            "authorName": authorName,
            "createdAt": Timestamp(date: createdAt),
            "likes": likes,
            "isPublic": isPublic
        ]
    }
}

#Preview {
    RecipePostView()
        .environmentObject(AuthViewModel())
}
