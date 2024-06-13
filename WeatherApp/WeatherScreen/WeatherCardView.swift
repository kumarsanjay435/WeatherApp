//
//  WeatherCardView.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-13.
//

import SwiftUI

struct WeatherCardView: View {
    let weatherData: WeatherViewModel.WeatherData
    let toggleTemperatureUnit: (Bool, Double) -> Double
    let showSearch: () -> Void
    let useCurrentLocation: () async -> Void
    
    @State private var displayedTemperature: Double
    @State private var isCelsius = true
    @State private var triggerUseCurrentLocation = false
    
    init(
        weatherData: WeatherViewModel.WeatherData,
        toggleTemperatureUnit: @escaping (Bool, Double) -> Double,
        showSearch: @escaping () -> Void,
        useCurrentLocation: @escaping () async -> Void
    ) {
        self.weatherData = weatherData
        self.showSearch = showSearch
        self.useCurrentLocation = useCurrentLocation
        self.toggleTemperatureUnit = toggleTemperatureUnit
        _isCelsius = State(initialValue: true)
        _displayedTemperature = State(initialValue: weatherData.temperature)
    }
    
    var body: some View {
        VStack {
            Text("RIGHT NOW")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(String(format: "%.0f", displayedTemperature))°\(isCelsius ? "C" : "F")")
                .font(.system(size: 72))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .accessibilityIdentifier("TemperatureText")
                .onTapGesture {
                    isCelsius.toggle()
                    displayedTemperature = toggleTemperatureUnit(isCelsius, displayedTemperature)
                }
            
            Text(weatherData.condition)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .accessibilityIdentifier("WeatherConditionText")
            
            AsyncImage(url: iconURL(for: weatherData.icon)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .accessibilityIdentifier("WeatherIcon")
            } placeholder: {
                ProgressView()
                    .accessibilityIdentifier("WeatherIconPlaceholder")
            }
            
            HStack {
                Text("\(weatherData.locationName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("LocationNameText")
                
                Button(action: {
                    showSearch()
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                        .accessibilityIdentifier("SearchButton")
                }
                Button(action: {
                    triggerUseCurrentLocation = true
                }) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.green)
                        .accessibilityIdentifier("CurrentLocationButton")
                }
            }
        }
        .padding()
        .task(id: triggerUseCurrentLocation) {
            if triggerUseCurrentLocation {
                await useCurrentLocation()
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color(UIColor.label).opacity(0.2), radius: 10)
    }
    
    func iconURL(for icon: String) -> URL {
        return URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")!
    }
}

struct WeatherCardView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherCardView(
            weatherData: WeatherViewModel.WeatherData(
                locationName: "Portland, OR", temperature: 60,
                condition: "Light Thunderstorms",
                icon: "11d",
                latitude: 22.99,
                longitude: -122.87
            ),
            toggleTemperatureUnit: {_,_ in
                return Double(2.22)
            },
            showSearch: {},
            useCurrentLocation: {}
        )
        .preferredColorScheme(.light)
        .previewLayout(.sizeThatFits)
        
        WeatherCardView(
            weatherData: WeatherViewModel.WeatherData(
                locationName: "Portland, OR", temperature: 60,
                condition: "Light Thunderstorms",
                icon: "11d",
                latitude: 40.99,
                longitude: -142.87
            ),
            toggleTemperatureUnit: {_,_ in
                return Double(2.22)
            },
            showSearch: {},
            useCurrentLocation: {}
        )
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
