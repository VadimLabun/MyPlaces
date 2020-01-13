//
//  StorageManager.swift
//  My pleces
//
//  Created by Vadim Labun on 8/31/19.
//  Copyright © 2019 Vadim Labun. All rights reserved.
//

import RealmSwift


let realm = try! Realm()

class StorageManager {
    static func saveObject(_ plece: Place) {
        try! realm.write {
            realm.add(plece)
            
        }
    }
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
