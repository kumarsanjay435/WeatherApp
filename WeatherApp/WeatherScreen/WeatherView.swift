//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-08.
//

import SwiftUI
import Combine
import CoreLocation

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("BackgroundTop"), Color("BackgroundBottom")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                switch viewModel.state {
                case .notStarted:
                    Text("Welcome to Weather App!")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .accessibilityIdentifier("WelcomeMessage")
                    
                case .loading(let provider):
                    ProgressView("Fetching weather...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .foregroundColor(.white)
                        .padding()
                        .accessibilityIdentifier("FetchingWeatherProgress")
                    
                    Text("Fetching weather for \(provider == .device ? "current location" : "selected location")")
                        .foregroundColor(.white)
                        .accessibilityIdentifier("FetchingWeatherText")
                    
                    
                case .showLocation(let weatherData):
                    WeatherCardView(
                        weatherData: weatherData,
                        toggleTemperatureUnit: { isCelsius, temperature in
                            
                            return viewModel.toggleTemperatureUnit(isCelsius, temperature: temperature)
                        },
                        showSearch: viewModel.showSearch,
                        useCurrentLocation: { await  viewModel.useCurrentLocation() }
                    )
                    
                case .error(let message):
                    VStack {
                        Text("\(message ?? "Unknown error occurred.")")
                            .foregroundColor(.red)
                            .padding()
                            .accessibilityIdentifier("ErrorMessage")
                        
                        Button(action: {
                            viewModel.onInit()
                        }) {
                            Text("Try Again")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .accessibilityIdentifier("TryAgainButton")
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
    
    static var previews: some View {
        let mockLocationManager = MockLocationManager()
        mockLocationManager.location = location
        
        let weatherServiceMock = WeatherServiceMock()
        
        // Set up weather data
        let weatherData = WeatherViewModel.WeatherData(
            locationName: "Current Location",
            temperature: 20.0,
            condition: "Clear",
            icon: "11d",
            latitude: 37.7749,
            longitude: -122.4194
        )
        weatherServiceMock.result = .success(weatherData)
        
        
        let viewModel = WeatherViewModel(
            locationManager: LocationManager(),
            weatherService: weatherServiceMock,
            coordinator: WeatherCoordinator(),
            locationUpdates: PassthroughSubject<SearchLocationViewModel.Location, Never>()
        )
        
        return Group {
            WeatherView(viewModel: viewModel)
                .environment(\.colorScheme, .light)
            
            WeatherView(viewModel: viewModel)
                .environment(\.colorScheme, .dark)
        }
    }
}
