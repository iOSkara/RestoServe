//
//  Category.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 14.07.2023.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""

    override class func primaryKey() -> String? {
        return "id"
    }
}
