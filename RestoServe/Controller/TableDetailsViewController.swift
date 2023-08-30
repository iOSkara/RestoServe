//
//  TableDetailsViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 15.07.2023.
//

import UIKit
import RealmSwift

class TableDetailsViewController: ExtensionViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    var currentUser: User?
    var currentTable: Table?
    var orders: Results<Order>?
    var customerOrders: [CustomerOrder]?
    var customerOrdersArray: [CustomerOrder] = []
    var clientIndex: Int?
    var tables: Results<Table>?
    var ordersDictionary: [String: [CustomerOrder]] = [:]
    var isItWaiterForShow = false
    var isCooker = false
    var timer: Timer?
    var isAdmin = false
    
    
    @IBOutlet weak var tableTitle: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var confirmOrder: UIButton!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var remainingTimeToOrderDone: UILabel!
    @IBOutlet weak var changeStatusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Назад"
        if isItWaiterForShow || isCooker || isAdmin {
            orderStatusLabel.isHidden = false
            remainingTimeToOrderDone.isHidden = false
        } else {
            orderStatusLabel.isHidden = true
            remainingTimeToOrderDone.isHidden = true
        }
        
        if !isCooker || currentTable?.orders.first?.status != "Прийняте" {
            changeStatusButton.isHidden = true
        }
        
        if let status = currentTable?.orders.first?.status{
            orderStatusLabel.text = "Статус: \(status)"
            if status == "Готується" {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRemainingTime), userInfo: nil, repeats: true)
            } else if status == "Готове" || status == "Прийняте" {
                remainingTimeToOrderDone.isHidden = true
            }
        }
        
        loadOrders()
        
        
        addBorderAndRoundedCorners(to: tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableTitle.text = currentTable?.tableNumber
        
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(goToPreviousClient))
        self.navigationItem.leftBarButtonItem = backButton
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateRemainingTime() {
        DispatchQueue.main.async {
            self.calculateAndSetRemainingTime()
        }
    }
    
    @IBAction func changeOrderStatusButtonPressed(_ sender: UIButton) {
        changeStatusButton.isHidden = true
        
        guard let currentOrder = currentTable?.orders.first else { return }
        // Зміна статусу замовлення на "Готується"
        do {
            try realm.write {
                currentOrder.status = "Готується"
                currentOrder.orderTime = Date() // Оновлюємо час прийняття замовлення
            }
        } catch {
            print("\(error)")
        }
        orderStatusLabel.text = "Статус: \(currentOrder.status)"
        remainingTimeToOrderDone.isHidden = false
        updateRemainingTime()
        
        // Запуск таймера для відліку часу до готовності замовлення
        
        
    }
    
    func calculateAndSetRemainingTime() {
        guard let currentOrder = currentTable?.orders.first else { return }
        
        var totalCookingTime = 0.0
        for customerOrder in currentOrder.customerOrders {
            for dish in customerOrder.dishes {
                totalCookingTime += Double(dish.remainingTime)
            }
        }
        
        let orderCompletionTime = currentOrder.orderTime.addingTimeInterval(totalCookingTime)
        let remainingTimeToOrderDone = orderCompletionTime.timeIntervalSinceNow
        
        if remainingTimeToOrderDone > 0 {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = [.pad]
            let formattedDuration = formatter.string(from: remainingTimeToOrderDone)
            self.remainingTimeToOrderDone.text = "Час до готовності: \(formattedDuration!)"
        } else {
            
            self.remainingTimeToOrderDone.isHidden = true
            guard let currentOrder = currentTable?.orders.first else { return }
            // Зміна статусу замовлення на "Готується"
            do {
                try realm.write {
                    currentOrder.status = "Готове"
                    // Оновлюємо час прийняття замовлення
                }
            } catch {
                print("\(error)")
            }
            orderStatusLabel.text = "Статус: \(currentOrder.status)"
        }
        
        orderStatusLabel.text = "Статус: \(currentOrder.status)"
    }
    
    @IBAction func confirmOrderPressed(_ sender: UIButton) {
        
        // Create a new order
        let newOrder = Order()
        newOrder.waiterId = currentUser?.id
        newOrder.status = "Прийняте" // or any other initial status
        newOrder.table = currentTable
        
        for customerOrder in customerOrdersArray {
            newOrder.customerOrders.append(customerOrder)
        }
        
        // Save the new order
        do {
            try realm.write {
                realm.add(newOrder)
                if let tableNumber = currentTable?.tableNumber {
                    // Збережіть замовлення в словнику
                    ordersDictionary[tableNumber] = customerOrdersArray
                }
                currentTable?.isOccupied = true
            }
            orderStatusLabel.isHidden = false
            remainingTimeToOrderDone.isHidden = false
            // Clear the current customer orders
            customerOrdersArray.removeAll()
            tableView.reloadData()
            updateConfirmButtonStatus()
            navigateToWaiterPanel()
            
        } catch {
            print("\(error)")
        }
        
    }
    
    func navigateToWaiterPanel() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let waiterVC = storyboard.instantiateViewController(withIdentifier: "WaiterViewController") as! WaiterViewController
        waiterVC.currentUser = currentUser
        //waiterVC.ordersDictionary = ordersDictionary
        // Replace the view controller stack with just the new view controller
        navigationController?.setViewControllers([waiterVC], animated: true)
    }
    
    private func updateConfirmButtonStatus() {
        let isButtonEnabled = customerOrdersArray.contains { !$0.dishes.isEmpty }
        confirmOrder.isEnabled = isButtonEnabled
    }
    
    @objc func goToPreviousClient() {
        if let clientIndex = self.clientIndex, clientIndex > 0 {
            self.clientIndex = clientIndex
            if let orderScreenVC = self.navigationController?.viewControllers.first(where: { $0 is OrderScreenViewController }) as? OrderScreenViewController {
                orderScreenVC.clientIndex = self.clientIndex
                self.navigationController?.popToViewController(orderScreenVC, animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCell")
    }
    
    func loadOrders() {
        
        if currentUser?.role == "Адміністратор" || isItWaiterForShow || isCooker {
            let allOrders = currentTable?.orders.filter("status IN %@", ["Прийняте", "Готується", "Готове"])
            customerOrdersArray = allOrders?.flatMap { $0.customerOrders.map { $0 } } ?? []
            confirmOrder.isHidden = true
            tableView.reloadData()
        } else {
            orders = currentTable?.orders.filter("TRUEPREDICATE")
            tableView.reloadData()
        }
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return customerOrdersArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerOrdersArray[section].dishes.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Замовлення для клієнта \(section + 1)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
        
        // Configure the cell...
        let order = customerOrdersArray[indexPath.section].dishes[indexPath.row]
        cell.textLabel?.text = order.dishId?.name
        cell.detailTextLabel?.text = "Кількість: \(order.quantity)"
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
        
        return cell
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
    
}
