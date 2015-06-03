//
//  NavigationControllerDelegate.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/3.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

/**
*  自定义UINavigationControllerDelegate
*/
class NavigationControllerDelegate: NSObject,UINavigationControllerDelegate,NewsDetailHandleGestureDelegate {
    
    @IBOutlet weak var navigationController: UINavigationController!
    
    var interactionController : UIPercentDrivenInteractiveTransition?
    
    func handleGesture(sender:UIPanGestureRecognizer) {
        let view = self.navigationController.view
        
        if  sender.state == UIGestureRecognizerState.Began {
            let location = sender.locationInView(view)
            
            let translation = sender.translationInView(view!)
            println("translation:\(translation) location:\(location)")
            
            
            let b = (view?.bounds)!
            let c = self.navigationController?.viewControllers
            
            if  translation.x > 0 && self.navigationController?.viewControllers.count == 2 {
                //只有向右滑动的时候才起作用
                interactionController = UIPercentDrivenInteractiveTransition.new()
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }else if  sender.state == UIGestureRecognizerState.Changed {
            let translation = sender.translationInView(view!)
            
            if translation.x<0 {
                //如果是向左移动,就不采取动作
                return
            }
            
            let b = (view?.bounds)!
            
            // fabs() 求浮点数的绝对值
            let d = fabs(translation.x / CGRectGetWidth(b))
            
            //            println("translation:\(translation) d:\(d)")
            
            interactionController?.updateInteractiveTransition(d)
            
        }else if sender.state == UIGestureRecognizerState.Ended {
            
            let location = sender.locationInView(view)
            
            let translation = sender.translationInView(view!)
            println("END translation:\(translation) location:\(location)")
            
            interactionController?.cancelInteractiveTransition()
            
            if  sender.velocityInView(view).x < 0 {
                interactionController?.finishInteractiveTransition()
            }else {
                interactionController?.cancelInteractiveTransition()
            }
            
            interactionController = nil;
        }
    }
    
    //返回动画
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == UINavigationControllerOperation.Pop {
            //如果是返回,就返回特殊的动画. 否则就返回nil,也就是默认动画
        }
        
        return nil
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
}