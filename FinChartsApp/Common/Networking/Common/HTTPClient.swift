//
//  HTTPClient.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation

class HTTPClient {
    func sendRequest<T: Decodable>(to endpoint: Endpoint, body: Data? = nil, headers: [String: String]? = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = endpoint.url else {
            completion(.failure(.invalidURL))
            return
        }

//        print("Final URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = APIConfiguration.timeoutInterval
        request.httpBody = body

        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(.noData))
                return
            }

//            print("Response Body: \(responseString)")

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch let decodingError {
                print("Decoding error: \(decodingError)")
                completion(.failure(.decodingError))
            }
        }

        task.resume()
    }
}
