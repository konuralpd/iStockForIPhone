//
//  MarketResponse.swift
//  iStockForIPhone
//
//  Created by Mac on 18.12.2022.
//

import Foundation


struct MarketResponse: Codable {
    let c, h, l, o: [Double]?
    let s: String?
    let t, v: [TimeInterval]?
    
    var candleSticks: [CandleStick] {
        var result = [CandleStick]()
        for index in 0..<(o?.count ?? 0) {
            result.append(.init(d: Date(timeIntervalSince1970: t![index]), h: h![index], l: l![index], o: o![index], c: c![index]))
        }
        let sorted = result.sorted(by: { $0.d < $1.d })
        return sorted
    }
}

struct CandleStick {
    let d: Date
    let h: Double
    let l: Double
    let o: Double
    let c: Double
}
