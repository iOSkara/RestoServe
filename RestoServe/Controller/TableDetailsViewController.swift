//
//  TableDetailsViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 15.07.2023.
//

import UIKit
import RealmSwift

class TableDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    var currentUser: User?
    var currentTable: Table?
    var orders: List<Order>?

    @IBOutlet weak var tableTitle: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableTitle.text = currentTable?.tableNumber

        // Do any additional setup after loading the view.
    }
    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCell")
    }

    func loadOrders() {
        orders = currentTable?.orders
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)

        // Configure the cell...
        let order = orders?[indexPath.row]
        // Задайте атрибути комірки на основі даних замовлення

        return cell
    }

}
