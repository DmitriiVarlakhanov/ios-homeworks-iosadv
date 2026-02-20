//
//  MapViewController.swift
//  IOSADVHomeworks
//
//  Created by Dmitrii Varlakhanov on 2/16/26.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    // MARK: - Properties

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()

        mapView.translatesAutoresizingMaskIntoConstraints = false

        mapView.showsUserLocation = true
        mapView.mapType = .standard
        mapView.showsBuildings = true

        mapView.delegate = self

        if #available(iOS 16.0, *) {
            let configuration = MKHybridMapConfiguration()

            configuration.elevationStyle = .realistic
            configuration.showsTraffic = true

            mapView.preferredConfiguration = configuration
        }

        return mapView
    }()

    private lazy var buttonToDeleteAllAnnotations: UIButton = {
        let buttonToDeleteAllAnnotations = UIButton(type: .system)

        buttonToDeleteAllAnnotations.translatesAutoresizingMaskIntoConstraints = false

        buttonToDeleteAllAnnotations.setTitle("Delete all annotations", for: .normal)
        buttonToDeleteAllAnnotations.backgroundColor = .white
        buttonToDeleteAllAnnotations.setTitleColor(.black, for: .normal)

        buttonToDeleteAllAnnotations.layer.cornerRadius = 8
        buttonToDeleteAllAnnotations.layer.borderWidth = 1
        buttonToDeleteAllAnnotations.layer.borderColor = UIColor.black.cgColor

        buttonToDeleteAllAnnotations.addTarget(
            self,
            action: #selector(buttonToDeleteAllAnnotationsTapped),
            for: .touchUpInside
        )

        return buttonToDeleteAllAnnotations
    }()

    private lazy var buttonToSetupRoute: UIButton = {
        let buttonToSetupRoute = UIButton(type: .system)

        buttonToSetupRoute.translatesAutoresizingMaskIntoConstraints = false

        buttonToSetupRoute.setTitle("Build route", for: .normal)
        buttonToSetupRoute.backgroundColor = .white
        buttonToSetupRoute.setTitleColor(.black, for: .normal)

        buttonToSetupRoute.layer.cornerRadius = 8
        buttonToSetupRoute.layer.borderWidth = 1
        buttonToSetupRoute.layer.borderColor = UIColor.black.cgColor

        buttonToSetupRoute.addTarget(
            self,
            action: #selector(buttonToSetupRouteTapped),
            for: .touchUpInside
        )

        return buttonToSetupRoute
    }()

    private let locationManager = CLLocationManager()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupRootView()
        self.setupTabBarItem()
        self.addSubviews()
        self.setupConstraints()
        self.setupLocationManager()
        self.setupMKPoints()
    }

    // MARK: - Actions

    @objc private func buttonToDeleteAllAnnotationsTapped() {
        self.mapView.removeAnnotations(mapView.annotations)
    }

    @objc private func buttonToSetupRouteTapped() {
        if let userLocation = self.locationManager.location?.coordinate {
            let destination = CLLocationCoordinate2D(latitude: 55.7843, longitude: 49.1198)

            let request = MKDirections.Request()

            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))

            let directions = MKDirections(request: request)

            directions.calculate { response, error in
                if let error = error {
                    print(error.localizedDescription)

                    return
                }

                self.mapView.addOverlay(response!.routes.first!.polyline)
            }
        } else {
            let alertController = UIAlertController(
                title: "Error building route",
                message: "Please allow access to location services in settings",
                preferredStyle: .alert
            )

            let action = UIAlertAction(
                title: "Ok",
                style: .cancel
            )

            alertController.addAction(action)

            self.present(alertController, animated: true)
        }
    }

    // MARK: - Private

    private func setupRootView() {
        self.view.backgroundColor = .systemBackground
    }

    private func setupTabBarItem() {
        self.tabBarItem = UITabBarItem(
            title: "Map",
            image: UIImage(systemName: "mappin.circle"),
            tag: 0
        )
    }

    private func addSubviews() {
        self.view.addSubview(mapView)
        self.view.addSubview(buttonToDeleteAllAnnotations)
        self.view.addSubview(buttonToSetupRoute)
    }

    private func setupConstraints() {
        let safeAreaGuide = self.view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor),

            buttonToDeleteAllAnnotations.leftAnchor.constraint(equalTo: safeAreaGuide.leftAnchor, constant: 30),
            buttonToDeleteAllAnnotations.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor, constant: -50),
            buttonToDeleteAllAnnotations.widthAnchor.constraint(equalToConstant: 160),
            buttonToDeleteAllAnnotations.heightAnchor.constraint(equalToConstant: 50),

            buttonToSetupRoute.rightAnchor.constraint(equalTo: safeAreaGuide.rightAnchor, constant: -30),
            buttonToSetupRoute.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor, constant: -50),
            buttonToSetupRoute.widthAnchor.constraint(equalToConstant: 160),
            buttonToSetupRoute.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupLocationManager() {
        self.locationManager.requestWhenInUseAuthorization()

        self.locationManager.delegate = self

        self.locationManager.startUpdatingLocation()
    }

    private func setupMKPoints() {
        let saintPetersburgAnnotation = MKPointAnnotation()

        saintPetersburgAnnotation.coordinate = CLLocationCoordinate2D(latitude: 59.9385, longitude: 30.3125)
        saintPetersburgAnnotation.title = "St.Peterburg"

        let serpukhovAnnotation = MKPointAnnotation()

        serpukhovAnnotation.coordinate = CLLocationCoordinate2D(latitude: 54.9166, longitude: 37.4000)
        serpukhovAnnotation.title = "Serpukhov"

        self.mapView.addAnnotation(saintPetersburgAnnotation)
        self.mapView.addAnnotation(serpukhovAnnotation)
    }
}

    // MARK: - Extensions

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last?.coordinate)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)

            renderer.strokeColor = .blue
            renderer.lineWidth = 3

            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
