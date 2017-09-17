//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Panagiotis Siapkaras on 7/7/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
//    var searchResults = [SearchResult]()
//    var hasSearched = false
//    var isLoading = false
//    var dataTask : URLSessionDataTask?

    let search = Search()
    var landscapeViewController: LandscapeViewController?
    
    weak var splitViewDetail : DetailViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        searchBar.becomeFirstResponder()
        
        var cellNib = UINib(nibName: TableViewIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewIdentifiers.loadingCell)
        tableView.rowHeight = 80
        title = NSLocalizedString("Search", comment: "Split view Master button")
        
        if UIDevice.current.userInterfaceIdiom != .pad{
            searchBar.becomeFirstResponder()
        }
    }
    
    struct TableViewIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        performSearch()
    }
    
    //MARK: - ShowNetwork Error()
    
    
    func showNetworkError(){
        
        let alert = UIAlertController(title: NSLocalizedString("Whoooops ....", comment: "Error alert: Whoooops ...."), message: NSLocalizedString("There was an error reading from the iTune Store. Please try again.", comment: "Error Message : title"), preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    func hideMasterPane(){
        UIView.animate(withDuration: 0.25, animations: { 
            self.splitViewController?.preferredDisplayMode = .primaryHidden
        }) { (_) in
            self.splitViewController?.preferredDisplayMode = .automatic
        }
    }
    
    
    //MARK: - Transision to LanscapeViewController
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass{
        case .compact:
            showLandscape(with: coordinator)
        case .regular,.unspecified:
            hideLandscape(with :coordinator)
        }
    }
    
    
        
    
    func showLandscape(with coordinator : UIViewControllerTransitionCoordinator){
        guard landscapeViewController == nil else { return }
        
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let childController = landscapeViewController {
            childController.search = search
            childController.view.frame = view.frame
            view.addSubview(childController.view)
            childController.view.alpha = 0.0
            addChildViewController(childController)
            
            
            coordinator.animate(alongsideTransition: { (_) in
                childController.view.alpha = 1.0
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }

            }, completion: { (_) in
                childController.didMove(toParentViewController: self)
            })
            
        }
    }
    
    func hideLandscape(with coordinator : UIViewControllerTransitionCoordinator){
        if let childController = landscapeViewController {
            childController.willMove(toParentViewController: nil)
            coordinator.animate(alongsideTransition: { (_) in
                childController.view.alpha = 0.0
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { (_) in
                childController.view.removeFromSuperview()
                childController.removeFromParentViewController()
                self.landscapeViewController = nil

            })
                    }
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "ShowDetails" {
            if case .results(let list) = search.state{
                let destinationController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                destinationController.searchResult = searchResult
                destinationController.isPopUp = true
            }
            
        }
    
    }
    

}

extension SearchViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        //hasSearched = false
        if let category = Search.Category(rawValue: segmentControl.selectedSegmentIndex){
            search.performSearch(for: searchBar.text!, category: category, completion: {success in
        
            if !success {
                self.showNetworkError()
            }
            self.tableView.reloadData()
                self.landscapeViewController?.SearchResultRecieved()
        })
        tableView.reloadData()
        searchBar.resignFirstResponder()
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

extension SearchViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        
        if view.window?.rootViewController?.traitCollection.horizontalSizeClass == .compact{
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetails", sender: indexPath)
        }else{
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            if splitViewController?.displayMode != .allVisible{
                hideMasterPane()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        switch search.state{
        case .notSearchedYet ,.noResults ,.loading:
            return nil
        case .results:
            return indexPath
        }
    }
    
    
}

extension SearchViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state{
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch search.state {
        case .notSearchedYet:
            fatalError("shouldNeverGetThere")
        
        case .loading :
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableViewIdentifiers.nothingFoundCell, for: indexPath)
        case .results(let list):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configureCell(searchResult: searchResult)
            return cell
            
        
        }
        
    }
}
