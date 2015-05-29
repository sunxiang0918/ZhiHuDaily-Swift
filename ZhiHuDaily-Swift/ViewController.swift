//
//  ViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/26.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,RefreshControlDelegate,MainTitleViewDelegate {
    
    var leftViewController : UIViewController?
    weak var mainTitleViewController : MainTitleViewController?
    
    let scrollHeight:Float = 80
    let kImageHeight:Float = 400
    let kInWindowHeight:Float = 200
    let titleHeight:Float = 44
    
    var refreshControl : RefreshControl!
    
    //主页面上关联的表格
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var mainTitleView: UIView!
    
    override func viewDidLoad() {
        
        refreshControl = RefreshControl(scrollView: mainTableView, delegate: self)
        refreshControl.topEnabled = true
        refreshControl.registeTopView(mainTitleViewController!)
        refreshControl.enableInsetTop = 80
        
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
            if -Float(scrollView.contentOffset.y)>scrollHeight{
                //表示到顶了,不能再让他滑动了,思路就是让offset一直保持在最大值. 并且 animated 动画要等于false
                scrollView.setContentOffset(CGPointMake(CGFloat(0), CGFloat(-scrollHeight)), animated: false)
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
        if  indexPath.row == 0 {
            return CGFloat(self.kInWindowHeight)
        }else {
            return 100
        }
    }
    
    //配置tableView 的单元格
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell
        if  indexPath.row == 0 {
            //如果是第一行,就需要构建热门条目
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            cell.backgroundColor = UIColor.clearColor()
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.clipsToBounds = true
            
            var slideRect = CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:tableView.frame.width,height:CGFloat(self.kImageHeight)))
            var slideView = SlideScrollView(frame: slideRect)
            slideView.initWithFrameRect(slideRect,imgArr:["http://pic1.zhimg.com/42207cef5d8621be6a1106a2d46d58f0.jpg","http://pic2.zhimg.com/272834eb23f278f907cf6ca200be5d7d.jpg"],titArr:["苏轼果然不是神，苏轼着凉也会感冒","年年都有「隔夜西瓜」的谣言跳出来，吓唬谁呢？"])
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  section == 0 {
            return 0
        }
        return 24
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "你妹的:\(section)"
//    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let myView = UIView()
        myView.backgroundColor = UIColor(red: 0.125, green: 0.471, blue: 1.000, alpha: 1)
        
        let view = UILabel(frame:CGRectMake(0, 0, tableView.frame.width, 24))
        view.font = UIFont.boldSystemFontOfSize(14)
        view.text = "05月2\(section)日 星期\(section)"
        view.textAlignment = NSTextAlignment.Center
        view.textColor = UIColor.whiteColor()
        myView.addSubview(view)
        
        return myView
    }


    //================RefreshControlDelegate的实现===============================
    func refreshControl(refreshControl: RefreshControl, didEngageRefreshDirection direction: RefreshDirection) {
        println("开始刷新!!")
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            println("结束刷新!!")
            refreshControl.finishRefreshingDirection(direction)
        })
        
    }
    

}

