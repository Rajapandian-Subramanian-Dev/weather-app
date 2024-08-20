//
//  WeatheViewModelMockTests.swift
//  WeatherAppTests
//
//  Created by rajapandian on 8/19/24.
//

import XCTest
import CoreLocation
@testable import WeatherApp

enum MockType {
    case success
    case failure
}
/**
 Mocking the protocols to stub the API responses and test the different kind of data to ensure the model provides the expected data
 */
class MockWeatherViewModel: WeatherModelProtocol {
    var locationQuery = String()
    var searchQueryParams = [String: String]()
    
    let locationManager: LocationMangerProtocol
    let weatherRepository : MockWeatherRepository
    
    init(locationManager: LocationMangerProtocol, weatherRepository: MockWeatherRepository) {
        self.locationManager = locationManager
        self.weatherRepository = weatherRepository
    }
    
    func updateUserLocation(coordinate: CLLocationCoordinate2D) { }
    func updateUserQuery(searchParams: [String : String]) { }
    
    /// Mocks the response data from the mock file, this enables us to test different set of the mock files. Mocks files can be removed using script before shipping the app
    func getWeather(completed: @escaping (WeatherProtocol?) -> Void) {
        weatherRepository.fetchWeatherInfo(queryString: "") { result in
            switch result {
            case .success(let weather):
                completed(weather)
            case .failure(_):
                completed(nil)
            }
        }
    }
    
}

// Mocking the weather repository so that the API response can be mocked using either the objects or from the json file
class MockWeatherRepository: WeatherRepoProtocol {
    var mockType: MockType = .success
    
    func fetchWeatherInfo(queryString: String, completed: @escaping (Result<Weather, CustomError>) -> Void) {
        if mockType == .success {
            fetchItemsFromBundle(resource: "weather-mock", ext: "json") { result in
                switch result {
                case .success(let weather):
                    completed(.success(weather))
                case .failure(let error):
                    completed(.failure(error))
                }
            }
        } else {
            completed(.failure(CustomError(message: "failed to load")))
        }
    }
    
    // Fetches data from the bundle for the provided resource name
    func fetchItemsFromBundle(resource: String, ext: String, completed: @escaping (Result<Weather, CustomError>) -> Void) {
        guard let bundlePath = Bundle.main.url(forResource: resource, withExtension: ext)
        else {
            return completed(.failure(CustomError(message: "")))
        }
        do {
            let data = try Data(contentsOf: bundlePath)
            let decoder = JSONDecoder()
            let result = try decoder.decode(Weather.self, from: data)
            return completed(.success(result))
        } catch {
            return completed(.failure(CustomError(message: "")))
        }
    }
}

final class WeatherViewModelMockTests: XCTestCase {
    let weatherMockViewModel = MockWeatherViewModel(locationManager: LocationManger(), weatherRepository: MockWeatherRepository())
    
    // Tests wether the mocked weather data properly parsed and values are returned as expected
    func testMockWeatherInfo() {
        weatherMockViewModel.getWeather { weather in
            XCTAssertNotNil(weather)
            XCTAssertEqual(weather?.location, "Plano")
            XCTAssertEqual(weather?.temp, "85.50")
            XCTAssertEqual(weather?.tempDescription, "clear sky")
        }
    }
}
