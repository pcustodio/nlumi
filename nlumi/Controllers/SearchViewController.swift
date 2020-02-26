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
        //print(data)
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate (disable since its only an example
        tableView.delegate = self
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        
        let pt = data[indexPath.row].pt
        let gramatica = data[indexPath.row].gramatica
        let changana = data[indexPath.row].changana
        let macua = data[indexPath.row].macua
        let xironga = data[indexPath.row].xironga
        
        cell.textLabel?.text = pt
        cell.detailTextLabel?.text = "(\(gramatica)) \(changana) or \(macua) or \(xironga)"
        
        return cell
    }
    

}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row) //will print cell that was tapped on
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        vc?.ptWord = data[indexPath.row].pt
        vc?.grWord = data[indexPath.row].gramatica
        vc?.chWord = data[indexPath.row].changana
        vc?.maWord = data[indexPath.row].macua
        vc?.xiWord = data[indexPath.row].xironga
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? DetailViewController {
//            //destination.ptLabel.text = "test" THIS IS CRASHING
//
//        }
//    }
}
