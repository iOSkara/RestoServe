//
//  TablesListViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 15.07.2023.
//

import UIKit
import RealmSwift

class TablesListViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(clientsArray[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        clientsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNumberOfClients = clientsArray[row]
        
        // Зберігаємо вибрану кількість клієнтів
    }
    
    
    let realm = try! Realm()
    var tables: Results<Table>?
    var currentUser: User?
    var currentTable: Table?
    let clientsArray = [1, 2, 3, 4, 5, 6]
    var selectedNumberOfClients: Int?
    var isOrderToPrint = false
    var isCooker = false
    var tablesFilter: [Table]?
    
    @IBOutlet weak var labelText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Назад"
        print(isCooker)
        
        self.tableView.delegate = self
        
        loadTables()
        
        switch currentUser?.role {
            case "Адміністратор":
                labelText.text = "Список столиків"
                break
            case "Офіціант":
                labelText.text = "Оберіть столик"
                break
            case "Кухар":
                labelText.text = "Список столиків"
                break
            default:
                break
        }
        
        if tables?.isEmpty ?? true {
            addInitialTables()
        }
        
    }
    
    func loadTables() {
        tables = realm.objects(Table.self)
        tableView.reloadData()
    }
    
    func addInitialTables() {
        do {
            try realm.write {
                for i in 1...15 {
                    let table = Table()
                    table.tableNumber = "Стіл № \(i)"
                    table.isOccupied = false
                    realm.add(table)
                }
            }
        } catch let error {
            print("Помилка додавання таблиці: \(error)")
        }
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tables?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        
        // Налаштувати комірку з даними про столик
        var table = tables?[indexPath.row]
        
        cell.textLabel?.text = table?.tableNumber
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        if table?.isOccupied ?? false {
            cell.detailTextLabel?.text = "Зайнятий"
            cell.detailTextLabel?.textColor = .red
        } else {
            cell.detailTextLabel?.text = "Вільний"
            cell.detailTextLabel?.textColor = .green
        }
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
        
        return cell
    }
    
    // Викликається, коли користувач натискає на стіл
    func tableTapped() {
        let alert = UIAlertController(title: "Виберіть кількість клієнтів", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let picker = UIPickerView(frame: CGRect(x: 0, y: 50, width: 260, height: 162))
        picker.delegate = self
        picker.dataSource = self
        
        alert.view.addSubview(picker)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
            let selectedNumberOfClients = picker.selectedRow(inComponent: 0) + 1 // Додайте 1, бо рядки починаються з 0
            
            if selectedNumberOfClients > 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let orderScreenVC = storyboard.instantiateViewController(withIdentifier: "OrderScreenViewController") as! OrderScreenViewController
                orderScreenVC.clientIndex = 0
                orderScreenVC.totalClients = selectedNumberOfClients
                orderScreenVC.currentUser = self.currentUser
                orderScreenVC.currentTable = self.currentTable
                var customerOrdersArray: [CustomerOrder] = []
                for _ in 0..<selectedNumberOfClients {
                    customerOrdersArray.append(CustomerOrder())
                }
                orderScreenVC.customerOrdersArray = customerOrdersArray
                navigationController?.pushViewController(orderScreenVC, animated: false)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Відмінити", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let selectedTable = tables?[indexPath.row]
        if currentUser?.role == "Офіціант" {
            // Якщо поточний користувач є адміністратором або офіціантом, дозволити вибір усіх столиків
            return indexPath
        } else {
            return indexPath
        }
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTable = tables?[indexPath.row]
        currentTable = selectedTable
        
        switch currentUser?.role {
            case "Адміністратор":
                if currentTable?.isOccupied == true {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let tableDetailsVC = storyboard.instantiateViewController(withIdentifier: "TableDetailsViewController") as! TableDetailsViewController
                    tableDetailsVC.currentTable = selectedTable
                    tableDetailsVC.currentUser = currentUser
                    tableDetailsVC.isAdmin = true
                    navigationController?.pushViewController(tableDetailsVC, animated: true)
                } else {
                    let alert = UIAlertController(title: "Помилка", message: "Цей столик вільний.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
                
                break
            case "Офіціант":
                if selectedTable?.isOccupied ?? false {
                    // Якщо стіл зайнятий, запропонувати видалити замовлення
                    presentDeletionConfirmation(for: selectedTable)
                } else {
                    if isOrderToPrint {
                        let alert = UIAlertController(title: "Помилка", message: "Цей столик вільний.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        present(alert, animated: true, completion: nil)
                        tableView.deselectRow(at: indexPath, animated: true)
                    } else {
                        tableTapped()
                    }
                    
                }
                tableView.deselectRow(at: indexPath, animated: true)
                break
            case "Кухар":
                if currentTable?.isOccupied == true {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let tableDetailsVC = storyboard.instantiateViewController(withIdentifier: "TableDetailsViewController") as! TableDetailsViewController
                    tableDetailsVC.currentTable = selectedTable
                    tableDetailsVC.currentUser = currentUser
                    tableDetailsVC.isCooker = true
                    navigationController?.pushViewController(tableDetailsVC, animated: true)
                } else {
                    let alert = UIAlertController(title: "Помилка", message: "Цей столик вільний.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
                break
            default:
                break
        }
    }
    
    func presentDeletionConfirmation(for table: Table?) {
        let alert = UIAlertController(title: "Замовлення", message: "Цей столик зайнятий. Що ви хочете зробити з цим замовленням?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Переглянути", style: .default, handler: { [weak self] _ in
            
            guard let self = self else { return }
            
            if self.isOrderToPrint {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let billVC = storyboard.instantiateViewController(withIdentifier: "BillViewController") as! BillViewController
                billVC.currentTable = self.currentTable
                billVC.currentUser = self.currentUser
                self.navigationController?.pushViewController(billVC, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tableDetailsVC = storyboard.instantiateViewController(withIdentifier: "TableDetailsViewController") as! TableDetailsViewController
                tableDetailsVC.currentTable = self.currentTable
                tableDetailsVC.currentUser = self.currentUser
                tableDetailsVC.isItWaiterForShow = true
                self.navigationController?.pushViewController(tableDetailsVC, animated: true)
            }
            
        }))
        
        if !isOrderToPrint {
            alert.addAction(UIAlertAction(title: "Редагувати", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                
                // Тут ми робимо перехід до OrderScreenViewController з поточним замовленням для редагування
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let orderScreenVC = storyboard.instantiateViewController(withIdentifier: "OrderScreenViewController") as! OrderScreenViewController
                orderScreenVC.currentOrder = table?.orders.first // Передаємо перше замовлення для редагування
                orderScreenVC.currentUser = self.currentUser
                orderScreenVC.clientIndex = 0
                self.navigationController?.pushViewController(orderScreenVC, animated: false)
            }))
            
            alert.addAction(UIAlertAction(title: "Архівувати замовлення", style: .default, handler: { [weak self] _ in
                
                if table?.orders.first?.status == "Прийняте" {
                    guard let self = self, let table = table else { return }
                    
                    do {
                        let realm = try Realm()
                        
                        try realm.write {
                            let orders = Array(table.orders)
                            for order in orders {
                                let archivedOrder = ArchivedOrder()
                                archivedOrder.id = order.id
                                archivedOrder.waiterId = order.waiterId
                                archivedOrder.customerOrders.append(objectsIn: order.customerOrders)
                                archivedOrder.orderTime = order.orderTime
                                archivedOrder.status = order.status
                                archivedOrder.table = order.table
                                
                                realm.add(archivedOrder)
                                realm.delete(order)
                            }
                            
                            table.isOccupied = false
                            // здається, тут вам потрібно оновити tableView
                            self.tableView.reloadData()
                        }
                        
                    } catch {
                        print("Помилка архівування замовлення: \(error)")
                    }
                } else {
                    let alert = UIAlertController(title: "Помилка", message: "Замовлення вже готується або готове.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self!.present(alert, animated: true, completion: nil)
                }
                
                
                
            }))
            
        } else {
            alert.addAction(UIAlertAction(title: "Закрити замовлення(Друк)", style: .default, handler: { [weak self] _ in
                
                if table?.orders.first?.status == "Готове" {
                    guard let self = self, let table = table else { return }
                    
                    do {
                        let realm = try Realm()
                        
                        try realm.write {
                            let orders = Array(table.orders)
                            for order in orders {
                                let archivedOrder = ArchivedOrder()
                                archivedOrder.id = order.id
                                archivedOrder.waiterId = order.waiterId
                                archivedOrder.customerOrders.append(objectsIn: order.customerOrders)
                                archivedOrder.orderTime = order.orderTime
                                archivedOrder.status = order.status
                                archivedOrder.table = order.table
                                
                                realm.add(archivedOrder)
                                realm.delete(order)
                            }
                            
                            table.isOccupied = false
                            // здається, тут вам потрібно оновити tableView
                            self.tableView.reloadData()
                        }
                        let alert = UIAlertController(title: "Повідомлення", message: "Рахунок успішно відправлено на термінал для друку.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    } catch {
                        print("Помилка архівування замовлення: \(error)")
                    }
                } else {
                    let alert = UIAlertController(title: "Помилка", message: "Замовлення ще не готове.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self!.present(alert, animated: true, completion: nil)
                }
                
                
                
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Відмінити", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
}
