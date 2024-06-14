//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-09.
//

import Foundation

struct WeatherService: WeatherServiceProtocol {
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherViewModel.WeatherData {
        
        let queryParams: [String: String] = [
            "appid": apiKey,
            "lat": "\(latitude)",
            "lon": "\(longitude)",
            "units": temperatureUnit.rawValue
        ]
        
        guard let url = URLBuilder.buildURL(baseURL: baseURL, endpoint: endpoint, queryParams: queryParams) else {
            throw GeocodingServiceError.invalidURL
        }
        
        
        do {
            let weatherData: Weather = try await NetworkManager.shared.fetchData(from: url)
            
            print("Debug: ", url, weatherData)
            
            let weatherDataVM = WeatherViewModel.WeatherData(
                locationName: weatherData.name + "," + weatherData.country,
                temperature: weatherData.temperature,
                condition: weatherData.weatherCondition.main,
                icon: weatherData.weatherCondition.icon,
                latitude: weatherData.latitude,
                longitude: weatherData.longitude
            )
            return weatherDataVM
        } catch {
            throw mapError(error)
        }
    }
    
    private func mapError(_ error: Error) -> WeatherServiceError {
        if error is URLError {
            return .networkError
        } else if error is DecodingError {
            return .responseParseError
        } else {
            return .unknownError
        }
    }
}

