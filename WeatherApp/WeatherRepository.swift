//
//  WeatherRepository.swift
//  WeatherApp
//
//  Created by rajapandian on 8/18/24.
//

import Foundation
import CoreLocation

protocol WeatherRepoProtocol {
    func fetchWeatherInfo(queryString: String, completed: @escaping (_ result: Result<Weather, CustomError>) -> Void)
}

class WeatherRepository: WeatherRepoProtocol {
    // URL and API key stored here. This goes to config file
    let weatherApi = "https://api.openweathermap.org/data/2.5/weather?%@&appid=eb69b58c06634a5289dcdf6af8097077&units=imperial"
    
    func fetchWeatherInfo(queryString: String, completed: @escaping (Result<Weather, CustomError>) -> Void) {
       guard let url = URL(string: String(format: weatherApi, queryString)) else {
            // invalid URL
            completed(.failure(CustomError(message: "Invalid URL")))
            return
        }
        print("url: \(url)")
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, urlResponse, error in
            guard error == nil, let responseData = data else {
                print("Something went wrong! : \(error?.localizedDescription)")
                completed(.failure(CustomError(message: error?.localizedDescription ?? "")))
                return
            }
            do {
                print("API response: \(String(describing: String(data: responseData, encoding: .utf8)))")
                let jsonDecoder = JSONDecoder()
                let weatherObject = try jsonDecoder.decode(Weather.self, from: responseData)
                completed(.success(weatherObject))
            } catch {
                // Request failed
                print(error)
                completed(.failure(CustomError(message: error.localizedDescription)))
            }
        }
        task.resume()
    }
}

struct CustomError: Error {
    let message: String
}
