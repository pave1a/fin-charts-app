//
//  KeychainService.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation
import Security

struct TokenInfo: Codable {
    let token: String
    let expiration: Date
}

struct RefreshTokenInfo: Codable {
    let refreshToken: String
    let expiration: Date
}

enum KeychainKey: String {
    case accessToken = "authToken"
    case refreshToken = "refreshToken"
}

class KeychainService {
    private let service = "com.finChartsApp.tokeninfo"

    @discardableResult
    func saveTokenInfo(_ tokenInfo: TokenInfo, for key: KeychainKey) -> Bool {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(tokenInfo)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key.rawValue,
                kSecValueData as String: data
            ]
            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        } catch {
            print("Error encoding token info: \(error)")
            return false
        }
    }

    func getTokenInfo(for key: KeychainKey) -> TokenInfo? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let tokenInfo = try decoder.decode(TokenInfo.self, from: data)
            return tokenInfo
        } catch {
            print("Error decoding token info: \(error)")
            return nil
        }
    }

    @discardableResult
    func deleteTokenInfo(for key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
