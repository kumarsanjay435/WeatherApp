//
//  SearchBarViewModel.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-12.
//

import SwiftUI

class SearchBarViewModel: ObservableObject {
    @Published var searchOpened = false
    @Published var searchedQuery = "" {
        didSet {
            if searchedQuery.count >= 3 {
                onSearchQueryChanged?(searchedQuery)
            }
        }
    }

    var onSearchQueryChanged: ((String) -> Void)?

    func resetSearch() {
        withAnimation(.smooth) {
            self.searchOpened.toggle()
            self.searchedQuery = ""
        }
    }
}
