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

    let newsDetailControl : NewsDetailControl = NewsDetailControl()
    
    var newsListControl : MainNewsListControl!
    
    var newsLocation: (Int,Int)!
    
    var news:NewsDetailVO!
    var newsExtral:NewsExtraVO!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commonButton: UIButton!
    @IBOutlet weak var voteNumberLabel: UILabel!
    @IBOutlet weak var commonNumberLabel: UILabel!
    
    let topImage = UIImageView(frame: CGRectZero)
    let maskImage = UIImageView(frame: CGRectZero)
    let imageSourceLabel = UILabel(frame: CGRectZero)
    let titleLabel = UILabel(frame: CGRectZero)
    
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
        
        //顶部图片
        self.topImage.frame = CGRect(origin: CGPoint(x: 0,y: 0),size: CGSize(width: self.view.bounds.width,height: CGFloat(IN_WINDOW_HEIGHT)))
        self.topImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.topImage.clipsToBounds = true
        self.webView.scrollView.addSubview(self.topImage)
        
        //图片阴影遮罩
        self.maskImage.frame = CGRect(origin: CGPoint(x: 0,y: 125),size: CGSize(width: self.view.bounds.width,height: 75))
        self.maskImage.image = UIImage(named: "Home_Image_Mask_Plus")
        self.webView.scrollView.addSubview(self.maskImage)
        
        //图片版权
        self.imageSourceLabel.frame = CGRect(origin: CGPoint(x: CGFloat(self.view.bounds.width-150-10),y: CGFloat(IN_WINDOW_HEIGHT-12-5)),size: CGSize(width: 150,height: 12))
        self.imageSourceLabel.backgroundColor = UIColor.clearColor()
        self.imageSourceLabel.textColor = UIColor.whiteColor()
        self.imageSourceLabel.textAlignment = NSTextAlignment.Right
        self.imageSourceLabel.font = UIFont.systemFontOfSize(8)
        self.webView.scrollView.addSubview(self.imageSourceLabel)
        
        //标题的label
        //CGRect(origin: CGPoint(x: 10,y: 130),size: CGSize(width: 300,height: 50))
        self.titleLabel.frame = CGRect(origin: CGPoint(x: 10,y: 130),size: CGSize(width: 300,height: 50))
        self.titleLabel.backgroundColor = UIColor.clearColor()
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.textAlignment = NSTextAlignment.Left
        self.titleLabel.font = UIFont.boldSystemFontOfSize(16)
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.webView.scrollView.addSubview(self.titleLabel)

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
        
        let news = getNewsVO(self.newsLocation)
        
        //加载详细页面
        newsDetailControl.loadNewsDetail(news.id, complate: { (newsDetail) -> Void in
            self.loadDetailView(newsDetail!)
        })
        
        //加载新闻扩展信息
        newsDetailControl.loadNewsExtraInfo(news.id, complate: { (newsExtra) -> Void in
            self.newsExtral = newsExtra
            self.voteNumberLabel.text = "\(self.newsExtral.popularity)"
            self.commonNumberLabel.text = "\(self.newsExtral.comments)"
        })
    }
    
    /**
    根据读取的数据,加载页面
    
    :param: news
    */
    private func loadDetailView(news:NewsDetailVO) {
        if  var body = news.body {
            if let css = news.css {
                for c in css {
                    body = "<link href='\(c)' rel='stylesheet' type='text/css' />\(body)"
                }
            }
            
            webView.loadHTMLString(body, baseURL: nil)
        }
        
        if  let _image = news.image {
            self.topImage.hnk_setImageFromURL(NSURL(string: _image)!, placeholder: UIImage(named: "Image_Preview"))
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(-100, 0, 0, 0)
        }else {
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
        
        if let imageSource = news.imageSource {
            self.imageSourceLabel.text = "图片:\(imageSource)"
        }
        
        self.titleLabel.text = news.title
    }
    
    /**
    获取新闻VO
    
    :param: location
    
    :returns:
    */
    private func getNewsVO(location:(Int,Int)) -> NewsVO {
        let section = location.0
        let row = location.1
        
        var news:NewsVO!
        
        if  section == 0 {
            //如果选择的是当天的新闻
            //如果是第0行
            if  row <= 0 {
                //这个选择的是topView的新闻
                news = self.newsListControl.todayNews?.topNews![abs(row)]
            }else{
                news = self.newsListControl.todayNews?.news![row-1]
            }
        }else {
            //选择的是今天前的新闻
            news = self.newsListControl.news[section-1].news![row]
        }
        
        news.alreadyRead = true
        
        return news
    }
    
    /**
    返回上一界面的Action
    
    :param: sender
    */
    @IBAction func backButtonAction(sender: UIButton) {
        //开始调用navigation的POP转场
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
}
