//
//  NormalPopAnimation.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/3.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

/**
*  自定义 Pop动画
*/
class NormalPopAnimation: NSObject,UIViewControllerAnimatedTransitioning {
   
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        let screenBounds = UIScreen.main.bounds
        
        let initFrame = transitionContext.initialFrame(for: fromViewController!)
        let finalFrame = initFrame.offsetBy(dx: screenBounds.size.width, dy: 0)
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview((toViewController?.view ?? nil)!)
        containerView.sendSubview(toBack: (toViewController?.view ?? nil)!)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            fromViewController?.view.frame = finalFrame
        }, completion: { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            if  !transitionContext.transitionWasCancelled {
                UIApplication.shared.statusBarStyle = .lightContent
            }
        }) 
        
    }
    
}
