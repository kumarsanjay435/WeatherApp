//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-08.
//

import Combine
import CoreLocation

protocol LocationManagerProtocol: AnyObject {
    var latitudePublisher: AnyPublisher<Double?, Never> { get }
    var longitudePublisher: AnyPublisher<Double?, Never> { get }
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }
    var location: CLLocation? { get }
    func requestLocation()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, LocationManagerProtocol {
    
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation? {
        didSet {
            if let location = location {
                    latitude = Double(String(format: "%.2f", location.coordinate.latitude))
                    longitude = Double(String(format: "%.2f", location.coordinate.longitude))
                    print("Current Location: ", latitude!, longitude!)
            }
        }
    }
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
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
            location = newLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Error Fetching your current Location. Allow Location Permission under Settings -> Privacy & Security -> Location Services -> WeatherApp"
    }
}
