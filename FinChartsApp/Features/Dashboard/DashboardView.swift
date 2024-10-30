//
//  DashboardView.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var assetName = ""
    @State private var showDropdown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            topSection
            marketDataSection
            Spacer()
            linearChart
        }
        .padding()
        .overlay(dropdownOverlay, alignment: .top)
    }
}

private extension DashboardView {
    var topSection: some View {
        HStack {
            assetTextField
            subscribeButton
        }
    }

    var assetTextField: some View {
        TextField("Enter asset name", text: $assetName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.trailing, 8)
            .onChange(of: assetName, perform: handleTextChange)
    }

    var subscribeButton: some View {
        Button(action: {
            viewModel.subscribeToAsset(assetName: assetName)
        }) {
            Text("Subscribe")
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }

    var dropdownOverlay: some View {
        Group {
            if showDropdown {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(filteredAssets, id: \.id) { asset in
                            dropdownOption(asset: asset)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .frame(maxHeight: 150)
                .padding(.horizontal)
                .padding(.top, 60)
            }
        }
    }

    var marketDataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Market data:")
                .font(.headline)
            MarketDataView(assetSymbol: viewModel.assetSymbol, assetPrice: viewModel.assetPrice, assetTime: viewModel.assetTime)
        }
    }

    var linearChart: some View {
        LinearChartView(bars: viewModel.bars)
    }

    func dropdownOption(asset: Asset) -> some View {
        Text(asset.symbol)
            .padding(.horizontal)
            .onTapGesture {
                handleDropdownSelection(asset: asset)
            }
    }

    var filteredAssets: [Asset] {
        viewModel.assets.filter { $0.symbol.lowercased().contains(assetName.lowercased()) }
    }

    func handleTextChange(_ newValue: String) {
        showDropdown = !newValue.isEmpty && filteredAssets.count > 1
    }

    func handleDropdownSelection(asset: Asset) {
        assetName = asset.symbol
        showDropdown = false
    }
}
