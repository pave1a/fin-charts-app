//
//  APIEndpoint.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation

enum APIEndpoint: Endpoint {
    case getToken
    case listInstruments(provider: String, kind: String)
    case historicalData(instrumentId: String, startDate: String, endDate: String, provider: String, interval: String, periodicity: String)

    var path: String {
        switch self {
        case .getToken:
            return "/identity/realms/fintatech/protocol/openid-connect/token"
        case .listInstruments:
            return "/api/instruments/v1/instruments"
        case .historicalData:
            return "/api/bars/v1/bars/date-range"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getToken:
            return .post
        case .listInstruments, .historicalData:
            return .get
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .listInstruments(let provider, let kind):
            return [URLQueryItem(name: "provider", value: provider),
                    URLQueryItem(name: "kind", value: kind)]
        case .historicalData(let instrumentId, let startDate, let endDate, let provider, let interval, let periodicity):
            return [
                URLQueryItem(name: "instrumentId", value: instrumentId),
                URLQueryItem(name: "startDate", value: startDate),
                URLQueryItem(name: "endDate", value: endDate),
                URLQueryItem(name: "provider", value: provider),
                URLQueryItem(name: "interval", value: interval),
                URLQueryItem(name: "periodicity", value: periodicity)
            ]
        default:
            return nil
        }
    }
}
