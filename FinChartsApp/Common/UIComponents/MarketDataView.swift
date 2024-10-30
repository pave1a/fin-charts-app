//
//  MarketDataView.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import SwiftUI

struct MarketDataView: View {
    var assetSymbol: String
    var assetPrice: String
    var assetTime: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            dataColumn(title: "Symbol:", value: assetSymbol)
            dataColumn(title: "Price:", value: assetPrice)
            dataColumn(title: "Time:", value: assetTime)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }

    private func dataColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
