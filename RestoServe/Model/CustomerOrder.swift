//
//  CustomerOrder.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 18.07.2023.
//

import Foundation
import RealmSwift

class CustomerOrder: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var customerId: String?
    let dishes = List<OrderedDish>()

    override class func primaryKey() -> String? {
        return "id"
    }
}
