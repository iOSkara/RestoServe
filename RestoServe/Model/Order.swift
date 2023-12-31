//
//  Order.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 14.07.2023.
//

import Foundation
import RealmSwift

class Order: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var waiterId: String?
    let customerOrders = List<CustomerOrder>()
    @objc dynamic var orderTime = Date()
    @objc dynamic var status = "" // "accepted", "in progress", "ready"
    @objc dynamic var table: Table?

    override class func primaryKey() -> String? {
        return "id"
    }
}
