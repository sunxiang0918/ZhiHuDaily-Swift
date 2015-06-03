//
//  NewsDetailViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/3.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController{

//    var interactionController : UIPercentDrivenInteractiveTransition?
    
    @IBAction func panGestureAction(sender: UIPanGestureRecognizer) {
        
        let view = self.view
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
