//  ArchivedOrderDetailViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 15.07.2023.
//

import UIKit
import RealmSwift

class ArchivedOrderDetailViewController: ExtensionViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    var currentUser: User?
    var currentArchivedOrder: ArchivedOrder?
    var orders: Results<Order>?
    var customerOrders: [CustomerOrder]?
    var customerOrdersArray: [CustomerOrder] = []
    var clientIndex: Int?
    var ordersDictionary: [String: [CustomerOrder]] = [:]
    
    @IBOutlet weak var orderTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Назад"
        loadOrders()
        
        addBorderAndRoundedCorners(to: tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        orderTitle.text = currentArchivedOrder?.id
        
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(goToPreviousClient))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func loadOrders() {
        // Logic to load the archived orders
        // You may want to filter based on order status or other properties
        
        customerOrdersArray = currentArchivedOrder?.customerOrders.map { $0 } ?? []
        tableView.reloadData()
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
        let headerLabel = UILabel(frame: CGRect(x: 25, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.textColor = UIColor.black
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.font = UIFont(name: "Helvetica", size: 25)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    @objc func goToPreviousClient() {
        // Navigation logic when the "Back" button is pressed
        navigationController?.popViewController(animated: true)
    }
    
}
