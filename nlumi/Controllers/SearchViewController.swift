//
//  SearchViewController.swift
//  nlumi
//
//  Created by Paulo Custódio on 24/02/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let data = DictionaryLoader().dictionary
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print json
        print(data)
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
    }
    
}

extension SearchViewController: UITableViewDataSource {

    //how many rows do we expect in our table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return nr of messages dynamically
        return data.count
    }
    
    //this is where we are creating our cell
    //indexpath is the position: which cell it should display on each row of our table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].pt
        print(cell)
        return cell
    }
}
