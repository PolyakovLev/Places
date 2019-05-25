//
//  MapViewController.swift
//  Places
//
//  Created by Lev polyakov on 21/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol mapViewControllerDelegate {
    func getAddress(_ addres: String?) 
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var addressLable:    UILabel!
    @IBOutlet weak var marker:          UIImageView!
    @IBOutlet weak var mapView:         MKMapView!
    @IBOutlet weak var doneButton:      UIButton!
    @IBOutlet weak var navigationButton: UIButton!
    
    var mapVCDelegate:              mapViewControllerDelegate?
    var place:                      Place!
    var placeCoordinates:           CLLocationCoordinate2D?
    var previousLocation:           CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    
    let locationManager                 = CLLocationManager()
    let regionInMeters                  = 1000.0
    var anotationIdentifier             = "anotationIdentifier"
    var identyfire: String?             = nil
    var derectionsArray: [MKDirections] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        checkLocationServises()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func myLocationButton(_ sender: Any) {
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        mapVCDelegate?.getAddress(addressLable.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func navigationButtonPressed(_ sender: Any) {
        getDirection()
    }
    
    private func setupMapView () {
        if identyfire != "getAddress" {
            setupPlacemark()
            marker.isHidden         = true
            addressLable.isHidden   = true
            doneButton.isHidden     = true
        }
    }
    
    private func resetMapView(withNew derections: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        derectionsArray.append(derections)
        let _ = derectionsArray.map {$0.cancel()}
        derectionsArray.removeAll()
    }
    
    private func setupPlacemark() {
        let location = place.location!
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error { // TODO: also check internet connection
                print(error)
                let mapAlert = UIAlertController(title: "Error",
                                                 message: "Sorry the adress dont exist or no internet conection",
                                                 preferredStyle: .alert)
                mapAlert.addAction(UIAlertAction(title: "OK",
                                                 style: .default,
                                                 handler: nil))
                self.present(mapAlert, animated: true, completion: nil)
            }
            
            guard let placemarks    = placemarks else  { return }
            let placemark           = placemarks.first
            
            let annotation              = MKPointAnnotation()
            annotation.title            = self.place.name
            annotation.subtitle         = self.place.type
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate       = placemarkLocation.coordinate
            self.placeCoordinates       = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true) // make marker big
        }
    }
    
    private func checkLocationServises() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
            errorAlert(text: "Sorry the location servises not avalible, go to settings to fix that,")
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAutorization() {
        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation =  true
            if identyfire == "getAddress" {
                showUserLocation()
                navigationButton.isHidden = true
            }
            break
        case .denied:
            errorAlert(text: "Location servises are disable, please go to settings to allow")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            errorAlert(text: "This app is not authorized to use location services.")
            break
        @unknown default:
            print("new case avalible")
        }
    }
    
    private func errorAlert(text: String) {
        let alert = UIAlertController(title: "Error",
                                      message: text,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func startTrackingUserLocation() {
        guard let previousLocation = previousLocation else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation)  > 50 else { return }
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { 
            self.showUserLocation()
        }
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude    = mapView.centerCoordinate.latitude
        let longetude   = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longetude)
    }
    
    private func getDirection() {
        guard let location = locationManager.location?.coordinate else { 
            errorAlert(text: "Sorry cannot find you")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = getDirectionReguest(from: location) else {
            errorAlert(text: "destination not found")
            return
        }
        
        let derections = MKDirections(request: request)
        resetMapView(withNew: derections)
        
        derections.calculate { (responce, error) in
            if let error = error {
                print(error)
                return
            }
            guard  let responce = responce else {
                self.errorAlert(text: "direction is not avalible")
                return
            }
                        
            for route in responce.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
//                let distance = String(format: "%.1f", route.distance / 1000)
//                let timeInterval = route.expectedTravelTime
//                
            }
        }
    }
    
    private func getDirectionReguest(from coordinates: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let distanationCoordinates    = placeCoordinates else { return nil }
        let startLocation                   = MKPlacemark(coordinate: coordinates)
        let destination                     = MKPlacemark(coordinate: distanationCoordinates)
        let request                         = MKDirections.Request()
        request.source                      = MKMapItem(placemark: startLocation)
        request.destination                 = MKMapItem(placemark: destination)
        request.transportType               = .automobile
        request.requestsAlternateRoutes     = true
        
        return request
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendere = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        rendere.strokeColor = .blue
        return rendere
    }
}

// MARK: - Extensions
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        var anotationView = mapView.dequeueReusableAnnotationView(withIdentifier: anotationIdentifier)
        
        if anotationView == nil {
            anotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: anotationIdentifier)
            anotationView?.canShowCallout = true
        }
        
        let imageView                           = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.image                         = UIImage(data: place.imageData!)
        imageView.layer.cornerRadius            = 10
        imageView.clipsToBounds                 = true
        imageView.contentMode                   = .scaleAspectFit
        anotationView?.leftCalloutAccessoryView = imageView
        return anotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if identyfire != "getAddress" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { 
                self.showUserLocation()
            }
        }
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark   = placemarks.first
            let streetName  = placemark?.thoroughfare
            let bilding     = placemark?.subThoroughfare
            
            if streetName != nil && bilding != nil {
                self.addressLable.text = "\(streetName!), \(bilding!)"
            } else if streetName != nil {
                self.addressLable.text = "\(streetName!)"
            } else {
                self.addressLable.text = "floor is lava"
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutorization()
    }
}
