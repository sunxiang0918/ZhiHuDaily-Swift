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
class NavigationControllerDelegate: NSObject,UINavigationControllerDelegate {
    
    @IBOutlet weak var navigationController: UINavigationController!
    
    var interactionController : UIPercentDrivenInteractiveTransition?
    
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