//
//  String+Formatting.swift
//  FinChartsApp
//
//  Created by Vladyslav Pavelko on 30.10.2024.
//

import Foundation

extension String {
    var marketDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d, h:mm a"
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")
            return outputFormatter.string(from: date)
        }

        return self
    }
    
    var asMarketPrice: String {
        guard let doubleValue = Double(self) else { return self }
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.currencyGroupingSeparator = ","
        formatter.maximumFractionDigits = 3
        
        if let formattedPrice = formatter.string(from: NSNumber(value: doubleValue)) {
            return formattedPrice.replacingOccurrences(of: ".", with: ",")
        }
        
        return self
    }
}
