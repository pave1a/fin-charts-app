//
//  AuthResponse.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

struct AuthResponse: Codable {
    let accessToken: String
    let expiresIn: Int // 1800 = 30m
    let refreshExpiresIn: Int // 3600 = 1h
    let refreshToken: String
    let tokenType: String // Bearer
    let notBeforePolicy: Int
    let sessionState: String // current session id
    let scope: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshExpiresIn = "refresh_expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case notBeforePolicy = "not-before-policy"
        case sessionState = "session_state"
        case scope
    }
}

