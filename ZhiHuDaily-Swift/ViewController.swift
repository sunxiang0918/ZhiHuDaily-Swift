//
//  ViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/26.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var leftViewController : UIViewController?
    
    let scrollHeight:Float = 80
    let kImageHeight:Float = 400
    let kInWindowHeight:Float = 200
    let titleHeight:Float = 44
    
    //主页面上关联的表格
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var arcProgressView: KYCircularProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arcProgressView.lineWidth = 2.0
        arcProgressView.colors = [0xFFFFFF,0xFFFFFF]
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //整个View的上下滑动事件的响应
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if  scrollView is UITableView {
            
            //这部分代码是为了 限制下拉滑动的距离的.当到达scrollHeight后,就不允许再继续往下拉了
            if -Float(scrollView.contentOffset.y)>scrollHeight{
                //表示到顶了,不能再让他滑动了,思路就是让offset一直保持在最大值. 并且 animated 动画要等于false
                scrollView.setContentOffset(CGPointMake(CGFloat(0), CGFloat(-scrollHeight)), animated: false)
                return
            }
            
            //只有是在上下滑动TableView的时候进行处理
            changeTitleViewAlpha(Float(scrollView.contentOffset.y))
            
            //用来显示重新加载的进度条
            showRefeshProgress(Float(scrollView.contentOffset.y))
            
//            println("\(scrollView)")
        }
    }
    
    func showRefeshProgress(offsetY:Float){
        
        //计算出透明度
        var result=(0-offsetY)/scrollHeight
        
        if result>1 {
            result = 1.0
        }else if result<0 {
            result = 0.0
        }
        
        arcProgressView.progress = Double(result)
    }
    
    //这部分是用来根据TableView的滑动来调整TitleView的透明度的
    func changeTitleViewAlpha(offsetY:Float){
        //计算出最大上划大小. 当上划到此处后, title就全部显示
        let needY=kInWindowHeight-scrollHeight-titleHeight
        
        //计算出透明度
        var result =  offsetY/needY
        
        if result>1 {
            result = 1.0
        }else if result<0 {
            result = 0.0
        }
        
        //这里使用的是修改他得背景颜色的透明度来实现的.不直接使用titleView.alpha = CGFloat(result)是因为, 这样修改会导致这个View上面的所有的subView都会透明
        titleView.backgroundColor = UIColor(red: 0.125, green: 0.471, blue: 1.000, alpha: CGFloat(result))
        
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
            return 106
        }
    }
    
    //显示左边界面
    @IBAction func showLeftButtonAction(sender: UIButton) {
         self.revealController.showViewController(leftViewController!)
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
    
    


}

