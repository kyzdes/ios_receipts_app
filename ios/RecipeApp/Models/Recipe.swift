import Foundation

struct Recipe: Codable, Identifiable {
    let id: UUID
    let userId: UUID?
    var title: String
    var ingredients: [Ingredient]
    var instructions: [Instruction]
    var prepTime: Int?
    var cookTime: Int?
    var servings: Int?
    var difficulty: Difficulty?
    var isFavorite: Bool
    var notes: String?
    var images: [RecipeImage]
    var categories: [Category]
    var folders: [Folder]
    let createdAt: Date?
    let updatedAt: Date?

    var primaryImage: RecipeImage? {
        images.first { $0.isPrimary } ?? images.first
    }

    var totalTime: Int? {
        guard let prep = prepTime, let cook = cookTime else { return nil }
        return prep + cook
    }

    enum CodingKeys: String, CodingKey {
        case id, title, ingredients, instructions, servings, difficulty, notes, images, categories, folders
        case userId = "user_id"
        case prepTime = "prep_time"
        case cookTime = "cook_time"
        case isFavorite = "is_favorite"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Ingredient: Codable, Identifiable {
    let id: UUID
    var name: String
    var quantity: String
    var unit: String?

    init(id: UUID = UUID(), name: String, quantity: String, unit: String? = nil) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}

struct Instruction: Codable, Identifiable {
    let id: UUID
    var step: Int
    var description: String

    init(id: UUID = UUID(), step: Int, description: String) {
        self.id = id
        self.step = step
        self.description = description
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy, medium, hard

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .easy: return "🟢"
        case .medium: return "🟡"
        case .hard: return "🔴"
        }
    }
}

struct RecipeImage: Codable, Identifiable {
    let id: UUID
    let url: String
    let isPrimary: Bool

    enum CodingKeys: String, CodingKey {
        case id, url
        case isPrimary = "is_primary"
    }
}

// Request/Response models
struct CreateRecipeRequest: Codable {
    let title: String
    let ingredients: [Ingredient]
    let instructions: [Instruction]
    let prepTime: Int?
    let cookTime: Int?
    let servings: Int?
    let difficulty: Difficulty?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case title, ingredients, instructions, servings, difficulty, notes
        case prepTime = "prep_time"
        case cookTime = "cook_time"
    }
}

struct RecipeResponse: Codable {
    let recipe: Recipe
    let message: String?
}

struct RecipesResponse: Codable {
    let recipes: [Recipe]
    let count: Int
}
