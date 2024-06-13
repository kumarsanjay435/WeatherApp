//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Sanjay Kumar on 2024-06-08.
//

import Combine
import XCTest
import CoreLocation
@testable import WeatherApp

final class WeatherViewModelTests: XCTestCase {
    var sut: WeatherViewModel!
    var mockLocationManager: MockLocationManager!
    var mockWeatherService: WeatherServiceMock!
    var mockCoordinator: WeatherCoordinator!
    var locationUpdates: PassthroughSubject<SearchLocationViewModel.Location, Never>!
    
    override func setUp() {
        super.setUp()
        mockLocationManager = MockLocationManager()
        mockCoordinator = MockWeatherCoordinator()
        mockWeatherService = WeatherServiceMock()
        locationUpdates = PassthroughSubject<SearchLocationViewModel.Location, Never>()
        
        sut = WeatherViewModel(
            locationManager: mockLocationManager,
            weatherService: mockWeatherService,
            coordinator: mockCoordinator,
            locationUpdates: locationUpdates
        )
    }
    
    override func tearDown() {
        sut = nil
        mockLocationManager = nil
        mockWeatherService = nil
        mockCoordinator = nil
        locationUpdates = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(sut.state, .notStarted)
    }
    
    func testUseCurrentLocation() async {
        // Simulate location
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        mockLocationManager.location = location
        
        // Set up weather data
        let weatherData = WeatherViewModel.WeatherData(
            locationName: "Current Location",
            temperature: 20.0,
            condition: "Clear",
            icon: "",
            latitude: 37.7749,
            longitude: -122.4194
        )
        mockWeatherService.result = .success(weatherData)

        
        // Expectation for async operation
        let expectation = self.expectation(description: "useCurrentLocation completes")
        
        Task {
            await self.sut.useCurrentLocation()
            expectation.fulfill()
        }
        
        // Wait
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Verify
        XCTAssertEqual(sut.state, .showLocation(weatherData))
    }
    
    func testFetchWeatherData() async {
        let location = SearchLocationViewModel.Location(id: UUID().uuidString, name: "Test Location", latitude: 37.7749, longitude: -122.4194)
        
        let weatherData = WeatherViewModel.WeatherData(
            locationName: "Test Location",
            temperature: 22.0,
            condition: "Partly CLoudy",
            icon: "11d",
            latitude: 37.7749,
            longitude: -122.4194
        )
        mockWeatherService.result = .success(weatherData)
        
        let expectation = XCTestExpectation(description: "Wait for fetchTemperature to complete")
        
        Task{
            await sut.fetchTemperature(for: location, locationType: .user)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertEqual(sut.state, .showLocation(weatherData))
    }
    
    func testHandleError() async {
        let expectation = XCTestExpectation(description: "Wait for fetchTemperature to complete")
        
        let location = SearchLocationViewModel.Location(id: UUID().uuidString, name: "Test Location", latitude: 37.7749, longitude: -122.4194)
        mockWeatherService.result = .failure(URLError(.badServerResponse))
        
        Task {
            await sut.fetchTemperature(for: location, locationType: .user)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        if case .error(let errorMessage) = sut.state {
            XCTAssertEqual(errorMessage, "There was a network error. Please check your internet connection and try again.")
        } else {
            XCTFail("State should be error")
        }
    }
    
    func testObserveCustomLocationUpdates() {
        let expectation = self.expectation(description: "Location update")
        
        let location = SearchLocationViewModel.Location(id: UUID().uuidString, name: "Test Location", latitude: 37.7749, longitude: -122.4194)
        
        let weatherData = WeatherViewModel.WeatherData(
            locationName: "Test Location",
            temperature: 22.0,
            condition:"Haze",
            icon:"",
            latitude: 37.7749,
            longitude: -122.4194
        )
        mockWeatherService.result = .success(weatherData)
        
        sut.observeCustomLocationUpdates(locationUpdates: locationUpdates)
        
        locationUpdates.send(location)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if case .showLocation(let data) = self.sut.state {
                XCTAssertEqual(data, weatherData)
                expectation.fulfill()
            } else {
                XCTFail("State should be showLocation")
            }
        }
        
        wait(for: [expectation], timeout: 2)
    }
}
