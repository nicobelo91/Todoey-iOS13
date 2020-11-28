//
//  ViewController.swift
//  Todoey
////
//  Created by user183145 on 11/21/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//


import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
             loadItems()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
     
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.color {
            
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
            
            navBar.backgroundColor = UIColor(hexString: colorHex)
            
            if let navBarColor = UIColor(hexString: colorHex) {
                navBar.barTintColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                    searchBar.barTintColor = navBarColor
            }
        }
    }

//MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = todoItems?[indexPath.row]
        
        cell.textLabel?.text = todoItems?[indexPath.row].title ?? "No Items Added yet"
        
        cell.accessoryType = item!.done ? .checkmark : .none
        
        //cell.backgroundColor = UIColor(hexString: todoItems?[indexPath.row].color ?? "#FFFFFF")
        
        //HOW TO TURN A STRING TO A COLOR????
        if let color = HexColor(selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - TablewView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
                
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
    
        tableView.deselectRow(at: indexPath, animated: true)
        
    
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //what will happen once the user clicks the Add Item button in our UIAlert
            
            if let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                        newItem.dateCreated = Date()
                        newItem.color = UIColor.randomFlat().hexValue()
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }

    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }

    // MARK: - Delete Data From Swipe

    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}

    //MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS [cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
