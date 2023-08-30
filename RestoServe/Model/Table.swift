//
//  Table.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 14.07.2023.
//

import Foundation
import RealmSwift

class Table: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var tableNumber = ""
    @objc dynamic var isOccupied = false
    let orders = LinkingObjects(fromType: Order.self, property: "table")

    override class func primaryKey() -> String? {
        return "id"
    }
}
