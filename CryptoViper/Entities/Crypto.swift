//
//  Crypto.swift
//  CryptoViper
//
//  Created by Rafet Can AKAY on 3.02.2025.
//

import Foundation

struct Crypto: Codable {
    
    let id : String
    let currencyname: String
    let currentprice: Double
    let currencyimageurl: String
    let currencytotalsupply: Double
    let currencysymbol : String
    let alltimehigh : Double
    let alltimelow : Double
    let marketcap : Double
    let maxsupply : Double?
    let marketcaprank : Double
    
    let priceChangePercentage24h : Double
    let marketCapChangePercentage24h : Double
    let circulatingSupply : Double
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case currencyname = "name"
        case currentprice = "current_price"
        case currencyimageurl = "image" 
        case currencytotalsupply = "total_supply"
        case currencysymbol = "symbol"
        case alltimehigh = "ath"
        case alltimelow = "atl"
        case marketcap = "market_cap"
        case maxsupply = "max_supply"
        case marketcaprank = "market_cap_rank"
        
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCapChangePercentage24h = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        
    }
    
}
