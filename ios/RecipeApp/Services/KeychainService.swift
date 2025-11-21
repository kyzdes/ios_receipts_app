import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()

    private let accessTokenKey = "com.recipeapp.accessToken"
    private let refreshTokenKey = "com.recipeapp.refreshToken"
    private let userIdKey = "com.recipeapp.userId"

    private init() {}

    // MARK: - Access Token

    func saveAccessToken(_ token: String) {
        save(key: accessTokenKey, value: token)
    }

    func getAccessToken() -> String? {
        return get(key: accessTokenKey)
    }

    func deleteAccessToken() {
        delete(key: accessTokenKey)
    }

    // MARK: - Refresh Token

    func saveRefreshToken(_ token: String) {
        save(key: refreshTokenKey, value: token)
    }

    func getRefreshToken() -> String? {
        return get(key: refreshTokenKey)
    }

    func deleteRefreshToken() {
        delete(key: refreshTokenKey)
    }

    // MARK: - User ID

    func saveUserId(_ userId: String) {
        save(key: userIdKey, value: userId)
    }

    func getUserId() -> String? {
        return get(key: userIdKey)
    }

    func deleteUserId() {
        delete(key: userIdKey)
    }

    // MARK: - Clear All

    func clearAll() {
        deleteAccessToken()
        deleteRefreshToken()
        deleteUserId()
    }

    // MARK: - Private Methods

    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }

        return nil
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
