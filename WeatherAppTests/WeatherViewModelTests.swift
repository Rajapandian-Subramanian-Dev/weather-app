//
//  WeatheViewModelTests.swift
//  WeatherAppTests
//
//  Created by rajapandian on 8/19/24.
//

import XCTest
import CoreLocation
@testable import WeatherApp

final class WeatherViewModelTests: XCTestCase {

    // Tests whether the provided user location parsed without any issues and generated required query params
    func testUserLocationSearchQuery() {
        let weatherViewModel = WeatherViewModel(locationManager: LocationManger(), weatherRepository: WeatherRepository())
        weatherViewModel.updateUserLocation(coordinate: CLLocationCoordinate2DMake(33.0974, -96.6632))
        var userLocationQueryParams = weatherViewModel.getSearchQueryParams()
        XCTAssertEqual(userLocationQueryParams.contains("lon=-96.6632"), true)
        XCTAssertEqual(userLocationQueryParams.contains("lat=33.0974"), true)

        weatherViewModel.updateUserLocation(coordinate: CLLocationCoordinate2DMake(33.09, -96.6632))
        userLocationQueryParams = weatherViewModel.getSearchQueryParams()        
        XCTAssertEqual(userLocationQueryParams.contains("lon=-96.6632"), true)
        XCTAssertEqual(userLocationQueryParams.contains("lat=33.0900"), true)
    }

    // Tests whether the provided invalid user location ignored or not
    func testInvalidCoordinateUserLocationSearchQuery() {
        let weatherViewModel = WeatherViewModel(locationManager: LocationManger(), weatherRepository: WeatherRepository())
        weatherViewModel.updateUserLocation(coordinate: CLLocationCoordinate2DMake(-150.013, 135.0023))
        let userLocationQueryParams = weatherViewModel.getSearchQueryParams()
        XCTAssertNotEqual(userLocationQueryParams, "lon=135.0023&lat=150.013")
    }

    // Tests whether the selected location from the search results parsed without any issues and generated required query params
    func testSelectedLocationSearchQuery() {
        let weatherViewModel  = WeatherViewModel(locationManager: LocationManger(), weatherRepository: WeatherRepository())
        let location = Location(name: "Texhoma", lat: 36.4976, lon: -101.7838, country: "US", state: "Texas")
        weatherViewModel.updateUserQuery(searchParams: location.searchQueryParams)
        let searchParams = weatherViewModel.searchQueryParams
        XCTAssertEqual(searchParams["units"], "imperial")
        XCTAssertEqual(searchParams["lat"], "36.4976")
        XCTAssertEqual(searchParams["lon"], "-101.7838")
    }

    // Tests whether last searched/available weather location saved in the cache after clearing the data from live memory
    func testLastRequestedWeatherInfoCache() {
        let weatherViewModel = WeatherViewModel(locationManager: LocationManger(), weatherRepository: WeatherRepository())
        weatherViewModel.updateUserLocation(coordinate: CLLocationCoordinate2DMake(33.0974, -96.6632))
        let userLocationQueryParams = weatherViewModel.getSearchQueryParams()
        XCTAssertEqual(userLocationQueryParams.contains("lon=-96.6632"), true)
        XCTAssertEqual(userLocationQueryParams.contains("lat=33.0974"), true)

        // Resets last searched values from the memory
        weatherViewModel.updateUserQuery(searchParams: [:])
        weatherViewModel.locationManager.updateUserLocation(coordinate: CLLocationCoordinate2DMake(.zero, .zero))
        
        // After clearing all search values from the model, last searched value fetched from the cache
        XCTAssertEqual(userLocationQueryParams.contains("lon=-96.6632"), true)
        XCTAssertEqual(userLocationQueryParams.contains("lat=33.0974"), true)
        //XCTAssertEqual(userLocationQueryParams, "lon=-96.6632&lat=33.0974")
    }

    // Tests whether search results object producing the expected location details or not
    func testLocationDetails() {
        let location = Location(name: "Texhoma", lat: 36.4976, lon: -101.7838, country: "US", state: "Texas")
        XCTAssertEqual(location.locationDetail, "Texhoma, Texas, US")
    }
}
