import Foundation

struct DailyRecipe: Codable, Identifiable {
    let id: UUID
    let recipe: Recipe
    let featuredDate: Date

    enum CodingKeys: String, CodingKey {
        case id, recipe
        case featuredDate = "featured_date"
    }
}

struct DailyRecipeResponse: Codable {
    let recipe: Recipe
}

struct DailyRecipeHistory: Codable {
    let history: [DailyRecipeHistoryItem]
}

struct DailyRecipeHistoryItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let featuredDate: Date
    let primaryImage: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case featuredDate = "featured_date"
        case primaryImage = "primary_image"
    }
}
