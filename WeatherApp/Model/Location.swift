//
//  Location.swift
//  WeatherApp
//
//  Created by rajapandian on 8/19/24.
//

import Foundation

struct Location: Codable {
    let name: String?
    let lat, lon: Double?
    let country, state: String?
}

extension Location {
    
    var locationDetail: String {
        return [name, state, country].compactMap({$0}).joined(separator: ", ")
    }

    var searchQueryParams: [String: String] {
        var query: [String: String] = ["units": "imperial"]
        if let lat { query["lat"] = String(format: "%.4f", lat) }
        if let lon { query["lon"] = String(format: "%.4f", lon) }
        return query
    }
    
    var searchQuery: String {
        var query = [String]()
        // this can be moved into compact map and generate query string
        if let name { query.append("q=\(name)") }
        if let state { query.append("state=\(state)") }
        if let country { query.append("country=\(country)") }
        return query.joined(separator: ",")
    }
}
