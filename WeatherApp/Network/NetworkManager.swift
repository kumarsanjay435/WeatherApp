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
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        if let cacheControl = httpResponse.value(forHTTPHeaderField: "Cache-Control") {
            print("Cache-Control: \(cacheControl)")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

enum NetworkError: Error {
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case encodingError(Error)
}
