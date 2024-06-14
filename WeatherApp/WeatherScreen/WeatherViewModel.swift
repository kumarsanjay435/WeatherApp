//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-08.
//

import Combine
import SwiftUI

final class WeatherViewModel: ObservableObject {
    @Published var state: State = .notStarted
    
    enum State: Equatable {
        case notStarted
        case loading(LocationProvider)
        case showLocation(WeatherData)
        case error(String?)
        
        static func == (lhs: WeatherViewModel.State, rhs: WeatherViewModel.State) -> Bool {
            switch (lhs, rhs) {
            case (.notStarted, .notStarted):
                return true
            case (.loading(let lhsProvider), .loading(let rhsProvider)):
                return lhsProvider == rhsProvider
            case (.showLocation(let lhsData), .showLocation(let rhsData)):
                return lhsData == rhsData
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    enum LocationProvider {
        case device
        case user
    }
    
    struct WeatherData: Equatable {
        let locationName: String
        let temperature: Double
        let condition: String
        let icon: String
        let latitude: Double
        let longitude: Double
    }
    
    private let locationManager: LocationManagerProtocol
    private let weatherService: WeatherServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let coordinator: WeatherCoordinator
    
    init(
        locationManager: LocationManagerProtocol = LocationManager(),
        weatherService: WeatherServiceProtocol = WeatherService(),
        coordinator: WeatherCoordinator,
        locationUpdates: PassthroughSubject<SearchLocationViewModel.Location, Never>
    ) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        self.coordinator = coordinator
        observeCustomLocationUpdates(locationUpdates: locationUpdates)
        self.onInit()
    }
    
    // MARK: - Private Functions
    func onInit() {
        startUpdatingLocation()
        startListeningForLocationUpdates()
        setState(.loading(.device))
    }
    
    private func startListeningForLocationUpdates() {
        locationManager.latitudePublisher
            .combineLatest(locationManager.longitudePublisher)
            .sink { [weak self] (latitude, longitude) in
                guard let self, let latitude, let longitude else { return }
                self.stopUpdatingLocation()
                Task {
                    let location = SearchLocationViewModel.Location(
                        id: UUID().uuidString,
                        name: "Current Location",
                        latitude: latitude,
                        longitude: longitude
                    )
                    await self.fetchTemperature(for: location, locationType: .device)
                }
            }
            .store(in: &cancellables)
        
        // Observe errors from locationManager
        locationManager.errorMessagePublisher
            .sink { [weak self] errorMessage in
                guard let self, let errorMessage else { return }
                setState(.error(errorMessage))
            }
            .store(in: &cancellables)
    }
    
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    private func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    @MainActor
    private func updateWeatherData(_ data: WeatherData) {
        setState(.showLocation(data))
    }
    
    @MainActor
    private func handleError(_ error: Error?) {
        guard let error else {
            setState(.error(ServiceError.unknownError.errorMessage))
            return
        }
        
        if let serviceError = error as? ServiceError {
            setState(.error(serviceError.errorMessage))
        } else {
            setState(.error(ServiceError.networkError.errorMessage))
        }
    }
    
    private func setState(_ viewState: State) {
        DispatchQueue.main.async {
            self.state = viewState
        }
    }
    
    // MARK: - Public Functions
    
    func fetchTemperature(for location: SearchLocationViewModel.Location, locationType: LocationProvider) async {
        setState(.loading(locationType))
        do {
            let weatherData = try await weatherService.fetchWeather(
                latitude: location.latitude,
                longitude: location.longitude
            )
            await self.updateWeatherData(weatherData)
        } catch {
            await self.handleError(error)
        }
    }
    
    func observeCustomLocationUpdates(locationUpdates: PassthroughSubject<SearchLocationViewModel.Location, Never>) {
        locationUpdates
            .sink { [weak self] location in
                guard let self = self else { return }
                Task {
                    await self.fetchTemperature(for: location, locationType: .user)
                }
            }
            .store(in: &cancellables)
    }
    
    func useCurrentLocation() async {
        locationManager.requestLocation()
        if let currentLocation = locationManager.location {
            let location = SearchLocationViewModel.Location(id: UUID().uuidString, name: "Current Location", latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            await fetchTemperature(for: location, locationType: .device)
        } else {
            await self.handleError(nil)
        }
    }
    
    func toggleTemperatureUnit(_ isCelsius: Bool, temperature: Double) -> Double {
        if isCelsius {
            return (temperature - 32) * 5 / 9
        } else {
            return (temperature * 9 / 5) + 32
        }
    }
    
    func tryAgain() {
        locationManager.requestLocation()
    }
    
    func showSearch() {
        coordinator.showSearch()
    }
}
