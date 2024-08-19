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
    var locationManager: CLLocationManager?
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempUnit: UILabel!
    @IBOutlet weak var tempDescriptionLabel: UILabel!
    @IBOutlet weak var tempImage: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
        getWeather()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
    }
    
    private func getWeather() {
        activityIndicatorView.startAnimating()
        weatherModel.getWeather { [weak self] weather in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
                guard let self = self, let weather else { return }
                self.tempUnit.isHidden = false
                self.locationLabel.text = weather.location
                self.tempLabel.text = weather.temp
                self.tempDescriptionLabel.text = weather.tempDescription
                if let iconURL = weather.iconURL {
                    self.tempImage.load(url: iconURL)
                }
            }
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("manager.authorizationStatus 1: \(manager.authorizationStatus)")
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager?.requestLocation()
        } else if manager.authorizationStatus == .restricted || manager.authorizationStatus == .denied {
            showAlert(text: "Location access is required. Please enable location access for the Weather app in your iPhone Settings.")
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager: \(locations.last?.coordinate)")
        guard let location = locations.last else { return }
        weatherModel.updateUserLocation(coordinate: location.coordinate)
        self.getWeather()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError 1: \(manager.authorizationStatus)")
        print("didFailWithError: \(error)")
        if manager.authorizationStatus == .restricted || manager.authorizationStatus == .denied {
            showAlert(text: "Location access is required. Please enable location access for the Weather app in your iPhone Settings.")
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard 
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsTableViewCell", for: indexPath) as? SearchResultsTableViewCell
        else {
            return UITableViewCell()
        }
        cell.locationLabel.text = "Detail goes here"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension UIViewController {
    func showAlert(text: String) {
        let alert = UIAlertController(title: "Alert", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
