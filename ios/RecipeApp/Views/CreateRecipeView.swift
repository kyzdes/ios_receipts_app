import SwiftUI
import PhotosUI

struct CreateRecipeView: View {
    @EnvironmentObject var recipeViewModel: RecipeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var ingredients: [Ingredient] = [Ingredient(name: "", quantity: "")]
    @State private var instructions: [Instruction] = [Instruction(step: 1, description: "")]
    @State private var prepTime = ""
    @State private var cookTime = ""
    @State private var servings = ""
    @State private var difficulty: Difficulty = .easy
    @State private var notes = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var imageData: [Data] = []

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
                            TextField("Quantity", text: $ingredients[index].quantity)
                                .frame(width: 60)

                            TextField("Unit", text: Binding(
                                get: { ingredients[index].unit ?? "" },
                                set: { ingredients[index].unit = $0 }
                            ))
                            .frame(width: 60)

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

                Section(header: Text("Photos")) {
                    PhotosPicker(selection: $selectedImages, maxSelectionCount: 10, matching: .images) {
                        Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                    }

                    if !imageData.isEmpty {
                        Text("\(imageData.count) photo(s) selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("New Recipe")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveRecipe() }
                    .disabled(title.isEmpty || ingredients.isEmpty || instructions.isEmpty)
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

    func saveRecipe() {
        let filteredIngredients = ingredients.filter { !$0.name.isEmpty && !$0.quantity.isEmpty }
        let filteredInstructions = instructions.filter { !$0.description.isEmpty }

        let request = CreateRecipeRequest(
            title: title,
            ingredients: filteredIngredients,
            instructions: filteredInstructions,
            prepTime: Int(prepTime),
            cookTime: Int(cookTime),
            servings: Int(servings),
            difficulty: difficulty,
            notes: notes.isEmpty ? nil : notes
        )

        Task {
            if await recipeViewModel.createRecipe(request) {
                // Upload images if any
                if let recipe = recipeViewModel.selectedRecipe, !imageData.isEmpty {
                    _ = await recipeViewModel.uploadImages(recipeId: recipe.id, images: imageData)
                }
                dismiss()
            }
        }
    }
}
