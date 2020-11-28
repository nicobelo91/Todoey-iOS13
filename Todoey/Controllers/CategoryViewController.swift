//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Nico on 24/11/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadCategories()
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added yet"
        
        if let category = categoryArray?[indexPath.row] {
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
                                              
            cell.backgroundColor = UIColor(hexString: category.color)
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {

        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
           print("Error saving context \(error)")
        }
            
        self.tableView.reloadData()
    }

    func loadCategories() {

        categoryArray = realm.objects(Category.self)
    }
    
    // MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            //what will happen once the user clicks the Add Category button in our UIAlert
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
                        
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
}
