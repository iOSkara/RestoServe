//
//  BillViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 19.07.2023.
//

import UIKit
import RealmSwift

class BillViewController: ExtensionViewController, UITableViewDataSource, UITableViewDelegate {
    
    var currentUser: User?
    var currentTable: Table?
    
    @IBOutlet weak var receiptLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    var order: Order?
    var total = 0.00
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Назад"
        if let firstOrder = currentTable?.orders.first {
            self.order = firstOrder
            receiptLabel.text! += " \(firstOrder.id)"
        } else {
            // Вирішіть, що робити, якщо замовлення немає, наприклад:
            self.order = nil
            receiptLabel.text! += " Немає замовлень"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        calculateTotal()
    }
    
    func calculateCustomerOrderTotal(section: Int) -> String {
        var total = 0.0
        
        if let customerOrder = order?.customerOrders[section] {
            for orderedDish in customerOrder.dishes {
                if let dish = orderedDish.dishId {
                    let dishTotal = dish.price * Double(orderedDish.quantity)
                    total += dishTotal
                }
            }
        }
        
        return String(format: "%.2f", total)
    }
    
    func calculateTotal() {
        guard let order = order else { return }
        
        for customerOrder in order.customerOrders {
            for orderedDish in customerOrder.dishes {
                if let dish = orderedDish.dishId {
                    let dishTotal = dish.price * Double(orderedDish.quantity)
                    total += dishTotal
                }
            }
        }
        var totalString = String(format: "%.2f", total)
        var perPerson = total / Double(order.customerOrders.count)
        if order.customerOrders.count > 1 {
            totalLabel.text = "Загальна сума: \(totalString) \nПорівну: \(totalString) / \(order.customerOrders.count) = \(String(format: "%.2f", perPerson))"
        } else {
            totalLabel.text = "Загальна сума: \(totalString)"
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return order?.customerOrders.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Додаємо додатковий рядок для підсумку
        return (order?.customerOrders[section].dishes.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Клієнт № \(section + 1)"
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "billCell", for: indexPath)
        
        // Перевіряємо, чи є поточний рядок останнім у секції
        if indexPath.row < (order?.customerOrders[indexPath.section].dishes.count ?? 0) {
            if let orderedDish = order?.customerOrders[indexPath.section].dishes[indexPath.row],
               let dish = orderedDish.dishId {
                cell.textLabel?.text = dish.name
                cell.detailTextLabel?.text = "\(orderedDish.quantity) x \(String(format: "%.2f", dish.price)) = \(String(format: "%.2f", Double(orderedDish.quantity) * dish.price))"
            }
        } else {
            // Якщо це останній рядок, відображаємо підсумок замовлення
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = "Підсумок: " + calculateCustomerOrderTotal(section: indexPath.section)
        }
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
        
        return cell
    }
    
}
