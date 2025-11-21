import SwiftUI
import VisionKit
import Vision

struct RecipeScannerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipeViewModel: RecipeViewModel

    @State private var scannerAvailable = DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    @State private var scannedText = ""
    @State private var isProcessing = false
    @State private var showingCreateRecipe = false
    @State private var extractedRecipe: ExtractedRecipeData?

    var body: some View {
        VStack {
            if scannerAvailable {
                VStack {
                    Text("Scan Recipe")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()

                    Text("Position your camera over a recipe to scan text")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Scanner View would go here in actual implementation
                    // This is a placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 400)
                        .overlay(
                            VStack {
                                Image(systemName: "viewfinder")
                                    .font(.system(size: 100))
                                    .foregroundColor(.gray)

                                Text("Camera Scanner")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        )
                        .cornerRadius(15)
                        .padding()

                    if !scannedText.isEmpty {
                        ScrollView {
                            Text(scannedText)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                    }

                    Spacer()

                    VStack(spacing: 15) {
                        Button(action: processScannedText) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Process Recipe")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(scannedText.isEmpty || isProcessing)

                        Button("Use Manual Entry Instead") {
                            showingCreateRecipe = true
                        }
                        .foregroundColor(.blue)
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "Scanner Not Available",
                    systemImage: "camera.fill",
                    description: Text("The document scanner is not available on this device. Please use manual recipe entry.")
                )

                Button("Manual Entry") {
                    showingCreateRecipe = true
                }
                .padding()
            }
        }
        .navigationTitle("Scan Recipe")
        .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        .sheet(isPresented: $showingCreateRecipe) {
            if let extracted = extractedRecipe {
                CreateRecipeWithDataView(extractedData: extracted)
            } else {
                CreateRecipeView()
            }
        }
    }

    func processScannedText() {
        isProcessing = true

        // Simulate text processing and recipe extraction
        // In a real app, this would use NLP/ML to parse the text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            extractedRecipe = parseRecipeText(scannedText)
            isProcessing = false
            showingCreateRecipe = true
        }
    }

    func parseRecipeText(_ text: String) -> ExtractedRecipeData {
        // Simple parsing logic - in production, use advanced NLP
        let lines = text.components(separatedBy: .newlines)

        let title = lines.first ?? "Scanned Recipe"

        // Extract ingredients (lines with measurements)
        let ingredients = lines.filter { line in
            line.range(of: "\\d+", options: .regularExpression) != nil
        }.map { line in
            Ingredient(name: line, quantity: "1")
        }

        // Extract instructions (numbered or bulleted lines)
        let instructions = lines.enumerated().compactMap { (index, line) -> Instruction? in
            if line.range(of: "^\\d+\\.", options: .regularExpression) != nil ||
               line.range(of: "^[•-]", options: .regularExpression) != nil {
                return Instruction(step: index + 1, description: line)
            }
            return nil
        }

        return ExtractedRecipeData(
            title: title,
            ingredients: ingredients,
            instructions: instructions
        )
    }
}

struct ExtractedRecipeData {
    let title: String
    let ingredients: [Ingredient]
    let instructions: [Instruction]
}

struct CreateRecipeWithDataView: View {
    let extractedData: ExtractedRecipeData
    @Environment(\.dismiss) var dismiss

    var body: some View {
        // This would use CreateRecipeView with pre-filled data
        // For simplicity, showing a basic implementation
        Text("Recipe extracted: \(extractedData.title)")
            .padding()
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
