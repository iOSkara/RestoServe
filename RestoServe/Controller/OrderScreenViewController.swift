//
//  OrderScreenViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 18.07.2023.
//

import UIKit
import RealmSwift

class OrderScreenViewController: ExtensionViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var clientIndex: Int?
    var totalClients: Int?
    let realm = try! Realm()
    var tables: Results<Table>?
    var currentUser: User?
    var currentTable: Table?
    var categories: Results<Category>?
    var dishes: Results<Dish>?
    var selectedDishes: [Dish] = []
    var selectedCategory: Category?
    var customerOrder: CustomerOrder?
    var customerOrdersArray: [CustomerOrder] = []
    var currentOrder: Order?
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var dishPicker: UIPickerView!
    @IBOutlet weak var quantityOfDish: UILabel!
    @IBOutlet weak var stepperForQuantityOfDish: UIStepper!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Назад"
        loadCategories()
        loadDishes()
        
        if let currentOrder = currentOrder {
            // Load the data from the current order into the table and other UI elements
            // For example:
            self.customerOrdersArray = Array(currentOrder.customerOrders)
            self.totalClients = self.customerOrdersArray.count
        } else {
            // This is a new order, so leave the table and other UI elements blank
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        dishPicker.delegate = self
        dishPicker.dataSource = self
        deleteButton.isHidden = true
        addButton.isEnabled = false
        stepperForQuantityOfDish.isEnabled = false
        
        addBorderAndRoundedCorners(to: tableView)
        
        quantityOfDish.text = "Кількість: \(Int(stepperForQuantityOfDish.value))"
        
        if let clientIndex = clientIndex {
            if clientIndex >= customerOrdersArray.count {
                let newCustomerOrder = CustomerOrder()
                customerOrdersArray.append(newCustomerOrder)
                
            }
            customerOrder = customerOrdersArray[clientIndex]
        }
        
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(goToPreviousClient))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.title = "Замовлення для клієнта \(clientIndex! + 1 ?? 1)"
        self.setupNavigationBarButtons()
    }
    
    @IBAction func stepper(_ sender: UIStepper) {
        quantityOfDish.text = "Кількість: \(Int(sender.value))"
    }
    
    @IBAction func addNewDishButtonPressed(_ sender: UIButton) {
        stepperForQuantityOfDish.isEnabled = false
        deleteButton.isHidden = true
        let selectedRow = dishPicker.selectedRow(inComponent: 0)
        if let dish = dishes?.filter("category == %@ AND isAvailable == true", selectedCategory)[selectedRow] {
            let dishId = dish.id
            
            if let orderedDishIndex = customerOrder?.dishes.index(where: { $0.dishId?.id == dishId }) {
                // Update existing dish
                do {
                    try realm.write {
                        customerOrder?.dishes[orderedDishIndex].quantity = Int(stepperForQuantityOfDish.value)
                        customerOrder?.dishes[orderedDishIndex].remainingTime = dish.estimatedCookingTime * Int(stepperForQuantityOfDish.value)
                    }
                } catch {
                    print("\(error)")
                }
            } else {
                // Add new dish
                let orderedDish = OrderedDish()
                orderedDish.dishId = dish
                orderedDish.remainingTime = dish.estimatedCookingTime * Int(stepperForQuantityOfDish.value)
                orderedDish.quantity = Int(stepperForQuantityOfDish.value)
                do {
                    try realm.write {
                        customerOrder?.dishes.append(orderedDish)
                    }
                } catch {
                    print("\(error)")
                }
            }
            addButton.isEnabled = false
            tableView.reloadData()
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            let alert = UIAlertController(title: "Видалення страви", message: "Ви дійсно хочете видалити цю страву з замовлення?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { [weak self] action in
                do {
                    try self?.realm.write {
                        self?.customerOrder?.dishes.remove(at: indexPathForSelectedRow.row)
                    }
                } catch {
                    print("Помилка при видаленні страви: \(error)")
                }
                
                self?.tableView.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "Ні", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
        deleteButton.isHidden = true
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
    
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        categoryPicker.reloadAllComponents()
    }
    
    // загрузка блюд
    func loadDishes() {
        dishes = realm.objects(Dish.self)
        dishPicker.reloadAllComponents()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerOrder?.dishes.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath)
        
        // Configure the cell...
        if let orderedDish = customerOrder?.dishes[indexPath.row] {
            cell.textLabel?.text = orderedDish.dishId?.name
            cell.detailTextLabel?.text = "Кількість: \(String(orderedDish.quantity))"
            // Add more configurations as needed...
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addButton.isEnabled = true
        stepperForQuantityOfDish.isEnabled = true
        if let orderedDish = customerOrder?.dishes[indexPath.row] {
            // find the index of category in categories array
            if let categoryIndex = categories?.index(of: orderedDish.dishId!.category!) {
                categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: true)
                selectedCategory = categories?[categoryIndex]
                // reload dishes based on selected category
                dishPicker.reloadAllComponents()
                
                // find the index of dish in dishes array
                if let dishIndex = dishes?.filter("category == %@ AND isAvailable == true", selectedCategory).index(of: orderedDish.dishId!) {
                    dishPicker.selectRow(dishIndex, inComponent: 0, animated: true)
                }
            }
            
            // update quantity label and stepper
            stepperForQuantityOfDish.value = Double(orderedDish.quantity)
            quantityOfDish.text = "Кількість: \(orderedDish.quantity)"
            deleteButton.isHidden = false
        }
        
        //tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setupNavigationBarButtons() {
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(goToNextClient))
        self.navigationItem.rightBarButtonItem = nextButton
    }
    
    @objc func goToPreviousClient() {
        deleteButton.isHidden = true
        addButton.isEnabled = false
        if let clientIndex = self.clientIndex, clientIndex > 0 {
            self.clientIndex = clientIndex - 1
            self.customerOrder = customerOrdersArray[self.clientIndex!]
            self.title = "Замовлення для клієнта \(self.clientIndex! + 1)"
            self.stepperForQuantityOfDish.value = 1
            self.quantityOfDish.text = "Кількість: 1"
            self.tableView.reloadData()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func goToNextClient() {
        addButton.isEnabled = false
        deleteButton.isHidden = true
        if let clientIndex = self.clientIndex, let totalClients = self.totalClients, clientIndex < totalClients - 1 {
            self.clientIndex = clientIndex + 1
            
            if self.clientIndex! >= customerOrdersArray.count {
                let newCustomerOrder = CustomerOrder()
                customerOrdersArray.append(newCustomerOrder)
            }
            
            self.customerOrder = customerOrdersArray[self.clientIndex!]
            self.title = "Замовлення для клієнта \(self.clientIndex! + 1)"
            self.stepperForQuantityOfDish.value = 1
            self.quantityOfDish.text = "Кількість: 1"
            self.tableView.reloadData()
        } else {
            // Go to the Table Details screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tableDetailsVC = storyboard.instantiateViewController(withIdentifier: "TableDetailsViewController") as! TableDetailsViewController
            tableDetailsVC.currentUser = currentUser
            tableDetailsVC.currentTable = currentTable
            tableDetailsVC.clientIndex = clientIndex
            tableDetailsVC.customerOrdersArray = customerOrdersArray
            navigationController?.pushViewController(tableDetailsVC, animated: true)
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPicker {
            return categories?.count ?? 0
        } else if pickerView == dishPicker {
            return dishes?.filter("category == %@ AND isAvailable == true", selectedCategory).count ?? 0
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return categories?[row].name
        } else if pickerView == dishPicker {
            return dishes?.filter("category == %@ AND isAvailable == true", selectedCategory)[row].name
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPicker {
            selectedCategory = categories?[row]
            
            dishPicker.reloadAllComponents()
            
            if (dishes?.filter("category == %@ AND isAvailable == true", selectedCategory).count ?? 0) == 0 {
                addButton.isEnabled = false
                stepperForQuantityOfDish.isEnabled = false
            } else {
                addButton.isEnabled = true
                stepperForQuantityOfDish.isEnabled = true
            }
        }
        
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
        
        deleteButton.isHidden = true
        stepperForQuantityOfDish.value = 1
        quantityOfDish.text = "Кількість: 1"
    }
    
    
}

