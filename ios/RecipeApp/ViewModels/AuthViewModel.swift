import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService.shared

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        isAuthenticated = authService.isAuthenticated()
        if isAuthenticated {
            Task {
                await loadProfile()
            }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await authService.login(email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func register(email: String, password: String, username: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await authService.register(email: email, password: password, username: username)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logout() async {
        isLoading = true

        do {
            try await authService.logout()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadProfile() async {
        do {
            currentUser = try await authService.getProfile()
        } catch {
            // If profile load fails, user might need to log in again
            isAuthenticated = false
            currentUser = nil
        }
    }
}
