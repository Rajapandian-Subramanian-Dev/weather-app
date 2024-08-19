//
//  Weather.swift
//  WeatherApp
//
//  Created by rajapandian on 8/18/24.
//

import Foundation

protocol WeatherProtocol {
    var location: String { get }
    var temp: String { get }
    var feelsLike: String { get }
    var tempDescription: String { get }
    var iconURL: URL? { get }
}
// MARK: - Weather
struct Weather: Codable {
    let coord: Coord?
    let weather: [WeatherElement]?
    let base: String?
    let main: Main?
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int?
    let sys: Sys?
    let timezone, id: Int?
    let name: String?
    let cod: Int?
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int?
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double?
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double?
    let pressure, humidity, seaLevel, grndLevel: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

// MARK: - Sys
struct Sys: Codable {
    let type, id: Int?
    let country: String?
    let sunrise, sunset: Int?
}

// MARK: - WeatherElement
struct WeatherElement: Codable {
    let id: Int?
    let main, description, icon: String?
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double?
    let deg: Int?
    let gust: Double?
}

extension Weather: WeatherProtocol {
    var location: String {
        return name ?? ""
    }
    
    var temp: String {
        guard let temp = main?.temp else {
            return "-"
        }
        return String(format: "%.2f", temp)
    }
    
    var feelsLike: String {
        guard let feelsLike = main?.feelsLike else {
            return "-"
        }
        return String(format: "%.2f", feelsLike)
    }
    
    var tempDescription: String {
        return weather?.first?.description ?? ""
    }
    
    var iconURL: URL? {
        guard
            let iconURL = weather?.first?.icon,
            !iconURL.isEmpty,
            let url = URL(string: "https://openweathermap.org/img/wn/\(iconURL)@2x.png")
        else { return nil }
        return url
    }
    
}

struct CustomError: Error {
    let message: String
}
