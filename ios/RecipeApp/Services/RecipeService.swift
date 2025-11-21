import Foundation

class RecipeService {
    static let shared = RecipeService()
    private let client = APIClient.shared

    private init() {}

    // MARK: - Recipe CRUD

    func createRecipe(_ request: CreateRecipeRequest) async throws -> Recipe {
        let response: RecipeResponse = try await client.request(
            endpoint: "/recipes",
            method: "POST",
            body: request
        )
        return response.recipe
    }

    func getRecipes(limit: Int = 50, offset: Int = 0, sortBy: String = "created_at", order: String = "DESC") async throws -> [Recipe] {
        let response: RecipesResponse = try await client.request(
            endpoint: "/recipes?limit=\(limit)&offset=\(offset)&sortBy=\(sortBy)&order=\(order)",
            method: "GET"
        )
        return response.recipes
    }

    func getRecipe(id: UUID) async throws -> Recipe {
        let response: RecipeResponse = try await client.request(
            endpoint: "/recipes/\(id.uuidString)",
            method: "GET"
        )
        return response.recipe
    }

    func updateRecipe(id: UUID, request: CreateRecipeRequest) async throws -> Recipe {
        let response: RecipeResponse = try await client.request(
            endpoint: "/recipes/\(id.uuidString)",
            method: "PUT",
            body: request
        )
        return response.recipe
    }

    func deleteRecipe(id: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/recipes/\(id.uuidString)",
            method: "DELETE"
        )
    }

    func searchRecipes(query: String) async throws -> [Recipe] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let response: RecipesResponse = try await client.request(
            endpoint: "/recipes/search?q=\(encodedQuery)",
            method: "GET"
        )
        return response.recipes
    }

    func toggleFavorite(id: UUID) async throws -> Recipe {
        let response: RecipeResponse = try await client.request(
            endpoint: "/recipes/\(id.uuidString)/favorite",
            method: "POST"
        )
        return response.recipe
    }

    // MARK: - Images

    func uploadImages(recipeId: UUID, images: [Data]) async throws -> RecipeResponse {
        return try await client.uploadImages(
            endpoint: "/recipes/\(recipeId.uuidString)/images",
            images: images
        )
    }

    func deleteImage(recipeId: UUID, imageId: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/recipes/\(recipeId.uuidString)/images/\(imageId.uuidString)",
            method: "DELETE"
        )
    }

    func setPrimaryImage(recipeId: UUID, imageId: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/recipes/\(recipeId.uuidString)/images/\(imageId.uuidString)/primary",
            method: "PUT"
        )
    }

    // MARK: - Daily Recipe

    func getDailyRecipe() async throws -> Recipe {
        let response: DailyRecipeResponse = try await client.request(
            endpoint: "/recipe-of-the-day",
            method: "GET",
            requiresAuth: false
        )
        return response.recipe
    }

    func getDailyRecipeHistory() async throws -> [DailyRecipeHistoryItem] {
        let response: DailyRecipeHistory = try await client.request(
            endpoint: "/recipe-of-the-day/history",
            method: "GET",
            requiresAuth: false
        )
        return response.history
    }
}
