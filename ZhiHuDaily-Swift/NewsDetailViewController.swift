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
class NewsDetailViewController: UIViewController,UIWebViewDelegate,RefreshControlDelegate,RefreshViewDelegate{

    /// 用于获取新闻详细的Control
    let newsDetailControl : NewsDetailControl = NewsDetailControl()
    
    /// 用于获取新闻list的Control
    var newsListControl : MainNewsListControl!
    
    /// 上下拉动的 Control
    var _refreshControl : RefreshControl!
    
    /// 记录本条新闻位置的变量
    var newsLocation: (Int,Int)!
    
    /// 记录新闻详细的VO
    private var news:NewsDetailVO!
    
    /// 记录新闻扩展信息的VO
    private var newsExtral:NewsExtraVO!
    
    /// 主视图的Controller
    var mainViewController : UIViewController!
    
    /// 用于记录POP动画状态的变量
    private var popstate = PopActionState.NONE
    
    private var topRefreshState = TopRefreshState.NONE
    
    /// 界面上的 各种组件
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commonButton: UIButton!
    @IBOutlet weak var voteNumberLabel: UILabel!
    @IBOutlet weak var commonNumberLabel: UILabel!
    @IBOutlet weak var statusBarView: UIView!

    /// title上的各种组件
    let topImage = UIImageView(frame: CGRectZero)
    let maskImage = UIImageView(frame: CGRectZero)
    let topMaskImage = UIImageView(frame: CGRectZero)
    let imageSourceLabel = UILabel(frame: CGRectZero)
    let titleLabel = UILabel(frame: CGRectZero)
    
    /// 推荐者的组件
    var recommandView : RecommendersView!
    
    /// 上方 下拉刷新的组件
    let topRefreshImage = UIImageView(frame: CGRectZero)
    let topRefreshLabel = UILabel(frame: CGRectZero)
    
    /// 下方 上拉刷新的组件
    let bottomRefreshImage = UIImageView(frame: CGRectZero)
    let bottomRefreshLabel = UILabel(frame: CGRectZero)
    
    /**
    响应整个View的 慢拖动事件
    
    :param: sender
    */
    @IBAction func panGestureAction(sender: UIPanGestureRecognizer) {
        
        let view = self.view
        
        if  sender.state == UIGestureRecognizerState.Began {
            //当拖动事件开始的时候
            
            popstate = PopActionState.NONE
            
            //获取拖动事件的开始点坐标
            let location = sender.locationInView(view)
            
            //获取拖动事件的偏移坐标
            let translation = sender.translationInView(view!)
            
            //当偏移坐标的x轴大于0,也就是向右滑动的时候.开始做真正的动作
            if  translation.x > 0 && self.navigationController?.viewControllers.count >= 2 {
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
                popstate = PopActionState.FINISH
                //完成整个动画
                interactionController?.finishInteractiveTransition()
            }else {
                popstate = PopActionState.CANCEL
                //停止转场
                interactionController?.cancelInteractiveTransition()
            }
            
            //这个地方必须设置成nil. 避免两次之间的转场冲突了
            interactionController = nil;
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recommandView = UINib(nibName: "RecommendersView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! RecommendersView
        
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        self.webView.delegate = self
        
        //顶部图片
        self.topImage.frame = CGRect(origin: CGPoint(x: 0,y: 0),size: CGSize(width: self.view.bounds.width,height: CGFloat(IN_WINDOW_HEIGHT)))
        self.topImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.topImage.clipsToBounds = true
        self.webView.scrollView.addSubview(self.topImage)
        
        //图片上阴影遮罩
        self.topMaskImage.frame = CGRect(origin: CGPoint(x: 0,y: 0),size: CGSize(width: self.view.bounds.width,height: 75))
        self.topMaskImage.image = UIImage(named: "News_Image_Mask")
        self.webView.scrollView.addSubview(self.topMaskImage)
        
        //图片阴影遮罩
        self.maskImage.frame = CGRect(origin: CGPoint(x: 0,y: 125),size: CGSize(width: self.view.bounds.width,height: 75))
        self.maskImage.image = UIImage(named: "Home_Image_Mask_Plus")
        self.webView.scrollView.addSubview(self.maskImage)
        
        topRefreshImage.frame = CGRect(origin: CGPoint(x: self.view.bounds.width/2-60,y: 40),size: CGSize(width: 15,height: 20))
        topRefreshImage.image = UIImage(named: "ZHAnswerViewBack")
        self.webView.scrollView.addSubview(self.topRefreshImage)

        topRefreshLabel.frame = CGRect(origin: CGPoint(x: self.view.bounds.width/2-40,y: 40),size: CGSize(width: 95,height: 20))
        topRefreshLabel.font = UIFont.systemFontOfSize(12)
        topRefreshLabel.textColor = UIColor.whiteColor()
        self.webView.scrollView.addSubview(self.topRefreshLabel)
        
        recommandView.frame = CGRect(origin: CGPoint(x: 0,y: 200),size: CGSize(width: self.view.bounds.width,height: CGFloat(40)))
        self.webView.scrollView.addSubview(recommandView)
        
        //图片版权
        self.imageSourceLabel.frame = CGRect(origin: CGPoint(x: CGFloat(self.view.bounds.width-150-10),y: CGFloat(IN_WINDOW_HEIGHT-12-5)),size: CGSize(width: 150,height: 12))
        self.imageSourceLabel.backgroundColor = UIColor.clearColor()
        self.imageSourceLabel.textColor = UIColor.whiteColor()
        self.imageSourceLabel.textAlignment = NSTextAlignment.Right
        self.imageSourceLabel.font = UIFont.systemFontOfSize(8)
        self.webView.scrollView.addSubview(self.imageSourceLabel)
        
        //标题的label
        self.titleLabel.frame = CGRect(origin: CGPoint(x: 10,y: 130),size: CGSize(width: 300,height: 50))
        self.titleLabel.backgroundColor = UIColor.clearColor()
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.textAlignment = NSTextAlignment.Left
        self.titleLabel.font = UIFont.boldSystemFontOfSize(16)
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.webView.scrollView.addSubview(self.titleLabel)


        bottomRefreshImage.image = UIImage(named: "ZHAnswerViewPrevIcon")
        self.webView.scrollView.addSubview(self.bottomRefreshImage)
        
        bottomRefreshLabel.font = UIFont.systemFontOfSize(12)
        bottomRefreshLabel.textColor = UIColor.grayColor()
        self.webView.scrollView.addSubview(self.bottomRefreshLabel)
        
        _refreshControl = RefreshControl(scrollView: webView.scrollView, delegate: self)
        _refreshControl.topEnabled = true
        _refreshControl.bottomEnabled = true
        _refreshControl.registeTopView(self)
        _refreshControl.registeBottomView(self)
        _refreshControl.enableInsetTop = SCROLL_HEIGHT
        _refreshControl.enableInsetBottom = SCROLL_HEIGHT
        
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
        
        if  popstate == PopActionState.CANCEL {
            //如果是 pop动画 一半而取消的, 虽然还是会触发viewWillAppear这个方法, 但是就不让他做事情了
            return
        }
        
        let news = getNewsVO(self.newsLocation)
        
        //控制下一页不能进行点击  TODO 这个地方和原版的不同, 如果要按照原版的做的话,需要在点击下一页的时候开始动态的加载新的新闻,这个过程又是动态的.比较复杂,所以这里采取了简单的实现
        let currentRow = self.newsLocation.1
        let currentSection = self.newsLocation.0
        
        if  currentSection == 0 {
            if  currentRow == 1{
                topRefreshImage.hidden = true
                topRefreshLabel.text = "已经是第一篇了"
            }else {
                topRefreshImage.hidden = false
                topRefreshLabel.text = "载入上一篇"
            }
            
            //当天的新闻
            if  self.newsListControl.todayNews?.news?.count <= currentRow {
                //表示当天的新闻已经完了,不允许再点击了
                if  self.newsListControl.news.count==0{
                    self.nextButton.enabled = false
                    
                    bottomRefreshImage.hidden = true
                    bottomRefreshLabel.text = "已是最后一篇了"
                }else{
                    self.nextButton.enabled = true
                    
                    bottomRefreshImage.hidden = false
                    bottomRefreshLabel.text = "载入下一篇"
                }
            }else {
                self.nextButton.enabled = true
                
                bottomRefreshImage.hidden = false
                bottomRefreshLabel.text = "载入下一篇"
            }
        }else{
            topRefreshImage.hidden = false
            topRefreshLabel.text = "载入上一篇"
            //今天前的新闻
            if self.newsListControl.news[currentSection-1].news?.count == currentRow+1 {
                //表示当天的新闻已经完了,不允许再点击了
                if  self.newsListControl.news.count > currentSection {
                    self.nextButton.enabled = true
                    
                    bottomRefreshImage.hidden = false
                    bottomRefreshLabel.text = "载入下一篇"
                }else {
                  self.nextButton.enabled = false
                    
                    bottomRefreshImage.hidden = true
                    bottomRefreshLabel.text = "已是最后一篇了"
                }
            }else {
               self.nextButton.enabled = true
                
                bottomRefreshImage.hidden = false
                bottomRefreshLabel.text = "载入下一篇"
            }
        }
        
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
        
        self.news = news
        
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
        }
        
        if let imageSource = news.imageSource {
            self.imageSourceLabel.text = "图片:\(imageSource)"
        }
        
        self.titleLabel.text = news.title
     
        
        let subviews = webView.scrollView.subviews
        let browser : UIView = subviews[0] as! UIView
        if  let recommanders = news.recommenders {
            if  recommanders.isEmpty {
                recommandView.hidden = true
                browser.frame = CGRectMake(0, 0, browser.frame.width, browser.frame.height)
            }else {
                recommandView.hidden = false
                browser.frame = CGRectMake(0, 40, browser.frame.width, browser.frame.height)

                for var i = 0; i<5;i++ {
                    if  i>=recommanders.count {
                        
                        if let image = recommandView.getImageView(i) {
                            image.hidden = true
                        }
                        continue
                    }else {
                        if let image = recommandView.getImageView(i) {
                            image.hidden = false
                            image.hnk_setImageFromURL(NSURL(string: recommanders[i])!, placeholder: UIImage(named: "Setting_Avatar"))
                        }
                    }
                }
            }
        }else {
            recommandView.hidden = true
            browser.frame = CGRectMake(0, 0, browser.frame.width, browser.frame.height)
        }
        
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
    
    /**
    界面切换传值的方法
    
    :param: segue
    :param: sender
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNextNewsSegue" {
            let newsDetailViewController = segue.destinationViewController as? NewsDetailViewController
            
            //这个地方要计算下一条新闻的index
            valuationIndexPath(newsDetailViewController, calculator: { (currentSection, currentRow) -> (Int, Int) in
                var indexPath:(Int,Int)!
                
                if  currentSection == 0 {
                    //当天的新闻
                    if  self.newsListControl.todayNews?.news?.count <= currentRow {
                        //表示当天的新闻已经完了,就需要加载下一天的新闻了
                        
                        //TODO 这个地方还需要判断 有没有下一天的新闻
                        indexPath = (self.newsLocation.0+1,0)
                    }else {
                        //表示当天的新闻还有剩,那么就返回下一天的就好了
                        indexPath = (self.newsLocation.0,self.newsLocation.1+1)
                    }
                }else{
                    //今天前的新闻
                    if self.newsListControl.news[currentSection-1].news?.count == currentRow+1 {
                        //表示当天的新闻已经完了,就需要加载下一天的新闻了
                        
                        //TODO 这个地方还需要判断 有没有下一天的新闻
                        indexPath = (self.newsLocation.0+1,0)
                    }else {
                        //表示当天的新闻还有剩,那么就返回下一天的就好了
                        indexPath = (self.newsLocation.0,self.newsLocation.1+1)
                    }
                }
                return indexPath
            })
            
        } else if segue.identifier == "showPreNewsSegue" {
            
            let newsDetailViewController = segue.destinationViewController as? NewsDetailViewController
            
            //计算上一条新闻的Index
            valuationIndexPath(newsDetailViewController, calculator: { (currentSection, currentRow) -> (Int, Int) in
                var indexPath:(Int,Int)!
                
                if  currentSection == 0 {
                    if currentRow <= 1 {
                        //没有了
                    }else {
                        indexPath = (self.newsLocation.0,self.newsLocation.1-1)
                    }
                }else{
                    //今天前的新闻
                    if  currentRow == 0 {
                        //表示当天的新闻已经完了,就需要加载前一天的新闻了
                        let a = self.newsListControl.news[self.newsLocation.0-1].news
                        indexPath = (self.newsLocation.0-1,a?.count ?? 0)
                    }else {
                        //表示当天的新闻还有剩,那么就返回下一天的就好了
                        indexPath = (self.newsLocation.0,self.newsLocation.1-1)
                    }
                }
                return indexPath
            })
        } else if segue.identifier == "showCommonsSegue" {
            let commentViewController = segue.destinationViewController as? CommonViewController
            
            commentViewController?.newsExtral = self.newsExtral
            commentViewController?.newsId = self.news.id
        }
    }
    
    /**
    用于计算与赋值 下一条/上一条新闻的 Index坐标
    
    :param: newsDetailViewController newsDetailViewController
    :param: calculator               具体的计算方法的闭包
    */
    private func valuationIndexPath(newsDetailViewController:NewsDetailViewController?,calculator:(currentSection:Int,currentRow:Int)->(Int,Int)){
        if  newsDetailViewController?.newsListControl == nil {
            newsDetailViewController?.newsListControl = self.newsListControl
            newsDetailViewController?.mainViewController = self.mainViewController
        }
        
        //这个地方要计算下一条新闻的index
        let currentRow = self.newsLocation.1
        let currentSection = self.newsLocation.0
        
        var indexPath:(Int,Int)!
        
        newsDetailViewController?.newsLocation = calculator(currentSection: currentSection, currentRow: currentRow)
    }

    //========================RefreshControlDelegate的实现================================================
    
    /**
    *  响应回调事件
    *  @param refreshControl 响应的控件
    *  @param direction 事件类型
    */
    func refreshControl(refreshControl:RefreshControl,didEngageRefreshDirection direction:RefreshDirection){
        
        if  direction == RefreshDirection.RefreshDirectionTop {
            
            // 如果已经没有上一条新闻了,那么就不能再执行加载上一条的跳转了
            let currentRow = self.newsLocation.1
            let currentSection = self.newsLocation.0
            if  currentSection == 0 {
                if currentRow <= 1 {
                    refreshControl.finishRefreshingDirection(direction)
                    return
                }
            }
            
            //是下拉 加载上一条 
            //这个地方开始异步的获取新闻详细.然后再进行跳转
            self.performSegueWithIdentifier("showPreNewsSegue", sender: nil)
            
            refreshControl.finishRefreshingDirection(direction)
        }else {
            
            let currentRow = self.newsLocation.1
            let currentSection = self.newsLocation.0
            
            if  currentSection == 0 {
                //当天的新闻
                if  self.newsListControl.todayNews?.news?.count <= currentRow {
                    //表示当天的新闻已经完了,不允许再点击了
                    if  self.newsListControl.news.count==0{
                        refreshControl.finishRefreshingDirection(direction)
                        return
                    }
                }
            }else{
                //今天前的新闻
                if self.newsListControl.news[currentSection-1].news?.count == currentRow+1 {
                    //表示当天的新闻已经完了,不允许再点击了
                    if  self.newsListControl.news.count > currentSection {
                        
                    }else {
                        refreshControl.finishRefreshingDirection(direction)
                        return
                    }
                }
            }
            
            //是上拉 加载下一条
            self.performSegueWithIdentifier("showNextNewsSegue", sender: nil)
            
            refreshControl.finishRefreshingDirection(direction)
            
        }
        
    }
    //========================RefreshControlDelegate的实现================================================
    
    //========================RefreshViewDelegate的实现================================================
    
    var refreshControl:RefreshControl? {
        get{ return _refreshControl}
        set{ _refreshControl = newValue}
    }
    
    /**
    重新设置Layout
    */
    func resetLayoutSubViews() {
        
    }
    
    /**
    松开可刷新的动画
    */
    func canEngageRefresh(scrollView:UIScrollView,direction:RefreshDirection) {
        
    }
    
    /**
    松开返回的动画
    */
    func didDisengageRefresh(scrollView:UIScrollView,direction:RefreshDirection) {
        
        if  direction == RefreshDirection.RefreshDirectionBottom {
            
            let offsetY = Float(scrollView.contentOffset.y)
            let contentHeight = Float(scrollView.contentSize.height)
            let frameHeight = Float(scrollView.frame.height)
            
            //上滑处理状态栏的背景色和样式
            if  offsetY > 120 {
                statusBarView.backgroundColor = UIColor.whiteColor()
                UIApplication.sharedApplication().statusBarStyle = .Default
            }else {
                statusBarView.backgroundColor = UIColor.clearColor()
                UIApplication.sharedApplication().statusBarStyle = .LightContent
            }
            
            if offsetY > contentHeight-frameHeight+50 {
                if topRefreshState == TopRefreshState.NONE {
                    topRefreshState = TopRefreshState.DOING
                    /**
                    *  这个就是 执行UI动画的方法. 第一个方法就是持续时间  第二个参数是动画效果  第三个参数是完成后做的事情
                    */
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.bottomRefreshImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                        }, completion: { (finished) -> Void in
                            if  finished {
                                self.topRefreshState = TopRefreshState.FINISH
                            }else {
                                self.topRefreshState = TopRefreshState.NONE
                            }
                    })
                }
            }else {
                if self.topRefreshState == TopRefreshState.FINISH {
                    topRefreshState = TopRefreshState.DOING
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.bottomRefreshImage.transform = CGAffineTransformMakeRotation(CGFloat(0))
                        }, completion: { (finished) -> Void in
                            if  finished {
                                self.topRefreshState = TopRefreshState.NONE
                            }else {
                                self.topRefreshState = TopRefreshState.FINISH
                            }
                    })
                }
            }
            
            
        }else if direction == RefreshDirection.RefreshDirectionTop {
            
            //下拉处理 上一条 的 动画. 思路是 当下拉了60后, 开始判断动画状态, 如果是没有执行动画, 就开始下拉动画并设置状态为doing. 动画完成后,设置状态为finish.
            if scrollView.contentOffset.y < -60 {
                if topRefreshState == TopRefreshState.NONE {
                    topRefreshState = TopRefreshState.DOING
                    /**
                    *  这个就是 执行UI动画的方法. 第一个方法就是持续时间  第二个参数是动画效果  第三个参数是完成后做的事情
                    */
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.topRefreshImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                        }, completion: { (finished) -> Void in
                            if  finished {
                                self.topRefreshState = TopRefreshState.FINISH
                            }else {
                                self.topRefreshState = TopRefreshState.NONE
                            }
                    })
                }
            } else {
                //当下拉小于60后,就需要反向的执行动画.
                if  self.topRefreshState == TopRefreshState.FINISH {
                    topRefreshState = TopRefreshState.DOING
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.topRefreshImage.transform = CGAffineTransformMakeRotation(CGFloat(0))
                        }, completion: { (finished) -> Void in
                            if  finished {
                                self.topRefreshState = TopRefreshState.NONE
                            }else {
                                self.topRefreshState = TopRefreshState.FINISH
                            }
                    })
                }
            }
        }
        
    }
    
    /**
    *  是否修改他的 ContentInset
    */
    func needContentInset(direction:RefreshDirection) -> Bool {
        
        return false
    }
    
    /**
    开始刷新的动画
    */
    func startRefreshing(direction:RefreshDirection) {
        
    }
    
    /**
    结束刷新的动画
    */
    func finishRefreshing(direction:RefreshDirection) {
        self.topRefreshState = TopRefreshState.NONE
    }

    //========================RefreshViewDelegate的实现================================================
    
    //========================UIWebViewDelegate的实现================================================
    func webViewDidFinishLoad(webView: UIWebView) {
        //在这里重新设置 下方 上拉刷新的组件的位置
        bottomRefreshImage.frame = CGRectMake(self.view.bounds.width/2-60, webView.scrollView.contentSize.height+30, 15, 20)
        bottomRefreshLabel.frame = CGRect(origin: CGPoint(x: self.view.bounds.width/2-40,y: webView.scrollView.contentSize.height+30),size: CGSize(width: 95,height: 20))
    }
    //========================UIWebViewDelegate的实现================================================
}


private enum TopRefreshState {
    case NONE
    case DOING
    case FINISH
}
