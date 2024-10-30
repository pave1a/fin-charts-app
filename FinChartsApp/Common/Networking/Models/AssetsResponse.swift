//
//  AssetsResponse.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

struct AssetsResponse: Decodable {
    let paging: PagingInfo
    let data: [Asset]
}

struct PagingInfo: Decodable {
    let page: Int
    let pages: Int
    let items: Int
}

struct Asset: Decodable {
    let id: String
    let symbol: String
    let kind: String
    let exchange: String?
    let description: String
    let tickSize: Double
    let currency: String
    let baseCurrency: String?
    let mappings: [String: MappingInfo]
    let profile: ProfileInfo
}

struct MappingInfo: Decodable {
    let symbol: String
    let exchange: String
}

struct ProfileInfo: Decodable {
    let name: String
    let location: String?
    let gics: GICSInfo?
}

struct GICSInfo: Decodable {
    let sectorId: Int?
    let industryGroupId: Int?
    let industryId: Int?
    let subIndustryId: Int?
}
