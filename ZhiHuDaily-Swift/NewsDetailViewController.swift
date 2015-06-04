//
//  NewsDetailViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/3.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

/**
*  新闻详细页面的 controller
*/
class NewsDetailViewController: UIViewController{

    var news:NewsDetailVO!
    
    @IBOutlet weak var webView: UIWebView!
    let topImage = UIImageView(frame: CGRectZero)
    let maskImage = UIImageView(frame: CGRectZero)
    
    /**
    响应整个View的 慢拖动事件
    
    :param: sender
    */
    @IBAction func panGestureAction(sender: UIPanGestureRecognizer) {
        
        let view = self.view
        
        if  sender.state == UIGestureRecognizerState.Began {
            //当拖动事件开始的时候
            
            //获取拖动事件的开始点坐标
            let location = sender.locationInView(view)
            
            //获取拖动事件的偏移坐标
            let translation = sender.translationInView(view!)
            
            //当偏移坐标的x轴大于0,也就是向右滑动的时候.开始做真正的动作
            if  translation.x > 0 && self.navigationController?.viewControllers.count == 2 {
                //开启新的转场动画控制器
                interactionController = UIPercentDrivenInteractiveTransition.new()
                
                //开始调用navigation的POP转场
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }else if  sender.state == UIGestureRecognizerState.Changed {
            //当拖动事件进行时
            
            //获取到事件的偏移坐标
            let translation = sender.translationInView(view!)
            
            if translation.x<0 {
                //如果是向左移动,就不采取动作
                return
            }
            
            //获取view的CGRect
            let b = (view?.bounds)!
            
            //计算百分比
            let d = fabs(translation.x / CGRectGetWidth(b))
            
            //设置转场动画的百分比
            interactionController?.updateInteractiveTransition(d)
        }else if sender.state == UIGestureRecognizerState.Ended {
            //当拖动事件结束时
            
            let translation = sender.translationInView(view!)
            
            //判断速率向量是否大于0, 并且拉动的距离已经过半了
            if  sender.velocityInView(view).x > 0 && translation.x > CGRectGetMidX(view.bounds)-20  {
                //完成整个动画
                interactionController?.finishInteractiveTransition()
            }else {
                //停止转场
                interactionController?.cancelInteractiveTransition()
            }
            
            //这个地方必须设置成nil. 避免两次之间的转场冲突了
            interactionController = nil;
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topImage.frame = CGRect(origin: CGPoint(x: 0,y: 0),size: CGSize(width: self.view.bounds.width,height: CGFloat(IN_WINDOW_HEIGHT)))
        self.topImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.topImage.clipsToBounds = true
        self.webView.scrollView.addSubview(self.topImage)
        
        self.maskImage.frame = CGRect(origin: CGPoint(x: 0,y: 125),size: CGSize(width: self.view.bounds.width,height: 75))
        self.maskImage.image = UIImage(named: "Home_Image_Mask_Plus")
        self.webView.scrollView.addSubview(self.maskImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    页面重新加载的时候调用的方法
    
    :param: animated
    */
    override func viewWillAppear(animated: Bool) {
        
        let body = news.body
        let css = news.css
        let image = news.image
        
        if  var _body = body {
            if let _css = css {
                for c in _css {
                    _body = "<link href='\(c)' rel='stylesheet' type='text/css' />\(_body)"
                }
            }
            
            webView.loadHTMLString(_body, baseURL: nil)
        }
        
        if  let _image = image {
            self.topImage.hnk_setImageFromURL(NSURL(string: _image)!, placeholder: UIImage(named: "Image_Preview"))
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(-100, 0, 0, 0)
        }else {
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
        
        println("news:\(news)")
    }
    
}
