//  自定义的启动图片的ViewController. 实现了显示放大一个图片,然后定时后消失
//  LaunchImageViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/27.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class LaunchImageViewController: UIViewController {

    //常量
    fileprivate let TIME_DURATION = 4.0     //动画的时间
    fileprivate let FROM_TIME_DURATION = 1.66       //开始放大的时间
    fileprivate let ALPHA:CGFloat = 0.0     //组件的透明度
    fileprivate let X_SCALE:CGFloat = 1.15      //放大倍数
    fileprivate let Y_SCALE:CGFloat = 1.15      //放大倍数
    
    fileprivate var myImage:UIImage!        //显示的图片
    
    fileprivate var sourceLabel: UILabel!       //版权的Label
    
    var viewController:UIViewController!    //动画完成后跳转的view
    
    fileprivate let fromImageView:UIImageView = UIImageView(frame: UIScreen.main.bounds)        //起始图片View
    
    fileprivate let toImageView:UIImageView = UIImageView(frame: UIScreen.main.bounds)  //目标图片View
    
    fileprivate let maskImageView:UIImageView = UIImageView(frame: UIScreen.main.bounds)        //遮罩图片View
    
    fileprivate var logoImageView:UIImageView?
    
    static var jumpTo:String?      //跳转使用的
    
    //本视图加载
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置关闭状态栏
        if self.responds(to: #selector(UIViewController.setNeedsStatusBarAppearanceUpdate)) {
            //self.prefersStatusBarHidden
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        //1536 × 570
        let width = UIScreen.main.bounds.width
        //这里应该使用两种尺寸比例的图,但是由于没有找到,就只有找到一种.因此 ipad和iphone的比例是不一样的,因此需要不同的处理
        let height = width>400 ? width*570/1536 : 185
        logoImageView = UIImageView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-height, width: width, height: height))   //LOGO图片View
    }
    
    //本视图显示前
    override func viewWillAppear(_ animated: Bool) {
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //开始设置动画,这个动画是渐变透明
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(FROM_TIME_DURATION)
        self.fromImageView.alpha = ALPHA
        UIView.commitAnimations()
        
        //开始设置动画,这个动画是渐变放大
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(TIME_DURATION)
        let transform = CGAffineTransform(scaleX: X_SCALE, y: Y_SCALE)
        self.toImageView.transform = transform
        UIView.commitAnimations()
        
        //启动一个定时器,到时间后执行 presentNextViewController: 方法
        Timer.scheduledTimer(timeInterval: TIME_DURATION, target: self, selector: #selector(LaunchImageViewController.presentNextViewController(_:)), userInfo: self.viewController, repeats: false)
    }

    //动画显示完毕后,把页面跳转到主视图
    func presentNextViewController(_ timer:Timer) {
        
        //从timer中把目标View获取出来
        let viewController:UIViewController = timer.userInfo as! UIViewController
        
        //跳转页面
        self.present(viewController, animated: true) { () -> Void in
            //这里设置了一个回调.当页面跳转到主视图后,判断是否存在直接跳转到新闻详细的里面.如果有,就继续跳转.
            if LaunchImageViewController.jumpTo != nil {
                //打开根视图
                let rootNavigationViewController = viewController as? UINavigationController
                let pkRevealController = rootNavigationViewController?.viewControllers.first as? PKRevealController
                let rootViewController = pkRevealController?.frontViewController
                
                //然后打开最新的日报
                rootViewController?.performSegue(withIdentifier: "pushSegue", sender: LaunchImageViewController.jumpTo)
                
                LaunchImageViewController.jumpTo = nil
            }
        }
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //类方法, 初始化本View.
    class func addTransitionToViewController(_ viewController : UIViewController,modalTransitionStyle theStyle:UIModalTransitionStyle,withImageDate imageDate:UIImage,withSourceName name:String) -> UIViewController? {
        
        let instance = LaunchImageViewController()
        
        instance.initWithTargetView(viewController, modalTransitionStyle: theStyle, withImageDate: imageDate, withSourceName: name)
        
        return instance
    }
    
    //初始化, 没有使用构造函数是因为 重写UIViewController的init 是非常麻烦的.
    func initWithTargetView(_ targetView:UIViewController,modalTransitionStyle theStyle:UIModalTransitionStyle,withImageDate imageDate:UIImage,withSourceName name:String){
        
        //设置targetView的转场效果
        targetView.modalTransitionStyle = theStyle
        
        self.viewController = targetView
        
        //这个地方可能会使用缓存
        self.myImage = imageDate;
        
        //初始化版权Label
        let rect = viewController.view.frame
        
        //初始化版权Label
        self.sourceLabel = UILabel(frame: CGRect(x: (rect.size.width-200)/2, y: (rect.size.height-30), width: 200, height: 30))
        self.sourceLabel.text = name        //设置版权Label的内容
        self.sourceLabel.textColor = UIColor.gray     //颜色
        self.sourceLabel.font = UIFont.systemFont(ofSize: 10) //字体大小
        self.sourceLabel.textAlignment = NSTextAlignment.center     //文字居中对齐
        self.sourceLabel.textColor = UIColor.white   //字体颜色为白色
        self.sourceLabel.backgroundColor = UIColor.clear //背景色为透明
    }
    
}
