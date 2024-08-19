//
//  LocationManger.swift
//  WeatherApp
//
//  Created by rajapandian on 8/19/24.
//

import Foundation
import CoreLocation

protocol LocationMangerProtocol {
    var userCoordinate: CLLocationCoordinate2D { get set }
    func updateUserLocation(coordinate: CLLocationCoordinate2D)
}

class LocationManger: LocationMangerProtocol {
    var userCoordinate = kCLLocationCoordinate2DInvalid

    func updateUserLocation(coordinate: CLLocationCoordinate2D) {
        self.userCoordinate = coordinate
    }
}
