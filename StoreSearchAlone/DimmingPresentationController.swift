//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Panagiotis Siapkaras on 7/8/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool{
        return false
    }
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = (containerView?.bounds)!
        containerView?.insertSubview(dimmingView, at: 0)
        
        dimmingView.alpha = 0
        if let coordinate = presentedViewController.transitionCoordinator {
            coordinate.animate(alongsideTransition: { (_) in
                self.dimmingView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (_) in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }

}
