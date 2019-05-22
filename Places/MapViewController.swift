//
//  MapViewController.swift
//  Places
//
//  Created by Lev polyakov on 21/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var place: Place!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacemark()
        
        // Do any additional setup after loading the view.
    }
    
    private func setupPlacemark() {
        let location = place.location!
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error { 
                print(error)
            }
            
            guard let placemarks = placemarks else  { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true) // make marker big
        }
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
