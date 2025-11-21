import Foundation

struct Folder: Codable, Identifiable {
    let id: UUID
    let userId: UUID?
    var name: String
    let parentFolderId: UUID?
    let recipeCount: Int?
    let recipes: [Recipe]?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, recipes
        case userId = "user_id"
        case parentFolderId = "parent_folder_id"
        case recipeCount = "recipe_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct FolderRequest: Codable {
    let name: String
    let parentFolderId: UUID?

    enum CodingKeys: String, CodingKey {
        case name
        case parentFolderId = "parent_folder_id"
    }
}

struct FolderResponse: Codable {
    let folder: Folder
    let message: String?
}

struct FoldersResponse: Codable {
    let folders: [Folder]
}
