//
//  SlideOutAnimationController.swift
//  StoreSearch
//
//  Created by Panagiotis Siapkaras on 7/10/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let fromView = transitionContext.view(forKey: .from){
            let containerView = transitionContext.containerView
            let duration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration, animations: {
                fromView.center.y -= containerView.bounds.height
                fromView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
        }
        
    }
}
