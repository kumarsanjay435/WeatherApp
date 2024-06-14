//
//  WeatherServiceProtocol.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-14.
//

import Foundation

protocol WeatherServiceProtocol: ServiceConfigurable {
    var temperatureUnit: WeatherTemperatureUnit { get }
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherViewModel.WeatherData
}

extension WeatherServiceProtocol {
    var endpoint: String {
        return "data/2.5/weather"
    }
    
    var temperatureUnit: WeatherTemperatureUnit {
        return .metric // default to celcius
    }
}
