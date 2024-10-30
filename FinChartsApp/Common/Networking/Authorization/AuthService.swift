//
//  AuthService.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation

private enum Constants {
    enum GrantType {
        static let password = "password"
        static let refreshToken =  "refresh_token"
    }
    static let clientId = "app-cli"
    
}

class AuthService {
    private let client = HTTPClient()
    private let keychainService = KeychainService()
    
    func authenticate(username: String, password: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let bodyParams = [
            "grant_type": Constants.GrantType.password,
            "client_id": Constants.clientId,
            "username": username,
            "password": password
        ]
        
        performTokenRequest(with: bodyParams) { result in
            switch result {
            case .success(let authResponse):
                self.saveAuthTokens(authResponse: authResponse)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func refreshTokenIfNeeded(completion: @escaping (Result<String, NetworkError>) -> Void) {
        if let accessTokenInfo = keychainService.getTokenInfo(for: .accessToken), accessTokenInfo.expiration > Date() {
            // Access token still valid
            completion(.success(accessTokenInfo.token))
        } else if let refreshTokenInfo = keychainService.getTokenInfo(for: .refreshToken), refreshTokenInfo.expiration > Date() {
            // Access token is expired, but refresh token is still valid
            let bodyParams = [
                "grant_type": Constants.GrantType.refreshToken,
                "client_id": Constants.clientId,
                "refresh_token": refreshTokenInfo.token
            ]
            performTokenRequest(with: bodyParams) { result in
                switch result {
                case .success(let authResponse):
                    self.saveAuthTokens(authResponse: authResponse)
                    completion(.success(authResponse.accessToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Both tokens are expired, user needs to re-authenticate
            completion(.failure(.serverError("No valid tokens available, re-authentication required")))
        }
    }
    
}

private extension AuthService {
    func performTokenRequest(with bodyParams: [String: String], completion: @escaping (Result<AuthResponse, NetworkError>) -> Void) {
        let endpoint = APIEndpoint.getToken
        let bodyString = bodyParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let bodyData = bodyString.data(using: .utf8)

        client.sendRequest(to: endpoint, body: bodyData, headers: ["Content-Type": "application/x-www-form-urlencoded"]) { (result: Result<AuthResponse, NetworkError>) in
            completion(result)
        }
    }

    func saveAuthTokens(authResponse: AuthResponse) {
        saveToken(type: .accessToken, token: authResponse.accessToken, expiresIn: authResponse.expiresIn)
        saveToken(type: .refreshToken, token: authResponse.refreshToken, expiresIn: authResponse.refreshExpiresIn)
    }

    func saveToken(type: KeychainKey, token: String, expiresIn: Int) {
        let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
        let tokenInfo = TokenInfo(token: token, expiration: expirationDate)
        keychainService.saveTokenInfo(tokenInfo, for: type)
    }
}
