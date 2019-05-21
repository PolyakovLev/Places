//
//  PlaceModel.swift
//  Places
//
//  Created by Lev polyakov on 15/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import RealmSwift

class Place: Object {
    @objc dynamic var name =          ""
    @objc dynamic var data =          Date()
    @objc dynamic var location:       String?
    @objc dynamic var type:           String?
    @objc dynamic var imageData:      Data?
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?) {
        self.init() // set default values
        self.name       = name
        self.location   = location
        self.type       = type
        self.imageData  = imageData
    }
}
