//
//  DishesViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 17.07.2023.
//

import UIKit
import RealmSwift

class DishesViewController: ExtensionViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    var categories: Results<Category>?
    var currentUser: User?
    var selectedDish: Dish?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var isAvailableSwitch: UISwitch!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var isAvailableLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Назад"
        NotificationCenter.default.addObserver(self, selector: #selector(dishUpdated(_:)), name: NSNotification.Name("DishUpdated"), object: nil)
        
        fetchDishes()
        
        addBorderAndRoundedCorners(to: tableView)
        
        categories = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        switch currentUser?.role {
            case "Адміністратор":
                labelText.text = "Список страв"
                editButton.isEnabled = false
                deleteButton.isEnabled = false
                isAvailableSwitch.isEnabled = false
                break
            case "Офіціант":
                labelText.text = "Меню"
                editButton.isHidden = true
                deleteButton.isHidden = true
                isAvailableSwitch.isHidden = true
                isAvailableLabel.isHidden = true
                break
            case "Кухар":
                break
            default:
                break
        }
        
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("DishUpdated"), object: nil)
    }
    
    @IBAction func isAvailableSwitchValueChanged(_ sender: UISwitch) {
        editButton.isEnabled = false
        deleteButton.isEnabled = false
        guard let dish = selectedDish else {
            return
        }
        
        do {
            try realm.write {
                dish.isAvailable = sender.isOn
            }
        } catch let error {
            print("\(error)")
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
    }
    
    @IBAction func editDishButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToNewDish", sender: self)
    }
    
    @IBAction func deleteDishButtonPressed(_ sender: UIButton) {
        
        guard let dish = selectedDish else {

            return
        }
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Видалити страву", message: "Вивпевнені, що хочете видалити \(dish.name)?", preferredStyle: .alert)
        
        // Create the actions
        let deleteAction = UIAlertAction(title: "Видалити", style: .destructive) { _ in
            do {
                try self.realm.write {
                    self.realm.delete(dish)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let dish = categories?[indexPath.section].dishes[indexPath.row] else {
            return
        }
        
        selectedDish = dish
        isAvailableSwitch.isOn = dish.isAvailable
        editButton.isEnabled = true
        deleteButton.isEnabled = true
        isAvailableSwitch.isEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNewDish" {
            let destinationVC = segue.destination as! NewDishViewController
            destinationVC.dishToEdit = selectedDish
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(hex: "#DCDCDC")
        addBorderAndRoundedCorners(to: headerView)
        let headerLabel = UILabel(frame: CGRect(x: 25, y: 0, width:
                                                    tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.textColor = UIColor.black
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.font = UIFont(name: "Helvetica", size: 25)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return categories?[section].name
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?[section].dishes.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath)
        guard let dish = categories?[indexPath.section].dishes[indexPath.row] else {
            return cell
        }
        cell.textLabel?.text = dish.name
        cell.detailTextLabel?.text = "\(dish.price) грн"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
        cell.accessoryType = dish.isAvailable ? .checkmark : .none
        return cell
    }
    
    func fetchDishes() {
        let categoriesResults = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
        self.categories = categoriesResults
        self.tableView.reloadData()
    }
    
    @objc private func dishUpdated(_ notification: Notification) {
        self.fetchDishes()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    
}
