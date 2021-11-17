//
//  MenuViewController.swift
//  Authentication
//
//  Created by Madan AR on 25/10/21.
//

import UIKit

class MenuViewController: UIViewController {
  
    // MARK: - properties
    weak var delegate: MenuViewControllerDelegate?
    enum MenuOptions: String, CaseIterable{
        case notes = "Notes"
        case profile = "Profile"
        case logout = "Logout"
        case archive = "Archive"
        case about = "About"
        
        var image: String{
            switch self {
            case .notes:
                return "note.text"
            case .profile:
                return "person.crop.circle.fill"
            case .logout:
                return "square.and.arrow.up"
            case .archive:
                return "archivebox.fill"
            case .about:
                return "info.circle.fill"
            }
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // MARK: - lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .gray
        view.backgroundColor = .gray
      
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.size.width, height: view.bounds.size.height)
    }
}

// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = MenuOptions.allCases[indexPath.row]
        delegate?.didSelect(menuItem: item)
        
    }
}

// MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = MenuOptions.allCases[indexPath.row].rawValue
        cell.backgroundColor = .gray
        cell.imageView?.image = UIImage(systemName: MenuOptions.allCases[indexPath.row].image)
        cell.imageView?.tintColor = .white
        return cell
    }
}

