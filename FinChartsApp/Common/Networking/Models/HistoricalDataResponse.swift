//
//  HistoricalDataResponse.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation

struct HistoricalDataResponse: Decodable {
    let data: [Bar]
}

struct Bar: Codable {
    let time: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int

    enum CodingKeys: String, CodingKey {
        case time = "t"
        case open = "o"
        case high = "h"
        case low = "l"
        case close = "c"
        case volume = "v"
    }
}

// Date specific
extension Bar {
    var date: Date {
        ISO8601DateFormatter().date(from: time) ?? Date()
    }
}
