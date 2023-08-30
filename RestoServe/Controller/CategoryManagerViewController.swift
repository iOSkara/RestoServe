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
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Назад"
        do {
            let realm = try Realm()
            if realm.objects(Category.self).filter("name == 'Без категорії'").count == 0 {
                let uncategorized = Category()
                uncategorized.name = "Без категорії"
                try realm.write {
                    realm.add(uncategorized)
                }
            }
        } catch {
            print("\(error)")
        }
        
        editButton.isEnabled = false
        deleteButton.isEnabled = false
        
        newCategoryTextField.addTarget(self, action: #selector(updateNewCategoryButtonState), for: .editingChanged)
        updateNewCategoryButtonState()
        
        categories = realm.objects(Category.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addBorderAndRoundedCorners(to: newCategoryTextField)
        addBorderAndRoundedCorners(to: tableView)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addNewCategryPressed(_ sender: UIButton) {
        
        if let categoryName = newCategoryTextField.text, !categoryName.isEmpty {
            // Перевірте, чи існує вже категорія з таким ім'ям
            let existingCategory = realm.objects(Category.self).filter("name = %@",categoryName).first
            if existingCategory != nil && selectedCategory == nil {
                // Категорія вже існує, покажемо повідомлення про помилку
                let alert = UIAlertController(title: "Помилка", message: "Категорія з такимім'ям вже існує.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            do {
                try realm.write {
                    if let selectedCategory = selectedCategory {
                        // Змінити існуючу категорію
                        selectedCategory.name = categoryName
                    } else {
                        // Створити нову категорію
                        let newCategory = Category()
                        newCategory.name = categoryName
                        realm.add(newCategory)
                    }
                    newCategoryTextField.text = ""
                    selectedCategory = nil
                    tableView.reloadData()
                    editButton.isEnabled = false
                    deleteButton.isEnabled = false
                }
            } catch {
                print("\(error)")
            }
        }
    }
    
    @IBAction func editSelectedCategoryPressed(_ sender: UIButton) {
        
        if selectedCategory!.name == "Без категорії" {
            let alertController = UIAlertController(title: "Помилка", message: "Ви не можете редагувати цю категорію.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if let selectedCategory = selectedCategory {
            newCategoryTextField.text = selectedCategory.name
        }
        
        
    }
    
    @IBAction func deleteSelectedCategoryPressed(_ sender: UIButton) {
        
        guard let category = selectedCategory else {
            return
        }
        
        if selectedCategory!.name == "Без категорії" {
            let alertController = UIAlertController(title: "Помилка", message: "Ви не можете видалити цю категорію.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Видалити категорію", message: "Вивпевнені, що хочете видалити \(category.name)?", preferredStyle: .alert)
        
        // Create the actions
        let deleteAction = UIAlertAction(title: "Видалити", style: .destructive) { _ in
            do {
                try self.realm.write {
                    let uncategorized = self.realm.objects(Category.self).filter("name == 'Без категорії'").first!
                    
                    // This should now properly access the dishes associated with the category
                    let dishesToReassign = Array(category.dishes)
                    for dish in dishesToReassign {
                        dish.category = uncategorized
                    }
                    
                    self.realm.delete(category)
                    self.tableView.reloadData()
                }
            } catch let error {
                print("\(error)")
            }
        }
        let cancelAction = UIAlertAction(title: "Скасувати", style: .cancel, handler: nil)
        
        // Add the actions
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func updateNewCategoryButtonState() {
        // Button is enabled if both text fields are not empty
        let newCategryText = newCategoryTextField.text ?? ""
        addNewCategryButton.isEnabled = !newCategryText.isEmpty
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categories?[indexPath.row]
        cell.textLabel?.text = category?.name
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories?[indexPath.row]
        editButton.isEnabled = true
        deleteButton.isEnabled = true
        //newCategoryTextField.text = selectedCategory?.name
    }
    
    
    
    
}
