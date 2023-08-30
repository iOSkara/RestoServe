//
//  User.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 14.07.2023.
//

import Foundation
import RealmSwift

class User: Object, Identifiable {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var username = ""
    @objc dynamic var password = ""
    @objc dynamic var role = "" // "admin", "waiter", "chef"

    override class func primaryKey() -> String? {
        return "id"
    }
}
