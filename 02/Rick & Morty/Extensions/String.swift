//
//  String.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation

/// Used for formatting the date to the desired format
extension String {
    func formattedDate() -> String {
        // Input format: "September 10, 2017"
        // Output format: "10 September 2017"
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MMMM d, yyyy"
        inputFormatter.locale = Locale(identifier: "en_US")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        if let date = inputFormatter.date(from: self) {
            return outputFormatter.string(from: date)
        }
        
        // If parsing fails, return original string
        return self
    }
}
