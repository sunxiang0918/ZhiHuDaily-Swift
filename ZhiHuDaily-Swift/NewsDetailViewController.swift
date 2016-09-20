//
//  NewsDetailViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/3.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit
import Kingfisher

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


/**
*  新闻详细页面的 controller
*/
class NewsDetailViewController: UIViewController,UIWebViewDelegate,RefreshControlDelegate,RefreshViewDelegate,CNPPopupControllerDelegate{

    /// 用于获取新闻详细的Control
    let newsDetailControl : NewsDetailControl = NewsDetailControl()
    var newsListControl : MainNewsListControl!
    
    /// 上下拉动的 Control
    var _refreshControl : RefreshControl!
    
    /// 记录本条新闻位置的变量
    var newsLocation: (Int,Int)!
    
    /// 记录新闻详细的VO
    fileprivate var news:NewsDetailVO!
    
    /// 记录新闻扩展信息的VO
    fileprivate var newsExtral:NewsExtraVO!
    
    /// 主视图的Controller
    var mainViewController : UIViewController!
    
    /// 用于记录POP动画状态的变量
    fileprivate var popstate = PopActionState.none
    
    fileprivate var topRefreshState = TopRefreshState.none
    
    fileprivate var popupController : CNPPopupController?
    
    /// 界面上的 各种组件
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var voteButton: ZanButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commonButton: UIButton!
    @IBOutlet weak var voteNumberLabel: UILabel!
    @IBOutlet weak var commonNumberLabel: UILabel!
    @IBOutlet weak var statusBarView: UIView!

    /// title上的各种组件
    let topImage = UIImageView(frame: CGRect.zero)
    let maskImage = UIImageView(frame: CGRect.zero)
    let topMaskImage = UIImageView(frame: CGRect.zero)
    let imageSourceLabel = UILabel(frame: CGRect.zero)
    let titleLabel = UILabel(frame: CGRect.zero)
    
    /// 推荐者的组件
    var recommandView : RecommendersView!
    
    /// 上方 下拉刷新的组件
    let topRefreshImage = UIImageView(frame: CGRect.zero)
    let topRefreshLabel = UILabel(frame: CGRect.zero)
    
    /// 下方 上拉刷新的组件
    let bottomRefreshImage = UIImageView(frame: CGRect.zero)
    let bottomRefreshLabel = UILabel(frame: CGRect.zero)
    
    /**
    响应整个View的 慢拖动事件
    
    - parameter sender:
    */
    @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
        
        let view = self.view
        
        if  sender.state == UIGestureRecognizerState.began {
            //当拖动事件开始的时候
            
            popstate = PopActionState.none
            
            //获取拖动事件的开始点坐标
            _ = sender.location(in: view)
            
            //获取拖动事件的偏移坐标
            let translation = sender.translation(in: view!)
            
            //当偏移坐标的x轴大于0,也就是向右滑动的时候.开始做真正的动作
            if  translation.x >= 0 && self.navigationController?.viewControllers.count >= 2 {
                //开启新的转场动画控制器
                interactionController = UIPercentDrivenInteractiveTransition()
                
                //开始调用navigation的POP转场
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else if  sender.state == UIGestureRecognizerState.changed {
            //当拖动事件进行时
            
            //获取到事件的偏移坐标
            let translation = sender.translation(in: view!)
            
            if translation.x<0 {
                //如果是向左移动,就不采取动作
                return
            }
            
            //获取view的CGRect
            let b = (view?.bounds)!
            
            //计算百分比
            let d = fabs(translation.x / b.width)
            
            //设置转场动画的百分比
            interactionController?.update(d)
        }else if sender.state == UIGestureRecognizerState.ended {
            //当拖动事件结束时
            
            let translation = sender.translation(in: view!)
            
            //判断速率向量是否大于0, 并且拉动的距离已经过半了
            if  sender.velocity(in: view).x > 0 && translation.x > (view?.bounds.midX)!-20  {
                popstate = PopActionState.finish
                //完成整个动画
                interactionController?.finish()
            }else {
                popstate = PopActionState.cancel
                //停止转场
                interactionController?.cancel()
            }
            
            //这个地方必须设置成nil. 避免两次之间的转场冲突了
            interactionController = nil;
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recommandView = UINib(nibName: "RecommendersView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RecommendersView
        
        // 这个是给recommandView这个非Button 增加点击事件. 方法就是添加一个 Tap的手势.   然后指明点击后 执行哪个响应方法
        self.recommandView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewsDetailViewController.showRecommendersViewAction(_:))))
        
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        self.webView.delegate = self
        
        //我也不知道为什么,设置界面约束后,如果直接实用bounds.width. 在ipad上 右边侧就可能出现2DPI的白边.也就是说宽度没够,所以这里再加了4DPI
        let width = self.view.bounds.width+4
        
        //顶部图片
        self.topImage.frame = CGRect(origin: CGPoint(x: 0,y: 0),size: CGSize(width: width,height: CGFloat(IN_WINDOW_HEIGHT)))
        self.topImage.contentMode = UIViewContentMode.scaleAspectFill
        self.topImage.clipsToBounds = true
        self.webView.scrollView.addSubview(self.topImage)
        
        //图片上阴影遮罩
        self.topMaskImage.frame = CGRect(origin: CGPoint(x: 0,y: 0),size: CGSize(width: width,height: 75))
        self.topMaskImage.image = UIImage(named: "News_Image_Mask")
        self.webView.scrollView.addSubview(self.topMaskImage)
        
        //图片阴影遮罩
        self.maskImage.frame = CGRect(origin: CGPoint(x: 0,y: CGFloat(IN_WINDOW_HEIGHT-75)),size: CGSize(width: width,height: 75))
        self.maskImage.image = UIImage(named: "Home_Image_Mask_Plus")
        self.webView.scrollView.addSubview(self.maskImage)
        
        topRefreshImage.frame = CGRect(origin: CGPoint(x: width/2-60,y: 40),size: CGSize(width: 15,height: 20))
        topRefreshImage.image = UIImage(named: "ZHAnswerViewBack")
        self.webView.scrollView.addSubview(self.topRefreshImage)

        topRefreshLabel.frame = CGRect(origin: CGPoint(x: width/2-40,y: 40),size: CGSize(width: 95,height: 20))
        topRefreshLabel.font = UIFont.systemFont(ofSize: 12)
        topRefreshLabel.textColor = UIColor.white
        self.webView.scrollView.addSubview(self.topRefreshLabel)

        self.recommandView.frame = CGRect(origin: CGPoint(x: 0,y: CGFloat(IN_WINDOW_HEIGHT)),size: CGSize(width: width,height: CGFloat(40)))
        self.webView.scrollView.addSubview(self.recommandView)
        
        //图片版权
        self.imageSourceLabel.frame = CGRect(origin: CGPoint(x: CGFloat(width-150-10),y: CGFloat(IN_WINDOW_HEIGHT-12-5)),size: CGSize(width: 150,height: 12))
        self.imageSourceLabel.backgroundColor = UIColor.clear
        self.imageSourceLabel.textColor = UIColor.white
        self.imageSourceLabel.textAlignment = NSTextAlignment.right
        self.imageSourceLabel.font = UIFont.systemFont(ofSize: 8)
        self.webView.scrollView.addSubview(self.imageSourceLabel)
        
        //标题的label
        self.titleLabel.frame = CGRect(origin: CGPoint(x: 10,y: CGFloat(IN_WINDOW_HEIGHT-50-20)),size: CGSize(width: 300,height: 50))
        self.titleLabel.backgroundColor = UIColor.clear
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.textAlignment = NSTextAlignment.left
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: FONT_SIZE)
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        self.webView.scrollView.addSubview(self.titleLabel)


        bottomRefreshImage.image = UIImage(named: "ZHAnswerViewPrevIcon")
        self.webView.scrollView.addSubview(self.bottomRefreshImage)
        
        bottomRefreshLabel.font = UIFont.systemFont(ofSize: 12)
        bottomRefreshLabel.textColor = UIColor.gray
        self.webView.scrollView.addSubview(self.bottomRefreshLabel)
        
        // 实例化 刷新的Control
        _refreshControl = RefreshControl(scrollView: webView.scrollView, delegate: self)
        _refreshControl.topEnabled = true
        _refreshControl.bottomEnabled = true
        _refreshControl.registeTopView(self)
        _refreshControl.registeBottomView(self)
        _refreshControl.enableInsetTop = SCROLL_HEIGHT
        _refreshControl.enableInsetBottom = SCROLL_HEIGHT
        
        // 处理点赞的按钮
        voteButton.unzanAction = {(number)->Void in
            self.voteNumberLabel.text = "\(number)"
            self.voteNumberLabel.textColor = UIColor.lightGray
        }
        voteButton.zanAction = {(number)->Void in
            self.voteNumberLabel.text = "\(number)"
            self.voteNumberLabel.textColor = UIColor(red: 0.098, green: 0.565, blue: 0.827, alpha: 1)
        }
        
        //实例化 popupController
        initPopupController()
    }
    
    fileprivate func initPopupController(){
        
        /// 实例化SharePopupView 弹出视图
        let view = UINib(nibName: "SharePopupView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SharePopupView
        /// 设置弹出视图的大小
        view?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300)
        
        /// 设置弹出视图中 取消操作的 动作闭包
        view?.cancelHandel = {self.popupController?.dismiss(animated: true)}
        
        /// 实例化弹出控制器
        self.popupController = CNPPopupController(contents: [view!])
        self.popupController!.theme = CNPPopupTheme.default()
        /// 设置点击背景取消弹出视图
        self.popupController!.theme.shouldDismissOnBackgroundTouch = true
        self.popupController!.theme.popupStyle = CNPPopupStyle.actionSheet
        //设置最大宽度,否则可能会在IPAD上出现只显示一半的情况,因为默认就只有300宽
        self.popupController!.theme.maxPopupWidth = self.view.frame.width
        /// 设置视图的边框
        self.popupController!.theme.popupContentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.popupController!.delegate = self;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    页面重新加载的时候调用的方法
    
    - parameter animated:
    */
    override func viewWillAppear(_ animated: Bool) {
        
        if  popstate == PopActionState.cancel {
            //如果是 pop动画 一半而取消的, 虽然还是会触发viewWillAppear这个方法, 但是就不让他做事情了
            return
        }
        
        let news = getNewsVO(self.newsLocation)
        
        //控制下一页不能进行点击  TODO 这个地方和原版的不同, 如果要按照原版的做的话,需要在点击下一页的时候开始动态的加载新的新闻,这个过程又是动态的.比较复杂,所以这里采取了简单的实现
        let currentRow = self.newsLocation.1
        let currentSection = self.newsLocation.0
        
        if  currentSection == 0 {
            if  currentRow == 1{
                topRefreshImage.isHidden = true
                topRefreshLabel.text = "已经是第一篇了"
            }else {
                topRefreshImage.isHidden = false
                topRefreshLabel.text = "载入上一篇"
            }
            
            //当天的新闻
            if  self.newsListControl.todayNews?.news?.count <= currentRow {
                //表示当天的新闻已经完了,不允许再点击了
                if  self.newsListControl.news.count==0{
                    self.nextButton.isEnabled = false
                    
                    bottomRefreshImage.isHidden = true
                    bottomRefreshLabel.text = "已是最后一篇了"
                }else{
                    self.nextButton.isEnabled = true
                    
                    bottomRefreshImage.isHidden = false
                    bottomRefreshLabel.text = "载入下一篇"
                }
            }else {
                self.nextButton.isEnabled = true
                
                bottomRefreshImage.isHidden = false
                bottomRefreshLabel.text = "载入下一篇"
            }
        }else{
            topRefreshImage.isHidden = false
            topRefreshLabel.text = "载入上一篇"
            //今天前的新闻
            if self.newsListControl.news[currentSection-1].news?.count == currentRow+1 {
                //表示当天的新闻已经完了,不允许再点击了
                if  self.newsListControl.news.count > currentSection {
                    self.nextButton.isEnabled = true
                    
                    bottomRefreshImage.isHidden = false
                    bottomRefreshLabel.text = "载入下一篇"
                }else {
                  self.nextButton.isEnabled = false
                    
                    bottomRefreshImage.isHidden = true
                    bottomRefreshLabel.text = "已是最后一篇了"
                }
            }else {
               self.nextButton.isEnabled = true
                
                bottomRefreshImage.isHidden = false
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
            self.voteButton.initNumber = self.newsExtral.popularity
            self.commonNumberLabel.text = "\(self.newsExtral.comments)"
        })
    }
    
    
    /**
    根据读取的数据,加载页面
    
    - parameter news:
    */
    fileprivate func loadDetailView(_ news:NewsDetailVO) {
        
        self.news = news
        
        if  var body = news.body {
            if let css = news.css {
                var temp = ""
                for c in css {
                    temp = "<link href='\(c)' rel='stylesheet' type='text/css' />\(temp)"
                }
                //由于它的CSS中已经写死了 顶部图片的高度就是200,因此这个地方需要增加一个CSS 来根据设备的大小来改变图片的高度
                body = "\(temp) <style> .headline .img-place-holder { height: \(IN_WINDOW_HEIGHT)px;}</style> \(body)"
            }

            webView.loadHTMLString(body, baseURL: nil)
        }
        
        let width = self.view.bounds.width+4
        
        if  let _image = news.image {
            self.topImage.kf_setImage(with: URL(string: _image)!, placeholder: UIImage(named: "Image_Preview"))
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
            self.recommandView.frame = CGRect(origin: CGPoint(x: 0,y: CGFloat(IN_WINDOW_HEIGHT)),size: CGSize(width: width,height: CGFloat(40)))
            self.topImage.isHidden = false
            self.topMaskImage.isHidden = false
            self.maskImage.isHidden = false
            self.imageSourceLabel.isHidden = false
            self.titleLabel.isHidden = false
        }else{
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
            self.recommandView.frame = CGRect(origin: CGPoint(x: 0,y: 0),size: CGSize(width: width,height: CGFloat(40)))
            self.topImage.isHidden = true
            self.topMaskImage.isHidden = true
            self.maskImage.isHidden = true
            self.imageSourceLabel.isHidden = true
            self.titleLabel.isHidden = true
        }
        
        if let imageSource = news.imageSource {
            self.imageSourceLabel.text = "图片:\(imageSource)"
        }
        
        self.titleLabel.text = news.title
     
        
        let subviews = webView.scrollView.subviews
        let browser : UIView = subviews[0] as UIView
        if  let recommanders = news.recommenders {
            if  recommanders.isEmpty {
                recommandView.isHidden = true
                browser.frame = CGRect(x: 0, y: 0, width: browser.frame.width, height: browser.frame.height)
            }else {
                recommandView.isHidden = false
                browser.frame = CGRect(x: 0, y: 40, width: browser.frame.width, height: browser.frame.height)

                for i in 0 ..< 5 {
                    if  i>=recommanders.count {
                        
                        if let image = recommandView.getImageView(i) {
                            image.isHidden = true
                        }
                        continue
                    }else {
                        if let image = recommandView.getImageView(i) {
                            image.isHidden = false
                            image.kf_setImage(with: URL(string: recommanders[i])!, placeholder: UIImage(named: "Setting_Avatar"))
                        }
                    }
                }
            }
        }else {
            recommandView.isHidden = true
            browser.frame = CGRect(x: 0, y: 0, width: browser.frame.width, height: browser.frame.height)
        }
        
    }
    
    /**
    获取新闻VO
    
    - parameter location:
    
    - returns:
    */
    fileprivate func getNewsVO(_ location:(Int,Int)) -> NewsVO {
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
    
    - parameter sender:
    */
    @IBAction func backButtonAction(_ sender: UIButton) {
        //开始调用navigation的POP转场
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        
        //显示弹出窗口
        self.popupController?.present(animated: true)
    }
    /**
    界面切换传值的方法
    
    - parameter segue:
    - parameter sender:
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNextNewsSegue" {
            let newsDetailViewController = segue.destination as? NewsDetailViewController
            
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
            
            let newsDetailViewController = segue.destination as? NewsDetailViewController
            
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
            let commentViewController = segue.destination as? CommonViewController
            
            commentViewController?.newsExtral = self.newsExtral
            commentViewController?.newsId = self.news.id
        }else if segue.identifier == "showRecommendersSegue" {
            let recommendersViewController = segue.destination as? RecommendersListViewController
            recommendersViewController?.newsId = self.news.id
        }
    }
    
    /**
    用于计算与赋值 下一条/上一条新闻的 Index坐标
    
    - parameter newsDetailViewController: newsDetailViewController
    - parameter calculator:               具体的计算方法的闭包
    */
    fileprivate func valuationIndexPath(_ newsDetailViewController:NewsDetailViewController?,calculator:(_ currentSection:Int,_ currentRow:Int)->(Int,Int)){
        if  newsDetailViewController?.newsListControl == nil {
            newsDetailViewController?.newsListControl = self.newsListControl
            newsDetailViewController?.mainViewController = self.mainViewController
        }
        
        //这个地方要计算下一条新闻的index
        let currentRow = self.newsLocation.1
        let currentSection = self.newsLocation.0
        
//        var indexPath:(Int,Int)!
        
        newsDetailViewController?.newsLocation = calculator(currentSection, currentRow)
    }

    //========================RefreshControlDelegate的实现================================================
    
    /**
    *  响应回调事件
    *  @param refreshControl 响应的控件
    *  @param direction 事件类型
    */
    func refreshControl(_ refreshControl:RefreshControl,didEngageRefreshDirection direction:RefreshDirection){
        
        if  direction == RefreshDirection.refreshDirectionTop {
            
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
            self.performSegue(withIdentifier: "showPreNewsSegue", sender: nil)
            
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
            self.performSegue(withIdentifier: "showNextNewsSegue", sender: nil)
            
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
    func canEngageRefresh(_ scrollView:UIScrollView,direction:RefreshDirection) {
        
    }
    
    /**
    松开返回的动画
    */
    func didDisengageRefresh(_ scrollView:UIScrollView,direction:RefreshDirection) {
        
        if  direction == RefreshDirection.refreshDirectionBottom {
            
            let offsetY = Float(scrollView.contentOffset.y)
            let contentHeight = Float(scrollView.contentSize.height)
            let frameHeight = Float(scrollView.frame.height)
            
            //上滑处理状态栏的背景色和样式
            if  offsetY > 120 {
                statusBarView.backgroundColor = UIColor.white
                UIApplication.shared.statusBarStyle = .default
            }else {
                statusBarView.backgroundColor = UIColor.clear
                UIApplication.shared.statusBarStyle = .lightContent
            }
            
            if offsetY > contentHeight-frameHeight+50 {
                if topRefreshState == TopRefreshState.none {
                    topRefreshState = TopRefreshState.doing
                    /**
                    *  这个就是 执行UI动画的方法. 第一个方法就是持续时间  第二个参数是动画效果  第三个参数是完成后做的事情
                    */
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.bottomRefreshImage.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                        }, completion: { (finished) -> Void in
                            if  finished {
                                self.topRefreshState = TopRefreshState.finish
                            }else {
                                self.topRefreshState = TopRefreshState.none
                            }
                    })
                }
            }else {
                if self.topRefreshState == TopRefreshState.finish {
                    topRefreshState = TopRefreshState.doing
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.bottomRefreshImage.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                        }, completion: { (finished) -> Void in
                            if  finished {
                                self.topRefreshState = TopRefreshState.none
                            }else {
                                self.topRefreshState = TopRefreshState.finish
                            }
                    })
                }
            }
            
            
        }else if direction == RefreshDirection.refreshDirectionTop {
            
            //下拉处理 上一条 的 动画. 思路是 当下拉了60后, 开始判断动画状态, 如果是没有执行动画, 就开始下拉动画并设置状态为doing. 动画完成后,设置状态为finish.
            if scrollView.contentOffset.y < -60 {
                if topRefreshState == TopRefreshState.none {
                    topRefreshState = TopRefreshState.doing
                    /**
                    *  这个就是 执行UI动画的方法. 第一个方法就是持续时间  第二个参数是动画效果  第三个参数是完成后做的事情
                    */
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.topRefreshImage.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                        }, completion: { (finished) -> Void in
                            if  finished {
                                self.topRefreshState = TopRefreshState.finish
                            }else {
                                self.topRefreshState = TopRefreshState.none
                            }
                    })
                }
            } else {
                //当下拉小于60后,就需要反向的执行动画.
                if  self.topRefreshState == TopRefreshState.finish {
                    topRefreshState = TopRefreshState.doing
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.topRefreshImage.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                        }, completion: { (finished) -> Void in
                            if  finished {
                                self.topRefreshState = TopRefreshState.none
                            }else {
                                self.topRefreshState = TopRefreshState.finish
                            }
                    })
                }
            }
        }
        
    }
    
    /**
    *  是否修改他的 ContentInset
    */
    func needContentInset(_ direction:RefreshDirection) -> Bool {
        
        return false
    }
    
    /**
    开始刷新的动画
    */
    func startRefreshing(_ direction:RefreshDirection) {
        
    }
    
    /**
    结束刷新的动画
    */
    func finishRefreshing(_ direction:RefreshDirection) {
        self.topRefreshState = TopRefreshState.none
    }

    //========================RefreshViewDelegate的实现================================================
    
    //========================UIWebViewDelegate的实现================================================
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //在这里重新设置 下方 上拉刷新的组件的位置
        bottomRefreshImage.frame = CGRect(x: self.view.bounds.width/2-60, y: webView.scrollView.contentSize.height+30, width: 15, height: 20)
        bottomRefreshLabel.frame = CGRect(origin: CGPoint(x: self.view.bounds.width/2-40,y: webView.scrollView.contentSize.height+30),size: CGSize(width: 95,height: 20))
    }
    

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if  navigationType == UIWebViewNavigationType.linkClicked {
            //监听用户的点击, 如果是点击了 页面上的超链接. 那么就用一个 单独的webView的页面来做显示
            if let url = request.url {
                //这个地方做简化的实现了, 真正的知乎是做了一个简易的浏览器. 这里直接调用系统的safari就行了.
                if url.scheme == "http" || url.scheme == "mailto" || url.scheme == "https" {
                    UIApplication.shared.openURL(url)
                    return false
                }
            }
        }
        return true
    }
    //========================UIWebViewDelegate的实现================================================
    
    
    /**
    响应
    */
    func showRecommendersViewAction(_ sender:AnyObject){
        self.performSegue(withIdentifier: "showRecommendersSegue", sender: self.recommandView)
    }
    
    
    //========================CNPPopupControllerDelegate的实现================================================
    
    //========================CNPPopupControllerDelegate的实现================================================
}


private enum TopRefreshState {
    case none
    case doing
    case finish
}
