//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by rajapandian on 8/18/24.
//

import Foundation
import CoreLocation

// protocol abstraction for weather model, helps writing modular and testable code
protocol WeatherModelProtocol {
    var locationQuery: String { get set }
    var searchQueryParams: [String: String] { get set }
    func updateUserLocation(coordinate: CLLocationCoordinate2D)
    func updateUserQuery(searchParams: [String: String])
    func getWeather(completed: @escaping (_ weather: WeatherProtocol?) -> Void)
}


class WeatherViewModel: WeatherModelProtocol {
    var locationQuery = String()
    var searchQueryParams = [String: String]()
    let locationManager: LocationMangerProtocol
    let weatherRepository : WeatherRepoProtocol
    
    init(locationManager: LocationMangerProtocol, weatherRepository: WeatherRepoProtocol) {
        self.locationManager = locationManager
        self.weatherRepository = weatherRepository
    }
    
    func updateUserLocation(coordinate: CLLocationCoordinate2D) {
        locationManager.updateUserLocation(coordinate: coordinate)
    }
    
    func updateUserQuery(searchParams: [String : String]) {
        locationQuery = ""
        searchQueryParams = searchParams
    }
    
    /// Get weather info from the openweather api
    func getWeather(completed: @escaping (WeatherProtocol?) -> Void) {
        let queryString = getSearchQueryParams()
        guard !queryString.isEmpty else {
            completed(nil)
            return
        }
        weatherRepository.fetchWeatherInfo(queryString: queryString) { result in
            switch result {
            case .success(let result):
                completed(result)
            case .failure(_):
                completed(nil)
            }
        }
    }
    
    // Get final query string data for the api call. Returns the query string data based on the currently available data on the view model
    func getSearchQueryParams() -> String {
        var params = [String: String]()
        if !searchQueryParams.isEmpty {
            params = searchQueryParams
        } else if locationQuery.isEmpty, CLLocationCoordinate2DIsValid(locationManager.userCoordinate){
            params = ["lat": String(format: "%.4f", locationManager.userCoordinate.latitude),
                          "lon": String(format: "%.4f", locationManager.userCoordinate.longitude)]
        } else if !locationQuery.isEmpty {
            params = ["q": locationQuery]
        } else if let lastKnownRequest = getLastWeatherRequestInfo() {
            params = lastKnownRequest
        }
        
        if !params.isEmpty {
            storeLastWeatherRequest(requestParam: params)
        }
        
        let queryString = params.map { $0.0 + "=" + $0.1 }.joined(separator: "&")
        return queryString
    }
    
    private func storeLastWeatherRequest(requestParam: [String: String]) {
        UserDefaults.standard.setValue(requestParam, forKey: "lastKnownQuery")
    }
    
    private func getLastWeatherRequestInfo() -> [String: String]? {
        UserDefaults.standard.dictionary(forKey: "lastKnownQuery") as? [String: String]
    }
}
