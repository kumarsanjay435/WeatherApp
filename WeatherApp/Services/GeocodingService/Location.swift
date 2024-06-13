//
//  Location.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-09.
//

import Foundation

struct Location: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    
    private enum CodingKeys: String, CodingKey {
        case name, lat, lon, state, country
    }
    
    init(id: String = UUID().uuidString, name: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID().uuidString
        
        let nameString = try container.decode(String.self, forKey: .name)
        let state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        let country = try container.decode(String.self, forKey: .country)
        
        if state.isEmpty {
            name = "\(nameString), \(country)"
        } else {
            name = "\(nameString), \(state), \(country)"
        }
        
        latitude = try container.decode(Double.self, forKey: .lat)
        longitude = try container.decode(Double.self, forKey: .lon)
    }
    
    func encode(to encoder: Encoder) throws {}
}
