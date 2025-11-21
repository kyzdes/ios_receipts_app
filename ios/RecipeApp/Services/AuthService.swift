import Foundation

class AuthService {
    static let shared = AuthService()
    private let client = APIClient.shared

    private init() {}

    // MARK: - Authentication

    func register(email: String, password: String, username: String) async throws -> AuthResponse {
        let request = RegisterRequest(email: email, password: password, username: username)
        let response: AuthResponse = try await client.request(
            endpoint: "/auth/register",
            method: "POST",
            body: request,
            requiresAuth: false
        )

        // Save tokens
        KeychainService.shared.saveAccessToken(response.accessToken)
        KeychainService.shared.saveRefreshToken(response.refreshToken)
        KeychainService.shared.saveUserId(response.user.id.uuidString)

        return response
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await client.request(
            endpoint: "/auth/login",
            method: "POST",
            body: request,
            requiresAuth: false
        )

        // Save tokens
        KeychainService.shared.saveAccessToken(response.accessToken)
        KeychainService.shared.saveRefreshToken(response.refreshToken)
        KeychainService.shared.saveUserId(response.user.id.uuidString)

        return response
    }

    func logout() async throws {
        do {
            let _: EmptyResponse = try await client.request(
                endpoint: "/auth/logout",
                method: "POST"
            )
        } catch {
            // Continue with logout even if server request fails
            print("Logout request failed: \(error)")
        }

        // Clear local tokens
        KeychainService.shared.clearAll()
    }

    func getProfile() async throws -> User {
        struct ProfileResponse: Codable {
            let user: User
        }

        let response: ProfileResponse = try await client.request(
            endpoint: "/auth/profile",
            method: "GET"
        )

        return response.user
    }

    // MARK: - Token Management

    func isAuthenticated() -> Bool {
        return KeychainService.shared.getAccessToken() != nil
    }
}

struct EmptyResponse: Codable {}
