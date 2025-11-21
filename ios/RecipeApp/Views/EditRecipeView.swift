import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    let recipe: Recipe
    @EnvironmentObject var recipeViewModel: RecipeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var ingredients: [Ingredient]
    @State private var instructions: [Instruction]
    @State private var prepTime: String
    @State private var cookTime: String
    @State private var servings: String
    @State private var difficulty: Difficulty
    @State private var notes: String
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var imageData: [Data] = []

    init(recipe: Recipe) {
        self.recipe = recipe
        _title = State(initialValue: recipe.title)
        _ingredients = State(initialValue: recipe.ingredients)
        _instructions = State(initialValue: recipe.instructions)
        _prepTime = State(initialValue: recipe.prepTime != nil ? "\(recipe.prepTime!)" : "")
        _cookTime = State(initialValue: recipe.cookTime != nil ? "\(recipe.cookTime!)" : "")
        _servings = State(initialValue: recipe.servings != nil ? "\(recipe.servings!)" : "")
        _difficulty = State(initialValue: recipe.difficulty ?? .easy)
        _notes = State(initialValue: recipe.notes ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Recipe Title", text: $title)

                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { diff in
                            Text(diff.displayName).tag(diff)
                        }
                    }

                    HStack {
                        TextField("Prep Time (min)", text: $prepTime)
                            .keyboardType(.numberPad)

                        TextField("Cook Time (min)", text: $cookTime)
                            .keyboardType(.numberPad)
                    }

                    TextField("Servings", text: $servings)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Ingredients")) {
                    ForEach(ingredients.indices, id: \.self) { index in
                        HStack {
                            TextField("Qty", text: $ingredients[index].quantity)
                                .frame(width: 50)

                            TextField("Unit", text: Binding(
                                get: { ingredients[index].unit ?? "" },
                                set: { ingredients[index].unit = $0 }
                            ))
                            .frame(width: 50)

                            TextField("Ingredient", text: $ingredients[index].name)

                            Button(action: {
                                ingredients.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Button(action: {
                        ingredients.append(Ingredient(name: "", quantity: ""))
                    }) {
                        Label("Add Ingredient", systemImage: "plus.circle.fill")
                    }
                }

                Section(header: Text("Instructions")) {
                    ForEach(instructions.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text("Step \(index + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack(alignment: .top) {
                                TextEditor(text: $instructions[index].description)
                                    .frame(minHeight: 60)

                                Button(action: {
                                    instructions.remove(at: index)
                                    updateStepNumbers()
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }

                    Button(action: {
                        instructions.append(Instruction(step: instructions.count + 1, description: ""))
                    }) {
                        Label("Add Step", systemImage: "plus.circle.fill")
                    }
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }

                Section(header: Text("Add More Photos")) {
                    PhotosPicker(selection: $selectedImages, maxSelectionCount: 10, matching: .images) {
                        Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                    }

                    if !imageData.isEmpty {
                        Text("\(imageData.count) new photo(s) selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Recipe")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { updateRecipe() }
                    .disabled(title.isEmpty)
            )
            .onChange(of: selectedImages) { newItems in
                Task {
                    imageData = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            imageData.append(data)
                        }
                    }
                }
            }
        }
    }

    func updateStepNumbers() {
        for (index, _) in instructions.enumerated() {
            instructions[index].step = index + 1
        }
    }

    func updateRecipe() {
        let request = CreateRecipeRequest(
            title: title,
            ingredients: ingredients.filter { !$0.name.isEmpty },
            instructions: instructions.filter { !$0.description.isEmpty },
            prepTime: Int(prepTime),
            cookTime: Int(cookTime),
            servings: Int(servings),
            difficulty: difficulty,
            notes: notes.isEmpty ? nil : notes
        )

        Task {
            if await recipeViewModel.updateRecipe(id: recipe.id, request: request) {
                // Upload new images if any
                if !imageData.isEmpty {
                    _ = await recipeViewModel.uploadImages(recipeId: recipe.id, images: imageData)
                }
                dismiss()
            }
        }
    }
}
