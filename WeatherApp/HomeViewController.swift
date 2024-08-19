//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by rajapandian on 8/18/24.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    let weatherModel = WeatherViewModel(locationManager: LocationManger(), weatherRepository: WeatherRepository())
    var locationSearchManager: LocationSearchProtocol = LocationSearchManager()
    var locationManager: CLLocationManager?
    
    // This can be moved either to SwiftUI or CustomUIView and embeded here in this Home VC
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempUnit: UILabel!
    @IBOutlet weak var tempDescriptionLabel: UILabel!
    @IBOutlet weak var tempImage: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var locationInfoLabel: UILabel!

    // Search View
    @IBOutlet weak var searchParentView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchTextField: UITextField!



    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
        
        // Observer search text changes
        searchTextField.placeholder = "Search for a city"
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func getWeather() {
        infoLabel.isHidden = true
        activityIndicatorView.startAnimating()
        weatherModel.getWeather { [weak self] weather in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                if weather == nil {
                    self?.infoLabel.isHidden = false
                    self?.infoLabel.text = "Could not load weather info. Please try again"
                    self?.locationSearchManager.selectedLocation = nil
                    return
                }
                guard let self = self, let weather else { return }
                self.updateWeatherDetails(weather: weather, selectedLocation: self.locationSearchManager.selectedLocation)
            }
        }
    }
    
    private func updateWeatherDetails(weather: WeatherProtocol, selectedLocation: Location?) {
        tempUnit.isHidden = false
        locationLabel.text = weather.location.capitalized
        tempLabel.text = weather.temp
        tempDescriptionLabel.text = weather.tempDescription.capitalized
        locationInfoLabel.text = selectedLocation?.locationDetail.capitalized
        if let iconURL = weather.iconURL {
            tempImage.load(url: iconURL)
        }
    }
    
    @IBAction func toggleSearchView(_ sender: Any) {
        infoLabel.isHidden = true
        searchParentView.isHidden = !searchParentView.isHidden
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager?.requestLocation()
        } else if manager.authorizationStatus == .restricted || manager.authorizationStatus == .denied {
            showAlert(text: "Location access is required to display weather based on your current location. Please enable location access for the Weather app in your iPhone Settings OR Search locations using search button")
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        weatherModel.updateUserLocation(coordinate: location.coordinate)
        getWeather()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if manager.authorizationStatus == .restricted || manager.authorizationStatus == .denied {
            showAlert(text: "Location access is required to display weather based on your current location. Please enable location access for the Weather app in your iPhone Settings. OR Search location using search button")
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationSearchManager.searchLocationsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard 
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsTableViewCell", for: indexPath) as? SearchResultsTableViewCell
        else {
            return UITableViewCell()
        }
        cell.locationLabel.text = locationSearchManager.searchLocationsList[safeIndex: indexPath.row]?.locationDetail ?? "Unknown name"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard 
            let selectedLocation = locationSearchManager.searchLocationsList[safeIndex: indexPath.row],
            !selectedLocation.searchQueryParams.isEmpty else {
            return
        }
        searchParentView.isHidden = !searchParentView.isHidden
        locationSearchManager.selectedLocation = selectedLocation
        weatherModel.updateUserQuery(searchParams: selectedLocation.searchQueryParams)
        getWeather()
    }
}

extension HomeViewController: UITextFieldDelegate {
    /* TODO: - Handle copy paste and other edge cases. Updating parent view behind the keyboard bottom constratins based on the keyboard height so the other views don't get hide behind the keyboard
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text.count >= 2 else { return }
        // TODO: Cancelling in-flight api calls before initiating new API call
        locationSearchManager.getLocation(forSearch: text) { [weak self] completed, error in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
            }
        }
    }
}
