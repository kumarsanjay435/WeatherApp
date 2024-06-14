//
//  SearchLocationViewModelTests.swift
//  WeatherAppTests
//
//  Created by Sanjay Kumar on 2024-06-13.
//
import Combine
import XCTest
@testable import WeatherApp

class SearchLocationViewModelTests: XCTestCase {
    private var sut: SearchLocationViewModel!
    private var mockGeocodingService: MockGeocodingService!
    private var mockCoordinator: MockWeatherCoordinator!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mockGeocodingService = MockGeocodingService()
        mockCoordinator = MockWeatherCoordinator()
        
        sut = SearchLocationViewModel(
            coordinator: mockCoordinator,
            geoCodingService: mockGeocodingService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockGeocodingService = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testSearchLocationsSuccess() async {
        // Given
        let locations = [
            SearchLocationViewModel.Location(id: UUID().uuidString, name: "San Francisco", latitude: 37.7749, longitude: -122.4194)
        ]
        mockGeocodingService.fetchLocationsResult = .success(locations)
        
        // When
        sut.query = "San Francisco"
        await sut.searchLocations()
        
        // Then
        XCTAssertEqual(sut.state, .loaded(locations))
    }
    
    func testSearchLocationsFailure() async {
        // Given
        let error = ServiceError.networkError
        mockGeocodingService.fetchLocationsResult = .failure(error)
        
        // Create an expectation
        let expectation = XCTestExpectation(description: "Wait for searchLocations to complete")
        
        // When
        sut.query = "Invalid Location"
        
        Task {
            await sut.searchLocations()
            expectation.fulfill()
        }
        
        // Wait for the expectation with a timeout
        await fulfillment(of: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(sut.state, .error(error.errorMessage))
    }

    
    func testSelectLocation() {
        // Given
        let location = SearchLocationViewModel.Location(id: UUID().uuidString, name: "San Francisco", latitude: 37.7749, longitude: -122.4194)
        
        // When
        sut.selectLocation(location)
        
        // Then
        XCTAssertEqual(mockCoordinator.selectedLocation, location)
    }
    
    func testSearchQueryChanged() {
        // Given
        let expectation = XCTestExpectation(description: "Query changed")
        let expectedQuery = "New York"
        
        sut.$query
            .dropFirst()
            .sink { query in
                XCTAssertEqual(query, expectedQuery)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.searchBarVM.onSearchQueryChanged?(expectedQuery)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResetSearch() async {
        // When
        await sut.resetSearch()
        
        // Then
        XCTAssertEqual(sut.query, "")
        XCTAssertEqual(sut.state, .notStarted)
    }
}
