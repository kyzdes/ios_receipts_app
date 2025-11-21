import SwiftUI

struct CategoriesView: View {
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var folderViewModel = FolderViewModel()
    @State private var showingCreateCategory = false
    @State private var showingCreateFolder = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Categories")) {
                    if categoryViewModel.categories.isEmpty {
                        Text("No categories yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(categoryViewModel.categories) { category in
                            HStack {
                                if let color = category.color {
                                    Circle()
                                        .fill(Color(hex: color) ?? .blue)
                                        .frame(width: 20, height: 20)
                                }

                                Text(category.name)

                                Spacer()

                                if let count = category.recipeCount {
                                    Text("\(count)")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                        .onDelete(perform: deleteCategory)
                    }

                    Button(action: { showingCreateCategory = true }) {
                        Label("Add Category", systemImage: "plus.circle")
                    }
                }

                Section(header: Text("Folders")) {
                    if folderViewModel.folders.isEmpty {
                        Text("No folders yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(folderViewModel.folders) { folder in
                            NavigationLink(destination: FolderDetailView(folder: folder)) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(.blue)

                                    Text(folder.name)

                                    Spacer()

                                    if let count = folder.recipeCount {
                                        Text("\(count)")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteFolder)
                    }

                    Button(action: { showingCreateFolder = true }) {
                        Label("Add Folder", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Organization")
            .sheet(isPresented: $showingCreateCategory) {
                CreateCategoryView(viewModel: categoryViewModel)
            }
            .sheet(isPresented: $showingCreateFolder) {
                CreateFolderView(viewModel: folderViewModel)
            }
            .task {
                await categoryViewModel.loadCategories()
                await folderViewModel.loadFolders()
            }
            .refreshable {
                await categoryViewModel.loadCategories()
                await folderViewModel.loadFolders()
            }
        }
    }

    func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = categoryViewModel.categories[index]
            Task {
                await categoryViewModel.deleteCategory(id: category.id)
            }
        }
    }

    func deleteFolder(at offsets: IndexSet) {
        for index in offsets {
            let folder = folderViewModel.folders[index]
            Task {
                await folderViewModel.deleteFolder(id: folder.id)
            }
        }
    }
}

struct CreateCategoryView: View {
    @ObservedObject var viewModel: CategoryViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var selectedColor = Color.blue

    var body: some View {
        NavigationView {
            Form {
                TextField("Category Name", text: $name)

                ColorPicker("Color", selection: $selectedColor)
            }
            .navigationTitle("New Category")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    Task {
                        if await viewModel.createCategory(
                            name: name,
                            color: selectedColor.toHex(),
                            icon: nil
                        ) {
                            dismiss()
                        }
                    }
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

struct CreateFolderView: View {
    @ObservedObject var viewModel: FolderViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Folder Name", text: $name)
            }
            .navigationTitle("New Folder")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    Task {
                        if await viewModel.createFolder(name: name, parentFolderId: nil) {
                            dismiss()
                        }
                    }
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

struct FolderDetailView: View {
    let folder: Folder

    var body: some View {
        List {
            if let recipes = folder.recipes {
                ForEach(recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeCard(recipe: recipe, isListView: true)
                    }
                }
            }
        }
        .navigationTitle(folder.name)
    }
}

// Color extension for hex conversion
extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }

    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
