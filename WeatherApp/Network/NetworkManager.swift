//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-09.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    private let urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()
    
    func fetchData<T: Codable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse,
           let cacheControl = httpResponse.value(forHTTPHeaderField: "Cache-Control") {
            print("Cache-Control: \(cacheControl)")
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
