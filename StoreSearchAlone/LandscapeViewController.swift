//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Panagiotis Siapkaras on 7/10/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var search : Search!
    private var downloadTasks = [URLSessionDownloadTask]()
    
    private var firstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        pageControl.removeConstraints(view.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(view.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        //scrollView.contentSize = CGSize(width: 1000, height: 1000)
        
        pageControl.numberOfPages = 0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("deinit : \(self)")
        for task in downloadTasks{
            task.cancel()
        }
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.3, animations: { 
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        }, completion: nil)
        
        
    }
    
    
    //creates your own layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.size.height - pageControl.frame.size.height,
                                   width: view.frame.size.width,
                                   height: pageControl.frame.size.height)
        
        if firstTime {
            firstTime = false
            
            switch search.state{
            case .notSearchedYet:
                break
            case .loading:
                showSpinner()
            case .noResults:
                showNothingFoundLabel()
            case .results(let list):
                tileButtons(list)
            }
            
        }
    }
    
    private func showNothingFoundLabel(){
        let label = UILabel(frame: CGRect.zero)
        label.text = NSLocalizedString("Nothing Found", comment: "label.text : Nothing Found")
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        
        label.sizeToFit()
        
        var rect = label.frame
        rect.size.width = ceil(rect.size.width/2) * 2
        rect.size.height = ceil(rect.size.height / 2) * 2
        label.frame = rect
        
        label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
        view.addSubview(label)
    }
    
    private func showSpinner(){
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5 , y: scrollView.bounds.midY + 0.5 )
        
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    func SearchResultRecieved(){
        hideSpinner()
        
        switch search.state{
        case .notSearchedYet, .loading :
            break
        case .noResults:
            showNothingFoundLabel()
        case .results(let list):
            tileButtons(list)
        }
    }
    
    func hideSpinner(){
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    private func tileButtons(_ searchResults: [SearchResult]){
        
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth : CGFloat = 96
        var itemHeight : CGFloat = 88
        var marginX: CGFloat = 0
        var marginY : CGFloat = 20
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth{
        case 568:
            
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
            
        case 667:
            
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
            
        case 736:
            
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
            
        default:
            break
        }
        
        let buttonWidth : CGFloat = 82
        let buttonHeight : CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
        var row = 0
        var column = 0
        var x = marginX
        
        for (index, searchResult) in searchResults.enumerated(){
            
            let button = UIButton(type: .custom)
            downloadImage(for: searchResult, andPlaceOn: button)
            button.backgroundColor = UIColor.white
            button.setBackgroundImage(UIImage(named:"LandscapeButton"), for: .normal)
            button.tag = 2000 + index
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            
            
            button.frame = CGRect(x: x + paddingHorz, y: marginY + CGFloat(row) * itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
            
            scrollView.addSubview(button)
            
            row += 1
            if row == rowsPerPage {
                row = 0
                x = x + itemWidth
                column = column + 1
                
                if column == columnsPerPage {
                column = 0
                x = x + marginX * 2
                }
            }
            
        }
        
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count) / buttonsPerPage
        
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * scrollViewWidth, height: scrollView.bounds.size.height)
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        
        
        print("Number of pages \(numPages)")
        
    }
    
    func buttonPressed(_ sender: UIButton){
        performSegue(withIdentifier: "ShowDetails", sender: sender)
    }
    
    private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton){
        
        if let url = URL(string: searchResult.artworkSmallURL){
            let downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [weak button](url, response, error) in
                if error == nil , let url = url , let data = try? Data(contentsOf: url),let image = UIImage(data: data){
                    
                    DispatchQueue.main.async {
                        if let button = button{
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            })
            downloadTask.resume()
            downloadTasks.append(downloadTask)
        }
       
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetails" {
            if case .results(let list) = search.state {
                let destinationController = segue.destination as! DetailViewController
                let searchResult = list[(sender as! UIButton).tag - 2000]
                destinationController.searchResult = searchResult
                destinationController.isPopUp = true
            }
        }
    }
    

}


extension LandscapeViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let currentPage = Int((scrollView.contentOffset.x + width/2)/width)
        pageControl.currentPage = currentPage
    }
}














