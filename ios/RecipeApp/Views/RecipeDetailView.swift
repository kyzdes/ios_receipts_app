import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var recipeViewModel: RecipeViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Images Gallery
                if !recipe.images.isEmpty {
                    TabView {
                        ForEach(recipe.images) { image in
                            AsyncImage(url: URL(string: image.url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .frame(height: 300)
                    .tabViewStyle(PageTabViewStyle())
                }

                VStack(alignment: .leading, spacing: 15) {
                    // Title and Favorite
                    HStack {
                        Text(recipe.title)
                            .font(.title)
                            .fontWeight(.bold)

                        Spacer()

                        Button(action: {
                            Task {
                                await recipeViewModel.toggleFavorite(id: recipe.id)
                            }
                        }) {
                            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    }

                    // Metadata
                    HStack(spacing: 20) {
                        if let prepTime = recipe.prepTime {
                            MetadataItem(icon: "clock", text: "Prep: \(prepTime)m")
                        }

                        if let cookTime = recipe.cookTime {
                            MetadataItem(icon: "flame", text: "Cook: \(cookTime)m")
                        }

                        if let servings = recipe.servings {
                            MetadataItem(icon: "person.2", text: "\(servings) servings")
                        }
                    }
                    .font(.subheadline)

                    if let difficulty = recipe.difficulty {
                        Text("\(difficulty.icon) \(difficulty.displayName)")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(8)
                    }

                    // Ingredients
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.bold)

                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.secondary)

                                Text("\(ingredient.quantity) \(ingredient.unit ?? "") \(ingredient.name)")
                            }
                        }
                    }

                    Divider()

                    // Instructions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.bold)

                        ForEach(recipe.instructions) { instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(instruction.step)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(Color.blue)
                                    .clipShape(Circle())

                                Text(instruction.description)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    // Notes
                    if let notes = recipe.notes, !notes.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text(notes)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Categories
                    if !recipe.categories.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Categories")
                                .font(.headline)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(recipe.categories) { category in
                                        Text(category.name)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditRecipeView(recipe: recipe)
        }
        .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    if await recipeViewModel.deleteRecipe(id: recipe.id) {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this recipe? This action cannot be undone.")
        }
    }
}

struct MetadataItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .foregroundColor(.secondary)
    }
}
