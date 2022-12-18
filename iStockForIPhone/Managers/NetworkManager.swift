//
//  NetworkManager.swift
//  iStockForIPhone
//
//  Created by Mac on 17.12.2022.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    
    private struct Constants {
        static let apiKey = "cbacmtqad3ickr4msme0"
        static let sandboxApiKey = ""
        static let baseUrl = "https://finnhub.io/api/v1/"
    }
    
    private init() {}
    
    public func search(query: String, completion: @escaping(Result<SearchResponse, Error>) -> Void) {
        guard let safeSearchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        request(url: url(for: .search, queryParams: ["q": safeSearchQuery]), expecting: SearchResponse.self, completion: completion)
            
    }
    
    public func news(for type: NewsViewController.`Type`, completion: @escaping(Result<[NewsResponseElement], Error>) -> Void) {
        switch type {
        case .topStories:
            let url = url(for: .topNews, queryParams: ["category": "general"])
            request(url: url, expecting: [NewsResponseElement].self, completion: completion)
        case .company(let symbol):
            let oneMonthBack = Date().addingTimeInterval(-(3600 * 24 * 30))
            let url = url(for: .companyNews, queryParams: ["symbol": symbol, "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),"to": DateFormatter.newsDateFormatter.string(from: Date())])
            request(url: url, expecting: [NewsResponseElement].self, completion: completion)
        }
    }
    
    public func marketData(for symbol: String, numberOfDays: TimeInterval = 7, completion: @escaping(Result<MarketResponse,Error>) -> Void ) {
        let today = Date()
        let oneMonthBack = today.addingTimeInterval(-(3600 * 24 * 30))
        let url = url(for: .marketData, queryParams: ["symbol": symbol, "resolution": "1", "from": "\(Int(oneMonthBack.timeIntervalSince1970))" , "to": "\(Int(today.timeIntervalSince1970))"])

        request(url: url, expecting: MarketResponse.self, completion: completion)
    }
    
    public func getCompanyLogo(for symbol: String, completion: @escaping(Result<LogoResponse, Error>) -> Void) {
        let url = url(for: .logo, queryParams: ["symbol": symbol])
        request(url: url, expecting: LogoResponse.self, completion: completion)
    }
    
    private enum Endpoint: String {
        case search = "search"
        case topNews = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case logo = "stock/profile2"
        case financials = "stock/metric"
    }
    
    private enum NetworkError: Error {
        case invalidURL
        case noDataReceived
    }
    
    private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        var queryItems = [URLQueryItem]()
        
        //Add Token
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        
        urlString += "?" + queryString
        
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(NetworkError.invalidURL))
            return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NetworkError.noDataReceived))
            }
                return }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func financialMetrics(for symbol: String, completion: @escaping(Result<MetricResponse, Error>) -> Void) {
        let url = url(for: .financials, queryParams: ["symbol": symbol, "metric": "all"])
        
        request(url: url, expecting: MetricResponse.self, completion: completion)
    }
}
