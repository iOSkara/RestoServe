//
//  TablesListViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 15.07.2023.
//

import UIKit
import RealmSwift

class TablesListViewController: UITableViewController {
    
    let realm = try! Realm()
    var tables: Results<Table>?
    var currentUser: User?
    var currentTable: Table?
    
    @IBOutlet weak var labelText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTables()
        
        switch currentUser?.role {
            case "Адміністратор":
                labelText.text = "Список столиків"
                break
            case "Офіціант":
                labelText.text = "Оберіть столик для замовлення"
                break
            case "Кухар":
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
                    table.tableNumber = "Table \(i)"
                    table.isOccupied = false
                    realm.add(table)
                }
            }
        } catch let error {
            print("Error adding initial tables: \(error)")
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
        let table = tables?[indexPath.row]
        cell.textLabel?.text = table?.tableNumber
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        if table?.isOccupied ?? false {
            cell.detailTextLabel?.text = "Occupied"
            cell.detailTextLabel?.textColor = .red
        } else {
            cell.detailTextLabel?.text = "Available"
            cell.detailTextLabel?.textColor = .green
        }
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTable = tables?[indexPath.row]
        currentTable = selectedTable
        // Перехід до TableDetailsViewController з обраним столиком
        
        switch currentUser?.role {
            case "Адміністратор":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tableDetailsVC = storyboard.instantiateViewController(withIdentifier: "TableDetailsViewController") as! TableDetailsViewController
                tableDetailsVC.currentTable = selectedTable
                navigationController?.pushViewController(tableDetailsVC, animated: true)
                break
            case "Офіціант":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newOrderVC = storyboard.instantiateViewController(withIdentifier: "NewOrderViewController") as! NewOrderViewController
                newOrderVC.currentTable = selectedTable
                newOrderVC.currentUser = currentUser
                navigationController?.pushViewController(newOrderVC, animated: true)
                break
            case "Кухар":
                break
            default:
                break
        }
        
        
    }
    
}
