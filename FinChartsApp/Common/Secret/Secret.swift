//
//  Secret.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation

enum SecretKey: String {
    case username = "username"
    case password = "password"
}

struct Secrets {
    static func getSecretValue(forKey key: SecretKey) -> String? {
        guard let path = Bundle.main.path(forResource: "Secret", ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path),
              let plist = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] else {

            return nil
        }

        return plist[key.rawValue] as? String
    }
}
