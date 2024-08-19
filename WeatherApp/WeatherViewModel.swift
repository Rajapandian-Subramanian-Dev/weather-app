//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by rajapandian on 8/18/24.
//

import Foundation
import CoreLocation

protocol LocationMangerProtocol {
    var locationQuery: String { get set }
    var userCoordinate: CLLocationCoordinate2D { get set }

    func updateUserLocation(coordinate: CLLocationCoordinate2D)
    func updateUserQuery(searchString: String)
}

protocol WeatherModelProtocol {
    func updateUserLocation(coordinate: CLLocationCoordinate2D)
    func updateUserQuery(searchString: String)
    func getWeather(completed: @escaping (_ weather: WeatherProtocol?) -> Void)
}

class LocationManger: LocationMangerProtocol {
    var locationQuery = String()
    var userCoordinate = kCLLocationCoordinate2DInvalid

    func updateUserLocation(coordinate: CLLocationCoordinate2D) {
        self.userCoordinate = coordinate
    }
    
    func updateUserQuery(searchString: String) {
        self.locationQuery = searchString
    }
}

class WeatherViewModel: WeatherModelProtocol {
    
    let locationManager: LocationMangerProtocol
    let weatherRepository : WeatherRepoProtocol
    
    init(locationManager: LocationMangerProtocol, weatherRepository: WeatherRepoProtocol) {
        self.locationManager = locationManager
        self.weatherRepository = weatherRepository
    }
    
    func updateUserLocation(coordinate: CLLocationCoordinate2D) {
        locationManager.updateUserLocation(coordinate: coordinate)
    }
    
    func updateUserQuery(searchString: String) {
        locationManager.updateUserQuery(searchString: searchString)
    }
    
    func getWeather(completed: @escaping (WeatherProtocol?) -> Void) {
        let queryString = getSearchQueryParams()
        print("queryString: \(queryString)")
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
    
    private func getSearchQueryParams() -> String {
        var params = [String: String]()
        if locationManager.locationQuery.isEmpty, CLLocationCoordinate2DIsValid(locationManager.userCoordinate){
            params = ["lat": String(format: "%.4f", locationManager.userCoordinate.latitude),
                          "lon": String(format: "%.4f", locationManager.userCoordinate.longitude)]
        } else if !locationManager.locationQuery.isEmpty {
            params = ["q": locationManager.locationQuery]
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

