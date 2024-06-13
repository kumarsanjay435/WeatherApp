//
//  Screen.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-08.
//

import Foundation

enum Screen: Hashable {
    case temperature(latitude: Double, longitude: Double)
    case location
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .location:
            hasher.combine("search")
        case .temperature(let latitude, let longitude):
            hasher.combine("temperature")
            hasher.combine(latitude)
            hasher.combine(longitude)
        }
    }
    
    static func == (lhs: Screen, rhs: Screen) -> Bool {
        switch (lhs, rhs) {
        case (.location, .location):
            return true
        case (.temperature(let lhsLat, let lhsLon), .temperature(let rhsLat, let rhsLon)):
            return lhsLat == rhsLat && lhsLon == rhsLon
        case (.temperature, .location):
            return false
        case (.location, .temperature):
            return false
        }
    }
}
