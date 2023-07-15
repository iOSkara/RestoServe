//
//  ViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 14.07.2023.
//

import UIKit
import RealmSwift

class LoginViewController: ExtensionViewController {
    
    var currentUser: User?
    
    var realm: Realm!

    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBorderAndRoundedCorners(to: loginTextField)
        addBorderAndRoundedCorners(to: passwordTextField)
        
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
        passwordTextField.isSecureTextEntry = true
        
        loginTextField.addTarget(self, action: #selector(updateLoginButtonState), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(updateLoginButtonState), for: .editingChanged)

        updateLoginButtonState()
        
        do {
            realm = try Realm()
        } catch {
            print("Error initialising Realm: \(error)")
        }
        
    }
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        guard let username = loginTextField.text,
        let password = passwordTextField.text else { return }
                
        let users = realm.objects(User.self).filter("username = %@ AND password = %@", username, password)
                
        if let user = users.first {
            if user.role == Role.admin.rawValue {
                currentUser = user
                navigateToAdminPanel()
            }
            
            print("User found: \(user.username)")
        } else {
            
            print("Invalid username or password.")
        }
        
    }
    
    func navigateToAdminPanel() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let adminVC = storyboard.instantiateViewController(withIdentifier: "AdminPanelViewController") as! AdminPanelViewController
        adminVC.currentUser = currentUser
        navigationController?.pushViewController(adminVC, animated: true)
    }
    
    @objc func updateLoginButtonState() {
        // Button is enabled if both text fields are not empty
        let userLoginText = loginTextField.text ?? ""
        let userPasswordText = passwordTextField.text ?? ""
        loginButton.isEnabled = !userLoginText.isEmpty && !userPasswordText.isEmpty
    }
    

}


