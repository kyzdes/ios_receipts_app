import Foundation

class CategoryService {
    static let shared = CategoryService()
    private let client = APIClient.shared

    private init() {}

    func getCategories() async throws -> [Category] {
        let response: CategoriesResponse = try await client.request(
            endpoint: "/categories",
            method: "GET"
        )
        return response.categories
    }

    func createCategory(_ request: CategoryRequest) async throws -> Category {
        let response: CategoryResponse = try await client.request(
            endpoint: "/categories",
            method: "POST",
            body: request
        )
        return response.category
    }

    func updateCategory(id: UUID, request: CategoryRequest) async throws -> Category {
        let response: CategoryResponse = try await client.request(
            endpoint: "/categories/\(id.uuidString)",
            method: "PUT",
            body: request
        )
        return response.category
    }

    func deleteCategory(id: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/categories/\(id.uuidString)",
            method: "DELETE"
        )
    }

    func addRecipeToCategory(recipeId: UUID, categoryId: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/categories/\(categoryId.uuidString)/recipes/\(recipeId.uuidString)",
            method: "POST"
        )
    }

    func removeRecipeFromCategory(recipeId: UUID, categoryId: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/categories/\(categoryId.uuidString)/recipes/\(recipeId.uuidString)",
            method: "DELETE"
        )
    }
}
