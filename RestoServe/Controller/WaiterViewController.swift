//
//  WaiterViewController.swift
//  RestoServe
//
//  Created by Roman Vasyltsov on 17.07.2023.
//

import UIKit
import RealmSwift

class WaiterViewController: ExtensionViewController, UINavigationControllerDelegate {
    
    let realm = try! Realm()
    var currentUser: User?
    var ordersDictionary: [String: [CustomerOrder]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Назад"
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(goToLogin))
        self.navigationItem.leftBarButtonItem = backButton
        
    }
    
    @objc func goToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navigationController?.delegate = self
        navigationController?.setViewControllers([loginVC], animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC is LoginViewController && operation == .push {
            return CustomTransition()
        } else {
            return nil // Use the default transition
        }
    }
    @IBAction func closeOrderToPrint(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tablesVC = storyboard.instantiateViewController(withIdentifier: "TablesListViewController") as! TablesListViewController
        tablesVC.currentUser = currentUser
        tablesVC.isOrderToPrint = true
        navigationController?.pushViewController(tablesVC, animated: true)
    }
    
    @IBAction func showMenuButtonPressed(_ sender: UIButton) {
        navigateToListOfDishes()
    }
    
    @IBAction func createOrderButtonPressed(_ sender: UIButton) {
        navigateToTablesList()
    }
    
    func navigateToListOfDishes() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listOfDishesVC = storyboard.instantiateViewController(withIdentifier: "DishesViewController") as! DishesViewController
        listOfDishesVC.currentUser = currentUser
        navigationController?.pushViewController(listOfDishesVC, animated: true)
    }
    
    func navigateToTablesList() {
        // Вам потрібно буде замінити 'AdminPanelViewController' на ім'я вашого класу в storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tablesVC = storyboard.instantiateViewController(withIdentifier: "TablesListViewController") as! TablesListViewController
        tablesVC.currentUser = currentUser
        navigationController?.pushViewController(tablesVC, animated: true)
    }
    
}

class CustomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        containerView.insertSubview(toView, belowSubview: fromView)
         
        // Set initial state
        toView.frame = CGRect(x: -containerView.frame.width, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        
        // Define animation
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.frame = CGRect(x: containerView.frame.width, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            toView.frame = containerView.frame
        }) { (completed) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

