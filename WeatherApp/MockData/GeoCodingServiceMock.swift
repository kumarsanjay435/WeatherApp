//
//  GeoCodingServiceMock.swift
//  WeatherAppTests
//
//  Created by Sanjay Kumar on 2024-06-11.
//

import Combine
import CoreLocation

class GeoCodingServiceMock: GeoCodingServiceProtocol {
    func fetchLocations(query: String) async throws -> [SearchLocationViewModel.Location] {
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 second
        
        let mockLocations = [
            SearchLocationViewModel.Location(id: UUID().uuidString, name: "Mock Location 1", latitude: 40.7128, longitude: -74.0060),
            SearchLocationViewModel.Location(id: UUID().uuidString, name: "Mock Location 2", latitude: 34.0522, longitude: -118.2437),
            SearchLocationViewModel.Location(id: UUID().uuidString, name: "Mock Location 3", latitude: 51.5074, longitude: -0.1278)
        ]
        
        return mockLocations
    }
}

class MockGeocodingService: GeoCodingServiceProtocol {
    var fetchLocationsResult: Result<[SearchLocationViewModel.Location], Error>?
    
    func fetchLocations(query: String) async throws -> [SearchLocationViewModel.Location] {
        if let result = fetchLocationsResult {
            switch result {
            case .success(let locations):
                return locations
            case .failure(let error):
                throw error
            }
        }
        return []
    }
}

class MockWeatherCoordinator: WeatherCoordinator {
    var selectedLocation: SearchLocationViewModel.Location?
    
    override func selectLocation(_ location: SearchLocationViewModel.Location) {
        selectedLocation = location
    }
}
