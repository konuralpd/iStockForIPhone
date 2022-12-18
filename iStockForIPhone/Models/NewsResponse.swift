//
//  NewsResponse.swift
//  iStockForIPhone
//
//  Created by Mac on 17.12.2022.
//


import Foundation

// MARK: - NewsResponseElement
struct NewsResponseElement: Codable {
    let category: String?
    let datetime: TimeInterval?
    let headline: String?
    let id: Int?
    let image: String?
    let related: String?
    let source: String?
    let summary: String?
    let url: String?
}



typealias NewsResponse = [NewsResponseElement]

