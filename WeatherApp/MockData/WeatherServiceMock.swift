//
//  WeatherServiceMock.swift
//  WeatherAppTests
//
//  Created by Sanjay Kumar on 2024-06-11.
//

import Combine
import CoreLocation


class WeatherServiceMock: WeatherServiceProtocol {
    var result: Result<WeatherViewModel.WeatherData, Error>?
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherViewModel.WeatherData {
        if let result = result {
            switch result {
            case .success(let data):
                return data
            case .failure(let error):
                throw error
            }
        } else {
            throw URLError(.badServerResponse)
        }
    }
}
