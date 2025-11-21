import Foundation
import Combine
import SwiftUI

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var selectedRecipe: Recipe?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    private let recipeService = RecipeService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSearchDebounce()
    }

    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                Task {
                    if text.isEmpty {
                        await self?.loadRecipes()
                    } else {
                        await self?.searchRecipes(query: text)
                    }
                }
            }
            .store(in: &cancellables)
    }

    func loadRecipes() async {
        isLoading = true
        errorMessage = nil

        do {
            recipes = try await recipeService.getRecipes()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadRecipe(id: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            selectedRecipe = try await recipeService.getRecipe(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createRecipe(_ request: CreateRecipeRequest) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let recipe = try await recipeService.createRecipe(request)
            recipes.insert(recipe, at: 0)
            selectedRecipe = recipe
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func updateRecipe(id: UUID, request: CreateRecipeRequest) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let recipe = try await recipeService.updateRecipe(id: id, request: request)
            if let index = recipes.firstIndex(where: { $0.id == id }) {
                recipes[index] = recipe
            }
            selectedRecipe = recipe
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func deleteRecipe(id: UUID) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await recipeService.deleteRecipe(id: id)
            recipes.removeAll { $0.id == id }
            if selectedRecipe?.id == id {
                selectedRecipe = nil
            }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func searchRecipes(query: String) async {
        isLoading = true
        errorMessage = nil

        do {
            recipes = try await recipeService.searchRecipes(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleFavorite(id: UUID) async {
        do {
            let recipe = try await recipeService.toggleFavorite(id: id)
            if let index = recipes.firstIndex(where: { $0.id == id }) {
                recipes[index] = recipe
            }
            if selectedRecipe?.id == id {
                selectedRecipe = recipe
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func uploadImages(recipeId: UUID, images: [Data]) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await recipeService.uploadImages(recipeId: recipeId, images: images)
            // Reload the recipe to get updated images
            await loadRecipe(id: recipeId)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
