//
//  ServiceError.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-14.
//

import Foundation

enum ServiceError: Error {
    case invalidURL
    case responseParseError
    case networkError
    case unknownError
    
    var errorMessage: String {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid. Please try again later."
        case .responseParseError:
            return "There was an issue parsing the data. Please try again later."
        case .networkError:
            return "There was a network error. Please check your internet connection and try again."
        case .unknownError:
            return "An unknown error occurred. Please try again later."
        }
    }
}
