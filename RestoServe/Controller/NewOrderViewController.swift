//
//  NewOrderViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 18.07.2023.
//

import UIKit
import RealmSwift

class NewOrderViewController: ExtensionViewController {
    
    let realm = try! Realm()
    var currentUser: User?
    var currentTable: Table?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
}
