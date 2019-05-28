//
//  MapManager.swift
//  Places
//
//  Created by Lev polyakov on 25/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    
    private var placeCoordinates:               CLLocationCoordinate2D?
    private let regionInMeters                  = 1000.0
    private var derectionsArray: [MKDirections] = []
    var bestTime                                = 0
    let locationManager                         = CLLocationManager()
    
    func setupPlacemark(place: Place, mapView: MKMapView) {
        let location = place.location!
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error { // TODO: also check internet connection
                print(error)
                self.errorAlert(text: "Sorry the adress dont exist or no internet conection")
            }
            
            guard let placemarks    = placemarks else  { return }
            
            let placemark               = placemarks.first
            let annotation              = MKPointAnnotation()
            annotation.title            = place.name
            annotation.subtitle         = place.type
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate       = placemarkLocation.coordinate
            self.placeCoordinates       = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true) // make marker big
        }
    }
    
    func checkLocationServises(mapView: MKMapView, identyfire: String?, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, identyfire: identyfire)
            closure()
        } else {
            self.errorAlert(text: "Sorry the location servises not avalible, go to settings to fix that,")
        }
    }
    
    func checkLocationAutorization(mapView: MKMapView, identyfire: String?) {
        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation =  true
            if identyfire == "getAddress" {
                showUserLocation(mapView: mapView)
            }
//            print("checkLocationaaa")
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
    
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirection(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else { 
            errorAlert(text: "Sorry cannot find you")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = getDirectionReguest(from: location) else {
            errorAlert(text: "destination not found")
            return
        }
        
        let derections = MKDirections(request: request)
        
        resetMapView(withNew: derections, mapView: mapView)
        
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
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                if self.bestTime == 0 {
                    self.bestTime = Int(route.expectedTravelTime)
                } else if Int(route.expectedTravelTime) < self.bestTime {
                    self.bestTime = Int(route.expectedTravelTime)
                }
            }
            print("time: \(self.secondsToHoursMinutes(seconds: self.bestTime))")
        }
    }
    
    func secondsToHoursMinutes (seconds : Int) -> String {
        var hoursMinutes = ""
        if seconds / 3600 >= 1 {
            hoursMinutes += "\(String(seconds / 3600))H. "
        } 
        if (seconds % 3600) / 60 > 1 {
            hoursMinutes += "\((seconds % 3600) / 60)M."
        }
        return hoursMinutes
    }
    
    func getDirectionReguest(from coordinates: CLLocationCoordinate2D) -> MKDirections.Request? {
        
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
    
    func startTrackingUserLocation(for mapView: MKMapView, location: CLLocation?, closure: (_ currentLocation:CLLocation) -> ()) {
        guard let location = location else { return }
        
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location)  > 50 else { return }
        closure(center)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude    = mapView.centerCoordinate.latitude
        let longetude   = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longetude)
    }
    
    func resetMapView(withNew derections: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        derectionsArray.append(derections)
        let _ = derectionsArray.map {$0.cancel()}
        derectionsArray.removeAll()
    }
    
    func errorAlert(text: String) {
        let alert = UIAlertController(title: "Error",
                                      message: text,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let alertWindow = UIWindow(frame:  UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
