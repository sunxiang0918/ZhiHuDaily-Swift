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
   
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.4
    }
    
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        let screenBounds = UIScreen.mainScreen().bounds
        
        let initFrame = transitionContext.initialFrameForViewController(fromViewController!)
        let finalFrame = CGRectOffset(initFrame, screenBounds.size.width, 0)
        
        let containerView = transitionContext.containerView()
        
        containerView.addSubview(toViewController?.view ?? nil)
        containerView.sendSubviewToBack(toViewController?.view ?? nil)
        
        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            fromViewController?.view.frame = finalFrame
        }) { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            
            if  !transitionContext.transitionWasCancelled() {
                UIApplication.sharedApplication().statusBarStyle = .LightContent
            }
        }
        
    }
    
}
