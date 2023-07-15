//
//  CategoryManagerViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 15.07.2023.
//

import UIKit
import RealmSwift

class CategoryManagerViewController: ExtensionViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    var currentUser: User?
    var users: [User] = []
    var selectedUser: User?
    var categories: Results<Category>?
    var selectedCategory: Category?

    
    @IBOutlet weak var newCategoryTextField: UITextField!
    
    @IBOutlet weak var addNewCategryButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = realm.objects(Category.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addBorderAndRoundedCorners(to: newCategoryTextField)
        addBorderAndRoundedCorners(to: tableView)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addNewCategryPressed(_ sender: UIButton) {
        
        if let newCategoryName = newCategoryTextField.text, !newCategoryName.isEmpty {
            let newCategory = Category()
            newCategory.name = newCategoryName
            do {
                try realm.write {
                    realm.add(newCategory)
                }
                newCategoryTextField.text = "" // Очищення поля введення після додавання
            } catch {
                print("Error saving new category: \(error)")
            }
            
            tableView.reloadData() // Перезавантаження таблиці, щоб відобразити нову категорію
        }
        
    }
    
    @IBAction func editSelectedCategoryPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func deleteSelectedCategoryPressed(_ sender: UIButton) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categories?[indexPath.row]
        cell.textLabel?.text = category?.name

        return cell
    }
    

}
