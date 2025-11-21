import Foundation
import Combine

@MainActor
class FolderViewModel: ObservableObject {
    @Published var folders: [Folder] = []
    @Published var selectedFolder: Folder?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let folderService = FolderService.shared

    func loadFolders() async {
        isLoading = true
        errorMessage = nil

        do {
            folders = try await folderService.getFolders()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadFolder(id: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            selectedFolder = try await folderService.getFolder(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createFolder(name: String, parentFolderId: UUID?) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = FolderRequest(name: name, parentFolderId: parentFolderId)
            let folder = try await folderService.createFolder(request)
            folders.append(folder)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func updateFolder(id: UUID, name: String, parentFolderId: UUID?) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = FolderRequest(name: name, parentFolderId: parentFolderId)
            let folder = try await folderService.updateFolder(id: id, request: request)
            if let index = folders.firstIndex(where: { $0.id == id }) {
                folders[index] = folder
            }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func deleteFolder(id: UUID) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await folderService.deleteFolder(id: id)
            folders.removeAll { $0.id == id }
            if selectedFolder?.id == id {
                selectedFolder = nil
            }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
