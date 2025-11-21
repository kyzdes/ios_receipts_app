import Foundation
import Combine

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let categoryService = CategoryService.shared

    func loadCategories() async {
        isLoading = true
        errorMessage = nil

        do {
            categories = try await categoryService.getCategories()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createCategory(name: String, color: String?, icon: String?) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = CategoryRequest(name: name, color: color, icon: icon)
            let category = try await categoryService.createCategory(request)
            categories.append(category)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func updateCategory(id: UUID, name: String, color: String?, icon: String?) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = CategoryRequest(name: name, color: color, icon: icon)
            let category = try await categoryService.updateCategory(id: id, request: request)
            if let index = categories.firstIndex(where: { $0.id == id }) {
                categories[index] = category
            }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func deleteCategory(id: UUID) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await categoryService.deleteCategory(id: id)
            categories.removeAll { $0.id == id }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
