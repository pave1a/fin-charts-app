//
//  MarketWebSocketManager.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation

protocol MarketWebSocketManaging {
    var onMarketDataReceived: (([String: String]) -> Void)? { get set }
    func connect()
    func disconnect()
    func subscribeToMarketData(assetId: String, provider: String)
}

class MarketWebSocketManager: NSObject, MarketWebSocketManaging {
    private var webSocketTask: URLSessionWebSocketTask?
    private let authService = AuthService()
    private var urlSession: URLSession = URLSession(configuration: .default)
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let reconnectDelay: TimeInterval = 5.0

    var onMarketDataReceived: (([String: String]) -> Void)?

    override init() {
        super.init()

        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }

    func connect() {
        guard webSocketTask?.state != .running else { return }

        authService.refreshTokenIfNeeded { [weak self] result in
            switch result {
            case .success(let token):
                self?.initializeWebSocket(token: token)
            case .failure(let error):
                print("Failed to get token for WebSocket: \(error)")
                self?.handleReconnect()
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("WebSocket disconnected")
    }

    func subscribeToMarketData(assetId: String, provider: String) {
        let uniqueId = UUID().uuidString
        let subscriptionMessage: [String: Any] = [
            "type": "l1-subscription",
            "id": uniqueId,
            "instrumentId": assetId,
            "provider": provider,
            "subscribe": true,
            "kinds": ["ask", "bid", "last"]
        ]
        sendMessage(subscriptionMessage)
    }
}

private extension MarketWebSocketManager {
    func initializeWebSocket(token: String) {
        guard let url = URL(string: "wss://platform.fintacharts.com/api/streaming/ws/v1/realtime?token=\(token)") else {
            print("Invalid URL for WebSocket")
            return
        }

        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        print("WebSocket connection initiated")
        receiveMessages()
    }

    func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                self.processReceivedMessage(message)
                self.receiveMessages()
            case .failure(let error):
                print("Error receiving WebSocket message: \(error)")
                self.handleReconnect()
            }
        }
    }

    func processReceivedMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            handleReceivedText(text)
        case .data(let data):
            handleReceivedData(data)
        @unknown default:
            print("Unknown message type received")
        }
    }

    func handleReceivedText(_ text: String) {
        if let data = text.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    processReceivedJSON(json)
                }
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        }
    }

    func handleReceivedData(_ data: Data) {
        if let messageString = extractJSONMessage(from: data) {
            handleReceivedText(messageString)
        }
    }

    func processReceivedJSON(_ json: [String: Any]) {
        guard let type = json["type"] as? String else {
            print("Invalid JSON structure: \(json)")
            return
        }

        switch type {
        case "session":
            print("Session message received: \(json)")
        case "response":
            print("Response message received: \(json)")
        case "level1-provider-status-update":
            if let status = json["status"] as? String {
                print("Provider status update received: \(status)")
            }
        case "l1-update":
            if let last = json["last"] as? [String: Any],
               let price = last["price"] as? Double,
               let timestamp = last["timestamp"] as? String {
                onMarketDataReceived?(["price": String(price), "timestamp": timestamp])
            }
        default:
            print("Unhandled message type: \(type), content: \(json)")
        }
    }

    func sendMessage(_ message: [String: Any]) {
        guard webSocketTask?.state == .running else {
            print("WebSocket is not connected, can't send message.")
            handleReconnect()
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)

            webSocketTask?.send(wsMessage) { [weak self] error in
                if let error = error {
                    print("Error sending message: \(error)")
                    self?.handleReconnect()
                } else {
                    print("Message sent: \(jsonString)")
                }
            }
        } catch {
            print("Failed to serialize message: \(error)")
        }
    }

    func handleReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else {
            print("Max reconnect attempts reached. Giving up.")
            return
        }
        reconnectAttempts += 1
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        DispatchQueue.global().asyncAfter(deadline: .now() + reconnectDelay) { [weak self] in
            self?.connect()
        }
    }

    func extractJSONMessage(from data: Data) -> String? {
        if let endRange = data.range(of: Data([0x0A])) {
            let jsonData = data.subdata(in: 0..<endRange.lowerBound)
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}

extension MarketWebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connection opened successfully")
        reconnectAttempts = 0
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "No reason provided"
        print("WebSocket closed with code: \(closeCode), reason: \(reasonString)")
        handleReconnect()
    }
}
