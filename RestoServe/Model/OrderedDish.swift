//
//  OrderedDish.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 14.07.2023.
//

import Foundation
import RealmSwift

class OrderedDish: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var dishId: Dish?
    @objc dynamic var remainingTime = 0 // in seconds

    override class func primaryKey() -> String? {
        return "id"
    }
}
