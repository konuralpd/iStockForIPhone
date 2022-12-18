//
//  PersistenceManager.swift
//  iStockForIPhone
//
//  Created by Mac on 17.12.2022.
//

import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchListKey = "watchlist"
    }
    
    private init() {}
    
    public var watchList: [String] {
        if !userHasOnboarded {
            userDefaults.setValue(true, forKey: Constants.onboardedKey)
            setDefaults()
        }
        
        return userDefaults.stringArray(forKey: Constants.watchListKey) ?? []
    }
    
    public func addToWatchList(symbol: String, companyName: String) {
        var current = watchList
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchListKey)
        userDefaults.set(companyName, forKey: symbol)
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    public func deleteFromWatchList(symbol: String) {
        var newList = [String]()
        userDefaults.set(nil, forKey: symbol)
        for item in watchList where item != symbol {
            newList.append(item)
            
        }
        userDefaults.set(newList, forKey: Constants.watchListKey)
    }
    
    private var userHasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    private func setDefaults() {
        let map: [String: String] = [
             "MSFT" : "Microsoft Corp." , "GOOG" : "Alphabet", "AMZN": "Amazon.com", "TKC" : "Turkcell",
        ]
            
            let symbol = map.keys.map { $0 }
        userDefaults.set(symbol, forKey: Constants.watchListKey)
        
        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }

    }
    
    public func controlWatchlistAlreadyContains(symbol: String) -> Bool {
        return watchList.contains(symbol) 
    }
}
