//
//  MockLocationManager.swift
//  WeatherAppTests
//
//  Created by Sanjay Kumar on 2024-06-11.
//

import Combine
import CoreLocation

class MockLocationManager: LocationManagerProtocol {
    
    @Published var location: CLLocation?
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var errorMessage: String?
    
    var latitudePublisher: AnyPublisher<Double?, Never> {
        $latitude.eraseToAnyPublisher()
    }
    
    var longitudePublisher: AnyPublisher<Double?, Never> {
        $longitude.eraseToAnyPublisher()
    }
    
    var errorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
    
    func requestLocation() {}
    func stopUpdatingLocation() {}
    func startUpdatingLocation() {}
}
