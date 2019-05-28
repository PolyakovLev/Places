//
//  StorageManager.swift
//  Places
//
//  Created by Lev polyakov on 16/05/2019.
//  Copyright © 2019 Lev polyakov. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
