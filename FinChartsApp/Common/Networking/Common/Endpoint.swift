//
//  Endpoint.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents(string: APIConfiguration.baseUrl)
        components?.path = path
        components?.queryItems = queryItems
        return components?.url
    }
}
