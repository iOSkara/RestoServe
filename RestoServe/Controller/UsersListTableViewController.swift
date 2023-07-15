//
//  UsersListTableViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 14.07.2023.
//

import UIKit
import RealmSwift

class UsersListTableViewController: UITableViewController {
    
    var users: [User] = []
    var selectedUser: User?
    let realm = try! Realm()
    var currentUser: User?

    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchUsers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.userUpdated), name: NSNotification.Name("UserUpdated"), object: nil)
        
        
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        
        guard selectedUser != nil else {
            print("No user selected!")
            return
            
        }
        
            
        // Perform the segue to NewUserViewController
        performSegue(withIdentifier: "editUser", sender: self)
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        // Check if a user is selected
        print(currentUser)
        if selectedUser == currentUser {
            let alertController = UIAlertController(title: "Помилка", message: "Ви не можете видалити себе.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let user = selectedUser else {
            print("No user selected!")
            return
        }

        // Create the alert controller
        let alertController = UIAlertController(title: "Видалити користувача", message: "Вивпевнені, що хочете видалити \(user.username)?", preferredStyle: .alert)
        
        // Create the actions
        let deleteAction = UIAlertAction(title: "Видалити", style: .destructive) { _ in
            do {
                try self.realm.write {
                    self.realm.delete(user)
                    print("User deleted successfully")
                    self.fetchUsers()
                }
            } catch let error {
                print("Error deleting user: \(error)")
            }
        }
        let cancelAction = UIAlertAction(title: "Скасувати", style: .cancel, handler: nil)
        
        // Add the actions
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func navigateToAdminPanel() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let adminVC = storyboard.instantiateViewController(withIdentifier: "AdminPanelViewController") as! AdminPanelViewController
        navigationController?.pushViewController(adminVC, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = "\(user.username) (\(user.role))"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users[indexPath.row]
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editUser" { // replace "ShowNewUserViewController" with your actual segue identifier
            let newUserViewController = segue.destination as! NewUserViewController
            newUserViewController.userToEdit = selectedUser
            newUserViewController.isEditingUser = true
        }
    }
    
    func fetchUsers() {
        let usersResults = realm.objects(User.self)
        self.users = Array(usersResults)
        if usersResults.count == 0 {
            editButton.isHidden = true
            deleteButton.isHidden = true
            
        }
        self.tableView.reloadData()
    }
    
    @objc private func userUpdated(_ notification: Notification) {
        self.fetchUsers()
    }


}
