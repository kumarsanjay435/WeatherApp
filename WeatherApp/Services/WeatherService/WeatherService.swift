//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-09.
//

import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherViewModel.WeatherData
}

enum WeatherServiceError: Error {
    case invalidURL
    case responseParseError
    case networkError
    case unknownError
    
    var errorMessage: String {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid. Please try again later."
        case .responseParseError:
            return "There was an issue parsing the weather data. Please try again later."
        case .networkError:
            return "There was a network error. Please check your internet connection and try again."
        case .unknownError:
            return "An unknown error occurred. Please try again later."
        }
    }
}

struct WeatherService: WeatherServiceProtocol {
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let apiKey = "9a498bdb3bb09723c3ea8a76bc5d61fb"
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherViewModel.WeatherData {
        
        guard let url = URL(string: "\(baseURL)?appid=\(apiKey)&lat=\(latitude)&lon=\(longitude)&units=metric") else {
            throw WeatherServiceError.invalidURL
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
