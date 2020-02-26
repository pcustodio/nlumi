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
    var filteredWords = [Dictionary]()
        
    //add search bar and configure it
    lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchResultsUpdater = self
        s.obscuresBackgroundDuringPresentation = false
        s.searchBar.placeholder = "Pesquisar termos"
        s.searchBar.sizeToFit()
        s.searchBar.searchBarStyle = .prominent
        s.searchBar.scopeButtonTitles = ["Todos", "Changana", "Xironga", "Macua"]
        s.searchBar.delegate = self
        return s
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print json
        //print(data)
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate (disable since its only an example
        tableView.delegate = self
        
        navigationItem.searchController = searchController
    
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "Todos") {
        filteredWords = data.filter({ (dictionary: Dictionary) -> Bool in
            let doesLanguageMatch = (scope == "Todos") || (dictionary.language == scope)
            if isSearchBarEmpty() {
                return doesLanguageMatch
            } else {
                return doesLanguageMatch && dictionary.language.lowercased().contains(searchText.lowercased())
            }
        })
        tableView.reloadData()
    }
    
    func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty() || searchBarScopeIsFiltering)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchbar = searchController.searchBar
        let scope = searchbar.scopeButtonTitles![searchbar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}


extension SearchViewController: UITableViewDataSource {

    //how many rows do we expect in our table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return nr of messages dynamically
        if isFiltering() {return filteredWords.count}
        return data.count
    }
    
    //this is where we are creating our cell
    //indexpath is the position: which cell it should display on each row of our table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        
        let currentWord: Dictionary
        
        if isFiltering() {
            currentWord = filteredWords[indexPath.row]
        } else {
            currentWord = data[indexPath.row]
        }
        
        let pt = currentWord.pt
        let grammar = currentWord.grammar
        let translate = currentWord.translation
        let language = currentWord.language
        
        cell.textLabel?.text = pt
        cell.detailTextLabel?.text = "(\(grammar)) \(translate) in \(language)"
        
        return cell
        
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //will print cell that was tapped on
        print(indexPath.row)
        
        //deselect row
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        vc?.ptWord = data[indexPath.row].pt
        vc?.trWord = data[indexPath.row].translation
        vc?.laWord = data[indexPath.row].language
        vc?.grWord = data[indexPath.row].grammar
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
