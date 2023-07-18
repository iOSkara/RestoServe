//
//  NewDishViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 17.07.2023.
//

import UIKit
import RealmSwift

class NewDishViewController: ExtensionViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: NewDishViewControllerDelegate?
    
    let realm = try! Realm()
    var currentUser: User?
    var users: [User] = []
    var selectedUser: User?
    var categories: Results<Category>?
    var dishToEdit: Dish?
    
    @IBOutlet weak var dishNameTextField: UITextField!
    @IBOutlet weak var dishDescriptionTextField: UITextField!
    @IBOutlet weak var dishPriceTextField: UITextField!
    @IBOutlet weak var dishCategoryPicker: UIPickerView!
    @IBOutlet weak var dishTimePicker: UIDatePicker!
    @IBOutlet weak var saveNewDishButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dish = dishToEdit {
            dishNameTextField.text = dish.name
            dishDescriptionTextField.text = dish.descriptionText
            dishPriceTextField.text = String(dish.price)
            // Set category and estimated cooking time as well.
        }
        
        updateSaveButtonState()
        
        
        addBorderAndRoundedCorners(to: dishNameTextField)
        addBorderAndRoundedCorners(to: dishDescriptionTextField)
        addBorderAndRoundedCorners(to: dishPriceTextField)
        addBorderAndRoundedCorners(to: dishCategoryPicker)
        addBorderAndRoundedCorners(to: dishTimePicker)
        
        dishNameTextField.delegate = self
        dishCategoryPicker.delegate = self
        dishCategoryPicker.dataSource = self
        
        dishPriceTextField.delegate = self
        
        categories = realm.objects(Category.self)
        
    }
    
    @IBAction func saveNewDishButtonPressed(_ sender: UIButton) {
        
        if dishDescriptionTextField.text == nil || dishDescriptionTextField.text!.isEmpty {
            dishDescriptionTextField.text = " "
        }
        guard let dishName = dishNameTextField.text, !dishName.isEmpty,
              let dishDescription = dishDescriptionTextField.text,!dishDescription.isEmpty,
              let dishPriceText = dishPriceTextField.text, let dishPrice = Double(dishPriceText),
              let selectedCategory = categories?[dishCategoryPicker.selectedRow(inComponent: 0)]
        else {
            // Show an error message
            return
        }
        
        if dishNameExists(name: dishName) {
            // Display an error message
            if dishName != dishToEdit?.name {
                let alert = UIAlertController(title: "Помилка", message: "Страва з таким ім'ям вже існує", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if let dish = dishToEdit {
            do {
                try realm.write {
                    dish.name = dishNameTextField.text ?? ""
                    dish.descriptionText = dishDescriptionTextField.text ?? ""
                    dish.price = Double(dishPriceTextField.text ?? "") ?? 0.0
                    dish.estimatedCookingTime = Int(dishTimePicker.countDownDuration)
                    
                    // Change dish's category
                    dish.category = categories![dishCategoryPicker.selectedRow(inComponent: 0)]
                    NotificationCenter.default.post(name: NSNotification.Name("DishUpdated"), object: nil)
                    realm.add(dish, update: .modified)
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Error saving new dish: \(error)")
            }
        } else {
            let newDish = Dish()
            newDish.name = dishNameTextField.text ?? ""
            newDish.descriptionText = dishDescriptionTextField.text ?? " "
            newDish.price = Double(dishPriceTextField.text ?? "0") ?? 0.0
            newDish.category = selectedCategory
            newDish.estimatedCookingTime = Int(dishTimePicker.countDownDuration)
            
            do {
                try realm.write {
                    realm.add(newDish)
                }
            } catch {
                print("Error saving new dish, \(error)")
            }
        }
        dishNameTextField.text = ""
        dishDescriptionTextField.text = " "
        dishPriceTextField.text = ""
        
        
        dishCategoryPicker.selectRow(0, inComponent: 0, animated: true)
        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 5
        let calendar = Calendar.current
        let defaultTime = calendar.date(from: dateComponents)!
        
        dishTimePicker.date = defaultTime
        
        delegate?.didUpdateDish()
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    func dishNameExists(name: String) -> Bool {
        return realm.objects(Dish.self).filter("name == %@", name).count > 0
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dishPriceTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func updateSaveButtonState() {
        let dishNameText = dishNameTextField.text ?? ""
        let dishPriceText = dishPriceTextField.text ?? ""
        saveNewDishButton.isEnabled = !dishNameText.isEmpty && !dishPriceText.isEmpty
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories?[row].name
    }
    
    
}

protocol NewDishViewControllerDelegate: AnyObject {
    func didUpdateDish()
}
