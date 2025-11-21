import SwiftUI

struct RecipesView: View {
    @EnvironmentObject var recipeViewModel: RecipeViewModel
    @State private var showingCreateRecipe = false
    @State private var viewMode: ViewMode = .grid

    enum ViewMode {
        case grid, list
    }

    var body: some View {
        NavigationView {
            Group {
                if recipeViewModel.isLoading && recipeViewModel.recipes.isEmpty {
                    ProgressView()
                } else if recipeViewModel.recipes.isEmpty {
                    EmptyStateView(
                        icon: "book.closed",
                        title: "No Recipes Yet",
                        message: "Start by creating your first recipe!"
                    )
                } else {
                    ScrollView {
                        if viewMode == .grid {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                ForEach(recipeViewModel.recipes) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeCard(recipe: recipe, isCompact: true)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        } else {
                            LazyVStack(spacing: 15) {
                                ForEach(recipeViewModel.recipes) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeCard(recipe: recipe, isListView: true)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("My Recipes")
            .searchable(text: $recipeViewModel.searchText, prompt: "Search recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewMode = viewMode == .grid ? .list : .grid }) {
                        Image(systemName: viewMode == .grid ? "list.bullet" : "square.grid.2x2")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateRecipe = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateRecipe) {
                CreateRecipeView()
            }
            .task {
                if recipeViewModel.recipes.isEmpty {
                    await recipeViewModel.loadRecipes()
                }
            }
            .refreshable {
                await recipeViewModel.loadRecipes()
            }
        }
    }
}
