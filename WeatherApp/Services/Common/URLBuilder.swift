//
//  URLBuilder.swift
//  WeatherApp
//
//  Created by Sanjay Kumar on 2024-06-14.
//

import Foundation

struct URLBuilder {
    static func buildURL(baseURL: String, endpoint: String, queryParams: [String: String]) -> URL? {
        var components = URLComponents(string: baseURL + endpoint)
        components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url
    }
}
