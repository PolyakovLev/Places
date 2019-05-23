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

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var place:                  Place!
    var anotationIdentifier     = "anotationIdentifier"
    let locationManager         = CLLocationManager()
    let regionInMeters          = 10_000.0
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPlacemark()
        checkLocationServises()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func myLocationButton(_ sender: Any) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            
            mapView.setRegion(region, animated: true)
            
        }
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
}

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
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       checkLocationAutorization()
    }
}
