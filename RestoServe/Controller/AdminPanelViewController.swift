//
//  AdminPanelViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 14.07.2023.
//

import UIKit
import RealmSwift

class AdminPanelViewController: ExtensionViewController{
    
    let realm = try! Realm()
    var currentUser: User?

    @IBOutlet weak var createNewUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func createNewCategoryButtonPressed(_ sender: UIButton) {
        navigateToCreateNewCategory()
    }
    
    @IBAction func createNewUserButtonPressed(_ sender: UIButton) {
        
        navigateToCreateUser()
        
    }
    
    
    @IBAction func listOfUsers(_ sender: UIButton) {
        
        navigateToListOfUser()
        
    }
    @IBAction func listOfTablesButtonPressed(_ sender: UIButton) {
        
        navigateToTablesList()
        
    }
    
    func navigateToCreateUser() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "NewUserViewController") as! NewUserViewController
        createVC.currentUser = currentUser
        navigationController?.pushViewController(createVC, animated: true)
    }
    
    func navigateToListOfUser() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let showVC = storyboard.instantiateViewController(withIdentifier: "UsersListTableViewController") as! UsersListTableViewController
        showVC.currentUser = currentUser
        navigationController?.pushViewController(showVC, animated: true)
    }
    
    func navigateToTablesList() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tablesVC = storyboard.instantiateViewController(withIdentifier: "TablesListViewController") as! TablesListViewController
        tablesVC.currentUser = currentUser
        navigationController?.pushViewController(tablesVC, animated: true)
    }
    
    func navigateToCreateNewCategory() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let categoryVC = storyboard.instantiateViewController(withIdentifier: "CategoryManagerViewController") as! CategoryManagerViewController
        categoryVC.currentUser = currentUser
        navigationController?.pushViewController(categoryVC, animated: true)
    }

    
}
