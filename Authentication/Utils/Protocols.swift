//
//  Protocols.swift
//  Authentication
//
//  Created by Madan AR on 26/10/21.
//

import Foundation

protocol HomeViewControllerDelegate: AnyObject{
    func didTapMenuButton()
}

protocol MenuViewControllerDelegate: AnyObject {
    func didSelect(menuItem: MenuViewController.MenuOptions)
}
