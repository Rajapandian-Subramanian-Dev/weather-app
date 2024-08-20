//
//  LocationManger.swift
//  WeatherApp
//
//  Created by rajapandian on 8/19/24.
//

import Foundation
import CoreLocation

/// protocol abstraction for location manager, helps writing modular and testable code
protocol LocationMangerProtocol {
    var userCoordinate: CLLocationCoordinate2D { get set }
    func updateUserLocation(coordinate: CLLocationCoordinate2D)
}

/// Location manager for handling the user location. 
class LocationManger: LocationMangerProtocol {
    var userCoordinate = kCLLocationCoordinate2DInvalid

    func updateUserLocation(coordinate: CLLocationCoordinate2D) {
        self.userCoordinate = coordinate
    }
}
