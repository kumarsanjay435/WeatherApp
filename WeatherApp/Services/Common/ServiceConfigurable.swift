//
//  ServiceConfigurable.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-14.
//

import Foundation

protocol ServiceConfigurable {
    var baseURL: String { get }
    var apiKey: String { get }
    var endpoint: String { get }
}

extension ServiceConfigurable {
    var baseURL: String {
        return "https://api.openweathermap.org/"
    }

    var apiKey: String {
        return "9a498bdb3bb09723c3ea8a76bc5d61fb"
    }
}
