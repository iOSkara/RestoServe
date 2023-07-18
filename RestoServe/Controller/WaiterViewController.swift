//
//  WaiterViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 17.07.2023.
//

import UIKit
import RealmSwift

class WaiterViewController: ExtensionViewController {
    
    let realm = try! Realm()
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    @IBAction func showMenuButtonPressed(_ sender: UIButton) {
        navigateToListOfDishes()
    }
    
    @IBAction func createOrderButtonPressed(_ sender: UIButton) {
        navigateToTablesList()
    }
    
    func navigateToListOfDishes() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listOfDishesVC = storyboard.instantiateViewController(withIdentifier: "DishesViewController") as! DishesViewController
        listOfDishesVC.currentUser = currentUser
        navigationController?.pushViewController(listOfDishesVC, animated: true)
    }
    
    func navigateToTablesList() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tablesVC = storyboard.instantiateViewController(withIdentifier: "TablesListViewController") as! TablesListViewController
        tablesVC.currentUser = currentUser
        navigationController?.pushViewController(tablesVC, animated: true)
    }
    
}
