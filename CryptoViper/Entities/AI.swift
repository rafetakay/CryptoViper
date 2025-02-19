//
//  Entity.swift
//  CryptoViper
//
//  Created by Rafet Can AKAY on 27.01.2025.
//

import Foundation

// MARK: - Response Models
struct AIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String?
        }
        let message: Message
    }
    let choices: [Choice]
}

struct AIDecision: Codable {
    let buy_symbol: String
    let sell_symbol: String
    let buy_reason: String
    let sell_reason: String
}
