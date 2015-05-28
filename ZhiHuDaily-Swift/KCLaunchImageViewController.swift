//  自定义的启动图片的ViewController. 实现了显示放大一个图片,然后定时后消失
//  KCLaunchImageViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/27.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class KCLaunchImageViewController: UIViewController {

    //常量
    private let TIME_DURATION = 4.0     //动画的时间
    private let FROM_TIME_DURATION = 1.66       //开始放大的时间
    private let ALPHA:CGFloat = 0.0     //组件的透明度
    private let X_SCALE:CGFloat = 1.15      //放大倍数
    private let Y_SCALE:CGFloat = 1.15      //放大倍数
    
    private var myImage:UIImage!        //显示的图片
    
    private var sourceLabel: UILabel!       //版权的Label
    
    private var viewController:UIViewController!    //动画完成后跳转的view
    
    private let fromImageView:UIImageView = UIImageView(frame: UIScreen.mainScreen().bounds)        //起始图片View
    
    private let toImageView:UIImageView = UIImageView(frame: UIScreen.mainScreen().bounds)  //目标图片View
    
    private let maskImageView:UIImageView = UIImageView(frame: UIScreen.mainScreen().bounds)        //遮罩图片View
    
    private var logoImageView:UIImageView?
    
    //本视图加载
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置关闭状态栏
        if self.respondsToSelector("setNeedsStatusBarAppearanceUpdate") {
            self.prefersStatusBarHidden()
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        
        logoImageView = UIImageView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height-185, UIScreen.mainScreen().bounds.width, 185))   //LOGO图片View
    }
    
    //本视图显示前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //加载图片,并加入view中
        self.fromImageView.image = UIImage(named:"FakeLaunchImage")
        self.view.addSubview(self.fromImageView)
        
        //加载图片,并加入view中
        self.maskImageView.image = UIImage(named: "MaskImage")
        self.view.insertSubview(self.maskImageView, belowSubview:self.fromImageView)
        
        //加载图片,并加入view中
        self.toImageView.image = self.myImage
        self.view.insertSubview(self.toImageView, belowSubview: self.maskImageView)
        
        self.logoImageView!.image = UIImage(named: "Splash_Logo_Plus")
//        self.logoImageView!.alpha = 0.7
        self.view.insertSubview(self.logoImageView!, aboveSubview: toImageView)
//        self.view.addSubview(self.logoImageView)
        
        //加入版权Label到view中
        self.view.addSubview(self.sourceLabel)
    }
    
    //本视图显示后动作
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //开始设置动画,这个动画是渐变透明
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(FROM_TIME_DURATION)
        self.fromImageView.alpha = ALPHA
        UIView.commitAnimations()
        
        //开始设置动画,这个动画是渐变放大
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(TIME_DURATION)
        let transform = CGAffineTransformMakeScale(X_SCALE, Y_SCALE)
        self.toImageView.transform = transform
        UIView.commitAnimations()
        
        //启动一个定时器,到时间后执行 presentNextViewController: 方法
        NSTimer.scheduledTimerWithTimeInterval(TIME_DURATION, target: self, selector: "presentNextViewController:", userInfo: self.viewController, repeats: false)
    }

    //动画显示完毕后,把页面跳转到主视图
    func presentNextViewController(timer:NSTimer) {
        
        //从timer中把目标View获取出来
        let viewController:UIViewController = timer.userInfo as! UIViewController
        
        //跳转页面
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //类方法, 初始化本View.
    class func addTransitionToViewController(viewController : UIViewController,modalTransitionStyle theStyle:UIModalTransitionStyle,withImageDate imageDate:UIImage,withSourceName name:String) -> UIViewController? {
        
        let instance = KCLaunchImageViewController()
        
        instance.initWithTargetView(viewController, modalTransitionStyle: theStyle, withImageDate: imageDate, withSourceName: name)
        
        return instance
    }
    
    //初始化, 没有使用构造函数是因为 重写UIViewController的init 是非常麻烦的.
    func initWithTargetView(targetView:UIViewController,modalTransitionStyle theStyle:UIModalTransitionStyle,withImageDate imageDate:UIImage,withSourceName name:String){
        
        //设置targetView的转场效果
        targetView.modalTransitionStyle = theStyle
        
        self.viewController = targetView
        
        //这个地方可能会使用缓存
        self.myImage = imageDate;
        
        //初始化版权Label
        let rect = viewController.view.frame
        
        //初始化版权Label
        self.sourceLabel = UILabel(frame: CGRectMake((rect.size.width-200)/2, (rect.size.height-30), 200, 30))
        self.sourceLabel.text = name        //设置版权Label的内容
        self.sourceLabel.textColor = UIColor.grayColor()     //颜色
        self.sourceLabel.font = UIFont.systemFontOfSize(10) //字体大小
        self.sourceLabel.textAlignment = NSTextAlignment.Center     //文字居中对齐
        self.sourceLabel.textColor = UIColor.whiteColor()   //字体颜色为白色
        self.sourceLabel.backgroundColor = UIColor.clearColor() //背景色为透明
    }
    
}
