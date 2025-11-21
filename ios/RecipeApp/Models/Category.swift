import Foundation

struct Category: Codable, Identifiable {
    let id: UUID
    let userId: UUID?
    var name: String
    var color: String?
    var icon: String?
    let recipeCount: Int?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, color, icon
        case userId = "user_id"
        case recipeCount = "recipe_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CategoryRequest: Codable {
    let name: String
    let color: String?
    let icon: String?
}

struct CategoryResponse: Codable {
    let category: Category
    let message: String?
}

struct CategoriesResponse: Codable {
    let categories: [Category]
}
