//
//  BusinessDetailViewController.swift
//  Fast Foodz
//
//  Created by Jae Young Choi on 2/19/22.
//

import MapKit

class BusinessDetailViewController: UIViewController {

    // MARK: - Interface Builder

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var callButton: UIButton!

    /// Calling the provided business phone number
    @IBAction func callButtonPressed(_ sender: Any) {
        guard let phoneNumber = business?.phone else { return }
        guard let number = URL(string: "tel://" + phoneNumber) else { return }
        if UIApplication.shared.canOpenURL(number) {
            UIApplication.shared.open(number)
        } else {
            print("Can't open url on this device")
        }
    }

    /// Bring out share sheet to copy location URL
    @IBAction func presentShareSheet(_ sender: Any) {
        guard let url = URL(string: (business?.url)!) else { return }

        let shareSheetVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(shareSheetVC, animated: true, completion: nil)
    }

    var business: Business?
    var userLocation: CLLocationCoordinate2D?

    // MARK: - View Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Details"
        mapView.layer.cornerRadius = 12
        callButton.layer.cornerRadius = 6
        nameLabel?.text = business?.name

        if let url = URL(string: business?.image_url ?? "") {
            imageView.load(url: url)
        }

        mapView.delegate = self
        getDirections()
    }

    // MARK: - MKDirection Functions

    func getDirections() {
        guard let userLocation = userLocation else {
            return
        }

        let request = createDirectionsRequest(from: userLocation)
        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, error in
            guard let response = response else { return }

            self.mapView.addOverlay(response.routes[0].polyline)
            self.mapView.setVisibleMapRect(response.routes[0].polyline.boundingMapRect, animated: true)
        }
    }

    /// Creating the MKDirections.Request for directions
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        var destinationCoordinate = CLLocationCoordinate2D(latitude: 40.758896, longitude: -73.985130)

        if let latitude = business?.coordinates.latitude, let longitude = business?.coordinates.longitude {
            destinationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true

        return request
    }
}

// MARK: - Extensions

/// Rendering out the MKOverlay
extension BusinessDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .bluCepheus
        renderer.lineWidth = 4.0

        return renderer
    }
}

/// Asynchronous image fetching method
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
