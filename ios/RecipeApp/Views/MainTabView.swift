import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
                .tag(1)

            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "folder.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}
