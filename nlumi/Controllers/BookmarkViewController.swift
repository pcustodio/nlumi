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
    
    @IBOutlet weak var tableView: UITableView!
    
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
            self.tableView.setEmptyMessage("Sem anotações")
        } else {
            self.tableView.restore()
        }
        return bookmarks.count
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let bookmark = bookmarks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath)
        cell.textLabel?.text = bookmark.value(forKeyPath: "ptNoted") as? String
        cell.detailTextLabel?.text = bookmark.value(forKeyPath: "laNoted") as? String
        return cell
    }
    
    //cell was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //will print cell that was tapped on
        print(indexPath.row)
        
        //deselect row
        tableView.deselectRow(at: indexPath, animated: true)
        
        //send to DetailViewController
        let vc = storyboard?.instantiateViewController(withIdentifier: "BookmarkDetailViewController") as? BookmarkDetailViewController

        let bookmark = bookmarks[indexPath.row]
        vc?.ptWord = (bookmark.value(forKeyPath: "ptNoted") as? String)!
        vc?.trWord = (bookmark.value(forKeyPath: "trNoted") as? String)!
        vc?.laWord = (bookmark.value(forKeyPath: "laNoted") as? String)!
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
}
