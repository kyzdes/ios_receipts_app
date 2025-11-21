import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutAlert = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    if let user = authViewModel.currentUser {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.username)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                        }
                        .padding(.vertical, 8)
                    }
                }

                Section(header: Text("App Settings")) {
                    NavigationLink(destination: Text("App settings coming soon")) {
                        Label("Settings", systemImage: "gear")
                    }

                    NavigationLink(destination: Text("About coming soon")) {
                        Label("About", systemImage: "info.circle")
                    }
                }

                Section {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        Label("Log Out", systemImage: "arrow.right.square")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    Task {
                        await authViewModel.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}
