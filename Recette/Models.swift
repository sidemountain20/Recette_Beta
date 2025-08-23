//
//  Models.swift
//  Recette
//
//  Created by 横山哲也 on 2025/08/11.
//

import Foundation

// Recipe データモデル
struct Recipe: Identifiable, Codable, Equatable {
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
}

// Ingredient データモデル
struct Ingredient: Identifiable, Codable, Equatable {
    let id = UUID()
    var name: String
    var amount: String

    enum CodingKeys: String, CodingKey {
        case name, amount
    }
}

// ShoppingItem データモデル
struct ShoppingItem: Hashable {
    let id: String
    let name: String
    let quantity: String
}
