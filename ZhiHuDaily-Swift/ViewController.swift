//
//  ViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/26.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIViewControllerPreviewingDelegate,RefreshControlDelegate,MainTitleViewDelegate,SlideScrollViewDelegate {
    
    fileprivate let BACKGROUND_COLOR = UIColor(red: 0.098, green: 0.565, blue: 0.827, alpha: 1)
    
    var leftViewController : UIViewController?
    
    weak var mainTitleViewController : MainTitleViewController?

    var refreshBottomView : RefreshBottomView?
    
    var refreshControl : RefreshControl!
    
    let newsListControl : MainNewsListControl = MainNewsListControl()
    
    // 长按手势标识
    var longPress = UILongPressGestureRecognizer()
    
    //主页面上关联的表格
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var mainTitleView: UIView!
    
    override func viewDidLoad() {
        
        let nib=UINib(nibName: "NewsListTableViewCell", bundle: nil)
        mainTableView.register(nib, forCellReuseIdentifier: "newsListTableViewCell")
        
        refreshControl = RefreshControl(scrollView: mainTableView, delegate: self)
        refreshControl.topEnabled = true
        refreshControl.bottomEnabled = true
        refreshControl.registeTopView(mainTitleViewController!)
        refreshControl.enableInsetTop = SCROLL_HEIGHT
        refreshControl.enableInsetBottom = 30
        
        let y=max(self.mainTableView.bounds.size.height, self.mainTableView.contentSize.height);
        refreshBottomView = RefreshBottomView(frame: CGRect(x: CGFloat(0),y: y , width: self.mainTableView!.bounds.size.width, height: CGFloat(refreshControl.enableInsetBottom+45)))
        refreshControl.registeBottomView(refreshBottomView!)
        refreshBottomView?.resetLayoutSubViews()
        
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //检测3D Touch
        check3DTouch()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    界面切换传值的方法
    
    - parameter segue:
    - parameter sender:
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainTitleView" {
            mainTitleViewController = segue.destination as? MainTitleViewController
            mainTitleViewController?.mainTitleViewDelegate = self
        }else if segue.identifier == "pushSegue" {
            let newsDetailViewController = segue.destination as? NewsDetailViewController
            
            if  newsDetailViewController?.newsListControl == nil {
                newsDetailViewController?.newsListControl = self.newsListControl
                newsDetailViewController?.mainViewController = self
            }
            
            var index = sender as? IndexPath
            
            if index == nil {
                //这里说明不是NSIndexPath 那么就只能是 String了
                let command = sender as! String
                
                if  "newNews" == command {
                    //如果是打开的最新的日报,那么index就应该是 section=0 row = 1
                    index = IndexPath(row: 1, section: 0)
                }else if "xiacheNews" == command {
                    
                    let todayNews = self.newsListControl.todayNews?.news
                    
                    if todayNews != nil {
                        for (i,news) in todayNews!.enumerated() {
                            if news.title.contains("瞎扯") {
                                //找到瞎扯的文章
                                index = IndexPath(row: i+1, section: 0)
                                break
                            }
                        }
                    }
                    
                    if  index==nil {
                        //如果没有找到 那么就默认打开最新的
                        index = IndexPath(row: 1, section: 0)
                    }
                }
            }
            
            newsDetailViewController?.newsLocation = ((index! as NSIndexPath).section,(index! as NSIndexPath).row)
            
        }
    }
    
    
    //整个View的上下滑动事件的响应
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if  scrollView is UITableView {
            //这部分代码是为了 限制下拉滑动的距离的.当到达scrollHeight后,就不允许再继续往下拉了
            if -Float(scrollView.contentOffset.y)>SCROLL_HEIGHT{
                //表示到顶了,不能再让他滑动了,思路就是让offset一直保持在最大值. 并且 animated 动画要等于false
                scrollView.setContentOffset(CGPoint(x: CGFloat(0), y: CGFloat(-SCROLL_HEIGHT)), animated: false)
                return
            }
        }
    }
    
    func doLeftAction() {
        self.revealController.show(leftViewController!)
    }
    
    //MARK: UITableViewDataSource的实现
    //================UITableViewDataSource的实现================================
    
    //设置tableView的数据行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  section == 0 {
            if  let newsList = newsListControl.todayNews {
                if let news = newsList.news {
                   return news.count+1
                }
            }
            
            return 1
        }else {
            
            if newsListControl.news.count+1 >= section {
                let newsList = newsListControl.news[section-1]
                
                if let news = newsList.news {
                    return news.count
                }
            }
            
            return 0
        }
    }
    
    //返回单元格的高
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if  (indexPath as NSIndexPath).section==0&&(indexPath as NSIndexPath).row == 0 {
            return CGFloat(IN_WINDOW_HEIGHT)
        }else {
            return CGFloat(TABLE_CELL_HEIGHT)
        }
    }
    
    //配置tableView 的单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell
        if  (indexPath as NSIndexPath).section==0 && (indexPath as NSIndexPath).row == 0 {
            //如果是第一行,就需要构建热门条目
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.clipsToBounds = true
            
            let slideRect = CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:tableView.frame.width,height:CGFloat(IMAGE_HEIGHT)))
            let slideView = SlideScrollView(frame: slideRect)

            let todayNews = newsListControl.todayNews
            if let _todayNews = todayNews {
                let topNews = _todayNews.topNews
                
                slideView.initWithFrameRect(slideRect, topNewsArray: topNews)
                slideView.delegate = self
            }
            
            cell.addSubview(slideView)
            
            return cell
        }else{
            let tmp = tableView.dequeueReusableCell(withIdentifier: "newsListTableViewCell")
            
            if  tmp == nil {
                cell = NewsListTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "newsListTableViewCell")
            }else {
                cell = tmp!
            }
            
//            let c = cell as! NewsListTableViewCell
            
            if  (indexPath as NSIndexPath).section==0{
                //这个是今天的新闻
                
                let newsList = newsListControl.todayNews!
                
                cell = self.doReturnCell(newsList, row: (indexPath as NSIndexPath).row-1)
                
            }else {
                let newsList = newsListControl.news[(indexPath as NSIndexPath).section-1]
                
                cell = self.doReturnCell(newsList, row: (indexPath as NSIndexPath).row)
                
            }
            
            return cell
        }
        
    }
    
    /**
    返回视图Cell
    
    - parameter newsList:
    - parameter row:
    
    - returns:
    */
    fileprivate func doReturnCell(_ newsList:NewsListVO,row:Int) -> UITableViewCell {
        
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "newsListTableViewCell") as! NewsListTableViewCell
        
        if let news = newsList.news {
            cell.titleLabel.text = news[row].title
            
            if  news[row].alreadyRead {
                cell.titleLabel.textColor = UIColor.gray
            }else {
                cell.titleLabel.textColor = UIColor.black
            }
            
            let images = news[row].images
            if  let _img = images {
                cell.newsImageView.kf_setImage(with: URL(string: _img[0])!, placeholder: UIImage(named: "Image_Preview"))
            }
            cell.multipicLabel.isHidden = !news[row].multipic
        }
        
        return cell
    }
    
    //================UITableViewDataSource的实现================================
    
    // MARK: UITableViewDelegate的实现
    //================UITableViewDelegate的实现==================================
    
    /**
    返回有多少个Sections
    
    - parameter tableView:
    
    - returns:
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let newsCount = self.newsListControl.news.count
        
        return newsCount+1
    }
    
    /**
    返回每一个Sections的Ttitle的高度
    
    - parameter tableView:
    - parameter section:   section的序号, 从0开始
    
    - returns:
    */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  section == 0 {
            //由于第一个section是不要的,所以直接设置高度为0
            return 0
        }
        
        return CGFloat(SECTION_HEIGHT)
    }
    
    /**
    设置每一个Section的样子
    
    - parameter tableView:
    - parameter section:
    
    - returns: 自定义的View
    */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //自定义一个View
        let myView = UIView()
        
        myView.backgroundColor = BACKGROUND_COLOR
        
        //实例化一个标签
        let titleView = UILabel(frame:CGRect(x: 0, y: 0, width: tableView.frame.width, height: CGFloat(SECTION_HEIGHT)))
        
        titleView.font = UIFont.boldSystemFont(ofSize: 14)        //设置字体
        titleView.textAlignment = NSTextAlignment.center        //设置居中
        titleView.textColor = UIColor.white      //设置字体颜色
        
        //设置文字内容
        
        var news:NewsListVO
        if  section == 0 {
            news = self.newsListControl.todayNews!
        }else {
            news = self.newsListControl.news[section-1]
        }
        let date = news.date
        let formatter:DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyyMMdd"
        let today = formatter.date(from: "\(date!)")
        formatter.dateFormat = "MM月d日 cccc"
        
        titleView.text = formatter.string(from: today!)
        
        myView.addSubview(titleView)
        
        return myView
    }
    
    // 当点击选择Row了以后的 动作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        doAlreadyRead(indexPath)
        
        check3DTouch()
        
        //这个地方开始异步的获取新闻详细.然后再进行跳转
        self.performSegue(withIdentifier: "pushSegue", sender: indexPath)
        
    }
    
    /**
    标记 已点击的 单元格
    
    - parameter newsListVO:
    - parameter indexPath:
    */
    fileprivate func doAlreadyRead(_ indexPath:IndexPath) {
        
        let cell = mainTableView.cellForRow(at: indexPath)
        
        let c = cell as! NewsListTableViewCell
        
        c.titleLabel.textColor = UIColor.gray
        
    }
    
    //================UITableViewDelegate的实现==================================
    

    // MARK: RefreshControlDelegate的实现
    //================RefreshControlDelegate的实现===============================
    func refreshControl(_ refreshControl: RefreshControl, didEngageRefreshDirection direction: RefreshDirection) {
        
        if  direction == RefreshDirection.refreshDirectionTop {
            //是下拉刷新
            self.newsListControl.refreshNews()
            self.mainTableView.reloadData()
        }else{
            self.newsListControl.loadNewDayNews({ () -> Void in
                self.mainTableView.reloadData()
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            refreshControl.finishRefreshingDirection(direction)
        })
        
    }
    
    //================RefreshControlDelegate的实现===============================
    
    // MARK: SlideScrollViewDelegate的实现
    //================SlideScrollViewDelegate的实现===============================
    func SlideScrollViewDidClicked(_ index: Int) {
        
        ///用于处理最热新闻的 点击, 使用遍历,把已加载的新闻找出来对比ID是否相同. 然后获取到她在表格中的坐标,从而进行页面跳转
        if  let topNews=newsListControl.todayNews?.topNews {
            let news = topNews[index-1]
            
            var indexPath:IndexPath?
            
            if  let n = newsListControl.todayNews?.news {
                for i in 0  ..< n.count  {
                    if news.id==n[i].id {
                        indexPath = IndexPath(row: i+1, section: 0)
                        //这个地方开始异步的获取新闻详细.然后再进行跳转
                        self.performSegue(withIdentifier: "pushSegue", sender: indexPath)
                        return
                    }
                }
            }
            
            gotoTopNewsDetail(news, block: { (indexPath) -> Void in
                //这个地方开始异步的获取新闻详细.然后再进行跳转
                self.performSegue(withIdentifier: "pushSegue", sender: indexPath)
                self.mainTableView.reloadData()
            })
        }
    }
    
    /// 对于比在已加载新闻的 最热新闻. 需要加载今天以前的新闻来做对比. 又由于这个加载的过程是异步的.因此,这个地方做了一个递归
    fileprivate func gotoTopNewsDetail(_ news:NewsVO,block:@escaping (IndexPath)->Void){
        
        let nes = newsListControl.news
        
        for j in 0 ..< nes.count {
            let nList = nes[j]
            let n = nList.news!
            
            for i in 0  ..< n.count  {
                if news.id==n[i].id {
                    block(IndexPath(row: i, section: j+1))
                    return
                }
            }
        }
        
        /// 加载上一天的新闻
        newsListControl.loadNewDayNews({ () -> Void in
            /// 加载成功后,重新的找这篇新闻是否是在已加载了的新闻中
            self.gotoTopNewsDetail(news, block: block)
        })
    }
    
    //================SlideScrollViewDelegate的实现===============================

    // MARK: 3D Touch UIViewControllerPreviewingDelegate的实现
    
    /**
    检测页面是否处于3DTouch
    */
    func check3DTouch(){
        
        if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            
            self.registerForPreviewing(with: self, sourceView: self.view)
            //长按停止
            self.longPress.isEnabled = false
            
        } else {
            self.longPress.isEnabled = true
        }
    }
    
    /**
    轻按进入浮动页面
    
    - parameter previewingContext:
    - parameter location:
    
    - returns:
    */
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let cellPosition = mainTableView.convert(location, from: view)
        
        if let touchedIndexPath = mainTableView.indexPathForRow(at: cellPosition) {
            
            mainTableView.deselectRow(at: touchedIndexPath, animated: true)
            
            let aStoryboard = UIStoryboard(name: "Main", bundle:Bundle.main)
            
            if let newsDetailViewController = aStoryboard.instantiateViewController(withIdentifier: "newsDetailViewController") as? NewsDetailViewController  {
                
                if  newsDetailViewController.newsListControl == nil {
                    newsDetailViewController.newsListControl = self.newsListControl
                    newsDetailViewController.mainViewController = self
                }
                
                newsDetailViewController.newsLocation = ((touchedIndexPath as NSIndexPath).section,(touchedIndexPath as NSIndexPath).row)
                
                let cellFrame = mainTableView.cellForRow(at: touchedIndexPath)!.frame
                previewingContext.sourceRect = view.convert(cellFrame, from: mainTableView)
                
                return newsDetailViewController
            }
        }

        
        
        return UIViewController()
    }
    
    /**
    重按进入文章详情页
    
    - parameter previewingContext:
    - parameter viewControllerToCommit:
    */
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        self.show(viewControllerToCommit, sender: self)
    }
    
}

