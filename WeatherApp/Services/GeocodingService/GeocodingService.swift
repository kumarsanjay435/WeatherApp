//
//  GeocodingService.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-09.
//

import Foundation

protocol GeoCodingServiceProtocol {
    func fetchLocations(query: String) async throws -> [SearchLocationViewModel.Location]
}

enum GeocodingServiceError: Error {
    case invalidURL
    case responseParseError
    case networkError(Error)
    case unknownError
}

struct GeocodingService: GeoCodingServiceProtocol {
    private let baseURL = "https://api.openweathermap.org/geo/1.0/direct"
    private let apiKey = "9a498bdb3bb09723c3ea8a76bc5d61fb"
    
    func fetchLocations(query: String) async throws -> [SearchLocationViewModel.Location] {
        guard let url = URL(string: "\(baseURL)?appid=\(apiKey)&q=\(query)&limit=8") else {
            throw GeocodingServiceError.invalidURL
        }
        
        do {
            let locationData: [Location] = try await NetworkManager.shared.fetchData(from: url)
            print("geoService Url: ", url)
            
            let locations: [SearchLocationViewModel.Location] = locationData.map { location in
                SearchLocationViewModel.Location(
                    id: location.id,
                    name: location.name,
                    latitude: location.latitude,
                    longitude: location.longitude
                )
            }
            return locations
        } catch let error as GeocodingServiceError {
            throw error
        } catch {
            throw GeocodingServiceError.networkError(error)
        }
    }
}
