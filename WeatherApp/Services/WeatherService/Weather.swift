//
//  Weather.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-09.
//

import Foundation

struct Weather: Codable {
    let temperature: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let visibility: Int
    let windSpeed: Double
    let windDegree: Int
    let windGust: Double?
    let cloudiness: Int
    let sunrise: Date
    let sunset: Date
    let id: Int
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    let weatherCondition: WeatherCondition
    
    enum CodingKeys: String, CodingKey {
        case coord, weather, main, visibility, wind, clouds, dt, sys, id, name
    }
    
    enum MainKeys: String, CodingKey {
        case temp, feelsLike = "feels_like", tempMin = "temp_min", tempMax = "temp_max", pressure, humidity
    }
    
    enum WindKeys: String, CodingKey {
        case speed, deg, gust
    }
    
    enum CloudsKeys: String, CodingKey {
        case all
    }
    
    enum SysKeys: String, CodingKey {
        case sunrise, sunset, country
    }
    
    enum CoordKeys: String, CodingKey {
        case latitude = "lat", longitude = "lon"
    }
    
    enum WeatherKeys: String, CodingKey {
        case id, main, description, icon
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode coordinate data
        let coordContainer = try container.nestedContainer(keyedBy: CoordKeys.self, forKey: .coord)
        latitude = try coordContainer.decode(Double.self, forKey: .latitude)
        longitude = try coordContainer.decode(Double.self, forKey: .longitude)
                
        // Decode the first weather condition
        var weatherArray = try container.nestedUnkeyedContainer(forKey: .weather)
        let weatherContainer = try weatherArray.nestedContainer(keyedBy: WeatherKeys.self)
        weatherCondition = WeatherCondition(
            id: try weatherContainer.decode(Int.self, forKey: .id),
            main: try weatherContainer.decode(String.self, forKey: .main),
            description: try weatherContainer.decode(String.self, forKey: .description),
            icon: try weatherContainer.decode(String.self, forKey: .icon)
        )
        
        // Decode main weather data
        let mainContainer = try container.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        temperature = try mainContainer.decode(Double.self, forKey: .temp)
        feelsLike = try mainContainer.decode(Double.self, forKey: .feelsLike)
        tempMin = try mainContainer.decode(Double.self, forKey: .tempMin)
        tempMax = try mainContainer.decode(Double.self, forKey: .tempMax)
        pressure = try mainContainer.decode(Int.self, forKey: .pressure)
        humidity = try mainContainer.decode(Int.self, forKey: .humidity)
        
        visibility = try container.decode(Int.self, forKey: .visibility)
        
        // Decode wind data
        let windContainer = try container.nestedContainer(keyedBy: WindKeys.self, forKey: .wind)
        windSpeed = try windContainer.decode(Double.self, forKey: .speed)
        windDegree = try windContainer.decode(Int.self, forKey: .deg)
        windGust = try? windContainer.decode(Double.self, forKey: .gust)
        
        // Decode cloudiness data
        let cloudsContainer = try container.nestedContainer(keyedBy: CloudsKeys.self, forKey: .clouds)
        cloudiness = try cloudsContainer.decode(Int.self, forKey: .all)
        
        // Decode system data (sunrise and sunset)
        let sysContainer = try container.nestedContainer(keyedBy: SysKeys.self, forKey: .sys)
        let sunriseTime = try sysContainer.decode(Int.self, forKey: .sunrise)
        let sunsetTime = try sysContainer.decode(Int.self, forKey: .sunset)
        let countryName = try sysContainer.decode(String.self, forKey: .country)
        
        sunrise = Date(timeIntervalSince1970: TimeInterval(sunriseTime))
        sunset = Date(timeIntervalSince1970: TimeInterval(sunsetTime))
        country = countryName
        
        // Decode other data
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {}
    
}

struct WeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
