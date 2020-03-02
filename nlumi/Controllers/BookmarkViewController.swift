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
    
    //PROBLEM BEGINS HERE
//    let data = DictionaryLoader().dictionary
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //large title
        navigationController?.navigationBar.prefersLargeTitles = true
        
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

//MARK: - TableView

extension BookmarkViewController: UITableViewDataSource, UITableViewDelegate {

    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
                //PROBLEM CONTINUES HERE
                //WE NEED TO USE KEYPATH 
                let bookmark = bookmarks[indexPath.row]
        vc?.ptWord = (bookmark.value(forKeyPath: "ptNoted") as? String)!
        vc?.trWord = (bookmark.value(forKeyPath: "trNoted") as? String)!
        vc?.laWord = (bookmark.value(forKeyPath: "laNoted") as? String)!
        vc?.grWord = (bookmark.value(forKeyPath: "grNoted") as? String)!
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
}
