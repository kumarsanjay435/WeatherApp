//
//  SearchLocationViewModel.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-08.
//

import Combine
import Foundation

final class SearchLocationViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var state: State = .notStarted
    
    var searchBarVM: SearchBarViewModel
    
    private let geocodingService: GeoCodingServiceProtocol
    private let coordinator: WeatherCoordinator
    private var cancellables = Set<AnyCancellable>()
    
    enum State: Equatable {
        case notStarted
        case loading
        case loaded([SearchLocationViewModel.Location])
        case error(String)
    }
    
    struct Location: Equatable, Identifiable {
        let id: String
        let name: String
        let latitude: Double
        let longitude: Double
    }
    
    init(
        coordinator: WeatherCoordinator,
        geoCodingService:GeoCodingServiceProtocol = GeocodingService()
    ) {
        self.coordinator = coordinator
        self.geocodingService = geoCodingService
        self.searchBarVM = SearchBarViewModel()
        self.onInit()
    }
    
    private func onInit() {
        $query
            .debounce(for: .milliseconds(800), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self = self, !query.isEmpty else { return }
                Task {
                    await self.searchLocations()
                }
            }
            .store(in: &cancellables)
        
        searchBarVM.onSearchQueryChanged = { [weak self] query in
            self?.query = query
        }
        
        searchBarVM.$searchOpened
            .sink { [weak self] searchOpened in
                guard let self = self else { return }
                if !searchOpened {
                    Task { @MainActor in
                        self.resetSearch()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func searchLocations() async {
        await setIsLoading(true)
        do {
            let locationResults = try await geocodingService.fetchLocations(query: query)
            await self.updateLocation(locationResults)
        } catch {
            await self.handleError(error)
        }
    }
    
    func selectLocation(_ location: Location) {
        coordinator.selectLocation(location)
    }
    
    @MainActor
    func resetSearch() {
        self.query = ""
        self.state = .notStarted
    }
    
    @MainActor
    private func updateLocation(_ locationResults: [Location]) {
        self.state = .loaded(locationResults)
    }
    
    @MainActor
    private func handleError(_ error: Error) {
        self.state = .error(error.localizedDescription)
    }
    
    @MainActor
    private func setIsLoading(_ loading: Bool) {
        if loading {
            self.state = .loading
        }
    }
}
