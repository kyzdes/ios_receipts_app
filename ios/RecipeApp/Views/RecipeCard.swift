import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe
    var isFeatured: Bool = false
    var isCompact: Bool = false
    var isListView: Bool = false

    var body: some View {
        if isFeatured {
            featuredCard
        } else if isListView {
            listCard
        } else if isCompact {
            compactCard
        } else {
            standardCard
        }
    }

    var featuredCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            AsyncImage(url: URL(string: recipe.primaryImage?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 250)
            .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.title)
                    .font(.title2)
                    .fontWeight(.bold)

                if let time = recipe.totalTime {
                    HStack {
                        Image(systemName: "clock")
                        Text("\(time) min")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }

                if let difficulty = recipe.difficulty {
                    Text("\(difficulty.icon) \(difficulty.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    var compactCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: recipe.primaryImage?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)

                if let time = recipe.totalTime {
                    HStack {
                        Image(systemName: "clock")
                        Text("\(time)m")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 150)
    }

    var listCard: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: recipe.primaryImage?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 80, height: 80)
            .clipped()
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)

                if let time = recipe.totalTime {
                    HStack {
                        Image(systemName: "clock")
                        Text("\(time) min")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }

                if let difficulty = recipe.difficulty {
                    Text("\(difficulty.icon) \(difficulty.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if recipe.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    var standardCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: recipe.primaryImage?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(10)

            Text(recipe.title)
                .font(.headline)
                .lineLimit(2)
        }
    }
}
