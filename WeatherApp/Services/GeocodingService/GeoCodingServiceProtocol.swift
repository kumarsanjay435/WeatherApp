//
//  GeoCodingServiceProtocol.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-14.
//

import Foundation

protocol GeoCodingServiceProtocol: ServiceConfigurable {
    var maxQueryLimit: Int { get }
    func fetchLocations(query: String) async throws -> [SearchLocationViewModel.Location]
}

extension GeoCodingServiceProtocol {
    var endpoint: String {
        return "geo/1.0/direct"
    }

    var maxQueryLimit: Int {
        return 8
    }
}

enum GeocodingServiceError: Error {
    case invalidURL
    case responseParseError
    case networkError(Error)
    case unknownError
}
