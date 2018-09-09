//
//  WikiSearchViewController.swift
//  WikiSearch
//
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import UIKit
import Kingfisher

class WikiSearchViewController: UITableViewController {
    var wikiSearch = WikiSearch()
    var searchController : UISearchController?
    
    @IBAction func clearButtonAction(_ sender: Any) {
        wikiSearch.data.removeAll()
        self.tableView.reloadData()
        searchController?.searchBar.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Wiki Search"
        
        self.clearsSelectionOnViewWillAppear = true
        self.searchController = UISearchController(searchResultsController: nil)
        
        // Setup the Search Controller
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController?.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        WikiSearchLogic().getWikiSearchData(for: searchText, callBackObject: self)
        tableView.reloadData()
    }
}

extension WikiSearchViewController {
    // MARK: - UITableViewDataSource and  UITableViewDelegate methods
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if wikiSearch.data.count == 0 {
            return 1
        }
        
        return wikiSearch.data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if wikiSearch.data.count == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Swipe down to search"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .lightGray
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WikiCell", for: indexPath)
            (cell as? WikiCellTableViewCell)?.lblPersonName!.text = wikiSearch.data[indexPath.row].title
            (cell as? WikiCellTableViewCell)?.lblPersonDescription.text = wikiSearch.data[indexPath.row].description
            
            if let aURL = URL(string: wikiSearch.data[indexPath.row].imageURL ?? "") {
                let imageResource = ImageResource(downloadURL: aURL)
                (cell as? WikiCellTableViewCell)?.personImage.kf.setImage(with: imageResource, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                })
                
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let aWikiSearchDetailViewController = WikiSearchDetailViewController()
        aWikiSearchDetailViewController.pageID = self.wikiSearch.data[indexPath.row].id ?? 0
        
        self.navigationController?.pushViewController(aWikiSearchDetailViewController, animated: true)
    }
}

extension WikiSearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension WikiSearchViewController: ApiCallBack {
    //MARK: ApiCallBack methods
    public func onSuccess(_ data: AnyObject?, _ apiType: String) {
        HUD.hide()
        
        if let searchData = data as? WikiSearch {
            for aData in searchData.data.reversed() {
                var exixtingIndexes = Array<Int>()
                
                for (index, data) in self.wikiSearch.data.enumerated() {
                    if data.id == aData.id {
                        exixtingIndexes.append(index)
                    }
                }
                
                for index in exixtingIndexes {
                    self.wikiSearch.data.remove(at: index)
                }
                
                self.wikiSearch.data.insert(aData, at: 0)
            }
        }
        
        self.tableView.reloadData()
    }
    
    public func onError(_ errorMessage: ErrorResponse, apiType: String) {
        self.displayAlert(with: "Error!", message: errorMessage.errorMessage ?? "")
        HUD.hide()
    }
    
    private func displayAlert(with title: String, message: String) {
        let anAlertController = UIAlertController(title:title, message:message, preferredStyle: .alert)
        let anOKAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        
        anAlertController.addAction(anOKAction)
        self.present(anAlertController, animated: true, completion: nil)
    }
}
