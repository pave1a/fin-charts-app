//
//  DashboardViewModel.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation

class DashboardViewModel: ObservableObject {
    @Published var assetSymbol = ""
    @Published var assetPrice = ""
    @Published var assetTime = ""
    @Published var assets: [Asset] = []

    @Published var bars: [Bar] = []
    
    private let webSocketService = MarketWebSocketManager()
    private let marketDataService = MarketDataService()
    private let authService = AuthService()

    init() {
        performInitialAuthentication { [weak self] success in
            guard success else {
                return
            }

            self?.fetchAssets { fetchedAssets in
                DispatchQueue.main.async {
                    self?.assets = fetchedAssets
                }
            }

            self?.webSocketService.onMarketDataReceived = { [weak self] marketData in
                DispatchQueue.main.async {
                    self?.assetPrice = marketData["price"]?.asMarketPrice ?? "N/A"
                    self?.assetTime = marketData["timestamp"]?.marketDate ?? "N/A"
                }
            }

            self?.webSocketService.connect()
        }
    }

    private func performInitialAuthentication(completion: @escaping (Bool) -> Void) {
        authService.refreshTokenIfNeeded { [weak self] result in
            switch result {
            case .success(_):
                completion(true)
            case .failure(_):
                // need to use secret values
                let username = Secrets.getSecretValue(forKey: .username) ?? ""
                let password = Secrets.getSecretValue(forKey: .password) ?? ""
                self?.authService.authenticate(username: username, password: password) { result in
                    switch result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            }
        }
    }

    func subscribeToAsset(assetName: String) {
        if let asset = assets.first(where: { $0.symbol == assetName }) {
            assetSymbol = assetName

            webSocketService.subscribeToMarketData(assetId: asset.id, provider: "oanda")

            marketDataService.getHistoricalData(for: asset.id, provider: "oanda") { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        self.bars = response.data.map { data in
                            Bar(
                                time: data.time.marketDate,
                                open: data.open,
                                high: data.high,
                                low: data.low,
                                close: data.close,
                                volume: data.volume
                            )
                        }
                        print(self.bars)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func fetchAssets(completion: @escaping ([Asset]) -> Void) {
        marketDataService.getInstruments { result in
            switch result {
            case .success(let response):
                completion(response.data)
            case .failure(_):
                completion([])
            }
        }
    }
}
