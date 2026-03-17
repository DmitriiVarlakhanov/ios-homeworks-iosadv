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

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerTapped(gestureRecognizer:)))

        gestureRecognizer.numberOfTapsRequired = 1

        mapView.addGestureRecognizer(gestureRecognizer)

        return mapView
    }()

    private lazy var buttonToDeleteAllAnnotations: UIButton = {
        let buttonToDeleteAllAnnotations = UIButton(type: .system)

        buttonToDeleteAllAnnotations.translatesAutoresizingMaskIntoConstraints = false

        buttonToDeleteAllAnnotations.setTitle(
            NSLocalizedString("buttonToDeleteAllAnnotationsLocalizationKey", comment: ""),
            for: .normal
        )
        //buttonToDeleteAllAnnotations.backgroundColor = .white
        buttonToDeleteAllAnnotations.setTitleColor(.label, for: .normal)

        buttonToDeleteAllAnnotations.layer.cornerRadius = 8
        buttonToDeleteAllAnnotations.layer.borderWidth = 1
        buttonToDeleteAllAnnotations.layer.borderColor = UIColor.black.cgColor

        buttonToDeleteAllAnnotations.backgroundColor = UIColor.createColorTemplateFunction(
            lightMode: .white,
            darkMode: .black
        )

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

        buttonToSetupRoute.setTitle(
            NSLocalizedString("buttonToSetupRouteLocalizationKey", comment: ""),
            for: .normal
        )
        buttonToSetupRoute.setTitleColor(.label, for: .normal)

        buttonToSetupRoute.layer.cornerRadius = 8
        buttonToSetupRoute.layer.borderWidth = 1
        buttonToSetupRoute.layer.borderColor = UIColor.black.cgColor

        buttonToSetupRoute.backgroundColor = UIColor.createColorTemplateFunction(
            lightMode: .white,
            darkMode: .black
        )

        print(self)

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
    }

    // MARK: - Actions

    @objc private func buttonToDeleteAllAnnotationsTapped() {
        self.mapView.removeAnnotations(mapView.annotations)

        self.mapView.removeOverlays(self.mapView.overlays)
    }

    @objc private func buttonToSetupRouteTapped() {
        var destination = self.locationManager.location?.coordinate

        for annotation in self.mapView.annotations {
            if let annotation = annotation as? MKPointAnnotation {
                destination = annotation.coordinate
            } else {
                continue
            }
        }

        if let userLocation = self.locationManager.location?.coordinate {
            if destination?.latitude == userLocation.latitude && destination?.longitude == userLocation.longitude {
                return
            } else {
                let request = MKDirections.Request()

                request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination!))

                let directions = MKDirections(request: request)

                directions.calculate { response, error in
                    if let error = error {
                        print(error.localizedDescription)

                        return
                    }

                    self.mapView.addOverlay(response!.routes.first!.polyline)

                    self.mapView.setVisibleMapRect(response!.routes.first!.polyline.boundingMapRect, animated: true)
                }
            }
        } else {
            let alertController = UIAlertController(
                title: NSLocalizedString("alertControllerTitleLocalizationKey", comment: ""),
                message: NSLocalizedString("alertControllerMessageLocalizationKey", comment: ""),
                preferredStyle: .alert
            )

            let action = UIAlertAction(
                title: NSLocalizedString("alertActionTitleLocalizationKey", comment: ""),
                style: .cancel
            )

            alertController.addAction(action)

            self.present(alertController, animated: true)
        }
    }

    @objc private func tapGestureRecognizerTapped(gestureRecognizer: UITapGestureRecognizer) {
        let coordinateOnMapView = gestureRecognizer.location(in: self.mapView)

        let geographicCoordinates = self.mapView.convert(coordinateOnMapView, toCoordinateFrom: self.mapView)

        let specificAnnotation = MKPointAnnotation()

        specificAnnotation.coordinate = geographicCoordinates
        specificAnnotation.title = NSLocalizedString(
            "specificAnnotationTitleLocalizationKey",
            comment: ""
        )

        self.mapView.removeOverlays(self.mapView.overlays)

        self.mapView.removeAnnotations(mapView.annotations)

        self.mapView.addAnnotation(specificAnnotation)
    }

    // MARK: - Private

    private func setupRootView() {
        self.view.backgroundColor = .systemBackground
    }

    private func setupTabBarItem() {
        self.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBarItemTitleLocalizationKey", comment: ""),
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
}

    // MARK: - Extensions

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last?.coordinate)

        self.mapView.setRegion(MKCoordinateRegion(center: self.locationManager.location!.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000), animated: true)
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

extension UIColor {
    static func createColorTemplateFunction(lightMode: UIColor, darkMode: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else {
            return lightMode
        }
        return UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return darkMode
            } else {
                return lightMode
            }
        }
    }
}
