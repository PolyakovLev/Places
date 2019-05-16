//
//  PlaceModel.swift
//  Places
//
//  Created by Lev polyakov on 15/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import UIKit

struct Place {
    var name:           String
    var location:       String?
    var type:           String?
    var image:          UIImage?
    var restarantImage: String?
    
    static let restarantArray: [String] = ["bizon", "pinzza", "sirena", "klevo", "italy"]
    
    static func getPlaces() -> [Place] {
        var places: [Place] = []
        
        for place in restarantArray {
            places.append(Place(name: place, location: "Moscow", type: "restaran", image: nil, restarantImage: place))
        }
        return places
    }
    
    
}
