//
//  MainTitleViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/29.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

/**
*  主页面上部Title的View
*/
class MainTitleViewController: UIViewController,RefreshViewDelegate {

    private var _refreshControl:RefreshControl?     //关联的刷新Control
    
    //主页面上部Title上得 按键的事件委托
    var mainTitleViewDelegate:MainTitleViewDelegate?
    
    //各种常量
    let scrollHeight:Float = 80
    let kImageHeight:Float = 400
    let kInWindowHeight:Float = 200
    let titleHeight:Float = 44
    
    //View上的 各种组件
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var circularProgress: KYCircularProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //初始化圆形进度条
        circularProgress.lineWidth = 2.0
        circularProgress.progressAlpha = 0.85
        circularProgress.colors = [0xFFFFFF,0xFFFFFF]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    左边的按钮的事件响应
    
    :param: sender
    */
    @IBAction func leftButtonAction(sender: UIButton) {
        
        if let main = mainTitleViewDelegate {
            main.doLeftAction()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //===================以下是RefreshViewDelegate协议的实现===============================
    
    var refreshControl:RefreshControl? {
        get{
            return _refreshControl
        }
        
        set{
            _refreshControl = newValue
        }
    }
    
    /**
    重新设置Layout
    */
    func resetLayoutSubViews(){
        
    }
    
    /**
    松开可刷新的动画
    */
    func canEngageRefresh(scrollView:UIScrollView,direction:RefreshDirection){
        
    }
    
    /**
    松开返回的动画
    */
    func didDisengageRefresh(scrollView:UIScrollView,direction:RefreshDirection){
        if  scrollView is UITableView {
            
            //只有是在上下滑动TableView的时候进行处理
            changeTitleViewAlpha(Float(scrollView.contentOffset.y))
            
            //用来显示重新加载的进度条
            showRefeshProgress(Float(scrollView.contentOffset.y))
            
        }
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
        backgroundView.backgroundColor = UIColor(red: 0.125, green: 0.471, blue: 1.000, alpha: CGFloat(result))
    }
    
    /**
    显示刷新的进度条
    
    :param: offsetY
    */
    func showRefeshProgress(offsetY:Float){
        
        //计算出透明度
        var result=(0-offsetY)/scrollHeight
        
        if result>1 {
            result = 1.0
        }else if result<0 {
            result = 0.0
        }
        
        circularProgress.progress = Double(result)
    }

    
    /**
    开始刷新的动画
    */
    func startRefreshing(direction:RefreshDirection){
        
        //判断出是从上到下的刷新
        if  direction == RefreshDirection.RefreshDirectionTop {
            circularProgress.alpha = 0
            activityIndicator.startAnimating()
            activityIndicator.alpha = 1
        }
        
    }
    
    /**
    结束刷新的动画
    */
    func finishRefreshing(direction:RefreshDirection){
        
        //判断出是从上到下的刷新
        if direction == RefreshDirection.RefreshDirectionTop {
            self.activityIndicator.stopAnimating()
            //这个地方需要调用progress两次,因为他源码里面progress的didset决定的
            circularProgress.progress = 0
            circularProgress.progress = 0
            self.circularProgress.alpha = 1
            self.activityIndicator.alpha = 0
        }
        
    }
}

/**
*  自定义的协议,主要用来响应Title上左边的按钮的事件委托
*/
protocol MainTitleViewDelegate {
    /**
    *  委托左边按钮的事件
    */
    func doLeftAction()
}
