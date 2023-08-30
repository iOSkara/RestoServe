//
//  Dish.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 14.07.2023.
//

import Foundation
import RealmSwift

class Dish: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var descriptionText = ""
    @objc dynamic var price = 0.0
    @objc dynamic var category: Category?
    @objc dynamic var estimatedCookingTime = 0 // в секундах
    @objc dynamic var isAvailable: Bool = true

    override class func primaryKey() -> String? {
        return "id"
    }
}
