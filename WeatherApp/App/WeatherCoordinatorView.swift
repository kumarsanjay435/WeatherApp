//
//  CoordinatorView.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-08.
//

import SwiftUI

struct WeatherCoordinatorView: View {
    @StateObject private var coordinator: WeatherCoordinator
    @StateObject private var temperatureVM: WeatherViewModel
    
    init(coordinator: WeatherCoordinator = WeatherCoordinator()) {
        _coordinator = StateObject(wrappedValue: coordinator)
        _temperatureVM = StateObject(wrappedValue: WeatherViewModel(coordinator: coordinator, locationUpdates: coordinator.selectedLocationSubject))
    }
    
    var body: some View {
        return NavigationStack(path: $coordinator.path) {
            WeatherView(viewModel: temperatureVM)
                .navigationDestination(for: Screen.self) { screen in
                    if case .location = screen {
                        SearchLocationView(viewModel: SearchLocationViewModel(coordinator: coordinator))
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        coordinator.popToRoot()
                                    }) {
                                        Image(systemName: "chevron.backward")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .navigationBarBackButtonHidden(true)
                    }
                }
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    WeatherCoordinatorView()
}

