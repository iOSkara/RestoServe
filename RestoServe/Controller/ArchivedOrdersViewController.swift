//
//  ArchivedOrdersViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 19.07.2023.
//

import UIKit
import RealmSwift

class ArchivedOrdersViewController: UITableViewController {
    
    var archivedOrders: Results<ArchivedOrder>?
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Назад"
        // Припустимо, що ви використовуєте Realm для зберігання даних
        let realm = try! Realm()

        // Отримати всі архівні замовлення
        self.archivedOrders = realm.objects(ArchivedOrder.self)
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.archivedOrders?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let orderDetailsVC = storyboard.instantiateViewController(withIdentifier: "ArchivedOrderDetailViewController") as! ArchivedOrderDetailViewController
        orderDetailsVC.currentUser = currentUser
        orderDetailsVC.currentArchivedOrder = self.archivedOrders?[indexPath.row]
        navigationController?.pushViewController(orderDetailsVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "archiveOrder", for: indexPath)

        if let order = self.archivedOrders?[indexPath.row] {
            cell.textLabel?.text = "Замовлення ID: \(order.id), Статус: \(order.status)"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: order.orderTime)
            cell.detailTextLabel?.text = dateString
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        
        return cell
    }
}

