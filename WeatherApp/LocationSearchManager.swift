//
//  LocationSearchManager.swift
//  WeatherApp
//
//  Created by rajapandian on 8/19/24.
//

import Foundation

protocol LocationSearchProtocol {
    var locationQuery: String { get set }
    var selectedLocation: Location? { get set }
    var searchLocationsList: [Location] { get set }
    func getLocation(forSearch query: String, completed: @escaping (_ completed: Bool, _ error: Error?) -> Void)
}

class LocationSearchManager: LocationSearchProtocol {
    var selectedLocation: Location?
    var locationQuery = String()
    var searchLocationsList = [Location]()
    
    
    // This goes to config file
    let geocodeAPI = "https://api.openweathermap.org/geo/1.0/direct?q=%@&limit=10&appid=eb69b58c06634a5289dcdf6af8097077"
    
    func getLocation(forSearch query: String, completed: @escaping (Bool, Error?) -> Void) {
        self.locationQuery = query
        guard !locationQuery.isEmpty else  {
            return
        }
        fetchLocation(forSearch: query, completed: completed)
    }
    
}


extension LocationSearchManager {
    
    // Adding API calls here instead of repo(please refer WeatherRepoProtocol and weatherRepository) due to time constraints.
    func fetchLocation(forSearch query: String, completed: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: String(format: geocodeAPI, query)) else {
             completed(false, CustomError(message: "geocodeAPI Invalid URL"))
             return
         }
         let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, urlResponse, error in
             guard error == nil, let responseData = data else {
                 completed(false, CustomError(message: error?.localizedDescription ?? ""))
                 return
             }
             do {
                 let jsonDecoder = JSONDecoder()
                 self?.searchLocationsList = try jsonDecoder.decode([Location].self, from: responseData)
                 completed(true, nil)
             } catch {
                 // Request failed
                 completed(false, CustomError(message: error.localizedDescription))
             }
         }
         task.resume()
     }
}
