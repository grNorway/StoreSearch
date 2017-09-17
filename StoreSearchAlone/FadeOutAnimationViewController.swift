//
//  FadeOutAnimationViewController.swift
//  StoreSearch
//
//  Created by Panagiotis Siapkaras on 7/11/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit

class FadeOutAnimationViewController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let fromView = transitionContext.view(forKey: .from){
            
            let duration = transitionDuration(using: transitionContext)
            UIView.animate(withDuration: duration, animations: { 
                fromView.alpha = 0.0
            }, completion: { (finished) in
                transitionContext.completeTransition(finished)
            })
        }
    }
    
}
