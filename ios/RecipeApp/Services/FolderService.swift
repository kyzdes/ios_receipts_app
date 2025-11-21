import Foundation

class FolderService {
    static let shared = FolderService()
    private let client = APIClient.shared

    private init() {}

    func getFolders() async throws -> [Folder] {
        let response: FoldersResponse = try await client.request(
            endpoint: "/folders",
            method: "GET"
        )
        return response.folders
    }

    func getFolder(id: UUID) async throws -> Folder {
        let response: FolderResponse = try await client.request(
            endpoint: "/folders/\(id.uuidString)",
            method: "GET"
        )
        return response.folder
    }

    func createFolder(_ request: FolderRequest) async throws -> Folder {
        let response: FolderResponse = try await client.request(
            endpoint: "/folders",
            method: "POST",
            body: request
        )
        return response.folder
    }

    func updateFolder(id: UUID, request: FolderRequest) async throws -> Folder {
        let response: FolderResponse = try await client.request(
            endpoint: "/folders/\(id.uuidString)",
            method: "PUT",
            body: request
        )
        return response.folder
    }

    func deleteFolder(id: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/folders/\(id.uuidString)",
            method: "DELETE"
        )
    }

    func addRecipeToFolder(recipeId: UUID, folderId: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/folders/\(folderId.uuidString)/recipes/\(recipeId.uuidString)",
            method: "POST"
        )
    }

    func removeRecipeFromFolder(recipeId: UUID, folderId: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/folders/\(folderId.uuidString)/recipes/\(recipeId.uuidString)",
            method: "DELETE"
        )
    }
}
