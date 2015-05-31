//
//  ViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/26.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,RefreshControlDelegate,MainTitleViewDelegate {
    
    private let BACKGROUND_COLOR = UIColor(red: 0.125, green: 0.471, blue: 1.000, alpha: 1)
    
    var leftViewController : UIViewController?
    weak var mainTitleViewController : MainTitleViewController?
    
    var refreshControl : RefreshControl!
    
    var newsListControl:MainNewsListControl!
    
    //主页面上关联的表格
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var mainTitleView: UIView!
    
    override func viewDidLoad() {
        
        refreshControl = RefreshControl(scrollView: mainTableView, delegate: self)
        refreshControl.topEnabled = true
        refreshControl.registeTopView(mainTitleViewController!)
        refreshControl.enableInsetTop = 80
        
        newsListControl = MainNewsListControl()
        newsListControl.refreshNews()
        
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "mainTitleView") {
            mainTitleViewController = segue.destinationViewController as? MainTitleViewController
            mainTitleViewController?.mainTitleViewDelegate = self
        }
    }
    
    
    //整个View的上下滑动事件的响应
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if  scrollView is UITableView {
            println("\(scrollView)")
            //这部分代码是为了 限制下拉滑动的距离的.当到达scrollHeight后,就不允许再继续往下拉了
            if -Float(scrollView.contentOffset.y)>SCROLL_HEIGHT{
                //表示到顶了,不能再让他滑动了,思路就是让offset一直保持在最大值. 并且 animated 动画要等于false
                scrollView.setContentOffset(CGPointMake(CGFloat(0), CGFloat(-SCROLL_HEIGHT)), animated: false)
                return
            }
        }
    }
    
    func doLeftAction() {
        self.revealController.showViewController(leftViewController!)
    }
    
    //================UITableViewDataSource的实现================================
    
    //设置tableView的数据行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return 10
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if  indexPath.section==0&&indexPath.row == 0 {
            return CGFloat(IN_WINDOW_HEIGHT)
        }else {
            return CGFloat(TABLE_CELL_HEIGHT)
        }
    }
    
    //配置tableView 的单元格
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell
        if  indexPath.section==0 && indexPath.row == 0 {
            //如果是第一行,就需要构建热门条目
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            cell.backgroundColor = UIColor.clearColor()
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.clipsToBounds = true
            
            var slideRect = CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:tableView.frame.width,height:CGFloat(IMAGE_HEIGHT)))
            var slideView = SlideScrollView(frame: slideRect)

            let todayNews = newsListControl.todayNews
            if let _todayNews = todayNews {
                let topNews = _todayNews.topNews
                
                slideView.initWithFrameRect(slideRect, topNewsArray: topNews)
            }
            
            cell.addSubview(slideView)
            
            return cell
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("channelViewCell") as! UITableViewCell
            return cell
        }
        
//        let rowData = self.channelData[indexPath.row]
        
        //设置cell的标题
//        cell.textLabel?.text = rowData["name"].string
        
    }
    //================UITableViewDataSource的实现================================
    
    //================UITableViewDelegate的实现==================================
    
    /**
    返回有多少个Sections
    
    :param: tableView
    
    :returns:
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    /**
    返回每一个Sections的Ttitle的高度
    
    :param: tableView
    :param: section   section的序号, 从0开始
    
    :returns:
    */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  section == 0 {
            //由于第一个section是不要的,所以直接设置高度为0
            return 0
        }
        
        return CGFloat(SECTION_HEIGHT)
    }
    
    /**
    设置每一个Section的样子
    
    :param: tableView
    :param: section
    
    :returns: 自定义的View
    */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //自定义一个View
        let myView = UIView()
        
        myView.backgroundColor = BACKGROUND_COLOR
        
        //实例化一个标签
        let titleView = UILabel(frame:CGRectMake(0, 0, tableView.frame.width, CGFloat(SECTION_HEIGHT)))
        
        titleView.font = UIFont.boldSystemFontOfSize(14)        //设置字体
        titleView.textAlignment = NSTextAlignment.Center        //设置居中
        titleView.textColor = UIColor.whiteColor()      //设置字体颜色
        
        //设置文字内容
        titleView.text = "05月2\(section)日 星期\(section)"
        
        myView.addSubview(titleView)
        
        return myView
    }
    //================UITableViewDelegate的实现==================================
    

    //================RefreshControlDelegate的实现===============================
    func refreshControl(refreshControl: RefreshControl, didEngageRefreshDirection direction: RefreshDirection) {
        println("开始刷新!!")
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            println("结束刷新!!")
            refreshControl.finishRefreshingDirection(direction)
        })
        
    }
    

}

