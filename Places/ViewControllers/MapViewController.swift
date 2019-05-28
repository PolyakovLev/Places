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
    var identyfire: String?             = nil
    var anotationIdentifier             = "anotationIdentifier"
    
    let mapManager                      = MapManager()
    var mapVCDelegate:              mapViewControllerDelegate?
    var place:                      Place!
    var previousLocation:           CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, location: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func myLocationButton(_ sender: Any) {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        mapVCDelegate?.getAddress(addressLable.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func navigationButtonPressed(_ sender: Any) {
        mapManager.getDirection(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    private func setupMapView () {
        mapManager.checkLocationServises(mapView: mapView, identyfire: identyfire) { 
            mapManager.locationManager.delegate = self
        }
        
        if identyfire != "getAddress" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            marker.isHidden         = true
            addressLable.isHidden   = true
            doneButton.isHidden     = true
        }
        if identyfire == "getAddress" {
            
            navigationButton.isHidden = true
        }
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
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if identyfire != "getAddress" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { 
//                self.mapManager.showUserLocation(mapView: mapView)
//                print("mapView")
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
        mapManager.checkLocationAutorization(mapView: mapView, identyfire: identyfire)
    }
}
