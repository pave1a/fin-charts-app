//
//  MarketDataService.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation

typealias AssetResultCompletion = (Result<AssetsResponse, NetworkError>) -> Void
typealias HistoricalDataResultCompletion = (Result<HistoricalDataResponse, NetworkError>) -> Void

class MarketDataService {
    private let client = HTTPClient()
    private let authService = AuthService()

    func getInstruments(completion: @escaping AssetResultCompletion) {
        // TODO: remove hardcode
        let endpoint = APIEndpoint.listInstruments(provider: "oanda", kind: "forex")
        performAuthorizedRequest(endpoint: endpoint, completion: completion)
    }

    func getHistoricalData(for instrumentId: String, provider: String, completion: @escaping HistoricalDataResultCompletion) {
        guard let (startDateString, endDateString) = calculateDateRange() else {
            completion(.failure(.clientError("Failed to calculate date range")))
            return
        }

        // TODO: remove hardcode
        let interval = "1"
        let periodicity = "month"

        let endpoint = APIEndpoint.historicalData(
            instrumentId: instrumentId,
            startDate: startDateString,
            endDate: endDateString,
            provider: provider,
            interval: interval,
            periodicity: periodicity
        )
        
        performAuthorizedRequest(endpoint: endpoint, completion: completion)
    }
    
}

private extension MarketDataService {
    func performAuthorizedRequest<T: Decodable>(endpoint: APIEndpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        authService.refreshTokenIfNeeded { result in
            switch result {
            case .success(let token):
                self.client.sendRequest(to: endpoint, headers: ["Authorization": "Bearer \(token)"]) { (result: Result<T, NetworkError>) in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // TODO: remove hardcode. 1 year
    func calculateDateRange() -> (String, String)? {
        let endDate = Date()

        guard let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate) else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)

        return (startDateString, endDateString)
    }
}
