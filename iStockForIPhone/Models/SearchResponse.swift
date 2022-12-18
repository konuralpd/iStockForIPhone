//
//  SearchResponse.swift
//  iStockForIPhone
//
//  Created by Mac on 17.12.2022.


import Foundation

struct SearchResponse: Codable {
    let count: Int?
    let result: [SearchResult]?
}


struct SearchResult: Codable {
    let resultDescription, displaySymbol, symbol: String?

    enum CodingKeys: String, CodingKey {
        case resultDescription = "description"
        case displaySymbol, symbol
    }
}

struct LogoResponse: Codable {
    let country, currency, exchange, finnhubIndustry: String?
    let ipo: String?
    let logo: String?
    let marketCapitalization: Double?
    let name, phone: String?
    let shareOutstanding: Double?
    let ticker: String?
    let weburl: String?
}

