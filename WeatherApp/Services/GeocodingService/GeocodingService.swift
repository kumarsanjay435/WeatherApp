//
//  GeocodingService.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-09.
//

import Foundation

struct GeocodingService: GeoCodingServiceProtocol {
    
    func fetchLocations(query: String) async throws -> [SearchLocationViewModel.Location] {
        let queryParams: [String: String] = [
            "appid": apiKey,
            "q": query,
            "limit": "\(maxQueryLimit)"
        ]
        
        guard let url = URLBuilder.buildURL(
            baseURL: baseURL,
            endpoint: endpoint,
            queryParams: queryParams
        ) else {
            throw ServiceError.invalidURL
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
        } catch {
            throw mapError(error)
        }
    }
    
    private func mapError(_ error: Error) -> ServiceError {
        switch error {
        case is DecodingError:
            return .responseParseError
        case is URLError:
            return .networkError
        default:
            return .unknownError
        }
    }
}
