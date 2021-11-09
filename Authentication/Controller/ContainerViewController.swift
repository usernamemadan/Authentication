//
//  ContainerViewController.swift
//  Authentication
//
//  Created by Madan AR on 25/10/21.
//

import UIKit

class ContainerViewController: UIViewController {
    // MARK: - properties
    enum MenuState {
        case opened
        case closed
    }
    private var menuState: MenuState = .closed
    let menuVC = MenuViewController()
    var homeVC = HomeViewController()
    var navVC: UINavigationController?

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        homeVC = storyboard?.instantiateViewController(withIdentifier: "home") as! HomeViewController
        addChildVC()
    }
    
    // MARK: - helper functions
    func addChildVC(){
        //menu
        menuVC.delegate = self
        addChild(menuVC)
        view.addSubview(menuVC.view)
        menuVC.didMove(toParent: self)
      
        //home
        homeVC.delegate = self
        let navVC = UINavigationController(rootViewController: homeVC)
        addChild(navVC)
        view.addSubview(navVC.view)
        navVC.didMove(toParent: self)
        self.navVC = navVC
    }
    
}

// MARK: - HomeViewControllerDelegate
extension ContainerViewController: HomeViewControllerDelegate{
    func didTapMenuButton() {
        toggleMenu(completion: nil)
    }
    
    func toggleMenu(completion: (()-> Void)?){
        switch menuState {
        case .closed:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.navVC?.view.frame.origin.x = self.homeVC.view.frame.size.width - 100
            } completion: { [weak self] done in
                if done {
                    self?.menuState = .opened
                }
            }
        case .opened:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.navVC?.view.frame.origin.x = 0
            } completion: { [weak self] done in
                if done {
                    self?.menuState = .closed
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            }
        }
    }
}

// MARK: - MenuViewControllerDelegate
extension ContainerViewController: MenuViewControllerDelegate{
    func didSelect(menuItem: MenuViewController.MenuOptions) {
        toggleMenu { [weak self] in
            guard let self = self else { return }
   
            switch menuItem{
            case .notes:
                showArchivedNotes = false
                self.homeVC.viewDidAppear(true)
                
            case .profile:
                self.homeVC.presentProfileScreen()
        
            case .logout:
                self.homeVC.logout()
            
            case .archive:
                showArchivedNotes = true
                self.homeVC.viewDidAppear(true)
              
            case .about:
                break
            }
        }
    }
    
}
