import SwiftUI

@main
struct RecipeApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var recipeViewModel = RecipeViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(recipeViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
