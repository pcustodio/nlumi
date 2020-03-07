//
//  BookmarkViewController.swift
//  nlumi
//
//  Created by Paulo Custódio on 28/02/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class BookmarkViewController: UIViewController {

    var bookmarks: [NSManagedObject] = []
    var barButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //large title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //remove extraneous empty cells
        tableView.tableFooterView = UIView()
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate (disable since its only an example
        tableView.delegate = self
        
        //reload table
        tableView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
      
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
              return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Annotations")
        do {
            bookmarks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
        
    }
    
    // Edit/Done btn
    @IBAction func showEdit(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)

        if tableView.isEditing {
            self.editButton.title = "Concluir"
        } else {
            self.editButton.title = "Editar"
        }
    }
}


//MARK: - Empty message

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 30)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

//MARK: - TableView

extension BookmarkViewController: UITableViewDataSource, UITableViewDelegate {

    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if bookmarks.count == 0 {

            //display empty bookmarks msg
            self.tableView.setEmptyMessage("Sem anotações")
            
            //reset edit button in case there are no more bookmarks
            navigationItem.rightBarButtonItem?.isEnabled = false
            
        } else {
            self.tableView.restore()
            navigationItem.rightBarButtonItem?.isEnabled = true
            print(bookmarks.count)
        }
        return bookmarks.count
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let bookmark = bookmarks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath)
        cell.textLabel?.text = bookmark.value(forKeyPath: "ptNoted") as? String
        cell.detailTextLabel?.text = bookmark.value(forKeyPath: "trNoted") as? String
        return cell
    }
    
    //swipe to delete rows in Coredata
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let recipe = bookmarks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            guard let moc = recipe.managedObjectContext else { return }
            moc.delete(recipe)
            moc.processPendingChanges()
        }
    }
}
