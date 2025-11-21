import Foundation
import Combine

@MainActor
class DailyRecipeViewModel: ObservableObject {
    @Published var dailyRecipe: Recipe?
    @Published var history: [DailyRecipeHistoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let recipeService = RecipeService.shared

    func loadDailyRecipe() async {
        isLoading = true
        errorMessage = nil

        do {
            dailyRecipe = try await recipeService.getDailyRecipe()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadHistory() async {
        isLoading = true
        errorMessage = nil

        do {
            history = try await recipeService.getDailyRecipeHistory()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
