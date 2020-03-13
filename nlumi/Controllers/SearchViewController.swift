//
//  SearchViewController.swift
//  nlumi
//
//  Created by Paulo Custódio on 24/02/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    let data = DictionaryLoader().dictionary
    var filteredWords = [Dictionary]()
    
    var sortedFirstLetters: [String] = []
    var sections: [[Dictionary]] = [[]]
    
//    var sortedFilteredFirstLetters: [String] = []
//    var filteredSections: [[Dictionary]] = [[]]
       
    //add search bar and configure it
    lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchResultsUpdater = self
        s.obscuresBackgroundDuringPresentation = false
        s.searchBar.placeholder = "Pesquisar termos"
        s.searchBar.sizeToFit()
        s.searchBar.searchBarStyle = .prominent
        s.searchBar.scopeButtonTitles = ["Tudo", "Changana", "Xironga", "Macua"]
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
        
        //add search field
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //position table above keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //generate the index from your data
        let firstLetters = data.map { $0.titleFirstLetter }
        let uniqueFirstLetters = Array(Set(firstLetters))
        sortedFirstLetters = uniqueFirstLetters.sorted()
        
//        //generate the filtered index from your data
//        let filtereredFirstLetters = filteredWords.map { $0.titleFirstLetter }
//        let filteredUniqueFirstLetters = Array(Set(filtereredFirstLetters))
//        sortedFilteredFirstLetters = filteredUniqueFirstLetters.sorted()
        
        //generate sections
        sections = sortedFirstLetters.map { firstLetter in
            return data
                .filter { $0.titleFirstLetter == firstLetter }
                .sorted { $0.pt.localizedCaseInsensitiveCompare($1.pt) == ComparisonResult.orderedAscending }
        }
        
//        //generate filtered sections
//        filteredSections = sortedFilteredFirstLetters.map { firstLetter in
//            return data
//                .filter { $0.titleFirstLetter == firstLetter }
//                .sorted { $0.pt.localizedCaseInsensitiveCompare($1.pt) == ComparisonResult.orderedAscending }
//        }
        
        //prevent tableview from not scrolling to the very bottom
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0); //values
    }
    
    //position table above keyboard
    @objc func keyboardWillAppear(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            tableViewConstraint.constant = keyboardHeight
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    @objc func keyboardWillDisappear(notification: Notification) {
        tableViewConstraint.constant = 0
    }
    
    //when user cancels search
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        if isSearchBarEmpty() {
            //scroll to top of cell
            let savedIndex = (tableView.indexPathsForVisibleRows?.first)
            tableView.scrollToRow(at: savedIndex!, at: .top, animated: true)
        } else {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
//            let searchbar = searchController.searchBar
//            let label = searchbar.scopeButtonTitles![searchbar.selectedScopeButtonIndex]
            let label = filteredWords.count
            return "Resultados: \(label)"
        } else {
            return sortedFirstLetters[section]
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        label.frame = CGRect(x: 15, y: 0, width: tableView.frame.width , height: 30)
        view.backgroundColor = UIColor(named: "customGray")
        label.highlightedTextColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        view.addSubview(label)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }


    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isFiltering() {
            return nil
        } else {
            return sortedFirstLetters
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 1
        } else {
            return sections.count
        }
    }
    
    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return nr of messages dynamically
        if isFiltering() {
            return filteredWords.count
        } else {
            return sections[section].count
        }
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)

        let currentWord: Dictionary
        if isFiltering() {
            //show cells based on filtered dictionary
            currentWord = filteredWords[indexPath.row]

        } else {
            //show cells based on unfiltered dictionary
            currentWord = sections[indexPath.section][indexPath.row]
        }
        
        //setup our cell
        let pt = currentWord.pt
        let translate = currentWord.translation
        let language = currentWord.language
        
        //show cell content
        cell.textLabel?.text = "\(pt)"
        cell.detailTextLabel?.text = "\(translate)"
        
        //show language img
        if language == "Macua" {
            cell.imageView?.image = UIImage(named: "lang_icon_macua")
        } else if language == "Xironga" {
            cell.imageView?.image = UIImage(named: "lang_icon_xironga")
        } else if language == "changana" {
            cell.imageView?.image = UIImage(named: "lang_icon_changana")
        }
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
            vc?.ptWord = sections[indexPath.section][indexPath.row].pt
            vc?.trWord = sections[indexPath.section][indexPath.row].translation
            vc?.laWord = sections[indexPath.section][indexPath.row].language
            vc?.laWord = "Português > \(sections[indexPath.section][indexPath.row].language)"
            vc?.laHolder = sections[indexPath.section][indexPath.row].language
        }
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

//MARK: - Define the section into which every word belongs
extension Dictionary {
    var titleFirstLetter: String {
        return String(self.pt[self.pt.startIndex]).uppercased().folding(options: .diacriticInsensitive, locale: .current)
    }
}
