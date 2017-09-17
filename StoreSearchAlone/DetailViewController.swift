//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Panagiotis Siapkaras on 7/8/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult : SearchResult!{
        didSet{
            if isViewLoaded{
                updateUI()
            }
        }
    }
    var downloadTask : URLSessionDownloadTask?
    
    var isPopUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1.0)
        popupView.layer.cornerRadius = 10
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(close(_:)))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        if searchResult != nil{
        updateUI()
        }
        if isPopUp{
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
            
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            
            view.backgroundColor = UIColor.clear
        }else{
            view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
            popupView.isHidden = true
            if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String{
                title = displayName
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func openInStore(_ sender: UIButton) {
        if let url = URL(string: (searchResult?.storeURL)!){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismissAnimationStyle = .slide
        dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    func updateUI(){
        
        if let searchResult = searchResult {
           print("price : \(searchResult)")
            nameLabel.text = searchResult.name
            if searchResult.artistName.isEmpty {
                artistNameLabel.text = NSLocalizedString("uknown", comment: "artistNameLabel.text : unknown")
            }else{
                artistNameLabel.text = searchResult.artistName
            }
            kindLabel.text = searchResult.kindForDisplay()
            genreLabel.text = searchResult.genre
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = searchResult.currency
            let priceText : String
            if searchResult.price == 0 {
                priceText = NSLocalizedString("Free", comment: "priceTect : Free")
            }else if let text = formatter.string(from: searchResult.price as NSNumber){
                priceText = text
            
            }else {
                priceText = ""
            }
                
            
            priceButton.setTitle(priceText, for: .normal)
            
            if let largeURL = URL(string: searchResult.artworkLargeURL){
                downloadTask = artworkImageView.loadImage(url: largeURL)
            }
            
        }
        popupView.isHidden = false
    }
    
    enum AnimationStyle {
        case slide
        case fade
    }

    var dismissAnimationStyle = AnimationStyle.fade
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailViewController : UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch dismissAnimationStyle{
        case .slide :
            return SlideOutAnimationController()
        case .fade :
            return FadeOutAnimationViewController()
        }
    }
    
}



extension DetailViewController : UIGestureRecognizerDelegate{
   
    func tapRecognizer(byReactingto tapGesture: UIGestureRecognizer, shouldReceive touch : UITouch) -> Bool{
        return touch.view === self.view
    }
    
}






















































