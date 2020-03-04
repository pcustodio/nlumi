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
        s.searchBar.scopeButtonTitles = ["Tudo", "Changana", "Ronga", "Macua"]
        s.searchBar.delegate = self
        return s
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print json
        //print(data)
        
        //remove extraneous empty cells
        tableView.tableFooterView = UIView()
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
        
        navigationItem.searchController = searchController
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "Tudo") {
        filteredWords = data.filter({ (dictionary: Dictionary) -> Bool in
            let doesLanguageMatch = (scope == "Tudo") || (dictionary.language == scope)
            if isSearchBarEmpty() {
                return doesLanguageMatch
            } else {
                return doesLanguageMatch && dictionary.pt.lowercased().contains(searchText.lowercased())
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


//MARK: - Automatic Row Height for Subtitle Cell @ stackoverflow.com/questions/41421670/swift-automatic-row-height-for-subtitle-cell

class MyTableViewCell: UITableViewCell {

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {

        self.layoutIfNeeded()
        var size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)

        if let textLabel = self.textLabel, let detailTextLabel = self.detailTextLabel {
            let detailHeight = detailTextLabel.frame.size.height
            if detailTextLabel.frame.origin.x > textLabel.frame.origin.x { // style = Value1 or Value2
                let textHeight = textLabel.frame.size.height
                if (detailHeight > textHeight) {
                    size.height += detailHeight - textHeight
                }
            } else { // style = Subtitle, so always add subtitle height
                size.height += detailHeight
            }
        }
        return size
    }
}

//MARK: - SearchViewController

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

//MARK: - TableView

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return nr of messages dynamically
        if isFiltering() {return filteredWords.count}
        return data.count
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        
        //filter cells
        let currentWord: Dictionary
        if isFiltering() {
            currentWord = filteredWords[indexPath.row]
        } else {
            currentWord = data[indexPath.row]
        }
        
        //display our cell
        let pt = currentWord.pt
        let translate = currentWord.translation
        let language = currentWord.language

        cell.textLabel?.text = "\(pt)"
        cell.detailTextLabel?.text = "\(translate) (em \(language))"
        
        return cell
        
    }
    
    //cell was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //will print cell that was tapped on
        //print(indexPath.row)
        
        //deselect row
        tableView.deselectRow(at: indexPath, animated: true)
        
        //send to DetailViewController
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        if isFiltering() {
            vc?.ptWord = filteredWords[indexPath.row].pt
            vc?.trWord = filteredWords[indexPath.row].translation
            vc?.laWord = filteredWords[indexPath.row].language
            vc?.laWord = "Português > \(filteredWords[indexPath.row].language)"
            vc?.laHolder = filteredWords[indexPath.row].language
        } else {
            vc?.ptWord = data[indexPath.row].pt
            vc?.trWord = data[indexPath.row].translation
            vc?.laWord = data[indexPath.row].language
            vc?.laWord = "Português > \(data[indexPath.row].language)"
            vc?.laHolder = data[indexPath.row].language
        }
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }

}
