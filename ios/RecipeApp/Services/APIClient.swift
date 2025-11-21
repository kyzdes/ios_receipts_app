import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .serverError(let message):
            return message
        case .decodingError:
            return "Failed to decode server response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

class APIClient {
    static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession

    private init() {
        // Configure this with your server URL
        self.baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:3000/api/v1"

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Generic Request Method

    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authentication token if required
        if requiresAuth {
            if let token = KeychainService.shared.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.unauthorized
            }
        }

        // Add request body
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)

            case 401:
                // Try to refresh token
                try await refreshToken()
                // Retry the request
                return try await request(endpoint: endpoint, method: method, body: body, requiresAuth: requiresAuth)

            case 400...499:
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                }
                throw APIError.serverError("Client error: \(httpResponse.statusCode)")

            case 500...599:
                throw APIError.serverError("Server error: \(httpResponse.statusCode)")

            default:
                throw APIError.invalidResponse
            }

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Multipart Upload

    func uploadImages(
        endpoint: String,
        images: [Data]
    ) async throws -> RecipeResponse {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()

        for (index, imageData) in images.enumerated() {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError("Upload failed with status code: \(httpResponse.statusCode)")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(RecipeResponse.self, from: data)
    }

    // MARK: - Token Refresh

    private func refreshToken() async throws {
        guard let refreshToken = KeychainService.shared.getRefreshToken() else {
            throw APIError.unauthorized
        }

        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let response: RefreshTokenResponse = try await self.request(
            endpoint: "/auth/refresh",
            method: "POST",
            body: request,
            requiresAuth: false
        )

        KeychainService.shared.saveAccessToken(response.accessToken)
        KeychainService.shared.saveRefreshToken(response.refreshToken)
    }
}

struct ErrorResponse: Codable {
    let error: String
}
