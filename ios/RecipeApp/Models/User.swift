import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let username: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, email, username
        case createdAt = "created_at"
    }
}

struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
    let message: String?

    enum CodingKeys: String, CodingKey {
        case user, message
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let username: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct RefreshTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}
