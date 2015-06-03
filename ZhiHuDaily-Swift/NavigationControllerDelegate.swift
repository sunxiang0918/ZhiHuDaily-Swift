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
    
    //实例化一个 自定义的Pop 转场动画
    let popAnimation : NormalPopAnimation = NormalPopAnimation()
    
    //====================UINavigationControllerDelegate协议的实现======================================================
    //返回动画
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == UINavigationControllerOperation.Pop {
            //如果是返回,就返回特殊的动画. 否则就返回nil,也就是默认动画
            return popAnimation
        }
        
        return nil
    }
    
    // 返回 interactionController 也就是转场动画控制器.  注意! 如果 上面的那个方法 navigationController:animationControllerForOperation:fromViewController:toViewController: 返回的是nil. 那么就不会调用这个方法
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
     //====================UINavigationControllerDelegate协议的实现======================================================
    
}