//
//  ViewController.swift
//  Fast Foodz
//

import UIKit
import CoreLocation
import MapKit

class MainViewController: UIViewController {

    // MARK: - Interface Builder

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedController: UISegmentedControl!

    /// Function to swap between the Map and List with the UISegmentedControl
    @IBAction func didChangeSegment(_ segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            UIView.animate(withDuration: 0.3) {
                self.mapView.alpha = 1
                self.tableView.alpha = 0
            }
            UserDefaults.standard.set(segment.selectedSegmentIndex, forKey: "selection")
        case 1:
            UIView.animate(withDuration: 0.3){
                self.mapView.alpha = 0
                self.tableView.alpha = 1
            }
            UserDefaults.standard.set(segment.selectedSegmentIndex, forKey: "selection")
        default:
            break
        }
    }

    // MARK: - View Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        /// Add UIActivityIndicatorView to the view
        setUpActivityIndicatorView()

        /// Programmatically setting up UISegmentedView width and text colors
        segmentedController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        segmentedController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.deepIndigo], for: UIControl.State.normal)
        segmentedController.setWidth(view.bounds.width / 3.5, forSegmentAt: 0)
        segmentedController.setWidth(view.bounds.width / 3.5, forSegmentAt: 1)

        /// UISegmentedControl logic and persisting it's state through UserDefaults
        if let value = UserDefaults.standard.value(forKey: "selection") {
            let selectedMode = value as! Int
            segmentedController.selectedSegmentIndex = selectedMode
        }

        /// Default alpha levels for UIView transition animation
        if segmentedController.selectedSegmentIndex == 0 {
            mapView.alpha = 1
            tableView.alpha = 0
        } else {
            mapView.alpha = 0
            tableView.alpha = 1
        }

        /// UITableView connection setup
        tableView.delegate = self
        tableView.dataSource = self

        /// Updating the default MKAnnotation by creating a custom MKAnnotationView
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        /// Connecting MKMapView delegate to use didSelect method
        mapView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        /// CoreLocation setup
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // MARK: - TODO

        /// Check if Location access is denied so you request it again
        if #available(iOS 14.0, *) {
            if locationManager.authorizationStatus == .denied {
                locationManager.requestLocation()
            }
        } else {
            // Fallback on earlier versions
        }

    }

    // MARK: - Core Functions

    var activityIndicator = UIActivityIndicatorView()
    let locationManager = CLLocationManager()
    let defaultLocation = CLLocationCoordinate2D(latitude: 40.758896, longitude: -73.985130)

    var businesses = [Business]()
    var annotations = [CustomAnnotation]()
    var selectedMapBusiness: Business?
    var currentLocation: CLLocationCoordinate2D?

    func setUpActivityIndicatorView() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        view.addSubview(activityIndicator)
    }

    /// Fetch the businesses from Yelp Fusion API using the user's location
    func fetchBusinesses(latitude: Double, longitude: Double) {
        YelpAPIService.shared.fetchBusinesses(latitude: latitude, longitude: longitude) { [weak self] result in
            switch result {
            case .success(let response):
                self?.businesses = response.businesses
                self?.addMapAnnotations()

                /// Update the tableView data on the Main Thread
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }

        }
    }

    /// Adding the MapView Annotations
    func addMapAnnotations() {
        businesses.forEach { business in
            annotations.append(CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: business.coordinates.latitude, longitude: business.coordinates.longitude)))
        }
        mapView.addAnnotations(annotations)
    }

    /// Segue preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        /// From UITableViewCell
        if segue.identifier == "showBusinessDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! BusinessDetailViewController
                destinationController.business = businesses[indexPath.row]
                destinationController.userLocation = currentLocation
            }
        }

        /// From MKMapAnnotationView
        if segue.identifier == "mapSegue" {
            if let selectedMapBusiness = selectedMapBusiness {
                let destinationController = segue.destination as! BusinessDetailViewController
                destinationController.business = selectedMapBusiness
                destinationController.userLocation = currentLocation
            }
        }
    }
}

// MARK: - Extensions

/// Methods to grab user's location and update MKMapView
extension MainViewController: CLLocationManagerDelegate {

    /// Called when user allows location access
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            renderUserLocation(location)
            activityIndicator.startAnimating()
            fetchBusinesses(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }

    /// Rendering the user's current location and setting the mapView around it
    func renderUserLocation(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        currentLocation = coordinate
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)

        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }

}

/// UITableView Extensions
extension MainViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as? BusinessTableViewCell else { fatalError() }
        cell.configureCell(with: businesses[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
}

extension MainViewController: MKMapViewDelegate {

    /// Grabbing the Business data from the selected MKMapAnnotationView to send to the BusinessDetailViewController
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()

        if view is CustomAnnotationView {
            guard let coordinates = view.annotation?.coordinate else { fatalError() }
            guard let firstIndex = businesses.firstIndex(where: { $0.coordinates == Coordinates(longitude: coordinates.longitude, latitude: coordinates.latitude) }) else { return }
            selectedMapBusiness = businesses[firstIndex]
            generator.impactOccurred()
            performSegue(withIdentifier: "mapSegue", sender: nil)

        }
    }
}
