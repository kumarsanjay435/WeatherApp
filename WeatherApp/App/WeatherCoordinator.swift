//
//  WeatherCoordinator.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-08.
//

import Combine
import SwiftUI

class WeatherCoordinator: ObservableObject {
    
    @Published var path = NavigationPath()
    
    var selectedLocationSubject = PassthroughSubject<SearchLocationViewModel.Location, Never>()
    
    func selectLocation(_ location: SearchLocationViewModel.Location) {
        selectedLocationSubject.send(location)
        popToRoot()
    }
    
    func showSearch() {
        path.append(Screen.location)
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

protocol WeatherCoordinatorProtocol: AnyObject {
    func showSearch()
}
