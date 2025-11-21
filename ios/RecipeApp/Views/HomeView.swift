import SwiftUI

struct HomeView: View {
    @StateObject private var dailyRecipeViewModel = DailyRecipeViewModel()
    @EnvironmentObject var recipeViewModel: RecipeViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Recipe of the Day
                    if let dailyRecipe = dailyRecipeViewModel.dailyRecipe {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recipe of the Day")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            NavigationLink(destination: RecipeDetailView(recipe: dailyRecipe)) {
                                RecipeCard(recipe: dailyRecipe, isFeatured: true)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    // Recent Recipes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Recipes")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        if recipeViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(Array(recipeViewModel.recipes.prefix(10))) { recipe in
                                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                            RecipeCard(recipe: recipe, isCompact: true)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Quick Actions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Actions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        HStack(spacing: 15) {
                            NavigationLink(destination: CreateRecipeView()) {
                                QuickActionCard(
                                    icon: "plus.circle.fill",
                                    title: "New Recipe",
                                    color: .blue
                                )
                            }

                            NavigationLink(destination: RecipeScannerView()) {
                                QuickActionCard(
                                    icon: "camera.fill",
                                    title: "Scan Recipe",
                                    color: .green
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .task {
                await dailyRecipeViewModel.loadDailyRecipe()
                await recipeViewModel.loadRecipes()
            }
            .refreshable {
                await dailyRecipeViewModel.loadDailyRecipe()
                await recipeViewModel.loadRecipes()
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}
