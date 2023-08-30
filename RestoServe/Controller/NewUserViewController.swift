//
//  NewUserViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 14.07.2023.
//

import UIKit
import RealmSwift

class NewUserViewController: ExtensionViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let realm = try! Realm()
    
    var userToEdit: User? = User()
    
    var isEditingUser: Bool = false
    
    var currentUser: User?
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var userLoginTextField: UITextField!
    
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBOutlet weak var rolePickerView: UIPickerView!
    
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLoginTextField.delegate = self
        userPasswordTextField.delegate = self
        
        if isEditingUser {
            label.text = "Редагування користувача"
        } else {
            label.text = "Створення користувача"
        }
        
        userLoginTextField.addTarget(self, action: #selector(updateCreateButtonState), for: .editingChanged)
        userPasswordTextField.addTarget(self, action: #selector(updateCreateButtonState), for: .editingChanged)
        
        updateCreateButtonState()
        
        // Set the picker view's delegate and data source to this view controller
        rolePickerView.delegate = self
        rolePickerView.dataSource = self
        
        // Add border to UIPickerView
        addBorderAndRoundedCorners(to: rolePickerView)
        
        addBorderAndRoundedCorners(to: userLoginTextField)
        addBorderAndRoundedCorners(to: userPasswordTextField)
        
        changePlaceholderTextColor(of: userLoginTextField, to: .darkGray)
        changePlaceholderTextColor(of: userPasswordTextField, to: .darkGray)
        
        addBorderAndRoundedCorners(to: createButton)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.backButtonTitle = "Назад"
        if let user = userToEdit {
            userLoginTextField.text = user.username
            userPasswordTextField.text = user.password
            if let role = Role(rawValue: user.role),
               let index = Role.allCases.firstIndex(of: role) {
                rolePickerView.selectRow(index, inComponent: 0, animated: true)
            }
            
        }
        
        
    }
    
    
    
    func changePlaceholderTextColor(of textField: UITextField, to color: UIColor) {
        if let placeholder = textField.placeholder {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: color
            ]
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
    }
    
    @objc func updateCreateButtonState() {
        // Button is enabled if both text fields are not empty
        let userLoginText = userLoginTextField.text ?? ""
        let userPasswordText = userPasswordTextField.text ?? ""
        createButton.isEnabled = !userLoginText.isEmpty && !userPasswordText.isEmpty
    }
    
    @IBOutlet weak var rolePickerViewChanged: UIPickerView!
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        
        if isEditingUser {
            guard let user = userToEdit else { return }
            
            do {
                try realm.write {
                    user.username = userLoginTextField.text!
                    user.password = userPasswordTextField.text!
                    user.role = Role.allCases[rolePickerView.selectedRow(inComponent: 0)].rawValue
                    
                }
                NotificationCenter.default.post(name: NSNotification.Name("UserUpdated"), object: nil)
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            } catch let error {
                print("Помилка оновлення користувача: \(error)")
            }
            
        } else {
            let user = User()
            user.username = userLoginTextField.text!
            user.password = userPasswordTextField.text!
            user.role = Role.allCases[rolePickerView.selectedRow(inComponent: 0)].rawValue
            
            let existingUsers = realm.objects(User.self).filter("username = %@", user.username)
            
            if let _ = existingUsers.first {
                let alertController = UIAlertController(title: "Помилка", message: "Такий користувач вже існує.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            do {
                try realm.write {
                    realm.add(user)
                    print("Користувач успішно доданий")
                    userLoginTextField.text! = ""
                    userPasswordTextField.text! = ""
                    rolePickerView.selectRow(0, inComponent: 0, animated: true)
                }
                self.dismiss(animated: true, completion: nil)
            } catch let error {
                print("Помилка створення користувача: \(error)")
            }
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Role.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Role.allCases[row].rawValue
    }
}
